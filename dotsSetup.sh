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
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# =========================
# REPOs
# =========================
REPO_URL="https://github.com/alfberdi/dotfiles.git"

# ======================================
# Paths: Repos, Waybar, nvim, Sddm, Grub
# ======================================
REPO_DIR="$HOME/dotfiles/"
BACKUP_DIR="$HOME/dotfiles_backup"
# Waybar Paths
WAYBAR_STYLE_TARGET="$HOME/.config/waybar/style.css"
WAYBAR_LAYOUT_TARGET="$HOME/.config/waybar/config"
CUSTOM_WAYBAR_STYLE="$HOME/.config/waybar/style/Catppuccin Mocha Custom.css"
CUSTOM_WAYBAR_LAYOUT="$HOME/.config/waybar/configs/[TOP] Default Laptop"
# PWA(Desktop Apps)
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/apps"
BROWSER="firefox"


# ===========================
# Log Details
# ===========================
mkdir -p "$HOME/installer_log"
LOG_FILE="$HOME/installer_log/boot_file.log"

# =============================
# Packages list
# =============================

# Mandatory packages
REQUIRED_PACKAGES=(kitty lsd bat firefox zoxide walker)
YAY_REQUIRED_PACKAGES=()
# Pacman Packages (Optional)
PACMAN_PACKAGES=(
  kitty lsd bat firefox zoxide vlc hyprpicker
  ttf-noto-nerd noto-fonts noto-fonts-emoji
  hypridle hyprlock hyprsunset hyprsunset hyprland
  localsend
)
# Yay Packages (Optional)
YAY_PACKAGES=(
  visual-studio-code-bin walker
)

# ===========================
# Log Details
# ===========================
LOG_FILE="$HOME/dotsSetup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ================================
# Ask for sudo once, keep it alive
# ================================
echo "${NOTE} Asking for sudo password^^...${RESET}"
sudo -v
keep_sudo_alive() {
  while true; do
    sudo -n true
    sleep 30
  done
}
keep_sudo_alive &
SUDO_KEEP_ALIVE_PID=$!

trap 'kill $SUDO_KEEP_ALIVE_PID' EXIT

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

# =================
# Required Packages
# =================
echo -e "${ACTION} Installing required packages...${RESET}" | tee -a "$LOG_FILE"
# Print package list with header in blue and packages in default color
echo -e "\n\033[1;34mRequired Packages:\033[0m\n" | tee -a "$LOG_FILE"
for pkg in "${REQUIRED_PACKAGES[@]}"; do
  echo -e "  • $pkg" | tee -a "$LOG_FILE"
done
echo | tee -a "$LOG_FILE"
echo -e "${ACTION} Packages Installing in Progress...${RESET}" | tee -a "$LOG_FILE"
# Enable pipefail so pacman failure is detected even with tee
set -o pipefail
MAX_RETRIES=5
COUNT=0
SUCCESS=0
# Start with all required packages as missing
MISSING_PKGS=("${REQUIRED_PACKAGES[@]}")
until [ $COUNT -ge $MAX_RETRIES ]; do
  if script -qfc "sudo pacman -Sy --noconfirm --needed ${MISSING_PKGS[*]}" /dev/null | tee -a "$LOG_FILE"; then
    # Re-check what’s still missing
    NEW_MISSING=()
    for pkg in "${MISSING_PKGS[@]}"; do
      if ! pacman -Qi "$pkg" &>/dev/null; then
        NEW_MISSING+=("$pkg")
      fi
    done
    if [ ${#NEW_MISSING[@]} -eq 0 ]; then
      SUCCESS=1
      break
    else
      MISSING_PKGS=("${NEW_MISSING[@]}")
    fi
  fi
  COUNT=$((COUNT + 1))
  echo -e "${ERROR} Some packages failed to install. Retry $COUNT/$MAX_RETRIES in 5s...${RESET}" | tee -a "$LOG_FILE"
  sleep 5
done
set +o pipefail
if [ $SUCCESS -eq 1 ]; then
  echo -e "${OK} All required packages installed successfully.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to install packages after $MAX_RETRIES attempts: ${MISSING_PKGS[*]}${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# =================
# Required AUR Packages (yay)
# =================

echo -e "${ACTION} Installing required AUR packages with yay...${RESET}" | tee -a "$LOG_FILE"

# Print package list with header in blue and packages in default color
echo -e "\n\033[1;34mAUR Packages:\033[0m\n" | tee -a "$LOG_FILE"
for pkg in "${YAY_REQUIRED_PACKAGES[@]}"; do
  echo -e "  • $pkg" | tee -a "$LOG_FILE"
done
echo | tee -a "$LOG_FILE"

echo -e "${ACTION} Packages Installing in Progress...${RESET}" | tee -a "$LOG_FILE"

# Enable pipefail so yay failure is detected even with tee
set -o pipefail
MAX_RETRIES=5
COUNT=0
SUCCESS=0

# Start with all required packages as missing
MISSING_PKGS=("${YAY_REQUIRED_PACKAGES[@]}")

until [ $COUNT -ge $MAX_RETRIES ]; do
  if yay -Sy --noconfirm --needed ${MISSING_PKGS[*]} | tee -a "$LOG_FILE"; then
    # Re-check what’s still missing
    NEW_MISSING=()
    for pkg in "${MISSING_PKGS[@]}"; do
      if ! pacman -Qi "$pkg" &>/dev/null; then
        NEW_MISSING+=("$pkg")
      fi
    done
    if [ ${#NEW_MISSING[@]} -eq 0 ]; then
      SUCCESS=1
      break
    else
      MISSING_PKGS=("${NEW_MISSING[@]}")
    fi
  fi
  COUNT=$((COUNT + 1))
  echo -e "${ERROR} Some AUR packages failed to install. Retry $COUNT/$MAX_RETRIES in 5s...${RESET}" | tee -a "$LOG_FILE"
  sleep 5
done

set +o pipefail

if [ $SUCCESS -eq 1 ]; then
  echo -e "${OK} All AUR packages installed successfully with yay.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to install AUR packages after $MAX_RETRIES attempts: ${MISSING_PKGS[*]}${RESET}" | tee -a "$LOG_FILE"
  exit 1
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

# =============================
# Waybar style
# =============================
echo -e "${ACTION} Linking custom Waybar style...${RESET}"

if [ -f "$CUSTOM_WAYBAR_STYLE" ]; then
  ln -sf "$CUSTOM_WAYBAR_LAYOUT" "$WAYBAR_LAYOUT_TARGET" &>>"$LOG_FILE"
  ln -sf "$CUSTOM_WAYBAR_STYLE" "$WAYBAR_STYLE_TARGET" &>>"$LOG_FILE"

  if pgrep -x "waybar" &>/dev/null; then
    pkill -SIGUSR2 waybar &>>"$LOG_FILE"
    echo -e "${OK} Waybar style applied and reloaded.${RESET}"
  else
    echo -e "${WARN} Waybar not running. Style will apply on next launch.${RESET}"
  fi
else
  echo -e "${WARN} Custom Waybar style not found at ${CUSTOM_WAYBAR_STYLE}, skipping.${RESET}"
fi

# ==============================
# Ask to install pacman packages
# ==============================
echo -e "\n${ACTION} Do you want to install the following pacman packages?${RESET}"

# Print package list with header in blue and packages in default color
echo -e "\n\033[1;34mPacman Packages (Optional):\033[0m\n" | tee -a "$LOG_FILE"
for pkg in "${PACMAN_PACKAGES[@]}"; do
  echo -e "  • $pkg" | tee -a "$LOG_FILE"
done
echo | tee -a "$LOG_FILE"

# Keep asking until valid input
while true; do
  read -rp "Type 'yes' or 'no' to continue: " ans1
  case "${ans1,,}" in # convert input to lowercase
  yes | y)
    echo -e "${ACTION} Installing pacman packages...${RESET}" | tee -a "$LOG_FILE"
    echo -e "${NOTE} Installing packages in progress...${RESET}" | tee -a "$LOG_FILE"

    # Retry logic
    MAX_RETRIES=3
    RETRY_DELAY=5
    count=0
    while [ $count -lt $MAX_RETRIES ]; do
      if sudo pacman -Sy --needed --noconfirm "${PACMAN_PACKAGES[@]}" | tee -a "$LOG_FILE"; then
        echo -e "${OK} Pacman packages installed successfully.${RESET}" | tee -a "$LOG_FILE"
        break
      else
        count=$((count + 1))
        echo -e "${WARN} Installation failed. Retry $count of $MAX_RETRIES in $RETRY_DELAY seconds...${RESET}" | tee -a "$LOG_FILE"
        sleep $RETRY_DELAY
      fi
    done

    if [ $count -eq $MAX_RETRIES ]; then
      echo -e "${ERROR} Failed to install pacman packages after $MAX_RETRIES attempts. See $LOG_FILE for details.${RESET}" | tee -a "$LOG_FILE"
      exit 1
    fi

    break
    ;;
  no | n)
    echo -e "${NOTE} Skipped installing pacman packages.${RESET}" | tee -a "$LOG_FILE"
    break
    ;;
  *)
    echo -e "${ERROR} Invalid input. Please type 'yes' or 'no'.${RESET}"
    ;;
  esac
done

# ============================
# Ask to install yay packages
# ============================

if command -v yay >/dev/null 2>&1; then
  echo -e "\n${ACTION} Do you want to install the following AUR (yay) packages?${RESET}"
  echo -e "\n\033[1;34mYay Packages:\033[0m\n" | tee -a "$LOG_FILE"
  for pkg in "${YAY_PACKAGES[@]}"; do
    echo -e "  • $pkg" | tee -a "$LOG_FILE"
  done
  echo | tee -a "$LOG_FILE"
  while true; do
    read -rp "Type 'yes' or 'no' to continue: " ans2
    case "${ans2,,}" in # convert input to lowercase
    yes | y)
      echo -e "${ACTION} Installing AUR packages...${RESET}" | tee -a "$LOG_FILE"
      echo -e "${NOTE} Installing packages in progress...${RESET}" | tee -a "$LOG_FILE"
      MAX_RETRIES=5
      RETRY_DELAY=5
      count=0
      while [ $count -lt $MAX_RETRIES ]; do
        if yay -S --needed --noconfirm --mflags "--skippgpcheck" "${YAY_PACKAGES[@]}" | tee -a "$LOG_FILE"; then
          echo -e "${OK} AUR packages installed successfully.${RESET}" | tee -a "$LOG_FILE"
          break
        else
          count=$((count + 1))
          echo -e "${WARN} Installation failed. Retry $count of $MAX_RETRIES in $RETRY_DELAY seconds...${RESET}" | tee -a "$LOG_FILE"
          sleep $RETRY_DELAY
        fi
      done
      if [ $count -eq $MAX_RETRIES ]; then
        echo -e "${ERROR} Failed to install AUR packages after $MAX_RETRIES attempts. See $LOG_FILE for details.${RESET}" | tee -a "$LOG_FILE"
        exit 1
      fi
      break
      ;;
    no | n)
      echo -e "${NOTE} Skipped installing AUR packages.${RESET}" | tee -a "$LOG_FILE"
      break
      ;;
    *)
      echo -e "${ERROR} Invalid input. Please type 'yes' or 'no'.${RESET}"
      ;;
    esac
  done
else
  echo -e "${WARN} yay is not installed. Skipping AUR packages.${RESET}" | tee -a "$LOG_FILE"
fi

echo -e "\n\n${OK} !!======= Dotfiles setup complete! =========!!${RESET}\n\n"
