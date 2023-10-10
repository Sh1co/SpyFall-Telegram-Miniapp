
import {
    onDocumentCreated,
} from "firebase-functions/v2/firestore";

import { Bot } from "grammy";

const bot = new Bot("");

export const sendBotMessage = onDocumentCreated("Example Apps/{appName}/_bot/{requestId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event");
        return;
    }
    const data = snapshot.data();
    await bot.api.sendMessage(data.chatId, data.message);
});