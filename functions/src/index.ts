
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { checkWebAppSignature } from './validate';

import { onRequest } from "firebase-functions/v2/https";

initializeApp();

const auth = getAuth();

export { sendBotMessage } from "./bot-trigger";

export const generateCustomToken = onRequest({ secrets: ["BOT_SECRETKEY"], cors: true }, async (req, res) => {

    const botSecretKey = process.env.BOT_SECRETKEY!;

    console.log(req.body);

    const initData = req.body.initData;
    console.log(initData);

    let uid = checkWebAppSignature(initData, botSecretKey);
    console.log("uid: " + uid);
    if (uid === false) {
        res.send("Invalid user data");
        return;
    }

    let uid2 = uid.toString();

    try {
        // Generate a custom token for the valid uid
        const customToken = await auth.createCustomToken(uid2);
        res.send({ customToken, uid2 });
        return;
    } catch (error) {
        console.error('Error creating custom token:', (error as Error).message);
        res.status(500).send('Internal server error');
        return;
    }

});