# 💫 hyperspace-bot-lua
Simplifying Hyperspace CLI usage with a robust LUA bot, making commands easier to execute and manage.

> [!WARNING]
> Due to the large number of participants,and the server capacity has not been increased.
> You will often encounter errors from the server such as 500,502,503 (meaning the server is overloaded).

> [!TIP]
> If you're just focused on increasing uptime and collecting points, for now it's better to just run a node.

# 🤔 How To Do

## 🧬 Clone This Repository

```bash
git clone https://github.com/cmalf/hyperspace-bot-lua.git
```

## 📂 Go To Teneo Bot Folder

```bash
cd hyperspace-bot-lua
```

## 🏃🏻‍♂️‍➡️ Run the Script

- To run the bot script
```bash
lua app.lua
```

## ❓ How does it work

- Just run the script, if you haven't installed hyperspace-cli
  the bot automatically installs it.
- Select option number 1 (to start running node)
- You can now interact with hyperspace-cli via bot

> [!WARNING]
> THIS BOT IS ONLY FOR MACOS AND LINUX USERS

> [!TIP]
> After running node(option 1 Start Daemon), you can select option 0 to exit. (if you just want to run node, without interacting with hyperspace-cli) <br>
> The node will run in the background <br>
> You can check the log in the aios.log file <br>

- To stop a node, there are three ways
  1. run the bot again select option 1 then select option 3
  2. use manual commands
     ```bash
     pkill -f aios
     ```
     or
     
     ```bash
     aios-cli kill
     ```

## [◉°] ScreenShoot

- Bot Interface
  
<img src="https://github.com/user-attachments/assets/a324b1c1-665f-43f1-b21e-869fda1f16d5" widht=580 height=480 >

- Hive Interface
  
<img src="https://github.com/user-attachments/assets/bf49d401-e830-4406-9d91-e8525308ee28" widht=580 height=480 >

## ᝰ.ᐟ NOTE

Bots are created based on content from hyperspaceai [aios-cli](https://github.com/hyperspaceai/aios-cli)
