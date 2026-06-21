// supabase/functions/get-signed-url/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const B2_KEY_ID = Deno.env.get("B2_KEY_ID")!;
const B2_APP_KEY = Deno.env.get("B2_APPLICATION_KEY")!;
const B2_BUCKET_ID = Deno.env.get("B2_BUCKET_ID")!;
const B2_BUCKET_NAME = Deno.env.get("B2_BUCKET_NAME")!;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { file_path } = await req.json();

    if (!file_path) {
      return new Response(
        JSON.stringify({ error: "file_path is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Authorize with B2
    const authRes = await fetch(
      "https://api.backblazeb2.com/b2api/v2/b2_authorize_account",
      {
        headers: {
          Authorization: "Basic " + btoa(`${B2_KEY_ID}:${B2_APP_KEY}`),
        },
      }
    );

    const authData = await authRes.json();

    // DEBUG: return immediately if auth failed
    if (!authRes.ok) {
      return new Response(
        JSON.stringify({ step: "b2_authorize_account", status: authRes.status, body: authData }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Get a download authorization token
    const downloadAuthRes = await fetch(
      `${authData.apiUrl}/b2api/v2/b2_get_download_authorization`,
      {
        method: "POST",
        headers: { Authorization: authData.authorizationToken },
        body: JSON.stringify({
          bucketId: B2_BUCKET_ID,
          fileNamePrefix: file_path,
          validDurationInSeconds: 3600,
        }),
      }
    );

    const downloadAuthData = await downloadAuthRes.json();

    // DEBUG: return immediately if this step failed
    if (!downloadAuthRes.ok) {
      return new Response(
        JSON.stringify({ step: "b2_get_download_authorization", status: downloadAuthRes.status, body: downloadAuthData }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const signedUrl = `${authData.downloadUrl}/file/${B2_BUCKET_NAME}/${file_path}?Authorization=${downloadAuthData.authorizationToken}`;

    return new Response(JSON.stringify({ url: signedUrl }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});