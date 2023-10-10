import * as querystring from 'querystring';
import * as crypto from 'crypto';

export function checkWebAppSignature(initData: string, secretKeyHex: string): false | number {
    const parsedData = convertParsedData(querystring.parse(initData));
    if (!parsedData) return false;

    const { hash, ...rest } = parsedData;
    if (!hash) return false;

    const dataCheckString = Object.entries(rest)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, value]) => `${key}=${value}`)
        .join('\n');

    const uid = JSON.parse(rest['user'])['id'];
    console.log(dataCheckString);

    const secretKey = Buffer.from(secretKeyHex, 'hex');
    const calculatedHash = crypto.createHmac('sha256', secretKey)
        .update(dataCheckString)
        .digest('hex');

    if (calculatedHash === hash) return uid;
    return false;
}

function convertParsedData(parsedData: querystring.ParsedUrlQuery): { [key: string]: string } | null {
    const result: { [key: string]: string } = {};
    for (const key in parsedData) {
        const value = parsedData[key];
        if (Array.isArray(value)) {
            result[key] = value.join(',');
        } else if (typeof value === 'string') {
            result[key] = value;
        } else {
            return null;
        }
    }
    return result;
}