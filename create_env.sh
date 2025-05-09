#!/bin/bash

# Script to create Docker volumes and network defined in .env file

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found in the current directory."
    exit 1
fi

# Source the .env file to load variables
source .env

# --- Create Volumes ---

# Check if OLLAMA_VOLUME_NAME is set and create the volume
if [ -z "$OLLAMA_VOLUME_NAME" ]; then
    echo "Warning: OLLAMA_VOLUME_NAME is not set in .env. Skipping Ollama volume creation."
else
    echo "Attempting to create volume: $OLLAMA_VOLUME_NAME"
    # Check if volume already exists
    if docker volume inspect "$OLLAMA_VOLUME_NAME" &>/dev/null; then
        echo "Volume '$OLLAMA_VOLUME_NAME' already exists."
    else
        # Create the volume
        if docker volume create "$OLLAMA_VOLUME_NAME"; then
            echo "Volume '$OLLAMA_VOLUME_NAME' created successfully."
        else
            echo "Error: Failed to create volume '$OLLAMA_VOLUME_NAME'."
            exit 1
        fi
    fi
fi

# Check if OPENWEBUI_VOLUME_NAME is set and create the volume
if [ -z "$OPENWEBUI_VOLUME_NAME" ]; then
    echo "Warning: OPENWEBUI_VOLUME_NAME is not set in .env. Skipping Open WebUI volume creation."
else
    echo "Attempting to create volume: $OPENWEBUI_VOLUME_NAME"
     # Check if volume already exists
    if docker volume inspect "$OPENWEBUI_VOLUME_NAME" &>/dev/null; then
        echo "Volume '$OPENWEBUI_VOLUME_NAME' already exists."
    else
        # Create the volume
        if docker volume create "$OPENWEBUI_VOLUME_NAME"; then
            echo "Volume '$OPENWEBUI_VOLUME_NAME' created successfully."
        else
            echo "Error: Failed to create volume '$OPENWEBUI_VOLUME_NAME'."
            exit 1
        fi
    fi
fi

# --- Optional: Create Network ---
# If you uncommented the network sections in your .env and docker-compose.yml,
# you might also want to create the network using the variable.

if [ -n "$NETWORK_NAME" ]; then
    echo "Attempting to create network: $NETWORK_NAME"
    # Check if network already exists
    if docker network inspect "$NETWORK_NAME" &>/dev/null; then
        echo "Network '$NETWORK_NAME' already exists."
    else
        # Create the network
        if docker network create "$NETWORK_NAME"; then
            echo "Network '$NETWORK_NAME' created successfully."
        else
            echo "Error: Failed to create network '$NETWORK_NAME'."
            exit 1
        fi
    fi
else
    echo "NETWORK_NAME is not set in .env. Skipping network creation."
fi


echo "Environment (volumes & network) creation script finished."
exit 0