#!/bin/bash
# ==============================================================================
# OpenWrt Build Configuration Setup for Sercomm JioFiber JCOW414
# Target: EcoNet EN7528HU (MIPS 1004Kc)
# Author: Anand (@Asjohn720)
# ==============================================================================

set -e

echo "=== Configuring OpenWrt for JioFiber JCOW414 ==="

# Write minimal seed configuration
cat << 'EOF' > .config
# Target architecture & device
CONFIG_TARGET_econet=y
CONFIG_TARGET_econet_en7528=y
CONFIG_TARGET_econet_en7528_DEVICE_jiofiber_jcow414=y

# Web UI (LuCI) with SSL and Bootstrap theme
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-theme-bootstrap=y

# Custom distribution branding
CONFIG_IMAGEOPT=y
CONFIG_VERSIONOPT=y
CONFIG_VERSION_DIST="OpenWrt-Asjohn720"
CONFIG_VERSION_NUMBER="1.1"
CONFIG_VERSION_CODE="JCOW414"
EOF

# Expand configuration dependencies
make defconfig

echo ""
echo "=== Configuration generated successfully! ==="
echo "You can now run: make -j\$(nproc)"
