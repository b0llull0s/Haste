# Haste

A powerful and flexible network scanning utility that enhances nmap with visual feedback and smart defaults.

> [!CAUTION]
> Very vey noisy, that's why is fast... pls don't use it outside of CTF environments, it will disrupt any network and will get you ban or arrested.

## Features

- **Visual Progress Tracking**: Engaging skull spinner animation shows progress in real-time
- **Smart Workflows**: Automatically discovers open ports first, then performs detailed service scanning
- **Multiple Scan Modes**:
- Default TCP scan
- UDP scan (`-udp`)
- Full scan (both TCP and UDP) (`-full`)
- Stealth mode with fragmented packets (`-stealth`)
- **Organized Output**: Creates directories and saves scan results in multiple formats
- **Domain Extraction**: Automatically extracts domains from URLs
- **Hostname Management**: Optional hostname addition to /etc/hosts

## Installation

```bash
# Clone the repository
git clone https://github.com/b0llull0s/haste.git

# Make the script executable
cd haste
chmod +x haste.sh

# Optional: Create a symlink for system-wide access
sudo ln -s $(pwd)/haste.sh /usr/local/bin/haste
```

## Usage

```
./haste.sh <TARGET> [HOSTNAME] [-udp] [-full] [-no-dir] [-stealth]
```

### Parameters

- `TARGET`: IP address, domain name, or URL (required)
- `HOSTNAME`: Optional hostname to add to /etc/hosts (if different from TARGET)
>[!NOTE]
> This feature is mainly designed to be used on `HackTheBox`; where domains normally are `box.htb`

### Options

- `-udp`: Perform UDP scan only
- `-full`: Perform full scan (TCP and UDP)
- `-no-dir`: Run without creating directory or output files
- `-stealth`: Run in stealth mode (uses fragmented packets, no DNS resolution)

## Contribution

Feel free to contribute to this script by submitting issues or pull requests.

## Disclaimer

This script is intended for educational and ethical use only. By using this script, you agree that you will not use it for any illegal activities or to scan networks without proper authorization. Always ensure you have permission before scanning any IP addresses or networks. The author is not responsible for any misuse or damages resulting from the use of this script.

> Happy Hacking!!
