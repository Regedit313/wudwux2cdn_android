# wudwux2cdn_android

## Installation

1. Install Termux.

2. Copy the "wudwux2cdn_android" folder to the root of internal storage.

3. Open Termux and run:

termux-setup-storage

(When prompted, allow Termux to access all files on your device storage.)

4. Start wudwux2cdn:

bash ~/storage/shared/wudwux2cdn_android/wudwux2cdn.sh

(The scripts can be launched from any location in Termux.)

5. IMPORTANT:

For the first use, before using any other menu option, select:

9 = Run first-time setup (required before first use)

This step installs all required dependencies and prepares the project folders.

The first-time setup must be completed before using any other menu option.


## Menu

When started, wudwux2cdn.sh provides the following options:

1 = Extract WUD/WUX files

2 = Create common.key

3 = Create title key file

4 = Run first-time setup (required before first use)

5 = Exit


## Extract WUD/WUX Files

Place one or more .wud or .wux files inside:

auto_in/

When option 1 is selected, the script automatically:

- Searches for a valid common.key
- Searches for matching title key files
- Requests missing keys through interactive prompts
- Extracts the game using JWUDTool
- Stores extracted files in auto_out/
- Organizes key files automatically

Successfully extracted .wud/.wux files are removed from auto_in/.


## Create common.key

Option 2 creates:

commonkey/common.key

The key is entered manually through a prompt.

The created common.key will automatically be used by future extractions.


## Create Title Key Files

Option 3 creates title key files inside:

titlekeys/

Examples:

game.wux → game.key

game.wud → game.key

game → game.key

The title key is entered manually through a prompt.

Multiple title key files can be created without leaving the menu.

## Input

Place one game image per file inside:

auto_in/

Example:

auto_in/

---- Zelda.wux

---- Mario Kart 8.wud

Optional title key files:

titlekeys/

---- Zelda.key

---- Mario Kart 8.key

Optional common key:

commonkey/

---- common.key


## Output

Extracted files are created inside:

auto_out/

Example:

auto_out/

---- Zelda/

---- Mario Kart 8/


## Folder Structures

### Folder Structure Before Extraction

wudwux2cdn_android/

---- README.md

---- JWUDTool.jar

---- wudwux2cdn.sh

---- wudwux2cdn_setup.sh

---- auto_in/

-------- Zelda.wux

-------- Mario Kart 8.wud

---- auto_out/

---- commonkey/

---- titlekeys/


### Folder Structure After Extraction

wudwux2cdn_android/

---- README.md

---- JWUDTool.jar

---- wudwux2cdn.sh

---- wudwux2cdn_setup.sh

---- auto_in/

---- auto_out/

-------- Zelda/

-------- Mario Kart 8/

---- commonkey/

-------- common.key

---- titlekeys/

-------- Zelda.key

-------- Mario Kart 8.key


## Notes

The required folders are created during the first-time setup and are automatically recreated when launching wudwux2cdn.sh if they do not already exist.

The script searches for common.key in:

- commonkey/
- titlekeys/
- auto_in/
- project root

If no common.key is found, the key is requested manually.

A manually entered common key is automatically saved to:

commonkey/common.key

after a successful extraction.

The script searches for title key files in:

- titlekeys/
- auto_in/

If no matching title key file is found, the key is requested manually.

Title key files found in auto_in/ are automatically moved to titlekeys/ after a successful extraction.

The title key filename must match the game filename.

Example:

Zelda.wux → Zelda.key

Mario Kart 8.wud → Mario Kart 8.key

If an extraction fails, the original files remain untouched for troubleshooting.


## Credits

This project uses:

- JWUDTool by Maschell

Original repository:

https://github.com/Maschell/JWUDTool

This repository provides an Android/Termux workflow for extracting Wii U WUD/WUX images with automatic common.key and title key management.