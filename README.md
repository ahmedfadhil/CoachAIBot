# Running in development

* Clone the repository and access the cloned folder
```
git clone git@github.com:ahmedfadhil/CoachAIBot.git
cd CoachAiBot
```

* If you never used the system, remember to install all the dependencies and then run all migrations and seed the database.
```
bundle install              #installs dependencies

bundle exec rake db:drop    #drops any pld version of the db
bundle exec rake db:create  #creates a new db
bundle exec rake db:migrate #runs migrations
bundle exec rake db:seed    #seeds the db
```

* If you already cloned the repo pull the changes

```
cd CoachAiBot
git pull
```

* Switch to development branch

```
git checkout development
```

* Start ngrok. Ngrok will bind your localhost:3000 to a public address

```
cd CoachAIBot/ngrok
./ngrok http 3000
```

* Now you should see something like this:

```
ngrok by @inconshreveable                                       (Ctrl+C to quit)
                                                                                
Session Status                online                                            
Account                       Marian Diaconu (Plan: Free)                       
Version                       2.2.8                                             
Region                        United States (us)                                
Web Interface                 http://127.0.0.1:4040                             
Forwarding                    http://d9e5ba0e.ngrok.io -> localhost:3000        
Forwarding                    https://d9e5ba0e.ngrok.io -> localhost:3000       
                                                                                
Connections                   ttl     opn     rt1     rt5     p50     p90       
                              0       0       0.00    0.00    0.00    0.00 
```

* Set Telegram Bot Webhook by making a GET request like this:

```
curl https://api.telegram.org/bot294560170:AAFaB9cQ-hCzQEfYNr6z30gD2K7FeDZ1gVQ/setWebhook?url=${https_public_address}/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1
```

But replace `${https_public_address}` with your actual https public address. <br/>
In the example is `https://d9e5ba0e.ngrok.io`. 

This will tell to TelegramAPI to send the user interactions with the bot `@CoachAIBot` to the Rails server.

* If everything went well, you will receive a JSON response like this
```
{"ok":true,"result":true,"description":"Webhook is set"}
```

* Lets start [crono](https://github.com/plashchynski/crono) time-based background job scheduler daemon for Ruby on Rails.
We use it for periodically tasks like sending Notifications 
```
bundle exec crono start RAILS_ENV=development
```

* Now you can start your Rails server.
```
rails s
```

* Access `http://localhost:3000/` for the Web Platform 
* Credentials for LOG IN
```
email:      user@example.com
password:   12345678
```
* Search `@CoachAIBot` on [Telegram](https://web.telegram.org/#/login)



* In case of server issues, as: "A server is already running. When restarting" 

Try this:

- bin/bundle exec pumactl start -P tmp/pids/server.pid
- Wait for app to boot
- touch tmp/restart.txt
- App reboots just fine