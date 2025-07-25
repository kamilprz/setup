#!/bin/bash

BOOKMARKS_FILE="$HOME/.bookmarks"

# Create bookmarks file if it doesn't exist
create_bookmarks_file() {
    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        touch "$BOOKMARKS_FILE"
        echo "Created bookmarks file at $BOOKMARKS_FILE"
    fi
}

check_bookmarks_file() {
    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        echo "No bookmarks file at $BOOKMARKS_FILE"
        return 1
    fi

    if [[ ! -s "$BOOKMARKS_FILE" ]]; then
        echo "No bookmarks found. Add using: add <url>"
        return 1
    fi
}

add() {
    local bookmark="$1"
    
    if [[ -z "$bookmark" ]]; then
        echo "Usage: add <bookmark>"
        echo "Example: add https://github.com"
        return 1
    fi
    
    create_bookmarks_file
    
    if grep -Fxq "$bookmark" "$BOOKMARKS_FILE"; then
        echo "Bookmark already exists: $bookmark"
        return 1
    fi
    
    echo "$bookmark" >> "$BOOKMARKS_FILE"
    echo "Added bookmark: $bookmark"
}

find() {
    check_bookmarks_file || return 1
    
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed. Please install fzf first."
        return 1
    fi
    
    # Use fzf to select a bookmark
    local selected_bookmark=$(cat "$BOOKMARKS_FILE" | fzf --prompt="Search: " --height=10 --border)
    
    if [[ -n "$selected_bookmark" ]]; then
        if command -v xclip &> /dev/null; then
            echo -n "$selected_bookmark" | xclip -selection clipboard
            echo "Copied to clipboard: $selected_bookmark"
        else
            echo "No clipboard tool found. Cannot copy to clipboard."
            return 1
        fi
    else
        echo "Nothing selected."
    fi
}

# Function to remove a bookmark
remove() {
    local bookmark="$1"
    
    check_bookmarks_file || return 1

    if [[ -z "$bookmark" ]]; then
        echo "Usage: remove <bookmark>"
        return 1
    fi
    
    if grep -Fxq "$bookmark" "$BOOKMARKS_FILE"; then
        # Create temporary file and remove the bookmark
        grep -Fxv "$bookmark" "$BOOKMARKS_FILE" > "${BOOKMARKS_FILE}.tmp"
        mv "${BOOKMARKS_FILE}.tmp" "$BOOKMARKS_FILE"
        echo "Removed bookmark: $bookmark"
    else
        echo "Bookmark not found: $bookmark"
        return 1
    fi
}

help() {
    echo "Usage:"
    echo " [ba] add <bookmark>       - Add a new bookmark"
    echo " [bf] find                 - Fuzzy find and copy bookmark to clipboard"
    echo " [br] remove <bookmark>    - Remove a bookmark"
    echo " [bh] help                 - Show this help"
    echo ""
}

# Main script logic
case "$1" in
    "add")
        add "$2"
        ;;
    "find")
        find
        ;;
    "remove")
        remove "$2"
        ;;
    "help"|"--help"|"-h")
        help
        ;;
    "")
        help
        ;;
    *)
        echo "Unknown command: $1"
        help
        exit 1
        ;;
esac