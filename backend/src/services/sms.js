// SMS sender — supports MSG91, AWS SNS, or console (for local testing).
// Set SMS_PROVIDER in .env to choose.

const provider = process.env.SMS_PROVIDER || 'console';

export async function sendSms(phone, message) {
  switch (provider) {
    case 'msg91':
      return sendViaMsg91(phone, message);
    case 'sns':
      return sendViaSns(phone, message);
    default:
      // console: just log — great for local dev / testing without a gateway
      console.log(`[SMS→+91${phone}] ${message}`);
      return true;
  }
}

async function sendViaMsg91(phone, message) {
  const url = 'https://control.msg91.com/api/v5/flow/';
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      authkey: process.env.MSG91_AUTH_KEY,
    },
    body: JSON.stringify({
      template_id: process.env.MSG91_TEMPLATE_ID,
      sender: process.env.MSG91_SENDER_ID,
      mobiles: `91${phone}`,
      // MSG91 flow variables — adjust to match your template
      otp: message.match(/\d{4,6}/)?.[0] || '',
    }),
  });
  return res.ok;
}

async function sendViaSns(phone, message) {
  // Uses AWS SDK v3. Requires: npm i @aws-sdk/client-sns
  const { SNSClient, PublishCommand } = await import('@aws-sdk/client-sns');
  const client = new SNSClient({ region: process.env.AWS_REGION });
  await client.send(
    new PublishCommand({
      PhoneNumber: `+91${phone}`,
      Message: message,
    })
  );
  return true;
}
