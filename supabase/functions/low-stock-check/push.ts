// Shared by missed-dose-check and low-stock-check (copied next to each
// function so each deploys on its own). Sends FCM HTTP v1 pushes.
//
// Privacy (docs/08): never log names, drug names or tokens; only counts.
import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";

export type Db = SupabaseClient;

export function adminClient(): Db {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
}

/** Constant-time string compare. */
function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** Cron calls carry `x-cron-secret`, the value stored in Vault. */
export async function authorized(req: Request, db: Db): Promise<boolean> {
  const sent = req.headers.get("x-cron-secret");
  if (!sent) return false;
  const { data, error } = await db.rpc("get_cron_secret");
  return !error && typeof data === "string" && safeEqual(sent, data);
}

type ServiceAccount = {
  client_email: string;
  private_key: string;
  project_id: string;
};

function serviceAccount(): ServiceAccount | null {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!raw) return null;
  try {
    const sa = JSON.parse(raw);
    return sa.client_email && sa.private_key && sa.project_id ? sa : null;
  } catch {
    return null;
  }
}

export function fcmConfigured(): boolean {
  return serviceAccount() !== null;
}

function b64url(input: ArrayBuffer | string): string {
  const bytes = typeof input === "string"
    ? new TextEncoder().encode(input)
    : new Uint8Array(input);
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

let cached: { token: string; exp: number } | null = null;

async function accessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cached && cached.exp - 60 > now) return cached.token;

  const pem = sa.private_key
    .replace(/-----(BEGIN|END) PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const header = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(`${header}.${claims}`),
  );
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${header}.${claims}.${b64url(sig)}`,
    }),
  });
  if (!res.ok) throw new Error(`oauth ${res.status}`);
  const json = await res.json();
  cached = { token: json.access_token, exp: now + (json.expires_in ?? 3600) };
  return cached.token;
}

export type PushMessage = {
  title: string;
  body: string;
  data: Record<string, string>;
};

/**
 * Sends to every recipient token. Tokens FCM reports as unregistered are
 * deleted from `device_tokens` (docs/04 §7). A value with ":" is a classic
 * registration token; otherwise it is a Firebase Installation ID.
 */
export async function sendPush(
  db: Db,
  tokens: string[],
  msg: PushMessage,
): Promise<{ sent: number; failed: number; removed: number }> {
  const sa = serviceAccount();
  if (!sa) return { sent: 0, failed: tokens.length, removed: 0 };
  const bearer = await accessToken(sa);
  let sent = 0, failed = 0, removed = 0;
  for (const t of new Set(tokens)) {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${bearer}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            ...(t.includes(":") ? { token: t } : { fid: t }),
            notification: { title: msg.title, body: msg.body },
            data: msg.data,
            android: {
              priority: "HIGH",
              notification: { channel_id: "caregiver_alert" },
            },
          },
        }),
      },
    );
    if (res.ok) {
      sent++;
      continue;
    }
    const err = await res.json().catch(() => ({}));
    const code = err?.error?.details?.[0]?.errorCode ?? err?.error?.status;
    if (res.status === 404 || code === "UNREGISTERED") {
      await db.from("device_tokens").delete().eq("token", t);
      removed++;
    } else {
      failed++;
    }
  }
  return { sent, failed, removed };
}

/** "07:00" in an IANA time zone. */
export function hhmm(at: string | Date, timeZone: string): string {
  return new Intl.DateTimeFormat("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZone,
  }).format(new Date(at));
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
