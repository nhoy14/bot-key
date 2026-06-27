"""
🔑 LICENSING SERVER & TELEGRAM BOT FOR MQL5 (bot.py)
--------------------------------------------------
Run this script: python bot.py
This runs:
  1. A local Web Verification Server on port 8888.
  2. A Telegram Bot manager (Telegram updates polling with buttons).
  3. A local CLI interface in the terminal.

បញ្ជា (CLI & Telegram Bot Commands):
  - /gen <days> <account_id> : Create a new license key (e.g. /gen 30 263278853 or /gen 365 all)
  - /list                    : Show all active/revoked license keys
  - /revoke <key>            : Revoke/deactivate a license key
  - /help                    : Show help commands
"""

import os
import json
import uuid
import string
import random
import datetime
import threading
import time
import urllib.request
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler

# Configurations
PORT = int(os.environ.get("PORT", 8888))
DB_FILE = "licenses.json"
TELEGRAM_TOKEN = "8334804183:AAFCqfdeVJVuDlmpqH1r5JowpjaSc8gAktg"
TELEGRAM_API_URL = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}"

# Inline Keyboard Markup for Telegram Bot
MAIN_KEYBOARD = {
    "inline_keyboard": [
        [
            {"text": "➕ បង្កើត Key", "callback_data": "btn_gen"},
            {"text": "📋 បញ្ជី Key ទាំងអស់", "callback_data": "btn_list"}
        ],
        [
            {"text": "❌ លុប Key", "callback_data": "btn_revoke"},
            {"text": "❓ ជំនួយ / ការណែនាំ", "callback_data": "btn_help"}
        ]
    ]
}

# Lock for thread safety
db_lock = threading.Lock()

def load_db():
    with db_lock:
        if not os.path.exists(DB_FILE):
            return {}
        try:
            with open(DB_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}

def save_db(db):
    with db_lock:
        try:
            with open(DB_FILE, "w", encoding="utf-8") as f:
                json.dump(db, f, indent=4, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"\n❌ Error saving database: {e}")
            return False

def generate_key():
    # Format: XXXX-XXXX-XXXX-XXXX
    chars = string.ascii_uppercase + string.digits
    parts = [''.join(random.choices(chars, k=4)) for _ in range(4)]
    return '-'.join(parts)

def init_db():
    db = load_db()
    default_key = "SMC-KH-30DAYS-DEMO"
    if default_key not in db:
        expiry_date = (datetime.datetime.now() + datetime.timedelta(days=30)).strftime("%Y-%m-%d %H:%M:%S")
        db[default_key] = {
            "account_id": "all",
            "expiry": expiry_date,
            "status": "active",
            "created_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "note": "Default 30-day demo key"
        }
        save_db(db)
        print(f"📦 Pre-created default 30-day key: {default_key} (Expires: {expiry_date})")

# HTTP Request Handler for MT5 EA WebRequests
class LicenseHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        parsed_url = urllib.parse.urlparse(self.path)
        clean_path = parsed_url.path.strip("/")
        
        if clean_path == "verify":
            query = urllib.parse.parse_qs(parsed_url.query)
            key = query.get("key", [""])[0].strip()
            account = query.get("account", [""])[0].strip()
            
            db = load_db()
            response = {
                "status": "invalid",
                "message": "សោអាជ្ញាប័ណ្ណមិនត្រឹមត្រូវ (Invalid License Key)"
            }
            
            # Normalize request key (replace spaces/underscores with hyphens, uppercase)
            normalized_req_key = key.replace(" ", "-").replace("_", "-").upper()
            
            # Find matching key in database
            found_key = None
            for db_key in db:
                if db_key.replace(" ", "-").replace("_", "-").upper() == normalized_req_key:
                    found_key = db_key
                    break
            
            if not key:
                response = {"status": "invalid", "message": "Missing key parameter"}
            elif found_key is not None:
                license_info = db[found_key]
                
                if license_info.get("status") != "active":
                    response = {
                        "status": "revoked",
                        "message": "សោអាជ្ញាប័ណ្ណនេះត្រូវបានដកហូត (License key has been revoked)"
                    }
                else:
                    expiry_str = license_info.get("expiry")
                    try:
                        expiry_dt = datetime.datetime.strptime(expiry_str, "%Y-%m-%d %H:%M:%S")
                        now = datetime.datetime.now()
                        
                        if now > expiry_dt:
                            response = {
                                "status": "expired",
                                "message": f"សោអាជ្ញាប័ណ្ណបានផុតកំណត់កាលពី {expiry_str} (License expired)"
                            }
                        else:
                            allowed_acc = str(license_info.get("account_id", "")).strip()
                            if allowed_acc.lower() == "all" or allowed_acc == account:
                                response = {
                                    "status": "active",
                                    "expiry": expiry_str,
                                    "message": "ការផ្ទៀងផ្ទាត់ជោគជ័យ (Verification Successful)"
                                }
                            else:
                                response = {
                                    "status": "mismatch",
                                    "message": f"គណនី {account} មិនត្រូវគ្នានឹងសោនេះទេ (Account bound mismatch)"
                                }
                    except Exception as e:
                        response = {"status": "error", "message": f"Server date parsing error: {str(e)}"}
            
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response, ensure_ascii=False).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")

def start_http_server():
    server = HTTPServer(("0.0.0.0", PORT), LicenseHandler)
    print(f"🚀 License HTTP Server running on http://localhost:{PORT}")
    print(f"📡 MT5 Request URL: http://localhost:{PORT}/verify?key=<KEY>&account=<ACC_NUM>")
    try:
        server.serve_forever()
    except Exception:
        pass

# Telegram Bot Polling Implementation
def send_telegram_message(chat_id, text, reply_markup=None):
    url = f"{TELEGRAM_API_URL}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown"
    }
    if reply_markup:
        payload["reply_markup"] = json.dumps(reply_markup)
        
    data = urllib.parse.urlencode(payload).encode("utf-8")
    try:
        req = urllib.request.Request(url, data=data)
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(f"⚠️ Error sending Telegram message: {e}")

def run_telegram_bot():
    offset = 0
    print("🤖 Telegram Bot Polling is active and monitoring requests...")
    
    while True:
        try:
            url = f"{TELEGRAM_API_URL}/getUpdates?offset={offset}&timeout=30"
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=35) as resp:
                result = json.loads(resp.read().decode("utf-8"))
                
            if result.get("ok") and result.get("result"):
                for update in result["result"]:
                    offset = update["update_id"] + 1
                    
                    # --- Handle Callback Queries (Button Clicks) ---
                    callback_query = update.get("callback_query")
                    if callback_query:
                        chat_id = callback_query["message"]["chat"]["id"]
                        data = callback_query.get("data", "")
                        query_id = callback_query.get("id")
                        
                        # Dismiss loading spinner on the button
                        try:
                            urllib.request.urlopen(f"{TELEGRAM_API_URL}/answerCallbackQuery?callback_query_id={query_id}")
                        except Exception:
                            pass
                            
                        db = load_db()
                        admin_id = db.get("admin_chat_id")
                        
                        if chat_id != admin_id:
                            send_telegram_message(chat_id, "⚠️ *ការអនុញ្ញាតត្រូវបានបដិសេធ*\n\nបងមិនមានសិទ្ធិប្រើប្រាស់ Bot នេះឡើយ។")
                            continue
                            
                        if data == "btn_list":
                            keys = {k: v for k, v in db.items() if k != "admin_chat_id"}
                            if not keys:
                                send_telegram_message(chat_id, "📭 មិនទាន់មានអាជ្ញាប័ណ្ណណាមួយក្នុងប្រព័ន្ធឡើយ។", reply_markup=MAIN_KEYBOARD)
                                continue
                            list_text = "📋 *បញ្ជីសោអាជ្ញាប័ណ្ណក្នុងប្រព័ន្ធ:*\n\n"
                            for k, info in keys.items():
                                list_text += (
                                    f"🔑 `{k}`\n"
                                    f"   👤 គណនី: `{info.get('account_id')}`\n"
                                    f"   ⏳ ផុតកំណត់: `{info.get('expiry')}`\n"
                                    f"   ⚙️ ស្ថានភាព: `{'សកម្ម (ACTIVE)' if info.get('status') == 'active' else 'លុបចោល (REVOKED)'}`\n\n"
                                )
                            send_telegram_message(chat_id, list_text, reply_markup=MAIN_KEYBOARD)
                            
                        elif data == "btn_gen":
                            new_key = generate_key()
                            days = 30
                            expiry_date = (datetime.datetime.now() + datetime.timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
                            
                            db = load_db()
                            db[new_key] = {
                                "account_id": "all",
                                "expiry": expiry_date,
                                "status": "active",
                                "created_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                "note": "Generated via Telegram Button Click"
                            }
                            
                            if save_db(db):
                                resp_text = (
                                    "✅ *បង្កើតសោអាជ្ញាប័ណ្ណជោគជ័យ!*\n\n"
                                    f"🔑 *សោអាជ្ញាប័ណ្ណ:* `{new_key}`\n"
                                    f"👤 *លេខគណនី:* `គ្រប់គណនី (all)`\n"
                                    f"⏳ *ថ្ងៃផុតកំណត់:* `{expiry_date}` (៣០ ថ្ងៃ)"
                                )
                                send_telegram_message(chat_id, resp_text, reply_markup=MAIN_KEYBOARD)
                            
                        elif data == "btn_revoke":
                            revoke_instructions = (
                                "❌ *លុប ឬដកហូតសោអាជ្ញាប័ណ្ណ*\n\n"
                                "សូមវាយផ្ញើសារបញ្ជាតាមទម្រង់ខាងក្រោម៖\n"
                                "`/revoke <សោ>`\n\n"
                                "*ឧទាហរណ៍៖*\n"
                                "• `/revoke ABCD-1234-EFGH-5678`"
                            )
                            send_telegram_message(chat_id, revoke_instructions, reply_markup=MAIN_KEYBOARD)
                            
                        elif data == "btn_help":
                            help_text = (
                                "🔑 *SMC KH ACADEMY - ប្រព័ន្ធគ្រប់គ្រងអាជ្ញាប័ណ្ណ*\n\n"
                                "បងអាចចុចប៊ូតុងបញ្ជាខាងក្រោម ឬផ្ញើសារបញ្ជាផ្ទាល់៖\n"
                                "• `/gen <ចំនួនថ្ងៃ> <លេខគណនី>` - បង្កើតសោថ្មី\n"
                                "• `/list` - បង្ហាញបញ្ជីសោទាំងអស់\n"
                                "• `/revoke <សោ>` - លុប ឬដកហូតសោ\n"
                                "• `/help` - បង្ហាញការណែនាំនេះ"
                            )
                            send_telegram_message(chat_id, help_text, reply_markup=MAIN_KEYBOARD)
                        continue
                    
                    # --- Handle Standard Chat Messages ---
                    message = update.get("message")
                    if not message:
                        continue
                        
                    chat_id = message["chat"]["id"]
                    text = message.get("text", "").strip()
                    
                    if not text:
                        continue
                        
                    parts = text.split()
                    cmd = parts[0].lower()
                    
                    db = load_db()
                    admin_id = db.get("admin_chat_id")
                    
                    if not admin_id:
                        db["admin_chat_id"] = chat_id
                        save_db(db)
                        admin_id = chat_id
                        send_telegram_message(chat_id, "👑 *SMC KH ADMIN REGISTERED*\n\nគណនីរបស់បងត្រូវបានកំណត់ជាអ្នកគ្រប់គ្រង (Administrator) នៃប្រព័ន្ធនេះជោគជ័យហើយ។", reply_markup=MAIN_KEYBOARD)
                        
                    if chat_id != admin_id:
                        user_welcome_text = (
                            "👋 *សូមស្វាគមន៍មកកាន់ SMC KH ACADEMY*\n\n"
                            "បងអាចទាក់ទងមកកាន់ Admin ដើម្បីស្នើសុំសោអាជ្ញាប័ណ្ណ (License Key) សម្រាប់ប្រើប្រាស់ EA MyGoldTrade។\n\n"
                            "ℹ️ *សេចក្ដីណែនាំសម្រាប់តំឡើង៖*\n"
                            "១. បន្ថែម URL: `http://localhost:8888` ទៅកាន់ Allowed WebRequests ក្នុង MT5 (Tools -> Options -> Expert Advisors)។\n"
                            "២. ប្រើប្រាស់ Default Key: `SMC-KH-30DAYS-DEMO` សម្រាប់តេស្តសាកល្បងដោយឥតគិតថ្លៃរយៈពេល ៣០ ថ្ងៃ។"
                        )
                        send_telegram_message(chat_id, user_welcome_text)
                        continue
                        
                    if cmd == "/start" or cmd == "/help" or cmd == "help":
                        help_text = (
                            "🔑 *SMC KH ACADEMY - ប្រព័ន្ធគ្រប់គ្រងអាជ្ញាប័ណ្ណ*\n\n"
                            "បញ្ជាដែលមាន៖\n"
                            "• `/gen <ចំនួនថ្ងៃ> <លេខគណនី>` - បង្កើតអាជ្ញាប័ណ្ណថ្មី (ឧទាហរណ៍៖ `/gen 30 263278853` ឬ `/gen 365 all`)\n"
                            "• `/list` - បង្ហាញបញ្ជីសោអាជ្ញាប័ណ្ណទាំងអស់\n"
                            "• `/revoke <សោ>` - លុប ឬដកហូតអាជ្ញាប័ណ្ណ\n"
                            "• `/help` - បង្ហាញការណែនាំនេះ"
                        )
                        send_telegram_message(chat_id, help_text, reply_markup=MAIN_KEYBOARD)
                        
                    elif cmd == "/gen":
                        if len(parts) < 3:
                            send_telegram_message(chat_id, "❌ *ទម្រង់បញ្ជា:* `/gen <ចំនួនថ្ងៃ> <លេខគណនី>`", reply_markup=MAIN_KEYBOARD)
                            continue
                        try:
                            days = int(parts[1])
                        except ValueError:
                            send_telegram_message(chat_id, "❌ *កំហុស:* ចំនួនថ្ងៃត្រូវតែជាលេខរៀង។", reply_markup=MAIN_KEYBOARD)
                            continue
                            
                        account_id = parts[2].strip()
                        new_key = generate_key()
                        expiry_date = (datetime.datetime.now() + datetime.timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
                        
                        db = load_db()
                        db[new_key] = {
                            "account_id": account_id,
                            "expiry": expiry_date,
                            "status": "active",
                            "created_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                        }
                        
                        if save_db(db):
                            resp_text = (
                                f"✅ *បង្កើតសោអាជ្ញាប័ណ្ណជោគជ័យ!*\n\n"
                                f"🔑 *សោអាជ្ញាប័ណ្ណ:* `{new_key}`\n"
                                f"👤 *លេខគណនី:* `{account_id}`\n"
                                f"⏳ *ថ្ងៃផុតកំណត់:* `{expiry_date}` ({days} ថ្ងៃ)"
                            )
                            send_telegram_message(chat_id, resp_text, reply_markup=MAIN_KEYBOARD)
                            
                    elif cmd == "/list":
                        db = load_db()
                        keys = {k: v for k, v in db.items() if k != "admin_chat_id"}
                        if not keys:
                            send_telegram_message(chat_id, "📭 មិនទាន់មានអាជ្ញាប័ណ្ណណាមួយក្នុងប្រព័ន្ធឡើយ។", reply_markup=MAIN_KEYBOARD)
                            continue
                            
                        list_text = "📋 *បញ្ជីសោអាជ្ញាប័ណ្ណក្នុងប្រព័ន្ធ:*\n\n"
                        for k, info in keys.items():
                            list_text += (
                                f"🔑 `{k}`\n"
                                f"   👤 គណនី: `{info.get('account_id')}`\n"
                                f"   ⏳ ផុតកំណត់: `{info.get('expiry')}`\n"
                                f"   ⚙️ ស្ថានភាព: `{'សកម្ម (ACTIVE)' if info.get('status') == 'active' else 'លុបចោល (REVOKED)'}`\n\n"
                            )
                        send_telegram_message(chat_id, list_text, reply_markup=MAIN_KEYBOARD)
                        
                    elif cmd == "/revoke":
                        if len(parts) < 2:
                            send_telegram_message(chat_id, "❌ *ទម្រង់បញ្ជា:* `/revoke <សោ>`", reply_markup=MAIN_KEYBOARD)
                            continue
                        key_to_revoke = parts[1].strip()
                        
                        db = load_db()
                        if key_to_revoke in db:
                            db[key_to_revoke]["status"] = "revoked"
                            if save_db(db):
                                send_telegram_message(chat_id, f"✅ សោអាជ្ញាប័ណ្ណ `{key_to_revoke}` ត្រូវបាន *ដកហូត/លុបចោល* ជោគជ័យ។", reply_markup=MAIN_KEYBOARD)
                        else:
                            send_telegram_message(chat_id, f"❌ រកមិនឃើញសោអាជ្ញាប័ណ្ណ `{key_to_revoke}` ឡើយ។", reply_markup=MAIN_KEYBOARD)
                            
        except Exception as e:
            print(f"⚠️ Telegram bot error: {e}")
            time.sleep(5)

if __name__ == "__main__":
    # Initialize DB with default demo key
    init_db()
    
    # Start HTTP Verification Server in daemon thread
    http_thread = threading.Thread(target=start_http_server, daemon=True)
    http_thread.start()
    
    # Start Telegram Bot polling in daemon thread
    tg_thread = threading.Thread(target=run_telegram_bot, daemon=True)
    tg_thread.start()
    
    time.sleep(0.5)
    print("\n=======================================================")
    print("🔑 SMC KH ACADEMY - TELEGRAM BOT & WEB API IS RUNNING")
    print("=======================================================")
    print("Type commands directly in this terminal or in your Telegram Bot.")
    print("Local Console Commands:")
    print("  gen <days> <account_id> : Create license")
    print("  list                    : View licenses database")
    print("  revoke <key>            : Deactivate key")
    print("  exit                    : Shut down the server")
    print("-------------------------------------------------------\n")
    
    while True:
        try:
            cmd_input = input("LicenseManager> ").strip()
            if not cmd_input:
                continue
            
            parts = cmd_input.split()
            cmd = parts[0].lower()
            
            if cmd == "help":
                print("\n📌 CLI Commands:")
                print("  gen <days> <account_id> - Generate key")
                print("  list                    - List all keys")
                print("  revoke <key>            - Revoke key")
                print("  exit                    - Shutdown server")
                
            elif cmd == "exit":
                print("\n👋 Stopping Licensing Server. Goodbye!")
                break
                
            elif cmd == "gen":
                if len(parts) < 3:
                    print("❌ Syntax: gen <days> <account_id>")
                    continue
                try:
                    days = int(parts[1])
                except ValueError:
                    print("❌ Error: Days must be a number.")
                    continue
                acc_id = parts[2].strip()
                new_key = generate_key()
                expiry_date = (datetime.datetime.now() + datetime.timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
                
                db = load_db()
                db[new_key] = {
                    "account_id": acc_id,
                    "expiry": expiry_date,
                    "status": "active",
                    "created_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                }
                if save_db(db):
                    print(f"✅ Generated Key: {new_key} for Account: {acc_id} Expiring: {expiry_date}")
                    
            elif cmd == "list":
                db = load_db()
                keys = {k: v for k, v in db.items() if k != "admin_chat_id"}
                if not keys:
                    print("📭 No licenses in database.")
                    continue
                print("-" * 80)
                print(f"{'KEY':<22} | {'ACCOUNT':<15} | {'EXPIRY':<20} | {'STATUS':<8}")
                print("-" * 80)
                for k, info in keys.items():
                    print(f"{k:<22} | {str(info.get('account_id')):<15} | {info.get('expiry'):<20} | {info.get('status').upper():<8}")
                print("-" * 80)
                
            elif cmd == "revoke":
                if len(parts) < 2:
                    print("❌ Syntax: revoke <key>")
                    continue
                key_to_revoke = parts[1].strip()
                db = load_db()
                if key_to_revoke in db:
                    db[key_to_revoke]["status"] = "revoked"
                    if save_db(db):
                        print(f"✅ Key {key_to_revoke} revoked successfully.")
                else:
                    print(f"❌ Key {key_to_revoke} not found.")
            else:
                print(f"❓ Unknown command: {cmd}")
        except KeyboardInterrupt:
            print("\n👋 Stopping Licensing Server. Goodbye!")
            break
        except Exception as e:
            print(f"⚠️ CLI error: {e}")
