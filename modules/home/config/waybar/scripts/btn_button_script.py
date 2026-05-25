#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import time

# Configuration
MAC = os.environ.get('DEFAULT_HEADPHONES_ADDRESS', 'XX:XX:XX:XX:XX:XX')
FLAG_FILE = "/tmp/waybar_bt_connecting"
ERROR_FILE = "/tmp/waybar_bt_error"

def get_info():
    try:
        # We use bluetoothctl info to get all details
        res = subprocess.check_output(["bluetoothctl", "info", MAC], text=True, stderr=subprocess.DEVNULL)
        connected = "Connected: yes" in res
        
        name = "Unknown"
        battery = ""
        
        for line in res.split('\n'):
            line = line.strip()
            if line.startswith("Name:"):
                name = line.split("Name: ")[1]
            if "Battery Percentage:" in line:
                # Extracts the number inside the parentheses (e.g., 80 from "(80)")
                try:
                    battery = f" ({line.split('(')[1].split(')')[0]}%)"
                except:
                    pass
                    
        return name, connected, battery
    except:
        return "Error", False, ""

def cleanup():
    for f in [FLAG_FILE, ERROR_FILE]:
        if os.path.exists(f):
            os.remove(f)

output = {"text": "󰋋", "class": "disconnected", "tooltip": "Disconnected"}

# --- ACTION: CLICK ---
if "--action-click" in sys.argv:
    cleanup()
    
    with open(FLAG_FILE, "w") as f:
        f.write("connecting")
    
    # This shell command captures BOTH standard output and errors (2>&1)
    # It only keeps the file if the connection actually fails (||)
    cmd = f"tmp=$(mktemp); bluetoothctl connect {MAC} > \"$tmp\" 2>&1 || mv \"$tmp\" {ERROR_FILE}"
    subprocess.Popen(["sh", "-c", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    output["class"] = "connecting"
    output["tooltip"] = "Connecting..."
    print(json.dumps(output))
    sys.exit(0)

# --- ACTION: REGULAR POLL ---
name, connected, battery = get_info()

if connected:
    cleanup()
    output["class"] = "connected"
    output["tooltip"] = f"Connected: {name}{battery}"

# 1. Check if a "Problem" log exists
elif os.path.exists(ERROR_FILE):
    # Check age (20 seconds limit)
    if time.time() - os.path.getmtime(ERROR_FILE) > 20:
        os.remove(ERROR_FILE)
        output["class"] = "disconnected"
    else:
        # Read the raw error message from the file
        try:
            with open(ERROR_FILE, "r") as f:
                # We take the last line as it usually contains the specific error
                raw_log = f.readlines()[-1].strip()
        except:
            raw_log = "Unknown Connection Error"
            
        if os.path.exists(FLAG_FILE): os.remove(FLAG_FILE)
        output["class"] = "problem"
        output["tooltip"] = f"⚠ {raw_log}"

# 2. Check if we are still attempting to connect
elif os.path.exists(FLAG_FILE):
    if time.time() - os.path.getmtime(FLAG_FILE) > 15:
        os.remove(FLAG_FILE)
        output["class"] = "disconnected"
    else:
        output["class"] = "connecting"
        output["tooltip"] = "Connecting..."

else:
    output["class"] = "disconnected"

print(json.dumps(output))
