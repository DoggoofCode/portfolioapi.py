#!/bin/bash

# Configuration
SCREEN_NAME="api"
GIT_REPO_DIR="/root/profileholder/saver"   # Change this to your repo path
VENV_DIR="$GIT_REPO_DIR/.venv"       # Change if your venv is somewhere else
PYTHON_MODULE="main:app"            # Adjust to your FastAPI app module

# Function to check if screen session exists
function screen_exists() {
    screen -ls | grep -q "$SCREEN_NAME"
}

# Step 1: Check for existing screen session
if screen_exists; then
    read -p "A screen session '$SCREEN_NAME' is running. Do you want to kill it? [y/N]: " confirm
    case "$confirm" in
        [yY][eE][sS]|[yY])
            echo "Killing existing screen session..."
            screen -S "$SCREEN_NAME" -X quit
            ;;
        *)
            echo "Aborting."
            exit 0
            ;;
    esac
fi

# Step 2: Pull latest code from git
echo "Pulling latest code from git repository..."
cd "$GIT_REPO_DIR" || { echo "Repo path not found: $GIT_REPO_DIR"; exit 1; }
git pull origin main || { echo "Git pull failed"; exit 1; }

# Step 3: Activate Python virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Creating venv..."
    python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"

# Step 4: Install dependencies
pip install --upgrade pip
pip install -r "$GIT_REPO_DIR/requirements.txt"

# Step 5: Start API in a new screen session
echo "Starting API in a new screen session '$SCREEN_NAME'..."
screen -dmS "$SCREEN_NAME" bash -c "uvicorn $PYTHON_MODULE --host 0.0.0.0 --port 8000; exec bash"

echo "API is now running in screen session '$SCREEN_NAME'."
