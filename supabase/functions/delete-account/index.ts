import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function response(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return response({ error: "Method not allowed." }, 405);

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) return response({ error: "Sign in is required." }, 401);

  let body: { confirmation?: string };
  try {
    body = await req.json();
  } catch {
    return response({ error: "Invalid request body." }, 400);
  }
  if (body.confirmation !== "DELETE") {
    return response({ error: "Explicit DELETE confirmation is required." }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return response({ error: "Account deletion is not configured by the project operator." }, 503);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) return response({ error: "Your session is invalid or expired. Sign in again." }, 401);

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const userId = userData.user.id;

  // Remove this user's public media before deleting the auth user.
  // The bucket is public, but the storage policies keep each user's files in their own UUID folder.
  async function collectFiles(prefix: string): Promise<string[]> {
    const { data, error } = await admin.storage.from("drivenut-media").list(prefix, { limit: 1000 });
    if (error) throw error;
    const files: string[] = [];
    for (const item of data || []) {
      const path = prefix ? prefix + "/" + item.name : item.name;
      if (item.id === null) files.push(...await collectFiles(path));
      else files.push(path);
    }
    return files;
  }

  try {
    const files = await collectFiles(userId);
    for (let i = 0; i < files.length; i += 100) {
      const { error } = await admin.storage.from("drivenut-media").remove(files.slice(i, i + 100));
      if (error) throw error;
    }
  } catch (error) {
    console.error("Could not remove account media:", error);
    return response({ error: "We could not safely remove your uploaded photos. No account was deleted; contact support." }, 500);
  }

  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) {
    console.error("Auth user deletion failed:", deleteError);
    return response({ error: "Account deletion failed. Please contact support before trying again." }, 500);
  }

  return response({ success: true, message: "Your DriveNut account and account-linked database records have been deleted." });
});
