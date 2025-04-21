# WhatsApp Bot

This is a simple WhatsApp bot built using the unofficial WhatsApp Web API library [whatsapp-web.js](https://github.com/pedroslopez/whatsapp-web.js).

## Features

- Connects to WhatsApp Web using a QR code for authentication
- Listens for incoming messages
- Replies with a simple echo message or a greeting when you say "hi"

## Setup and Usage

1. Make sure you have [Node.js](https://nodejs.org/) installed (version 12 or higher).

2. Install dependencies:

```bash
npm install
```

3. Start the bot:

```bash
npm start
```

4. When you start the bot for the first time, a QR code will be displayed in the terminal. Scan it with your WhatsApp mobile app (under WhatsApp Web/Desktop).

5. Once authenticated, the bot will be ready to receive and reply to messages.

## Notes

- The bot uses local authentication to save your session, so you don't need to scan the QR code every time.
- This is an unofficial API and may break if WhatsApp changes their Web client.
- Use responsibly and respect WhatsApp's terms of service.

## License

MIT
