# 🔑 SMC KH Academy - Licensing Server & MQL5 EA Integration

A professional, fully integrated Licensing Server, Telegram Bot manager, and MQL5 Expert Advisors (EAs) suite built for MT5 algorithmic trading.

---

## 🚀 Key Features

* **Licensing HTTP Web API**: Runs a local HTTP licensing server that handles verification requests sent from MetaTrader 5 via `WebRequest`.
* **Telegram Bot Manager**: A Telegram bot interface to easily generate, list, and revoke license keys using custom keyboard buttons or direct chat commands.
* **Command Line Interface (CLI)**: Interactive console commands to manage client keys directly from the terminal.
* **MQL5 EA Protection**: Supports online client authorization checks (via `MyGoldTrade.mq5` and `Nhoy-Pro.mq5`) with dynamic expiration date displaying directly on the chart dashboard.
* **Automatic Backtest Bypass**: EAs automatically detect when they are running in the MT5 Strategy Tester or Optimizer and bypass verification for backtesting convenience.

---

## 🛠️ Project Structure

```text
├── bot.py                # Core Python script: HTTP Licensing Server + Telegram Bot + CLI
├── licenses.json         # Database file holding generated licenses and status (ignored by git)
├── index.html            # Trading Academy portal dashboard
├── style.css             # Stylesheet for portal dashboard
├── Nhoy-Pro.mq5          # MT5 Expert Advisor with online license validation integrated
├── MyGoldTrade.mq5       # MT5 Expert Advisor with online license validation integrated
├── .gitignore            # Git exclusions (prevents private DB and cache files from going public)
└── push_to_git.py        # Helper script to upload your code to GitHub
```

---

## ⚙️ Configuration & Setup

### 1. Telegram Bot Setup
Open `bot.py` and replace `TELEGRAM_TOKEN` with your Telegram Bot Token:
```python
TELEGRAM_TOKEN = "YOUR_TELEGRAM_BOT_TOKEN"
```

### 2. Allow WebRequests in MT5
To enable the EAs to connect to your licensing server:
1. Open **MetaTrader 5**.
2. Go to **Tools** -> **Options** -> **Expert Advisors**.
3. Check the box **"Allow WebRequest for listed URL"**.
4. Add: `http://localhost:8888` (or your public server URL).

---

## 🏃 Run the System

### Start the Licensing Server & Bot
Run the Python script in your terminal:
```bash
python bot.py
```
This launches:
1. **HTTP server** on port `8888` (listening for MT5 web requests).
2. **Telegram bot polling loop** (registers the first chat that messages it as the Admin).
3. **Interactive Console CLI**.

### CLI & Telegram Bot Commands
* `/gen <days> <account_id>` : Generate a license key (e.g. `/gen 30 183877074` or `/gen 365 all`).
* `/list` : Display the list of all keys, target accounts, and statuses.
* `/revoke <key>` : Revoke/deactivate a license key.
* `/help` : View the help instructions.
