#!/bin/bash

# Directory containing scripts
SCRIPT_DIR="./scripts"

# Function to display the table of contents
display_menu() {
    echo "---------------------------------------------"
    echo " 🚀 Welcome to the Script Selector"
    echo "---------------------------------------------"
    
    # List available scripts dynamically
    local index=1
    for script in "$SCRIPT_DIR"/*.sh; do
        # Get short description from the script header (comment at the top of the file)
        description=$(head -n 1 "$script" | sed 's/#//')  # Read the first line as a description
        echo "$index) $(basename "$script") - $description"
        scripts_list[$index]="$script"  # Store scripts in an array for selection
        ((index++))
    done

    # Exit option
    echo "$index) Exit"
    scripts_list[$index]="exit"
    echo "---------------------------------------------"
}

# Function to execute the selected script
run_script() {
    while true; do
        display_menu

        # Read user choice
        read -p "Select a script to run [1-${#scripts_list[@]}]: " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#scripts_list[@]} ]; then
            selected_script="${scripts_list[$choice]}"

            if [ "$selected_script" == "exit" ]; then
                echo "👋 Exiting. Goodbye!"
                break
            fi

            # Run the selected script
            echo "---------------------------------------------"
            echo "Running $(basename "$selected_script")..."
            echo "---------------------------------------------"
            bash "$selected_script"

            echo "---------------------------------------------"
            echo "✅ Script completed. Returning to the menu..."
            echo "---------------------------------------------"
        else
            echo "❌ Invalid choice. Please select a valid option."
        fi
    done
}

# Run the table of contents
run_script
