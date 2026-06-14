#!/bin/bash

# Exit immediately if any command fails unexpectedly
set -e

# Initialize empty tracking variables for safety
PARENT_DIR=""
INPUT_SUFFIX=""

# --- Process Management & Error Cleanup (Signal Trap) ---
cleanup_and_archive() {
    set +e
    echo -e "\n\n[!] SIGINT (Ctrl+C) caught! Triggering emergency cleanup and archive protocol..."
    
    if [ -n "$PARENT_DIR" ] && [ -d "$PARENT_DIR" ]; then
        ARCHIVE_NAME="attendance_tracker_${INPUT_SUFFIX}_archive.tar.gz"
        echo "[*] Bundling current workspace state into archive: ${ARCHIVE_NAME}..."
        tar -czf "$ARCHIVE_NAME" "$PARENT_DIR" 2>/dev/null
        echo "[*] Purging incomplete workspace directory to prevent clutter..."
        rm -rf "$PARENT_DIR"
    fi
    
    echo "[✔] Cleanup complete. Exiting cleanly."
    exit 1
}

# Bind SIGINT (Ctrl+C) directly to our custom cleanup function
trap cleanup_and_archive SIGINT

# --- Step 1: Prompt and Validate Folder Suffix ---
echo "======================================================================="
echo "        AUTOMATED PROJECT BOOTSTRAPPING ENGINE (PROJECT FACTORY)       "
echo "======================================================================="

read -p "Enter a unique suffix/identifier for your project directory: " INPUT_SUFFIX

# Clean up input: Remove spaces and dangerous terminal characters
INPUT_SUFFIX=$(echo "$INPUT_SUFFIX" | tr -d ' /\\&*|?$<>')

if [ -z "$INPUT_SUFFIX" ]; then
    echo -e "\n[Error] Invalid input. The project suffix cannot be empty."
    exit 1
fi

PARENT_DIR="attendance_tracker_${INPUT_SUFFIX}"

if [ -d "$PARENT_DIR" ]; then
    echo -e "\n[Error] Directory conflict: '$PARENT_DIR' already exists."
    exit 1
fi

# --- Step 2: Prompt and Validate Config Thresholds ---
echo -e "\n--- Configuring Student Attendance Thresholds ---"
read -p "Enter Warning Attendance Threshold (e.g., 75): " WARNING_VAL
read -p "Enter Failure Attendance Threshold (e.g., 50): " FAILURE_VAL

if [[ ! "$WARNING_VAL" =~ ^[0-9]+$ ]] || [[ ! "$FAILURE_VAL" =~ ^[0-9]+$ ]]; then
    echo -e "\n[Error] Configuration rejected: Thresholds must be positive integers."
    exit 1
fi

echo -e "\n[✔] Inputs validated successfully! Ready for file generation."


# --- Step 3: Architecture Generation & Structural Bootstrapping ---
echo -e "\n[*] Initializing infrastructure deployment paths..."
mkdir -p "$PARENT_DIR/Helpers"
mkdir -p "$PARENT_DIR/reports"

echo "[*] Writing application source files and dependencies..."

# 1. Write config.json file
cat << 'EOF' > "$PARENT_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

# 2. Write assets.csv data file
cat << 'EOF' > "$PARENT_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# 3. Create an empty log file
touch "$PARENT_DIR/reports/reports.log"

# 4. Write attendance_checker.py file
cat << 'EOF' > "$PARENT_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF


# --- Step 4: Config Customization via sed Stream Redirection ---
echo "[*] Customizing thresholds inside JSON manifest using stream editors..."

# This updates config.json with the numbers you typed in the prompts
if sed --version >/dev/null 2>&1; then
    sed -i "s/\"warning\": [0-9]*/\"warning\": $WARNING_VAL/" "$PARENT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $FAILURE_VAL/" "$PARENT_DIR/Helpers/config.json"
else
    sed -i "" "s/\"warning\": [0-9]*/\"warning\": $WARNING_VAL/" "$PARENT_DIR/Helpers/config.json"
    sed -i "" "s/\"failure\": [0-9]*/\"failure\": $FAILURE_VAL/" "$PARENT_DIR/Helpers/config.json"
fi


# --- Step 5: Environment Validation (Health Check) ---
echo -e "\n--- Running Environment System Health Check ---"
if command -v python3 &> /dev/null; then
    PY_VERSION=$(python3 --version 2>&1)
    echo "[✔] System Verification Passed: python3 is explicitly installed locally!"
    echo "    Binary Version Signature: $PY_VERSION"
else
    echo "[⚠️ WARNING] System Verification Failed: 'python3' binary not found!"
fi


# --- Step 6: Verify Final Structural Mapping Compliance ---
echo -e "\n======================================================================="
echo "[✔] System Deployment Successful! Target project factory is ready."
echo "======================================================================="
echo "Target Path Location: ./${PARENT_DIR}"
echo -e "Verified Contents Layout:\n"
ls -R "$PARENT_DIR"
echo "======================================================================="