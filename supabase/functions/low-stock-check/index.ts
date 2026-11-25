// Cron (daily): push caregivers when a medication is about to run out
// (stock / daily use <= refill threshold). docs/04 §1, US-10.
// Auth: x-cron-secret header (verify_jwt = false).
import {
  adminClient,
  authorized,
  fcmConfigured,
  json,
  sendPush,
} from "./push.ts";

type Low = {
  medication_id: string;
  patient_id: string;
  medication_name: string;
  patient_name: string;
  days_left: number;
};

Deno.serve(async (req) => {
  const db = adminClient();
  if (!(await authorized(req, db))) return json({ error: "unauthorized" }, 401);
  if (!fcmConfigured()) return json({ ok: false, reason: "fcm_not_configured" });

  const { data, error } = await db.rpc("find_low_stock");
  if (error) return json({ error: "query_failed" }, 500);

  const day = new Date().toISOString().slice(0, 10);
  let pushed = 0;
  for (const m of (data ?? []) as Low[]) {
    // One push per medication per day.
    const { data: first } = await db.rpc("record_push", {
      p_kind: "low_stock",
      p_ref_key: `${m.medication_id}:${day}`,
      p_patient_id: m.patient_id,
    });
    if (!first) continue;

    const { data: recipients } = await db.rpc("push_recipients", {
      p_patient_id: m.patient_id,
      p_only_notify_missed: false,
    });
    const tokens = ((recipients ?? []) as { token: string }[]).map((r) => r.token);
    if (tokens.length === 0) continue;

    const r = await sendPush(db, tokens, {
      title: `Stok obat ${m.patient_name} menipis`,
      body: `${m.medication_name} tinggal ${Math.max(0, Math.floor(Number(m.days_left)))} hari lagi. Jangan lupa tebus resep.`,
      data: { type: "low_stock", patientId: m.patient_id },
    });
    pushed += r.sent;
  }

  console.log(JSON.stringify({ candidates: (data ?? []).length, pushed }));
  return json({ ok: true, candidates: (data ?? []).length, pushed });
});
