#!/bin/bash
# Usage: sudo ./create_service.sh myservice

# === Check for root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# === Check input ===
if [ -z "$1" ]; then
  echo "Usage: sudo $0 <service_name>"
  exit 1
fi

SERVICE_NAME=$1
PROJECT_DIR=$(pwd)
VENV_DIR="$PROJECT_DIR/venv"

START_SCRIPT="$PROJECT_DIR/start.sh"
UPDATE_SCRIPT="$PROJECT_DIR/update.sh"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# === Create start.sh ===
cat > "$START_SCRIPT" <<EOF
#!/bin/sh
cd "$PROJECT_DIR"
source "$VENV_DIR/bin/activate"
python3 -m app.main
deactivate
EOF

# === Create update.sh ===
cat > "$UPDATE_SCRIPT" <<EOF
#!/bin/sh
cd "$PROJECT_DIR"
git pull
source "$VENV_DIR/bin/activate"
pip install -r requirements.txt
deactivate
systemctl restart ${SERVICE_NAME}.service
EOF

# === Make scripts executable ===
chmod +x "$START_SCRIPT" "$UPDATE_SCRIPT"

# === Create service file ===
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=${SERVICE_NAME}

[Service]
WorkingDirectory=${PROJECT_DIR}
ExecStart=${START_SCRIPT}
Restart=always
User=$(logname)

[Install]
WantedBy=multi-user.target
EOF

# === Reload systemd ===
systemctl daemon-reload

echo "✅ Service '${SERVICE_NAME}' created successfully!"
echo "Start with: sudo systemctl start ${SERVICE_NAME}.service"
echo "Enable on boot: sudo systemctl enable ${SERVICE_NAME}.service"
