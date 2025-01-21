#!/bin/sh

# MihomoTProxy's installer

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

# check repo
repo_url="https://openwrt-mihomo.pages.dev"
feed_url="$repo_url/latest"

# add key
echo "add key"
public_key_file="/etc/apk/keys/mihomo.pem"
public_key_url="https://openwrt-mihomo.pages.dev/public-key.pem"

rm -f "$public_key_file"
curl -s -o "$public_key_file" "$public_key_url"

# download apks
eval $(curl -s -L $feed_url/index.json | jsonfilter -e 'version=@["packages"]["mihomo"]' -e 'app_version=@["packages"]["luci-app-mihomo"]' -e 'i18n_version=@["packages"]["luci-i18n-mihomo-zh-cn"]')
curl -s -L -J -O "$feed_url/mihomo-${version}.apk"
curl -s -L -J -O "$feed_url/luci-app-mihomo-${app_version}.apk"
curl -s -L -J -O "$feed_url/luci-i18n-mihomo-zh-cn-${i18n_version}.apk"

# update feeds
echo "update feeds"
apk update

# install mihomo
echo "install mihomo"
for pkg in mihomo-*.apk luci-app-mihomo-*.apk luci-i18n-mihomo-zh-cn-*.apk; do
    apk add "$pkg"
done

rm -f -- *mihomo*.apk

echo "Success"

exit 0
