#!/bin/bash

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
CYAN="\e[1;36m"
PURPLE="\e[1;35m"
WHITE="\e[1;37m"
ENDCOLOR="\e[0m"

loading_animation() {
    local duration=$1
    local message=$2
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    local end_time=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end_time ]; do
        printf "\r${CYAN}${message} ${chars:$i:1}${ENDCOLOR}"
        i=$(( (i + 1) % ${#chars} ))
        sleep 0.1
    done
    printf "\r${GREEN}${message} ✓${ENDCOLOR}\n"
}

show_banner() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════════╗${EENDCOLO}"
    echo -e "${PURPLE}║                                            ║${ENDCOLOR}"
    echo -e "${PURPLE}║         ${WHITE}ARUNIKA PROXY INSTALLER   ${PURPLE}         ║${ENDCOLOR}"
    echo -e "${PURPLE}║                                            ║${ENDCOLOR}"
    echo -e "${PURPLE}║      ${CYAN}Growtopia Proxy for Android${PURPLE}           ║${ENDCOLOR}"
    echo -e "${PURPLE}║                                            ║${ENDCOLOR}"
    echo -e "${PURPLE}╚════════════════════════════════════════════╝${ENDCOLOR}"
    echo
}

check_package_updates() {
    echo -e "${BLUE}📦 Checking for package updates...${ENDCOLOR}"
    
    if [ -f "$PREFIX/var/lib/dpkg/status" ]; then
        last_update=$(stat -c %Y "$PREFIX/var/lib/dpkg/status" 2>/dev/null || echo 0)
        current_time=$(date +%s)
        time_diff=$((current_time - last_update))
        hours_since_update=$((time_diff / 3600))
        
        if [ $hours_since_update -lt 24 ]; then
            echo -e "${GREEN}✓ Package list is fresh (updated ${hours_since_update}h ago)${ENDCOLOR}"
            return 0
        else
            echo -e "${YELLOW}⚠ Package list is ${hours_since_update}h old, updating...${ENDCOLOR}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Unable to check update status, proceeding with update...${ENDCOLOR}"
        return 1
    fi
}

install_packages() {
    local packages=("openssl" "curl" "libenet" "wget")
    local missing_packages=()
    
    echo -e "${BLUE}🔍 Checking required packages...${ENDCOLOR}"
    
    for package in "${packages[@]}"; do
        if ! dpkg -s "$package" >/dev/null 2>&1; then
            missing_packages+=("$package")
            echo -e "${YELLOW}  ⚠ $package - ${RED}Not installed${ENDCOLOR}"
        else
            echo -e "${GREEN}  ✓ $package - ${GREEN}Already installed${ENDCOLOR}"
        fi
    done
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ All required packages are already installed!${ENDCOLOR}"
        sleep 1
    else
        echo -e "${CYAN}📥 Installing missing packages: ${missing_packages[*]}${ENDCOLOR}"
        pkg install -y "${missing_packages[@]}"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ All packages installed successfully!${ENDCOLOR}"
        else
            echo -e "${RED}✗ Failed to install some packages${ENDCOLOR}"
            exit 1
        fi
    fi
}

download_proxy() {
    local primary_url="https://github.com/AmertaByte/Arunika-Proxy/raw/main/arunika"
    local fallback_url="https://fairuko.arunika.my.id/proxy/arunika"
    
    echo -e "${BLUE}⬇️  Downloading Arunika Proxy...${ENDCOLOR}"
    
    echo -e "${CYAN}📡 Trying primary source (GitHub)...${ENDCOLOR}"
    if wget -q --show-progress --progress=bar:force --timeout=30 --tries=2 "$primary_url" 2>/dev/null; then
        echo
        echo -e "${GREEN}✓ Downloaded successfully from GitHub!${ENDCOLOR}"
        return 0
    else
        echo
        echo -e "${YELLOW}⚠ GitHub download failed or timeout${ENDCOLOR}"
        echo -e "${BLUE}🔄 Switching to backup server...${ENDCOLOR}"
        
        rm -f arunika 2>/dev/null
        
        echo -e "${CYAN}📡 Trying backup source...${ENDCOLOR}"
        if wget -q --show-progress --progress=bar:force --timeout=30 --tries=3 "$fallback_url" 2>/dev/null; then
            echo
            echo -e "${GREEN}✓ Downloaded successfully from backup server!${ENDCOLOR}"
            return 0
        else
            echo
            echo -e "${RED}❌ All download sources failed${ENDCOLOR}"
            echo -e "${RED}   Please check your internet connection${ENDCOLOR}"
            echo -e "${YELLOW}💡 Troubleshooting tips:${ENDCOLOR}"
            echo -e "${WHITE}   • Try using VPN if GitHub is blocked${ENDCOLOR}"
            echo -e "${WHITE}   • Check your internet connection${ENDCOLOR}"
            echo -e "${WHITE}   • Try again later${ENDCOLOR}"
            return 1
        fi
    fi
}

main() {
    show_banner
    
    echo -e "${BLUE}🔧 Checking device architecture...${ENDCOLOR}"
    bito=$(getprop ro.product.cpu.abi)
    
    if [[ "$bito" != "arm64-v8a" && "$bito" != "x86_64" ]]; then
        echo -e "${RED}❌ Sorry, your device is 32-bit (${bito})${ENDCOLOR}"
        echo -e "${RED}   The proxy does not support 32-bit devices.${ENDCOLOR}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Architecture: ${bito} (Compatible)${ENDCOLOR}"
    sleep 1
    
    if [ -f "arunika" ]; then
        echo -e "${YELLOW}📁 Found existing proxy file${ENDCOLOR}"
        echo -e "${BLUE}🗑️  Removing old version...${ENDCOLOR}"
        rm -f arunika
        loading_animation 2 "Cleaning up"
    fi
    
    if check_package_updates; then
        echo -e "${CYAN}⏭️  Skipping package list update${ENDCOLOR}"
    else
        loading_animation 3 "Updating package lists"
        pkg update -y >/dev/null 2>&1
        loading_animation 2 "Upgrading packages"
        pkg upgrade -y >/dev/null 2>&1
    fi
    
    install_packages
    
    echo
    
    if download_proxy; then
        loading_animation 2 "Verifying download"
        
        if [ -f "arunika" ] && [ -s "arunika" ]; then
            chmod +x arunika
            echo -e "${GREEN}✅ Proxy installed successfully!${ENDCOLOR}"
            echo
            echo -e "${PURPLE}╔═══════════════════════════════════════════╗${ENDCOLOR}"
            echo -e "${PURPLE}║                                           ║${ENDCOLOR}"
            echo -e "${PURPLE}║           ${GREEN}INSTALLATION COMPLETE${PURPLE}           ║${ENDCOLOR}"
            echo -e "${PURPLE}║                                           ║${ENDCOLOR}"
            echo -e "${PURPLE}║  ${WHITE}Execute proxy with: ${CYAN}./arunika${PURPLE}          ║${ENDCOLOR}"
            echo -e "${PURPLE}║                                           ║${ENDCOLOR}"
            echo -e "${PURPLE}╚═══════════════════════════════════════════╝${ENDCOLOR}"
            echo
        else
            echo -e "${RED}❌ Download verification failed${ENDCOLOR}"
            echo -e "${RED}   Downloaded file is empty or corrupted${ENDCOLOR}"
            exit 1
        fi
    else
        exit 1
    fi
}

main
