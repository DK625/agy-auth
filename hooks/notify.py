#!/usr/bin/env python3
import sys
import os
import json
import platform
import subprocess
import urllib.request
import urllib.parse

def get_credentials():
    bot_token = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
    chat_id = os.environ.get("TELEGRAM_CHAT_ID", "").strip()

    config_paths = [
        os.path.expanduser("~/.gemini/notify.json"),
        os.path.expanduser("~/.gemini/config/notify.json")
    ]

    for cpath in config_paths:
        if os.path.exists(cpath):
            try:
                with open(cpath, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    if not bot_token:
                        bot_token = str(data.get("telegram_bot_token", "")).strip()
                    if not chat_id:
                        chat_id = str(data.get("telegram_chat_id", "")).strip()
            except Exception:
                pass

    return bot_token, chat_id

def speak(text: str):
    try:
        system = platform.system()
        if system == "Windows":
            safe_text = text.replace("'", "''")
            ps_code = f"Add-Type -AssemblyName System.Speech; $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; $synth.Speak('{safe_text}')"
            subprocess.run(
                ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps_code],
                timeout=15,
                capture_output=True
            )
        elif system == "Darwin":
            subprocess.run(["say", text], timeout=15, capture_output=True)
        elif system == "Linux":
            if subprocess.run(["which", "spd-say"], capture_output=True).returncode == 0:
                subprocess.run(["spd-say", text], timeout=15, capture_output=True)
            elif subprocess.run(["which", "espeak"], capture_output=True).returncode == 0:
                subprocess.run(["espeak", text], timeout=15, capture_output=True)
    except Exception:
        pass

def send_telegram(bot_token: str, chat_id: str, text: str):
    if not bot_token or not chat_id:
        return
    try:
        url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
        data = urllib.parse.urlencode({"chat_id": chat_id, "text": text}).encode()
        req = urllib.request.Request(url, data=data)
        urllib.request.urlopen(req, timeout=10)
    except Exception:
        pass

if __name__ == "__main__":
    if len(sys.argv) > 1:
        raw = " ".join(sys.argv[1:]).strip()
        msg = raw.strip('\"\'')
    else:
        msg = "agy completed"

    bot_token, chat_id = get_credentials()
    speak(msg)
    send_telegram(bot_token, chat_id, msg)
    print(json.dumps({"decision": "allow"}))

