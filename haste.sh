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

NMAP_ERROR_COUNT=0

spinner() {
    local pid=$1
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local delay=0.1
    local index=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r${PURPLE} ${spin_chars[index]}${NC}"
        index=$(( (index + 1) % 10 ))
        sleep $delay
    done
    printf "\r${GREEN} ✔ Spell completed successfully! ${NC}\n"
}

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

usage() {
    echo "Usage:"
    echo "  $0 <IP> [HOSTNAME] [-udp] [-full]"
    echo ""
    echo "Options:"
    echo "  IP         Target IP address (required)"
    echo "  HOSTNAME   Optional hostname to add to /etc/hosts"
    echo "  -udp       Perform UDP scan only"
    echo "  -full      Perform full scan (TCP and UDP)"
    exit 1
}

IP=""
HOSTNAME=""
UDP_SCAN=false
FULL_SCAN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -udp)
            UDP_SCAN=true
            shift
            ;;
        -full)
            FULL_SCAN=true
            shift
            ;;
        -*)
            error_msg "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "$IP" ]]; then
                IP="$1"
            elif [[ -z "$HOSTNAME" ]]; then
                HOSTNAME="$1"
            else
                error_msg "Too many arguments"
                usage
            fi
            shift
            ;;
    esac
done

if [[ -z "$IP" ]]; then
    error_msg "IP address is required"
    usage
fi

DIRECTORY="${HOSTNAME:-$IP}"

if [ ! -d "$DIRECTORY" ]; then
    mkdir "$DIRECTORY" || { error_msg "Failed to create directory $DIRECTORY"; exit 1; }
fi

cd "$DIRECTORY" || { error_msg "Failed to change into directory $DIRECTORY"; exit 1; }

if [[ -n "$HOSTNAME" ]]; then
    echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null || { error_msg "Failed to update /etc/hosts"; exit 1; }
fi

info_msg "Haste $IP...!!"

if [[ "$UDP_SCAN" == false ]]; then
    info_msg "Performing TCP port discovery scan"
    ( sudo nmap -p- --min-rate=10000 -oG tcp_ports.txt "$IP" 2>/dev/null ) & spinner $!
    
    SORTED_TCP_PORTS=$(grep -oP '([\d]+)/open' tcp_ports.txt | awk -F/ '{print $1}' | tr '\n' ',')
    
    if [[ -n "$SORTED_TCP_PORTS" ]]; then
        info_msg "Performing detailed TCP service scan on ports: $SORTED_TCP_PORTS"
        ( sudo nmap -sCV -sV \
          -oA nmap_tcp \
          -p "${SORTED_TCP_PORTS%,}" "$IP" 2>/dev/null ) & spinner $!
    fi
fi

if [[ "$UDP_SCAN" == true || "$FULL_SCAN" == true ]]; then
    info_msg "Performing comprehensive UDP port discovery scan"
    ( sudo nmap -sU -p- \
      --min-rate=1000 \
      -oG udp_ports.txt \
      "$IP" 2>/dev/null ) & spinner $!
    
    SORTED_UDP_PORTS=$(grep -oP '([\d]+)/(open|open\|filtered)' udp_ports.txt | awk -F/ '{print $1}' | tr '\n' ',')
    
    if [[ -n "$SORTED_UDP_PORTS" ]]; then
        info_msg "Performing detailed UDP service scan on ports: $SORTED_UDP_PORTS"
        ( sudo nmap -sUCV \
          -p "${SORTED_UDP_PORTS%,}" \
          --max-retries=2 \
          --version-intensity=9 \
          -oA nmap_udp \
          "$IP" 2>/dev/null ) & spinner $!
    else
        info_msg "No open UDP ports discovered. Consider manual enumeration."
    fi
fi

success_msg "$DIRECTORY deployed. Ready to pwn!"
success_msg "Scan completed. Results saved in respective files."
ls
