#!/bin/bash

set -e

LAB_DIR="$HOME/AI-DFIR-Lab"

echo "==================================="
echo " AI-DFIR Lab Automated Installer"
echo "==================================="

echo "[1/7] Installing Docker and Docker Compose..."
sudo apt update
sudo apt install -y docker.io docker-compose

echo "[2/7] Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[3/7] Creating AI-DFIR lab folders..."
mkdir -p "$LAB_DIR"/evidence/{authentication,powershell,ioc,phishing,persistence,sysmon,timeline,reports}
mkdir -p "$LAB_DIR"/{workflows,reports,backups}

echo "[4/7] Creating docker-compose.yml..."
cat > "$LAB_DIR/docker-compose.yml" << 'EOF'
version: "3.8"

services:
  postgres:
    image: postgres:16
    container_name: ai-dfir-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: n8npassword
      POSTGRES_DB: n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n:
    image: n8nio/n8n:latest
    container_name: ai-dfir-n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: n8npassword
      N8N_HOST: localhost
      N8N_PORT: 5678
      N8N_PROTOCOL: http
      GENERIC_TIMEZONE: Asia/Manila
    volumes:
      - n8n_data:/home/node/.n8n
      - ./evidence:/home/node/.n8n-files
    depends_on:
      - postgres

volumes:
  postgres_data:
  n8n_data:
EOF

echo "[5/7] Starting AI-DFIR platform..."
cd "$LAB_DIR"
sudo docker-compose up -d

echo "[6/7] Waiting for containers..."
sleep 15

echo "[7/7] Current container status:"
sudo docker ps

echo ""
echo "==================================="
echo " AI-DFIR Lab Install Complete"
echo "==================================="
echo "n8n URL: http://localhost:5678"
echo "Lab Folder: $LAB_DIR"
echo "Evidence Folder: $LAB_DIR/evidence"
echo ""