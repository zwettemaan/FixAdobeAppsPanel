#!/bin/bash

# Adobe XML File Location (adjust if necessary)
XML_PATH="/Library/Application Support/Adobe/OOBE/Configs/ServiceConfig.xml"
CREATIVE_CLOUD_APP="/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app"

echo "*************************"
echo "Adobe Creative Cloud Apps Panel Fix Tool"
echo "*************************"
echo ""

# Check if Creative Cloud app exists
if [ ! -d "${CREATIVE_CLOUD_APP}" ]; then
    echo "⚠️ Could not find Adobe Creative Cloud at the expected location:"
    echo "${CREATIVE_CLOUD_APP}"
    echo "The Adobe software might be installed in a different location."
    echo "Aborting - no changes were made"
    echo ""
    echo "*************************"
    exit 1
fi

# Check if the XML config exists
if [ ! -f "${XML_PATH}" ]; then
    echo "⚠️ Could not find the Adobe configuration file:"
    echo "${XML_PATH}"
    echo "The Adobe software might be using a different configuration."
    echo "Aborting - no changes were made"
    echo ""
    echo "*************************"
    exit 1
fi

# Ask for Admin Rights
if [[ $EUID -ne 0 ]]; then
    echo "This tool needs administrative privileges to modify Adobe settings."
    echo "When asked for a password, please enter your user password."
    echo ""

    if ! sudo "$0" "$@"; then
        echo "⚠️ Failed to acquire admin privileges"
        echo "Aborting - no changes were made"
        echo ""
        echo "*************************"
    	exit 1
    fi
    
    # Exit the original script after successfully starting the sudo version
    exit 0
fi

echo "✅ Administrative privileges acquired"

# Create backup with timestamp
BACKUP_PATH="${XML_PATH}.bak-$(date +%Y%m%d-%H%M%S)"
if ! cp "$XML_PATH" "$BACKUP_PATH"; then
    echo "⚠️ Failed to make a backup copy of the configuration file"
    echo "Aborting - no changes were made"
    echo ""
    echo "*************************"
    exit 1
fi

echo "✅ Created backup at: ${BACKUP_PATH}"
echo "(If something goes wrong, you can restore this file manually)"

# Make the actual change
if grep -q '<config name="AppsPanel">false</config>' "$XML_PATH"; then
    if sed -i '' 's|<config name="AppsPanel">false</config>|<config name="AppsPanel">true</config>|g' "$XML_PATH"; then
        # Verify the change was made
        if grep -q '<config name="AppsPanel">true</config>' "$XML_PATH"; then
            echo "✅ Adobe Apps Panel has been successfully re-enabled."
        else
            echo "⚠️ Something went wrong while modifying the configuration."
            echo "Attempting to restore from backup..."
            cp "$BACKUP_PATH" "$XML_PATH"
            echo "Please try again or seek technical assistance."
            echo ""
            echo "*************************"
            exit 1
        fi
    else
        echo "⚠️ Failed to modify the configuration file"
        echo "Aborting - no changes were made"
        echo ""
        echo "*************************"
        exit 1
    fi
else
    echo "✅ Apps Panel is already enabled in the configuration file"
fi

echo ""
echo "📱 Restarting Adobe background services..."
echo "This may take a moment..."

# Kill Adobe services to force configuration reload
pkill -f "Adobe Desktop Service" 2>/dev/null
pkill -f "AdobeIPCBroker" 2>/dev/null
pkill -f "CCLibrary" 2>/dev/null
pkill -f "CCXProcess" 2>/dev/null
pkill -f "CoreSync" 2>/dev/null

echo ""
echo "🚀 Launching Adobe Creative Cloud..."
    
if ! open -a "${CREATIVE_CLOUD_APP}"; then
    echo "⚠️ Failed to launch Adobe Creative Cloud app"
    echo "Please try opening it manually from your Applications folder."
else
    echo "✅ Adobe Creative Cloud launched successfully"
fi

# Set readable permissions on the backup for the regular user
if [[ $SUDO_USER ]]; then
    chown $SUDO_USER "$BACKUP_PATH"
fi
    
echo ""
echo "✅ Process completed!"
echo "The Creative Cloud app should now show the Apps Panel."
echo "If you still experience issues, try restarting your computer."
echo "*************************"
