#!/bin/bash
# Script to set or remove system-wide + Git proxy with last proxy memory

# File to store last used proxy
LAST_PROXY_FILE="$HOME/.last_proxy"

# Read last proxy if exists
if [ -f "$LAST_PROXY_FILE" ]; then
    LAST_PROXY=$(cat "$LAST_PROXY_FILE")
else
    LAST_PROXY=""
fi

echo "Choose an option:"
echo "1) Set new proxy"
echo "2) Remove/unset proxy"
read -p "Enter choice [1-2]: " CHOICE

if [ "$CHOICE" == "1" ]; then
    # Ask for proxy, default is last used proxy if available
    read -p "Enter proxy [default: $LAST_PROXY]: " PROXY
    PROXY="${PROXY:-$LAST_PROXY}"

    if [ -z "$PROXY" ]; then
        echo "❌ No proxy entered. Exiting."
        exit 1
    fi

    # Remove any existing proxy lines first
    sudo sed -i '/_proxy=/d' /etc/environment

    # Add new proxy to /etc/environment
    echo "http_proxy=\"$PROXY\" https_proxy=\"$PROXY\" ftp_proxy=\"$PROXY\" rsync_proxy=\"$PROXY\" all_proxy=\"$PROXY\"" | sudo tee -a /etc/environment

    # Update Git proxy
    git config --global http.proxy "$PROXY"
    git config --global https.proxy "$PROXY"

    # Reload environment
    source /etc/environment

    # Save this proxy as last used
    echo "$PROXY" > "$LAST_PROXY_FILE"

    echo "✅ Proxy set to $PROXY for system and Git."

elif [ "$CHOICE" == "2" ]; then
    # Remove proxy lines from /etc/environment
    sudo sed -i '/_proxy=/d' /etc/environment

    # Remove Git proxy
    git config --global --unset http.proxy
    git config --global --unset https.proxy

    # Reload environment
    source /etc/environment

    echo "✅ Proxy removed from system and Git."

else
    echo "❌ Invalid choice. Exiting."
fi
