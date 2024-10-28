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
RED='\033[0;31m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
NC='\033[0m'
error_msg() {
    echo -e "${RED}Error: $1${NC}" >&2
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
sudo nmap -p- --min-rate=10000 -oG ports.txt "$IP" || { error_msg "Nmap scan failed"; exit 1; }
SORTED_PORTS=$(grep -oP '([\d]+)/open' ports.txt | awk -F/ '{print $1}' | tr '\n' ',')
info_msg "Performing detailed scan on ports: $SORTED_PORTS"
sudo nmap -sCV -oA nmap -p "${SORTED_PORTS%,}" "$IP" || { error_msg "Detailed scan failed"; exit 1; }
success_msg "$DIRECTORY deployed. Ready to pwn!"
success_msg "Scan completed. Results saved in nmap.gnmap, nmap.xml, and nmap.txt"
ls
