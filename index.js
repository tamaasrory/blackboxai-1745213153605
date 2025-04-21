const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');

// Use LocalAuth to save session and avoid scanning QR code every time
const client = new Client({
    authStrategy: new LocalAuth()
});

client.on('qr', (qr) => {
    // Generate and display QR code in terminal
    qrcode.generate(qr, { small: true });
    console.log('QR code received, scan please!');
});

client.on('ready', () => {
    console.log('Client is ready!');
});

client.on('message', message => {
    console.log(`Message from ${message.from}: ${message.body}`);

    // Simple echo reply
    if(message.body.toLowerCase() === 'hi') {
        message.reply('Hello! I am your WhatsApp bot.');
    } else {
        message.reply(`You said: ${message.body}`);
    }
});

client.initialize();
