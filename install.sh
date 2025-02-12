#!/bin/sh

# Nikki's installer

# include openwrt_release
. /etc/openwrt_release

# check arch & branch
echo "arch: $DISTRIB_ARCH"
echo "branch: $DISTRIB_RELEASE"

# check env
if [[ ! -x "/bin/opkg" && ! -x "/usr/bin/apk" || ! -x "/sbin/fw4" || "$DISTRIB_ARCH" != "x86_64" ]]; then
    echo "Supports only systems with firewall4, architecture x86_64."
    exit 1
fi

# get branch/arch
arch="$DISTRIB_ARCH"
branch=
case "$DISTRIB_RELEASE" in
	*"24.10"*)
		branch="openwrt-24.10"
		;;
	"SNAPSHOT")
		branch="SNAPSHOT"
		;;
	*)
		echo "unsupported release: $DISTRIB_RELEASE"
		exit 1
		;;
esac

# feed url
repository_url="https://nikkiproxy.pages.dev"
feed_url="$repository_url/$branch/$arch/nikki"

if [ -x "/bin/opkg" ]; then
	# download ipks
	eval $(curl -s -L $feed_url/index.json | jsonfilter -e 'version=@["packages"]["nikki"]' -e 'app_version=@["packages"]["luci-app-nikki"]' -e 'i18n_version=@["packages"]["luci-i18n-nikki-zh-cn"]')
	curl -s -L -J -O $feed_url/nikki_${version}_${arch}.ipk
	curl -s -L -J -O $feed_url/luci-app-nikki_${app_version}_all.ipk
	curl -s -L -J -O $feed_url/luci-i18n-nikki-zh-cn_${i18n_version}_all.ipk

	# update feeds
	echo "update feeds"
	opkg update

	# install ipks
	echo "install ipks"
    for pkg in nikki_*.ipk luci-app-nikki_*.ipk luci-i18n-nikki-zh-cn_*.ipk; do
        opkg install "$pkg"
    done
	rm -f -- *nikki*.ipk
elif [ -x "/usr/bin/apk" ]; then
    # add key
    echo "add key"
    public_key_file="/etc/apk/keys/nikki.pem"
    rm -f "$public_key_file"
    curl -s -L -o "$public_key_file" "$repository_url/public-key.pem"

    # download apks
    eval $(curl -s -L $feed_url/index.json | jsonfilter -e 'version=@["packages"]["nikki"]' -e 'app_version=@["packages"]["luci-app-nikki"]' -e 'i18n_version=@["packages"]["luci-i18n-nikki-zh-cn"]')
    curl -s -L -J -O "$feed_url/nikki-${version}.apk"
    curl -s -L -J -O "$feed_url/luci-app-nikki-${app_version}.apk"
    curl -s -L -J -O "$feed_url/luci-i18n-nikki-zh-cn-${i18n_version}.apk"

    # update feeds
    echo "update feeds"
    apk update
    
	# install apks
    for pkg in nikki-*.apk luci-app-nikki-*.apk luci-i18n-nikki-zh-cn-*.apk; do
        apk add "$pkg"
    done
    rm -f -- *nikki*.apk
fi

echo "Success"

exit 0
