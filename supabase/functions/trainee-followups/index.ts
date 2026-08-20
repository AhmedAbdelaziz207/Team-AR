import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
  const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY")!;

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // 14 days ago
  const fourteenDaysAgo = new Date();
  fourteenDaysAgo.setDate(fourteenDaysAgo.getDate() - 14);

  const { data: trainees, error } = await supabase
    .from("trainee_followups")
    .select("*")
    .lt("last_diet_update", fourteenDaysAgo.toISOString());

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 500 });
  }

  // For each trainee, send FCM (assuming we send it to a general topic or admin's token)
  // Here we send a notification to the 'admin' topic
  const promises = trainees.map((t) => {
    return fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=${FCM_SERVER_KEY}"
      },
      body: JSON.stringify({
        to: "/topics/admins",
        notification: {
          title: "????? ?????? ???????",
          body: "??? ???? ?????? ??????? ?? ??????: " + t.trainee_id
        }
      })
    });
  });

  await Promise.all(promises);

  return new Response(JSON.stringify({ message: "Reminders sent successfully!, count: trainees.length }), {
    headers: { "Content-Type": "application/json" },
  });
});
