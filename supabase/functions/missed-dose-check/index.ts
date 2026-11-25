// Cron (every 5 min): find doses nobody confirmed after the grace period,
// push the caregivers, and record `missed` logs (source = server).
// docs/02 §4.3, docs/04 §7. Auth: x-cron-secret header (verify_jwt = false).
import {
  adminClient,
  authorized,
  fcmConfigured,
  hhmm,
  json,
  sendPush,
} from "./push.ts";

const BUCKET_MS = 15 * 60 * 1000; // max one push per patient per 15 min

type Missed = {
  schedule_id: string;
  medication_id: string;
  patient_id: string;
  scheduled_at: string;
};

Deno.serve(async (req) => {
  const db = adminClient();
  if (!(await authorized(req, db))) return json({ error: "unauthorized" }, 401);
  // Without FCM credentials do not consume occurrences: nothing was sent.
  if (!fcmConfigured()) return json({ ok: false, reason: "fcm_not_configured" });

  const { data, error } = await db.rpc("find_missed_doses", {
    p_lookback: "6 hours",
  });
  if (error) return json({ error: "query_failed" }, 500);

  const byPatient = new Map<string, Missed[]>();
  for (const m of (data ?? []) as Missed[]) {
    byPatient.set(m.patient_id, [...(byPatient.get(m.patient_id) ?? []), m]);
  }

  let pushed = 0, logged = 0;
  for (const [patientId, items] of byPatient) {
    const { data: recipients } = await db.rpc("push_recipients", {
      p_patient_id: patientId,
      p_only_notify_missed: true,
    });
    const tokens = ((recipients ?? []) as { token: string }[]).map((r) => r.token);

    if (tokens.length > 0) {
      const bucket = Math.floor(Date.now() / BUCKET_MS);
      const { data: first } = await db.rpc("record_push", {
        p_kind: "missed",
        p_ref_key: `${patientId}:${bucket}`,
        p_patient_id: patientId,
      });
      // Already pushed for this patient in this window: leave the new misses
      // for the next run instead of dropping them.
      if (!first) continue;

      const { data: patient } = await db
        .from("patients").select("name").eq("id", patientId).single();
      const { data: meds } = await db
        .from("medications").select("id,name")
        .in("id", [...new Set(items.map((i) => i.medication_id))]);
      const { data: schedules } = await db
        .from("schedules").select("id,timezone")
        .in("id", [...new Set(items.map((i) => i.schedule_id))]);
      const names = [...new Set((meds ?? []).map((m) => m.name as string))];
      const earliest = [...items].sort((a, b) =>
        a.scheduled_at.localeCompare(b.scheduled_at)
      )[0];
      const tz = (schedules ?? []).find((s) => s.id === earliest.schedule_id)
        ?.timezone ?? "Asia/Jakarta";
      const when = hhmm(earliest.scheduled_at, tz);
      const who = patient?.name ?? "";
      const body = names.length === 1
        ? `${who} belum minum ${names[0]} (jadwal ${when})`
        : `${who} belum minum ${names.length} obat (jadwal ${when}): ${names.join(", ")}`;

      const r = await sendPush(db, tokens, {
        title: "Dosis belum dikonfirmasi",
        body,
        data: {
          type: "missed_dose",
          patientId,
          scheduleId: earliest.schedule_id,
          scheduledAt: earliest.scheduled_at,
        },
      });
      pushed += r.sent;
    }

    // Record the misses so they are not reported again. A later "taken" from
    // the device is stored next to it; the effective status is "taken".
    const { error: logErr } = await db.from("dose_logs").upsert(
      items.map((i) => ({
        schedule_id: i.schedule_id,
        patient_id: i.patient_id,
        scheduled_at: i.scheduled_at,
        status: "missed",
        source: "server",
      })),
      { onConflict: "schedule_id,scheduled_at,status", ignoreDuplicates: true },
    );
    if (!logErr) logged += items.length;
  }

  console.log(JSON.stringify({ patients: byPatient.size, pushed, logged }));
  return json({ ok: true, patients: byPatient.size, pushed, logged });
});
