#!/bin/bash

DEST_ME="$HOME/everything/personal/backup/staging/me"
DEST_MISC="$HOME/everything/personal/backup/staging/misc"

mkdir -p "$DEST_ME" "$DEST_MISC"

if ! adb get-state 1>/dev/null 2>&1; then
    echo "❌ No device found! Ensure USB Debugging is on and the phone is unlocked."
    read -p "Press Enter to exit..."
    exit 1
fi

echo "📱 Samsung Device Connected! Using high-speed tar streaming..."
echo "======================================================="

declare -a PULL_LIST=(
    "/sdcard/DCIM/Camera:$DEST_ME"
    "/sdcard/DCIM/Snapchat:$DEST_ME"
    "/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images:$DEST_MISC"
    "/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents:$DEST_MISC"
    "/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video:$DEST_MISC"
    "/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio:$DEST_MISC"
)

for item in "${PULL_LIST[@]}"; do
    PHONE_PATH="${item%%:*}"
    LOCAL_PATH="${item##*:}"
    
    PARENT_DIR="$(dirname "$PHONE_PATH")"
    TARGET_DIR="$(basename "$PHONE_PATH")"
    
    echo "🔍 Calculating size for $TARGET_DIR..."
    
    # Ask Android for the folder size in Kilobytes (strips out any Windows carriage returns)
    SIZE_KB=$(adb shell "du -sk '$PHONE_PATH' 2>/dev/null" | awk '{print $1}' | tr -d -c '0-9')
    
    if [ -n "$SIZE_KB" ]; then
        # Convert to bytes
        SIZE_BYTES=$((SIZE_KB * 1024))
        echo "🚀 Streaming $TARGET_DIR..."
        
        # -s tells pv the total size, activating the progress bar (-p) and ETA (-e)
        adb exec-out "cd '$PARENT_DIR' && tar cf - '$TARGET_DIR' 2>/dev/null" | pv -s "$SIZE_BYTES" -pterb | tar xf - -C "$LOCAL_PATH/"
    else
        echo "⚠️ Could not calculate size for $TARGET_DIR. Streaming without progress bar..."
        # Fallback if the folder doesn't exist or is empty
        adb exec-out "cd '$PARENT_DIR' && tar cf - '$TARGET_DIR' 2>/dev/null" | pv -btr | tar xf - -C "$LOCAL_PATH/"
    fi
    
    echo "✅ Finished $TARGET_DIR"
    echo "-------------------------------------------------------"
done

echo "🎉 All Backups Complete!"
read -p "Press Enter to close this window..."
