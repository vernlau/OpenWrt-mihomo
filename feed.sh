#!/bin/sh

# MihomoTProxy's feed

# include openwrt_release
. /etc/openwrt_release

# check openwrt_release
echo "arch: $DISTRIB_ARCH"
echo "branch: $DISTRIB_RELEASE"

# check env
if [[ ! -x "/sbin/fw4" ]] || [ ! -x "/usr/bin/apk" ] || [ "$DISTRIB_ARCH" != "x86_64" ] || [ "$DISTRIB_RELEASE" != "SNAPSHOT" ]; then
    [ ! -x "/sbin/fw4" ] && echo "This repositories supports only systems with firewall4"
    [ ! -x "/usr/bin/apk" ] && echo "This repositories supports only systems with apk"
    [ "$DISTRIB_ARCH" != "x86_64" ] && echo "This repositories supports only systems with architecture x86_64"
    [ "$DISTRIB_RELEASE" != "SNAPSHOT" ] && echo "This repositories supports only systems with branch SNAPSHOT"
    exit 1
fi

# add key
echo "add key"
public_key_file="/etc/apk/keys/mihomo.pem"
rm -f "$public_key_file"
curl -s -L -o "$public_key_file" "https://openwrt-mihomo.pages.dev/public-key.pem"

# add feed
echo "add feed"
if (grep -q -e mihomo -e openwrt-mihomo /etc/apk/repositories.d/customfeeds.list); then
    sed -i '/mihomo\|openwrt-mihomo/d' /etc/apk/repositories.d/customfeeds.list
fi
echo "https://openwrt-mihomo.pages.dev/latest/packages.adb" >> /etc/apk/repositories.d/customfeeds.list

# update feeds
echo "update feeds"
apk update

# install mihomo
echo "install mihomo"
apk add mihomo luci-app-mihomo luci-i18n-mihomo-zh-cn

echo "Success"

exit 0
