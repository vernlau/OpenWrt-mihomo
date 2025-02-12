#!/bin/sh

# Nikki's feed

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
	# add key
	echo "add key"
	key_build_pub_file="key-build.pub"
	curl -s -L -o "$key_build_pub_file" "$repository_url/key-build.pub"
	opkg-key add "$key_build_pub_file"
	rm -f "$key_build_pub_file"

	# add feed
	echo "add feed"
	if (grep -q nikki /etc/opkg/customfeeds.conf); then
		sed -i '/nikki/d' /etc/opkg/customfeeds.conf
	fi
	echo "src/gz nikki $feed_url" >> /etc/opkg/customfeeds.conf

	# update feeds
	echo "update feeds"
	opkg update

    # install nikki
    echo "install nikki"
    opkg install nikki luci-app-nikki luci-i18n-nikki-zh-cn    
elif [ -x "/usr/bin/apk" ]; then
    # add key
    echo "add key"
    public_key_file="/etc/apk/keys/nikki.pem"
    rm -f "$public_key_file"
    curl -s -L -o "$public_key_file" "$repository_url/public-key.pem"

    # add feed
    echo "add feed"
    if (grep -q -e nikki -e nikkiproxy /etc/apk/repositories.d/customfeeds.list); then
        sed -i '/nikki\|nikkiproxy/d' /etc/apk/repositories.d/customfeeds.list
    fi
    echo "$feed_url/packages.adb" >> /etc/apk/repositories.d/customfeeds.list

    # update feeds
    echo "update feeds"
    apk update
	
    # install nikki
    echo "install nikki"
    apk add nikki luci-app-nikki luci-i18n-nikki-zh-cn
fi

echo "Success"

exit 0
