#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p auto_in
mkdir -p auto_out
mkdir -p commonkey
mkdir -p titlekeys

read_hex_key() {
    prompt="$1"

    while true; do
        read -p "$prompt" key

        case "$key" in
            ""|*[!0-9a-fA-F]*)
                echo "Invalid key. Use 32 hexadecimal characters."
                ;;
            *)
                if [ "${#key}" -eq 32 ]; then
                    echo "$key"
                    return
                else
                    echo "Invalid key length. Use 32 hexadecimal characters."
                fi
                ;;
        esac
    done
}

key_file_to_hex() {
    xxd -p "$1" | tr -d '\n'
}

flatten_output_folder() {
    game_name="$1"
    out_dir="auto_out/$game_name"

    title_dir="$(find "$out_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

    if [ -n "$title_dir" ]; then
        mv "$title_dir"/* "$out_dir/"
        rmdir "$title_dir"
    fi
}

create_common_key() {
    key="$(read_hex_key "Enter Wii U common key: ")"

    echo -n "$key" | xxd -r -p > commonkey/common.key

    echo
    echo "common.key created in commonkey/."
}

create_title_key_file() {
    while true; do
        echo
        read -p "Enter game filename or name, or type 0 to return: " name

        if [ "$name" = "0" ]; then
            break
        fi

        game_name="$name"
        game_name="${game_name%.wud}"
        game_name="${game_name%.wux}"

        key="$(read_hex_key "Enter title key: ")"

        echo -n "$key" | xxd -r -p > "titlekeys/$game_name.key"

        echo "Created: titlekeys/$game_name.key"
    done
}

extract_games() {
    if [ ! -f JWUDTool.jar ]; then
        echo "Error: JWUDTool.jar not found."
        return
    fi

    found=0

    for game_path in auto_in/*.wud auto_in/*.wux; do
        [ -f "$game_path" ] || continue
        found=1

        game_file="$(basename "$game_path")"
        game_name="${game_file%.*}"
        title_key_path_auto="auto_in/$game_name.key"
        title_key_path_saved="titlekeys/$game_name.key"
        out_dir="auto_out/$game_name"

        echo
        echo "Processing: $game_file"

        common_arg=()
        common_entered_manually=0

        if [ -f commonkey/common.key ]; then
            echo "Using common.key from: commonkey/common.key"
            common_hex="$(key_file_to_hex commonkey/common.key)"
            common_arg=(-commonkey "$common_hex")
        else
            common_hex="$(read_hex_key "Enter Wii U common key: ")"
            common_arg=(-commonkey "$common_hex")
            common_entered_manually=1
        fi

        title_arg=()

        if [ -f "$title_key_path_auto" ]; then
            echo "Using title key from: $title_key_path_auto"
            title_hex="$(key_file_to_hex "$title_key_path_auto")"
            title_arg=(-titleKey "$title_hex")
        elif [ -f "$title_key_path_saved" ]; then
            echo "Using title key from: $title_key_path_saved"
            title_hex="$(key_file_to_hex "$title_key_path_saved")"
            title_arg=(-titleKey "$title_hex")
        else
            title_hex="$(read_hex_key "Enter title key for $game_name: ")"
            title_arg=(-titleKey "$title_hex")
        fi

        rm -rf "$out_dir"

        java -jar JWUDTool.jar \
            -in "$game_path" \
            -out "$out_dir" \
            -extract all \
            "${title_arg[@]}" \
            "${common_arg[@]}"

        if [ "$?" -eq 0 ] && [ -d "$out_dir" ]; then
            flatten_output_folder "$game_name"

            echo "Extraction completed: $out_dir"

            if [ "$common_entered_manually" -eq 1 ] && [ ! -f commonkey/common.key ]; then
                echo -n "$common_hex" | xxd -r -p > commonkey/common.key
                echo "Created common.key in commonkey/"
            fi

            rm -f -- "$game_path"
            rm -f -- "auto_in/$game_file"

            if [ ! -f "auto_in/$game_file" ]; then
                echo "Removed input file: $game_file"
            else
                echo "Warning: input file could not be removed: $game_file"
            fi

            if [ -f "$title_key_path_auto" ]; then
                rm -f -- "$title_key_path_auto"

                if [ ! -f "$title_key_path_auto" ]; then
                    echo "Removed input key: $game_name.key"
                else
                    echo "Warning: input key could not be removed: $game_name.key"
                fi
            fi
        else
            echo "Error: extraction failed for $game_file"
            echo "Input file was not removed."
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo
        echo "No .wud or .wux files found in auto_in."
    else
        echo
        echo "Done."
    fi
}

while true; do
    clear

    echo
    echo "wudwux2cdn_android"
    echo
    echo "1) Extract WUD/WUX files"
    echo "2) Create common.key"
    echo "3) Create title key file"
    echo "9) Run first-time setup (required before first use)"
    echo "0) Exit"
    echo

    read -p "Choose what to do: " choice

    case "$choice" in

        1)
            clear
            extract_games
            echo
            read -p "Press Enter to continue..."
            ;;

        2)
            clear
            create_common_key
            echo
            read -p "Press Enter to continue..."
            ;;

        3)
            clear
            create_title_key_file
            echo
            read -p "Press Enter to continue..."
            ;;

        9)
            clear
            bash ./wudwux2cdn_setup.sh
            ;;

        0)
            clear
            exit 0
            ;;

        *)
            echo
            echo "Invalid choice."
            sleep 1
            ;;

    esac
done
