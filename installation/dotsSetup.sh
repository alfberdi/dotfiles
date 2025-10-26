#!/bin/bash

set -e

# ===========================
# Color-coded status labels
# ===========================
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
WARN="$(tput setaf 3)[WARN]$(tput sgr0)"
OK="$(tput setaf 2)[OK]$(tput sgr0)"
NOTE="$(tput setaf 6)[NOTE]$(tput sgr0)"
ACTION="$(tput setaf 4)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

# =========================
# REPOs
# =========================
REPO_URL="https://github.com/alfberdi/dotfiles.git"

# ======================================
# Paths: Repos, backup
# ======================================
REPO_DIR="$HOME/dotfiles/"
BACKUP_DIR="$HOME/dotfiles_backup"

# ===========================
# Log Details
# ===========================
LOG_FILE="$HOME/dotsSetup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ====================
# Clone dotfiles repo
# ====================
echo -e "${ACTION} Cloning dotfiles into ${REPO_DIR}...${RESET}"

# If repo folder already exists
if [ -d "$REPO_DIR" ]; then
  echo -e "${NOTE} Folder ${REPO_DIR} already exists. Skipping clone.${RESET}"
else
  if git clone "$REPO_URL" "$REPO_DIR" &>>"$LOG_FILE"; then
    echo -e "${OK} Dotfiles cloned successfully to ${REPO_DIR}.${RESET}"
  else
    echo -e "${ERROR} Failed to clone dotfiles repo from ${REPO_URL}.${RESET}"
    exit 1
  fi
fi

# ===========================
# Backup old configs
# ===========================
echo -e "${ACTION} Backing up existing dotfiles to ${BACKUP_DIR}...${RESET}"
# Remove existing backup if it exists
if [ -d "$BACKUP_DIR" ]; then
  echo -e "${ACTION} Existing backup found. Removing old backup...${RESET}"
  rm -rf "$BACKUP_DIR" &>>"$LOG_FILE"
fi
if mkdir -p "$BACKUP_DIR" &>>"$LOG_FILE"; then
  # Copy only if files/folders exist
  [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/" &>>"$LOG_FILE"
  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/" &>>"$LOG_FILE"

  echo -e "${OK} Backup completed and stored in ${BACKUP_DIR}.${RESET}"
else
  echo -e "${ERROR} Failed to create backup directory at ${BACKUP_DIR}.${RESET}"
  exit 1
fi

# ========================================
# Remove old config folders before copying
# ========================================
echo -e "${ACTION} Removing old config folders from ~/.config that are in ${REPO_DIR}...${RESET}"
if [ -d "$REPO_DIR/.config" ]; then
  for folder in "$REPO_DIR/.config/"*; do
    folder_name=$(basename "$folder")
    if [ -d "$HOME/.config/$folder_name" ]; then
      rm -rf "$HOME/.config/$folder_name" &>>"$LOG_FILE"
    fi
  done
  echo -e "${OK} Old config folders removed successfully.${RESET}"
else
  echo -e "${WARN} No .config folder found in ${REPO_DIR}, skipping removal.${RESET}"
fi

# =================
# Copy new dotfiles
# =================
echo -e "${ACTION} Copying new dotfiles...${RESET}"

if [ -d "$REPO_DIR/.config" ]; then
  mkdir -p ~/.config
  {
    cp -r "$REPO_DIR/.config/"* ~/.config/
    cp "$REPO_DIR/.zshrc" ~/
  } >>"$LOG_FILE" 2>&1

  if [ $? -eq 0 ]; then
    echo -e "${OK} dotfiles copied successfully.${RESET}"
  else
    echo -e "${ERROR} Failed to copy one or more dotfiles. Check $LOG_FILE for details.${RESET}"
  fi
else
  echo -e "${ERROR} '$REPO_DIR/.config' does not exist. Dotfiles not copied.${RESET}"
fi

# =================
# Copy new binfiles
# =================
echo -e "${ACTION} Copying new binfiles...${RESET}"

if [ -d "$REPO_DIR/.bin" ]; then
  mkdir -p ~/.bin
  {
    cp -r "$REPO_DIR/.bin/"* ~/.bin/
  } >>"$LOG_FILE" 2>&1

  if [ $? -eq 0 ]; then
    echo -e "${OK} binfiles copied successfully.${RESET}"
  else
    echo -e "${ERROR} Failed to copy one or more binfiles. Check $LOG_FILE for details.${RESET}"
  fi
else
  echo -e "${ERROR} '$REPO_DIR/.bin' does not exist. Binfiles not copied.${RESET}"
fi

echo -e "\n\n${OK} !!======= Setup complete! =========!!${RESET}\n\n"
