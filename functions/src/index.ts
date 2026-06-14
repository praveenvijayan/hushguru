import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Runs every 15 minutes. Sends a practice reminder to each user whose
 * local practice time falls within the current 15-minute window.
 *
 * User document schema (relevant fields):
 *   remindersEnabled: boolean
 *   practiceTime: "HH:MM"   — local clock time
 *   timezoneOffset: number  — minutes east of UTC (e.g. 330 for IST)
 *   fcmToken: string
 */
export const dailyReminder = onSchedule("every 15 minutes", async () => {
  const now = new Date();
  const utcMinutes = now.getUTCHours() * 60 + now.getUTCMinutes();

  const snap = await db
    .collection("users")
    .where("remindersEnabled", "==", true)
    .get();

  const sends: Promise<void>[] = [];

  for (const doc of snap.docs) {
    const data = doc.data();
    const token: string | undefined = data.fcmToken;
    const practiceTime: string = data.practiceTime ?? "07:00";
    const offset: number = data.timezoneOffset ?? 0;

    if (!token) continue;

    const [hh, mm] = practiceTime.split(":").map(Number);
    const practiceMinutesLocal = hh * 60 + mm;

    // Convert current UTC time to user's local minutes (mod 1440)
    const localMinutes = ((utcMinutes + offset) % 1440 + 1440) % 1440;

    // Fire within the 15-minute window immediately preceding the reminder time
    const diff = (localMinutes - practiceMinutesLocal + 1440) % 1440;
    if (diff >= 15) continue;

    sends.push(
      messaging
        .send({
          token,
          notification: {
            title: "Time to breathe",
            body: "Your daily practice is ready. Open HushGuru to begin.",
          },
          data: { screen: "dashboard" },
          apns: {
            payload: { aps: { sound: "default" } },
          },
        })
        .then(() => undefined)
        .catch((err: Error) => {
          console.error(`FCM send failed for ${doc.id}:`, err.message);
        }),
    );
  }

  await Promise.all(sends);
});
