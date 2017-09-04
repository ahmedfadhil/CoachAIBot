# Running in development

Get a copy of chatscript-bot and start it using:

```
./BINARIES/LinuxChatScript64 port=1024 language=italian
```

Start ngrock:

```
./ngrok http 3000
```

Copy your https public address, it should look like this: `https://8750c73e.ngrok.io`

Now visit

```
https://api.telegram.org/bot434866375:AAF2FXmS2K598jsonxeilsnnxyOwAd83vHs/setWebhook?url=https://8750c73e.ngrok.io/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1
```

But replace `https://8750c73e.ngrok.io` with your actual public address. You should see the message "Webhook was set"

## Developing your own bot

You should do this if you are willing to develop your own bot. Contact Marian because he knows what to do!
