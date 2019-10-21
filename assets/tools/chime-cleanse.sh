#!/bin/bash

##### Killing Amazon Chime Process #####
killall "Amazon Chime"

##### Resetting the Data #####
sudo rm -rf /var/db/receipts/com.amazon.Amazon-Chime.plist /var/db/receipts/com.amazon.Amazon-Chime.bom
rm -rf ~/Library/Application\ Support/com.amazon.Amazon-Chime
rm -rf ~/Library/Caches/com.amazon.Amazon-Chime/
rm -rf ~/Library/Caches/com.plausiblelabs.crashreporter.data/
rm -rf ~/Library/Cookies/com.amazon.Amazon-Chime.binarycookies
rm -rf ~/Library/Logs/Amazon\ Chime/
rm -rf ~/Library/Preferences/com.amazon.Amazon-Chime.plist
rm -rf ~/Library/Saved\ Application\ State/com.amazon.Amazon-Chime.savedState
rm -rf ~/Library/WebKit/com.amazon.Amazon-Chime