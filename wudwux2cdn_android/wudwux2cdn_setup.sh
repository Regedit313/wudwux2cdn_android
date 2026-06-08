#!/data/data/com.termux/files/usr/bin/bash

clear

cd "$(dirname "$0")" || exit 1

echo
echo "wudwux2cdn_android setup"
echo

echo "Creating project folders..."

mkdir -p auto_in
mkdir -p auto_out
mkdir -p commonkey
mkdir -p titlekeys

echo
echo "Updating Termux..."
pkg update -y
pkg upgrade -y

if [ ! -d ~/storage/shared ]; then
    echo
    echo "Setting up storage..."
    termux-setup-storage
else
    echo
    echo "Storage is already configured."
fi

echo
echo "Installing OpenJDK..."
pkg install openjdk-21 -y

echo
echo "Installation completed."
echo
read -p "Press Enter to continue..."
