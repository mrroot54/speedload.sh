#!/bin/bash

# ==============================
# 🔥 Smart Download Script
# Author: Mr_root_54
# Date: 14/7/2025 
# ==============================

# ====== COLOUR FUNCTIONS ======
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

cecho() {
    echo -e "${!1}${2}${RESET}"
}

# ====== USAGE CHECK ======
if [ -z "$1" ]; then
    cecho RED "Usage: $0 <file-url>"
    exit 1
fi

URL=$1
DOMAIN=$(echo $URL | awk -F/ '{print $3}')

cecho BLUE "==============================="
cecho BLUE "🔍 Smart Download Script"
cecho BLUE "==============================="

# ====== PING TEST ======
cecho YELLOW "\n✅ Pinging the server ($DOMAIN)..."
PING_RESULT=$(timeout 10 ping -c 5 $DOMAIN)
echo "$PING_RESULT"

AVG_PING=$(echo "$PING_RESULT" | grep "rtt min" | awk -F/ '{print $5}')
cecho GREEN "\n➡️ Average ping latency: $AVG_PING ms"

LOSS=$(echo "$PING_RESULT" | grep "packet loss" | awk -F, '{print $3}')
cecho GREEN "➡️ Packet loss: $LOSS"

# ====== CURL SPEED TEST ======
cecho YELLOW "\n✅ Download Speed Test using curl (5 seconds)..."
CURL_SPEED=$(curl -o /dev/null --max-time 5 --limit-rate 100M -s -w '%{speed_download}\n' $URL)
SPEED_MB=$(echo "scale=2; $CURL_SPEED / 1024 / 1024" | bc)
cecho GREEN "➡️ Approximate download speed: $SPEED_MB MB/s"

# ====== CONCLUSION ======
cecho BLUE "\n==============================="
cecho BLUE "🔍 Load Analysis Conclusion"
cecho BLUE "==============================="

AVG_PING_NUM=$(echo $AVG_PING | cut -d. -f1)

if [ "$AVG_PING_NUM" -gt 300 ]; then
    cecho RED "⚠️ High latency detected (>300ms). Server might be busy or far."
else
    cecho GREEN "✅ Latency is good (<300ms)."
fi

if [[ $LOSS != *"0%"* ]]; then
    cecho RED "⚠️ Packet loss detected. Connection unstable."
else
    cecho GREEN "✅ No packet loss. Connection stable."
fi

# ====== CONFIRM DOWNLOAD ======
cecho BLUE "\n==============================="
cecho BLUE "❓ Do you want to start download now? (y/n)"
read choice

if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then

    # ====== AUTO-INSTALL aria2c IF MISSING ======
    if ! command -v aria2c &> /dev/null; then
        cecho YELLOW "🔧 aria2c not found. Installing..."
        sudo apt update && sudo apt install -y aria2
    fi

    cecho GREEN "✅ Starting download with aria2c (minimal clean output)..."

    # ====== DOWNLOAD USING aria2c with clean log ======
    aria2c -x 16 -s 16 --file-allocation=none --allow-overwrite=true --auto-file-renaming=false --console-log-level=warn $URL

else
    cecho RED "❌ Download skipped by user."
fi

cecho BLUE "\n==============================="
cecho BLUE "✅ Script completed."
cecho BLUE "==============================="


