#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p auto_in
mkdir -p auto_out
mkdir -p commonkey
mkdir -p titlekeys

find_common_key() {
    if [ -f commonkey/common.key ]; then
        common_key_path="commonkey/common.key"
    elif [ -f titlekeys/common.key ]; then
        common_key_path="titlekeys/common.key"
    elif [ -f auto_in/common.key ]; then
        common_key_path="auto_in/common.key"
    elif [ -f common.key ]; then
        common_key_path="common.key"
    else
        common_key_path=""
    fi
}

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

create_common_key() {
    key="$(read_hex_key "Enter Wii U common key: ")"

    echo -n "$key" | xxd -r -p > commonkey/common.key

    echo "common.key created in commonkey/."
}

create_title_key_files() {
    while true; do
        echo ""
        read -p "Enter game filename or name, or type 0 to return: " name

        if [ "$name" = "0" ]; then
            break
        fi

        base="$name"
        base="${base%.wud}"
        base="${base%.wux}"

        key="$(read_hex_key "Enter title key: ")"

        echo -n "$key" | xxd -r -p > "titlekeys/$base.key"

        echo "Created: titlekeys/$base.key"
    done
}

extract_games() {
    if [ ! -f JWUDTool.jar ]; then
        echo "Error: JWUDTool.jar not found."
        return
    fi

    found=0

    for game in auto_in/*.wud auto_in/*.wux; do
        [ -f "$game" ] || continue
        found=1

        filename="$(basename "$game")"
        base="${filename%.*}"

        echo ""
        echo "Processing: $filename"

        find_common_key

        common_arg=()
        common_from_file=0
        common_entered_manually=0

        if [ -n "$common_key_path" ]; then
            echo "Using common.key from: $common_key_path"
            common_hex="$(key_file_to_hex "$common_key_path")"
            common_arg=(-commonkey "$common_hex")
            common_from_file=1
        else
            common_hex="$(read_hex_key "Enter Wii U common key: ")"
            common_arg=(-commonkey "$common_hex")
            common_entered_manually=1
        fi

        title_arg=()
        title_key_path=""

        if [ -f "titlekeys/$base.key" ]; then
            title_key_path="titlekeys/$base.key"
            echo "Using title key from: $title_key_path"
            title_hex="$(key_file_to_hex "$title_key_path")"
            title_arg=(-titleKey "$title_hex")
        elif [ -f "auto_in/$base.key" ]; then
            title_key_path="auto_in/$base.key"
            echo "Using title key from: $title_key_path"
            title_hex="$(key_file_to_hex "$title_key_path")"
            title_arg=(-titleKey "$title_hex")
        else
            title_hex="$(read_hex_key "Enter title key for $base: ")"
            title_arg=(-titleKey "$title_hex")
        fi

        out_dir="auto_out/$base"

        java -jar JWUDTool.jar \
            -in "$game" \
            -out "$out_dir" \
            -extract all \
            "${title_arg[@]}" \
            "${common_arg[@]}"

        if [ "$?" -eq 0 ] && [ -d "$out_dir" ]; then
            echo "Extraction completed: $out_dir"

            if [ "$common_entered_manually" -eq 1 ] && [ ! -f commonkey/common.key ]; then
                echo -n "$common_hex" | xxd -r -p > commonkey/common.key
                echo "Created common.key in commonkey/"
            fi

            rm -f "$game"
            echo "Removed input file: $filename"

            if [ -n "$title_key_path" ] && [ "$title_key_path" = "auto_in/$base.key" ]; then
                mv "$title_key_path" "titlekeys/$base.key"
                echo "Moved $base.key to titlekeys/"
            fi

            if [ "$common_from_file" -eq 1 ]; then
                if [ "$common_key_path" = "auto_in/common.key" ] || [ "$common_key_path" = "common.key" ] || [ "$common_key_path" = "titlekeys/common.key" ]; then
                    if [ ! -f commonkey/common.key ]; then
                        mv "$common_key_path" commonkey/common.key
                        echo "Moved common.key to commonkey/"
                    fi
                fi
            fi
        else
            echo "Error: extraction failed for $filename"
            echo "Input file was not removed."
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo ""
        echo "No .wud or .wux files found in auto_in."
    else
        echo ""
        echo "Done."
    fi
}

while true; do
    echo ""
    echo "wudwux2cdn_android"
    echo ""
    echo "1) Extract WUD/WUX files"
    echo "2) Create common.key"
    echo "3) Create title key file"
    echo "9) Run first-time setup (required before first use)"
    echo "0) Exit"
    echo ""

    read -p "Choose what to do: " choice

    case "$choice" in

        1)
            extract_games
            ;;

        2)
            create_common_key
            ;;

        3)
            create_title_key_files
            ;;

        9)
            bash ./wudwux2cdn_setup.sh
            ;;

        0)
            echo "Exit."
            exit 0
            ;;

        *)
            echo "Invalid choice."
            ;;

    esac
done