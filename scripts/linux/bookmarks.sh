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
        echo "No bookmarks found. Add using: add <url> [description]"
        return 1
    fi
}

add() {
    local url="$1"
    local description="$2"
    
    if [[ -z "$url" ]]; then
        echo "Usage: add <url> [description]"
        echo "Example: add https://retina.sh \"Retina Docs\""
        echo "Example: add https://github.com"
        return 1
    fi
    
    create_bookmarks_file
    
    # Check if URL already exists
    if grep -q "^url: $url$" "$BOOKMARKS_FILE"; then
        echo "Bookmark already exists: $url"
        return 1
    fi
    
    # Add bookmark in YAML-like format
    echo "url: $url" >> "$BOOKMARKS_FILE"
    if [[ -n "$description" ]]; then
        echo "description: $description" >> "$BOOKMARKS_FILE"
    else
        echo "description: " >> "$BOOKMARKS_FILE"
    fi
    echo "---" >> "$BOOKMARKS_FILE"
    
    if [[ -n "$description" ]]; then
        echo "Added bookmark: $url ($description)"
    else
        echo "Added bookmark: $url"
    fi
}

find() {
    check_bookmarks_file || return 1
    
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed. Please install fzf first."
        return 1
    fi
    
    # Parse bookmarks file and create searchable format
    local temp_file=$(mktemp)
    local current_url=""
    local current_desc=""
    
    while IFS= read -r line; do
        if [[ $line =~ ^url:\ (.+)$ ]]; then
            current_url="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^description:\ (.*)$ ]]; then
            current_desc="${BASH_REMATCH[1]}"
        elif [[ $line == "---" ]]; then
            # Format for display: show description and URL, or just URL if no description
            if [[ -n "$current_desc" ]]; then
                echo "$current_desc | $current_url" >> "$temp_file"
            else
                echo "$current_url" >> "$temp_file"
            fi
            current_url=""
            current_desc=""
        fi
    done < "$BOOKMARKS_FILE"
    
    # Use fzf to select a bookmark (removed --with-nth=1 to show full line)
    local selected_line=$(cat "$temp_file" | fzf --prompt="Search bookmarks: " --height=10 --border --delimiter=' | ')
    
    if [[ -n "$selected_line" ]]; then
        # Extract URL from the selected line
        local selected_url
        if [[ $selected_line == *" | "* ]]; then
            selected_url=$(echo "$selected_line" | sed 's/.* | //')
        else
            selected_url="$selected_line"
        fi
        
        if command -v xclip &> /dev/null; then
            echo -n "$selected_url" | xclip -selection clipboard
            echo "Copied to clipboard: $selected_url"
        else
            echo "No clipboard tool found. Cannot copy to clipboard."
            return 1
        fi
    else
        echo "Nothing selected."
    fi
    
    rm -f "$temp_file"
}

list() {
    check_bookmarks_file || return 1
    
    echo "Bookmarks:"
    local current_url=""
    local current_desc=""
    local count=1
    
    while IFS= read -r line; do
        if [[ $line =~ ^url:\ (.+)$ ]]; then
            current_url="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^description:\ (.*)$ ]]; then
            current_desc="${BASH_REMATCH[1]}"
        elif [[ $line == "---" ]]; then
            if [[ -n "$current_desc" ]]; then
                printf "%3d. %s\n     %s\n" "$count" "$current_desc" "$current_url"
            else
                printf "%3d. %s\n" "$count" "$current_url"
            fi
            ((count++))
            current_url=""
            current_desc=""
        fi
    done < "$BOOKMARKS_FILE"
}

# Function to remove a bookmark
remove() {
    local url="$1"
    
    check_bookmarks_file || return 1

    if [[ -z "$url" ]]; then
        echo "Usage: remove <url>"
        return 1
    fi
    
    # Check if bookmark exists
    if ! grep -q "^url: $url$" "$BOOKMARKS_FILE"; then
        echo "Bookmark not found: $url"
        return 1
    fi
    
    # Create temporary file and remove the bookmark entry
    local temp_file=$(mktemp)
    local skip_lines=0
    
    while IFS= read -r line; do
        if [[ $line =~ ^url:\ (.+)$ ]] && [[ "${BASH_REMATCH[1]}" == "$url" ]]; then
            skip_lines=3  # Skip url, description, and --- lines
        elif [[ $skip_lines -gt 0 ]]; then
            ((skip_lines--))
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$BOOKMARKS_FILE"
    
    mv "$temp_file" "$BOOKMARKS_FILE"
    echo "Removed bookmark: $url"
}

import() {
    local html_file="$1"
    
    if [[ -z "$html_file" ]]; then
        echo "Usage: import <html_file>"
        echo "Example: import ~/Downloads/bookmarks.html"
        return 1
    fi
    
    if [[ ! -f "$html_file" ]]; then
        echo "Error: File not found: $html_file"
        return 1
    fi
    
    create_bookmarks_file
    
    # Check if user wants to append or replace
    if [[ -s "$BOOKMARKS_FILE" ]]; then
        echo "Existing bookmarks found. Do you want to:"
        echo "1) Append to existing bookmarks"
        echo "2) Replace existing bookmarks"
        read -p "Choose (1/2): " choice
        
        case "$choice" in
            "2")
                > "$BOOKMARKS_FILE"  # Clear the file
                echo "Cleared existing bookmarks."
                ;;
            "1"|"")
                echo "Appending to existing bookmarks."
                ;;
            *)
                echo "Invalid choice. Cancelling import."
                return 1
                ;;
        esac
    fi
    
    local count=0
    local temp_file=$(mktemp)
    local links_file=$(mktemp)
    
    # Extract URLs and descriptions from HTML
    # This regex looks for <A HREF="url">description</A> patterns
    grep -oP '<A HREF="[^"]*"[^>]*>[^<]*</A>' "$html_file" > "$links_file"
    
    # Process each line from the file instead of pipeline
    while IFS= read -r line; do
        # Extract URL
        local url=$(echo "$line" | sed -n 's/.*HREF="\([^"]*\)".*/\1/p')
        # Extract description (text between > and </A>)
        local description=$(echo "$line" | sed -n 's/.*>\([^<]*\)<\/A>.*/\1/p')
        
        # Skip if URL is empty or already exists
        if [[ -n "$url" ]] && ! grep -q "^url: $url$" "$BOOKMARKS_FILE"; then
            echo "url: $url" >> "$temp_file"
            if [[ -n "$description" ]]; then
                echo "description: $description" >> "$temp_file"
            else
                echo "description: " >> "$temp_file"
            fi
            echo "---" >> "$temp_file"
            ((count++))
        fi
    done < "$links_file"
    
    # Append the temporary file to bookmarks
    if [[ -s "$temp_file" ]]; then
        cat "$temp_file" >> "$BOOKMARKS_FILE"
        echo "Imported $count bookmarks from $html_file"
    else
        echo "No new bookmarks found to import."
    fi
    
    rm -f "$temp_file" "$links_file"
}

help() {
    echo "Usage:"
    echo " [ba] add <url> [description]  - Add a new bookmark"
    echo " [bf] find                     - Fuzzy find and copy bookmark to clipboard"
    echo " [bl] list                     - List all bookmarks"
    echo " [br] remove <url>             - Remove a bookmark"
    echo " [bi] import <html_file>       - Import bookmarks from HTML file"
    echo " [bh] help                     - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 add https://retina.sh \"Retina Docs\""
    echo "  $0 add https://github.com"
    echo "  $0 find"
    echo "  $0 remove https://retina.sh"
    echo "  $0 import ~/Downloads/bookmarks.html"
}

# Main script logic
case "$1" in
    "add")
        add "$2" "$3"
        ;;
    "find")
        find
        ;;
    "list")
        list
        ;;
    "remove")
        remove "$2"
        ;;
    "import")
        import "$2"
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