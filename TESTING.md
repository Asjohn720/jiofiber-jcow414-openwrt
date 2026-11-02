# JioFiber JCOW414 OpenWrt - Hardware & Feature Testing Report

[![Target Device](https://img.shields.io/badge/Device-Sercomm%20JCOW414-blue.svg)](#)
[![SoC](https://img.shields.io/badge/SoC-EcoNet%20EN7528HU-orange.svg)](#)
[![Kernel](https://img.shields.io/badge/Kernel-6.18.55-green.svg)](#)
[![Wi-Fi Status](https://img.shields.io/badge/Wi--Fi-Dual--Band%20Verified-brightgreen.svg)](#phase-3-wi-fi-radios-24-ghz--5-ghz)
[![LAN Status](https://img.shields.io/badge/LAN-4x%201Gbps%20PASSED-blueviolet.svg)](#phase-1-lan--switch-performance-test)
[![Main Documentation](https://img.shields.io/badge/Docs-README.md-yellow.svg)](README.md)

This document tracks physical hardware testing, peripheral bringup, driver verification, and operational stability of **OpenWrt 23.05 (Kernel 6.18.55)** on the **Sercomm JioFiber JCOW414 / JCO4032** home gateway.

> 📖 **Flashing Guide & Source Code:** Return to the primary [Project Documentation (README.md)](README.md).

---

## 📋 Testing Matrix Overview

| Phase | Feature / Component | Expected Behavior | Status | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1** | **Ethernet Switch & LAN Ports** | All 4 LAN ports link at 1 Gbps Full-Duplex | **PASSED** | DSA ports `lan1`-`lan4` auto-bridged to `br-lan` with full Gigabit routing |
| **Phase 2** | **System & SSH Management** | Web LuCI dashboard + Dropbear SSH login | **PASSED** | Root access confirmed, LuCI active at `192.168.1.1` |
| **Phase 3** | **Wi-Fi 2.4 GHz (MT7603E)** | 802.11b/g/n AP broadcasting, client connection | **PASSED** | Broadcasting on Channel 6, full signal on mobile client |
| **Phase 3** | **Wi-Fi 5 GHz (MT7613BE)** | 802.11a/n/ac AP broadcasting, client connection | **PASSED** | Broadcasting on Channel 44 (802.11ac, VHT80), full signal on mobile client |
| **Phase 4** | **Hardware LEDs (LAN GPHY & Status)** | Link & Activity blinking on Ethernet | **PASSED** | Green & Amber LAN port LEDs verified blinking with traffic |
| **Phase 4b** | **Buttons (Reset & WPS)** | Push button interrupts captured | **PENDING** | To test via `logread` and `evtest` |
| **Phase 5** | **USB 2.0 / 3.0 Host** | Mass storage mount and VBUS power control | **PASSED** | xHCI SuperSpeed Host controller active, dual VBUS GPIO 9/11 operational |
| **Phase 6** | **Settings Persistence & Reboot** | Overlayfs config survives power cycle | **PASSED** | UBIFS `rootfs_data` overlay active, `/etc/config` persists across reboots |
| **Phase 7** | **Throughput & NAT Performance** | Speedtest saturation under heavy load | **PENDING** | Bandwidth testing via iperf3 / fast.com |

---

## 🔍 Detailed Test Logs & Findings

### Phase 1: LAN & Switch Performance Test
* **Status:** **PASSED** (100% Verified)
* **Observations:**
  - Internal EcoNet switch ports 1 to 4 configured with DSA driver (`lan1`, `lan2`, `lan3`, `lan4`).
  - Auto-bridged into `br-lan` out of the box with default gateway `192.168.1.1`.
  - PC connected via CAT6 Ethernet negotiated 1000 Mbps Full-Duplex instantly.
  - LAN switching throughput and internal packet forwarding verified without packet drops.

### Phase 2: System Management & SSH Security
* **Status:** **PASSED** (100% Verified)
* **Observations:**
  - LuCI web dashboard accessible at `http://192.168.1.1`.
  - Admin root password set and authenticated properly.
  - SSH (`dropbear`) active and accessible on port 22.
  - Full 432 MB usable DDR3 RAM and all 4 CPU VPEs visible and active in system resource monitors.

### Phase 3: Wi-Fi Radios (2.4 GHz & 5 GHz)
* **Status:** **PASSED** (100% Fully Verified Dual-Band AP)
* **Hardware:**
  - **2.4 GHz Radio:** MediaTek MT7603E (PCIe Bus 0, `14c3:7603`)
  - **5 GHz Radio:** MediaTek MT7613BE (PCIe Bus 1, `14c3:7663`)
* **Verified Findings:**
  - **5 GHz (MT7613BE):** **PASSED**! Broadcasting on Channel 44 (802.11ac, VHT80), maximum signal strength, BSSID `b4:a7:c6:58:fc:0b`.
  - **2.4 GHz (MT7603E):** **PASSED**! Broadcasting on Channel 6 (802.11b/g/n, HT20, WPA2-PSK), maximum signal strength, BSSID `b4:a7:c6:58:fc:0a`.
  - Verified live on Android and iOS client devices: both `JioFiber_OpenWrt_2.4G` and `JioFiber_OpenWrt_5G` appear simultaneously in client scans with full signal bars.
  - 512-byte factory EEPROM (`RT30xxEEPROM.bin`) confirmed matching byte-for-byte in MT7603 driver memory.

### Phase 4: Hardware Peripherals (LAN GPHY LEDs & Status LEDs)
* **Status:** **PASSED** (100% Verified)
* **Observations:**
  - Internal MT7530 switch GPHY hardware LED pinmux active (`gpio30` to `gpio37`).
  - Green (Gigabit Link) and Amber (Traffic Activity) LEDs blinking properly on physical cable connection and data transfer.
  - Front panel status LEDs (Red, Green, Blue) mapped to GPIO 27, 25, 23.

### Phase 5: USB Port & Storage (USB 2.0 & USB 3.0)
* **Status:** **PASSED** (100% Hardware Verified)
* **Observations:**
  - `xhci-mtk 1fb90000.usb` probed with USB 3.1 Enhanced SuperSpeed support.
  - Dual independent 5V VBUS regulators mapped and active:
    - Port 1: `pinctrl 9` GPIO control.
    - Port 2: `pinctrl 11` GPIO control (always-on regulator).
  - Both USB bus 1 (USB 2.0 Hub, 2 ports) and bus 2 (USB 3.0 Hub, 1 port) registered in kernel dmesg.

### Phase 6: Persistence & Reboot
* **Status:** **PASSED** (100% Verified)
* **Observations:**
  - MTD concatenation (`tclinux_rootfs` + `unknown` -> `virtual_flash`) forms 43 MiB UBI partition.
  - UBIFS volume `rootfs_data` mounts smoothly as writable overlayfs.
  - All UCI configuration changes survive soft reboots and cold power cycles.

---

## 👨‍💻 Tested & Maintained By

* **Anand ([@Asjohn720](https://github.com/Asjohn720))**
  - 🌐 **GitHub:** [@Asjohn720](https://github.com/Asjohn720)
  - 🐦 **X (Twitter):** [@asjohn720](https://x.com/asjohn720)
  - 📸 **Instagram:** [@asjohn720](https://www.instagram.com/asjohn720)
