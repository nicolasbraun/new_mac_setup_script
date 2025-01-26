echo "There is still some manual stuff to do :("

echo "In Keyboard setting"
echo "change the shortcut to 'Move focus to next window' Alt+tab is a good one"
echo "Disable Spotlight."

read -p "Press [Enter] to open Preferences"
open "x-apple.systempreferences:com.apple.preference.keyboard"

echo "Launch Raycast and restore your backup file"
read -p "Press [Enter] to open Raycast"
open "Applications/RayRaycast.app"

echo "[VSCODE] Login to sync settings"
read -p "Press [Enter] to open VSCode"
open "/Applications/Visual\ Studio\ Code.app"

echo "[Firefox]"
echo "- Login in"
echo "- Restore sideberry backup"
read -p "Press [Enter] to open Firefox"
open "/Applications/Firefox.app"

echo "[Finder]"
echo "- Set the sidebar favorites"
read -p "Press [Enter] to finish this setup"
