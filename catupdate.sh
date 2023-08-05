RED="\e[1;31m"
GREEN="\e[1;32m"
ENDCOLOR="\e[0m"

clear
echo -e "${GREEN}Updating Proxy...${ENDCOLOR}"
sleep 1
if [ -f "arunika" ]; then
    echo -e "${RED}Deleting old proxy...${ENDCOLOR}"
    rm arunika
    sleep 1
    echo -e "${GREEN}Updating proxy...${ENDCOLOR}"
fi
echo -e "${RED}Checking Termux Installer..."
pkg update
pkg upgrade
pkg install wget
pkg install openssl
pkg install curl
pkg install libenet
wget -q https://github.com/AmertaByte/Arunika-Proxy/raw/main/arunika
sleep 1
echo -e "${GREEN}Proxy Installed${ENDCOLOR}"
sleep 1
echo -e "${GREEN}Executing Proxy...${ENDCOLOR}"
sleep 5
chmod +x arunika
./arunika
