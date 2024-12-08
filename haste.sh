#!/bin/bash
###########################################################
# by b0llull0s                                            #
###########################################################
echo "      .. ..',..''''','',,,,,,,,,,',,,,'.,,',,,,,,;,,,,,,,,,,,,'.',,'.  ..."
echo "       .   ..'...'.,'''''',,;;;,,,,;,,''.',';,,,;;;;;,,,,,,'......,'.    .."
echo "            .'..'..'',,;,;;;;;;;,;;;,,.';;;',;;;;:;;;;;;;,,...''';,.   ."
echo "             .....'''''''''''''''''''..''''.'''''''''''''''''.....'."
echo "            .,;;:;;::::;,,,'''.'',;;::;;;;::::;,,'',;;;;:::::;;;;;'.    ...."
echo "           .',,,''',,,,','.. .......',''',,,''''.....''',,,,,'',,,'.    ...."
echo "           ....''.....            . .',,','..... .   ........'',,,''.     ."
echo "            ... .                   ..';;;.....                .'''.."
echo "            .                         .........                    ."
echo "         .'.                          ..'......                    ..."
echo "         ',.           ...     ..    .;,,,'.'..              ..     ''"
echo "         .'            ...         .'','''.','.                     ..."
echo "        .',.    ........'.  .    .,;,. ..  .:;,'.       ....        .,'"
echo "        ..''.   ...'.......... ..','.       .''''.   .........      ...."
echo "       .....,,.....'......'....,,,;.         .''',,............    .',.."
echo "      .';,. ..''''''..',;,;,,.'',,'          .......''','........''''..'"
echo "   ....,,''..   ......',''..   .'.             ..........''...'.......''."
echo "   ...',;,,...      ..,,;;'.. .;.              .....,,,'.'.. ......';;;:,...."
echo "       .....          ....,,....                .'.','''..      ...''''.. .."
echo "        ...   . ..       .,,..''                .'.,;,'..    ...  ...,."
echo "               ............;,.,,.       ..      ''',,....  ...'.....'.."
echo "                    .........'''.      .'.     ..''.... ........   .."
echo "                     ...''.';:;;;;'...;:;,'....;':;,','  .;,..                  .."
# Color Definitions
RED='\033[0;31m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
NC='\033[0m'
# Error Tracking
NMAP_ERROR_COUNT=0
# Spinner
spinner() {
    local pid=$1
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local delay=0.1
    local index=0

    while kill -0 $pid 2>/dev/null; do
        printf "\r${PURPLE} ${spin_chars[index]} Casting haste spell...${NC}"
        index=$(( (index + 1) % 10 ))
        sleep $delay
    done
    printf "\r${GREEN} ✔ Spell completed successfully!       ${NC}\n"
}
# Error Handling with Minimalistic Motion Representation
error_msg() {
    ((NMAP_ERROR_COUNT++))
    echo -e "${RED}Error ($NMAP_ERROR_COUNT): $1${NC}" >&2
}

success_msg() {
    echo -e "${GREEN}$1${NC}"
}

info_msg() {
    echo -e "${PURPLE}$1${NC}"
}
## Usage ## 
if [ $# -ne 2 ]; then
    error_msg "Usage: $0 <IP_ADDRESS> <DIRECTORY_NAME>"
    exit 1
fi
## Values ## 
IP="$1"
DIRECTORY="$2"
## Spell ## 
if [ ! -d "$DIRECTORY" ]; then
    mkdir "$DIRECTORY" || { error_msg "Failed to create directory $DIRECTORY"; exit 1; }
fi
cd "$DIRECTORY" || { error_msg "Failed to change into directory $DIRECTORY"; exit 1; }
echo "$IP $DIRECTORY" | sudo tee -a /etc/hosts > /dev/null || { error_msg "Failed to update /etc/hosts"; exit 1; }
info_msg "Haste $IP...!!"
(
    sudo nmap -p- --min-rate=10000 -oG ports.txt "$IP" 2>/dev/null
) & 
spinner $!
SORTED_PORTS=$(grep -oP '([\d]+)/open' ports.txt | awk -F/ '{print $1}' | tr '\n' ',')
info_msg "Performing detailed scan on ports: $SORTED_PORTS"
(
    sudo nmap -sCV -oA nmap -p "${SORTED_PORTS%,}" "$IP" 2>/dev/null
) &
spinner $!
success_msg "$DIRECTORY deployed. Ready to pwn!"
success_msg "Scan completed. Results saved in nmap.gnmap, nmap.xml, and nmap.txt"
ls

# if ((NMAP_ERROR_COUNT > 0)); then
#     echo -e "${RED}Total Nmap Errors Encountered: $NMAP_ERROR_COUNT${NC}"
# fi
