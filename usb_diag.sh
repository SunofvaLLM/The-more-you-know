#!/bin/bash

# Color codes for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Pixel 9a Debian Linux USB and Environment Diagnostic Script ===${NC}"

# Function to check for command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
if ! command_exists lsusb; then
    echo -e "${RED}lsusb not found. Installing usbutils...${NC}"
    sudo apt update && sudo apt install -y usbutils || { echo -e "${RED}Failed to install usbutils. Exiting.${NC}"; exit 1; }
else
    echo -e "${GREEN}lsusb is installed.${NC}"
fi

echo -e "${YELLOW}Step 2: Checking USB devices detected by lsusb...${NC}"
LSUSB_OUTPUT=$(lsusb)
if [ -z "$LSUSB_OUTPUT" ]; then
    echo -e "${RED}No USB devices detected by lsusb inside the VM.${NC}"
else
    echo -e "${GREEN}USB devices detected:${NC}"
    echo "$LSUSB_OUTPUT"
fi

echo -e "${YELLOW}Step 3: Listing block devices (lsblk)...${NC}"
lsblk

echo -e "${YELLOW}Step 4: Kernel USB modules loaded (lsmod | grep usb)...${NC}"
USB_MODULES=$(lsmod | grep -i usb)
if [ -z "$USB_MODULES" ]; then
    echo -e "${RED}No USB kernel modules appear loaded.${NC}"
else
    echo -e "${GREEN}USB kernel modules loaded:${NC}"
    echo "$USB_MODULES"
fi

echo -e "${YELLOW}Step 5: Recent USB kernel messages (dmesg)...${NC}"
dmesg | tail -50 | grep -i usb || echo -e "${YELLOW}No recent USB kernel messages found.${NC}"

echo -e "${YELLOW}Step 6: USB related mounts in Android host (mount | grep usb)...${NC}"
mount | grep usb || echo -e "${YELLOW}No USB mounts detected.${NC}"

echo -e "${YELLOW}Step 7: Diagnosing environment and providing guidance...${NC}"

if [ -z "$LSUSB_OUTPUT" ]; then
    echo -e "${RED}Diagnosis: No USB devices detected inside the VM.${NC}"
    cat <<EOF

This is expected on Pixel 9a Debian Linux VM running on Android 16 because:
- The VM runs in a sandboxed Linux kernel separate from Android hosts.
- USB hardware passthrough is currently not supported.
- Physical USB devices are managed by Android host OS, not exposed to the VM.
- Devices must be unmounted/ejected inside Android before connecting to the VM.
- For interaction with USB devices, consider:
  - Using ADB file transfer or port forwarding.
  - Using network shares or Termux as intermediaries.
- Monitor updates which may add USB passthrough support in future.

EOF
else
    echo -e "${GREEN}USB devices detected inside the VM. USB passthrough might be working partially.${NC}"
fi

echo -e "${BLUE}=== End of diagnostic ===${NC}"
