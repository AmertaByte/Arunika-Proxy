RED="\e[1;31m"
GREEN="\e[1;32m"
ENDCOLOR="\e[0m"

clear
echo -e "${GREEN}Installing Proxy...${ENDCOLOR}"
sleep 1
if [ -f "proxy_linux" ]; then
    echo -e "${RED}Deleting old proxy...${ENDCOLOR}"
    rm proxy_linux
    sleep 1
    echo -e "${GREEN}Updating proxy...${ENDCOLOR}"
fi
wget -q https://github.com/AmertaByte/arunika/raw/main/proxy_linux
sleep 1
echo -e "${GREEN}Proxy Installed${ENDCOLOR}"
echo -e "${GREEN}Executing Proxy...${ENDCOLOR}"
sleep 5
chmod +x proxy_linux
./proxy_linux