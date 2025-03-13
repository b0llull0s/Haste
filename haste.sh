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
NO_DIR=false
STEALTH_MODE=false

skull_spinner() {
    local pid=$1
    local skulls=('󰚌' '󰯈')
    local max_items=25  
    local delay=0.1
    local status=0
    local bar=""
    
    while kill -0 $pid 2>/dev/null; do
        status=$(( (status + 1) % max_items ))
        bar=""
        for ((i=0; i<max_items; i++)); do
            if [ $i -le $status ]; then
                skull_idx=$(( i % 2 ))
                bar+="${skulls[$skull_idx]} "  
            else
                bar+="  "  
            fi
        done
        
        printf "\r${PURPLE}[%s]${NC}" "$bar"
        sleep $delay
    done
    
    bar=""
    for ((i=0; i<max_items; i++)); do
        skull_idx=$(( i % 2 ))
        bar+="${skulls[$skull_idx]} "
    done
    printf "\r${GREEN}[%s] ✔ Spell completed successfully! ${NC}\n" "$bar"
}

run_nmap_with_spinner() {
    local cmd="$1"
    local tempfile=$(mktemp)
    
    # Start the nmap command in background and redirect output to tempfile
    eval "$cmd" > "$tempfile" 2>&1 &
    local nmap_pid=$!
    
    # Wait until "Starting Nmap" appears or 2 seconds have passed
    local counter=0
    while ! grep -q "Starting Nmap" "$tempfile" && [ $counter -lt 20 ]; do
        sleep 0.1
        ((counter++))
    done
    
    # Start spinner only after "Starting Nmap" appears
    if [ $counter -lt 20 ]; then
        skull_spinner $nmap_pid
    else
        # If "Starting Nmap" doesn't appear, just wait for completion
        wait $nmap_pid
    fi
    
    # Show output from tempfile
    cat "$tempfile"
    rm "$tempfile"
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
    echo "  $0 <TARGET> [HOSTNAME] [-udp] [-full] [-no-dir] [-stealth]"
    echo ""
    echo "Options:"
    echo "  TARGET     Target IP address, domain name or URL (required)"
    echo "  HOSTNAME   Optional hostname to add to /etc/hosts (if different from TARGET)"
    echo "  -udp       Perform UDP scan only"
    echo "  -full      Perform full scan (TCP and UDP)"
    echo "  -no-dir    Run without creating directory or output files"
    echo "  -stealth   Run in stealth mode (uses fragmented packets, no DNS resolution)"
    exit 1
}

extract_domain() {
    local url="$1"
    domain=$(echo "$url" | sed -E 's,^(https?|ftp)://,,')
    domain=$(echo "$domain" | sed -E 's,([/:].*),,')
    echo "$domain"
}

TARGET=""
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
        -no-dir)
            NO_DIR=true
            shift
            ;;
        -stealth)
            STEALTH_MODE=true
            shift
            ;;
        -*)
            error_msg "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"
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

if [[ -z "$TARGET" ]]; then
    error_msg "Target is required"
    usage
fi

if [[ "$TARGET" =~ ^https?:// || "$TARGET" =~ /$ ]]; then
    ORIGINAL_TARGET="$TARGET"
    TARGET=$(extract_domain "$TARGET")
    info_msg "Extracted domain from URL: $TARGET"
fi

if [[ ! "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    info_msg "Resolving domain name: $TARGET"
    IP=$(dig +short "$TARGET" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)
    if [[ -z "$IP" ]]; then
        error_msg "Failed to resolve domain name: $TARGET"
        exit 1
    fi
    info_msg "Resolved to IP: $IP"
else
    IP="$TARGET"
fi

if [[ -z "$HOSTNAME" ]]; then
    if [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        HOSTNAME=""
    else
        HOSTNAME="$TARGET"
    fi
fi

DIRECTORY="${HOSTNAME:-$TARGET}"

DIRECTORY=$(echo "$DIRECTORY" | tr '/' '_' | tr ':' '_')

if [[ "$NO_DIR" == false && "$STEALTH_MODE" == false ]]; then
    if [ ! -d "$DIRECTORY" ]; then
        mkdir "$DIRECTORY" || { error_msg "Failed to create directory $DIRECTORY"; exit 1; }
    fi
    cd "$DIRECTORY" || { error_msg "Failed to change into directory $DIRECTORY"; exit 1; }
fi

if [[ -n "$HOSTNAME" && "$NO_DIR" == false && "$HOSTNAME" != "$TARGET" ]]; then
    echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null || { error_msg "Failed to update /etc/hosts"; exit 1; }
fi

info_msg "Haste $TARGET...!!"

if [[ "$STEALTH_MODE" == true ]]; then
    info_msg "Running in stealth mode with fragmented packets"
    run_nmap_with_spinner "sudo nmap -f -n -Pn --data-length 32 '$TARGET'"
    success_msg "Stealth scan completed."
    exit 0
fi

if [[ "$UDP_SCAN" == false ]]; then
    info_msg "Performing TCP port discovery scan"
    if [[ "$NO_DIR" == true ]]; then
        run_nmap_with_spinner "sudo nmap -p- --min-rate=10000 -Pn '$TARGET'"
    else
        run_nmap_with_spinner "sudo nmap -p- --min-rate=10000 -Pn -oG tcp_ports.txt '$TARGET'"
        
        SORTED_TCP_PORTS=$(grep -oP '([\d]+)/open' tcp_ports.txt | awk -F/ '{print $1}' | tr '\n' ',')
        
        if [[ -n "$SORTED_TCP_PORTS" ]]; then
            info_msg "Performing detailed TCP service scan on ports: $SORTED_TCP_PORTS"
            run_nmap_with_spinner "sudo nmap -sCV -sV -oA nmap_tcp -p '${SORTED_TCP_PORTS%,}' '$TARGET'"
        fi
    fi
fi

if [[ "$UDP_SCAN" == true || "$FULL_SCAN" == true ]]; then
    info_msg "Performing comprehensive UDP port discovery scan"
    if [[ "$NO_DIR" == true ]]; then
        run_nmap_with_spinner "sudo nmap -Pn -sU --min-rate=1000 '$TARGET'"
    else
        run_nmap_with_spinner "sudo nmap -Pn -sU --min-rate=1000 -oG udp_ports.txt '$TARGET'"
        
        SORTED_UDP_PORTS=$(grep -oP '([\d]+)/(open|open\|filtered)' udp_ports.txt | awk -F/ '{print $1}' | tr '\n' ',')
        
        if [[ -n "$SORTED_UDP_PORTS" ]]; then
            info_msg "Performing detailed UDP service scan on ports: $SORTED_UDP_PORTS"
            run_nmap_with_spinner "sudo nmap -sUCV -p '${SORTED_UDP_PORTS%,}' -oA nmap_udp '$TARGET'"
        else
            info_msg "No open UDP ports discovered. Consider manual enumeration."
        fi
    fi
fi

if [[ "$NO_DIR" == false ]]; then
    success_msg "$DIRECTORY deployed. Ready to pwn!"
    success_msg "Scan completed. Results saved in respective files."
    ls
else
    success_msg "Scan completed. No files were saved (no-dir mode)."
fi
