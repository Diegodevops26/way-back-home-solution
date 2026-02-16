#!/bin/bash

# --- Function for error handling ---
handle_error() {
  echo -e "\n\n*******************************************************"
  echo "Error: $1"
  echo "*******************************************************"
  exit 1
}

# --- Part 1: Find or Create Google Cloud Project ID ---
PROJECT_FILE="$HOME/project_id.txt"
PROJECT_ID_SET=false

# 0. Check for existing project_id.txt (Optional but helpful)
if [ -s "$PROJECT_FILE" ]; then
    EXISTING_PROJECT_ID=$(cat "$PROJECT_FILE" | tr -d '[:space:]')
    echo "--- Found previously saved project ID: $EXISTING_PROJECT_ID ---"
    if gcloud projects describe "$EXISTING_PROJECT_ID" --quiet >/dev/null 2>&1; then
        echo "Verified '$EXISTING_PROJECT_ID' access."
        FINAL_PROJECT_ID=$EXISTING_PROJECT_ID
        PROJECT_ID_SET=true
        gcloud config set project "$FINAL_PROJECT_ID" 2>/dev/null
    else
        echo "Saved ID '$EXISTING_PROJECT_ID' is invalid or inaccessible. Ignoring."
        rm "$PROJECT_FILE"
    fi
fi

if [ "$PROJECT_ID_SET" = false ]; then
    echo "--- Setup Google Cloud Project ID ---"

    # 1. First try to grab existing active project ID
    ACTIVE_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [ "$ACTIVE_PROJECT_ID" = "(unset)" ]; then ACTIVE_PROJECT_ID=""; fi

    if [ -n "$ACTIVE_PROJECT_ID" ]; then
        echo "Detected currently active project: $ACTIVE_PROJECT_ID"
        if gcloud projects describe "$ACTIVE_PROJECT_ID" --quiet >/dev/null 2>&1; then
            echo "Verified '$ACTIVE_PROJECT_ID' access. Using it."
            FINAL_PROJECT_ID="$ACTIVE_PROJECT_ID"
            PROJECT_ID_SET=true
        else
            echo "Warning: Detected active project '$ACTIVE_PROJECT_ID' but cannot describe it."
            echo "Proceeding to project selection..."
        fi
    fi
fi

# 2. If no project selected yet (User said No or No active project found)
if [ "$PROJECT_ID_SET" = false ]; then
    # Generate a random default ID
    CODELAB_PROJECT_PREFIX="waybackhome"
    PREFIX_LEN=${#CODELAB_PROJECT_PREFIX}
    MAX_SUFFIX_LEN=$(( 30 - PREFIX_LEN - 1 ))
    RANDOM_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c "$MAX_SUFFIX_LEN")
    RANDOM_PROJECT_ID="${CODELAB_PROJECT_PREFIX}-${RANDOM_SUFFIX}"

    while true; do
        echo -e "\nSelect a Project ID:"
        echo "1. Press Enter to CREATE a new project: $RANDOM_PROJECT_ID"
        echo "2. Or type an existing Project ID to use."
        read -p "Project ID: " USER_INPUT
        
        TARGET_ID="${USER_INPUT:-$RANDOM_PROJECT_ID}"
        
        if [[ -z "$TARGET_ID" ]]; then
            echo "Project ID cannot be empty."
            continue
        fi

        echo "Checking status of '$TARGET_ID'..."

        # Check if exists/accessible
        if gcloud projects describe "$TARGET_ID" >/dev/null 2>&1; then
            echo "Project '$TARGET_ID' exists and is accessible."
            FINAL_PROJECT_ID="$TARGET_ID"
            break
        else
            # Try to create it
            echo "Project '$TARGET_ID' not found (or no access). Attempting to create..."
            if gcloud projects create "$TARGET_ID" --quiet; then
                echo "Successfully created '$TARGET_ID'."
                FINAL_PROJECT_ID="$TARGET_ID"
                break
            else
                echo "Failed to create '$TARGET_ID'. Please try a different ID."
                # Loop continues
            fi
        fi
    done
fi

# Final setup with the selected ID
echo -e "\n--- Finalizing Setup for: $FINAL_PROJECT_ID ---"

# Save project ID first to ensure persistence
if [ -n "$FINAL_PROJECT_ID" ]; then
    echo "$FINAL_PROJECT_ID" > "$PROJECT_FILE"
    if [ -f "$PROJECT_FILE" ]; then
        echo "Project ID successfully saved to $PROJECT_FILE"
    else
        echo "Warning: Failed to confirm saving Project ID to $PROJECT_FILE"
    fi
else
    handle_error "Project ID is empty. Cannot save."
fi

gcloud config set project "$FINAL_PROJECT_ID" || handle_error "Failed to set project."

# --- Part 2: Install Dependencies and Run Billing Setup ---
echo -e "\n--- Installing Python dependencies ---"
pip install --upgrade --user google-cloud-billing || handle_error "Failed to install Python libraries."

echo -e "\n--- Running the Billing Enablement Script ---"
python3 billing-enablement.py || handle_error "Billing check failed."

echo -e "\n--- Full Setup Complete ---"
exit 0
