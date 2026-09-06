#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)  # 第5个参数为自定义名称列表
	local REPO_NAME=${PKG_REPO#*/}

	echo " "

	# 删除本地可能存在的不同名称的软件包
	for NAME in "${PKG_LIST[@]}"; do
		# 查找匹配的目录
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		# 删除找到的目录
		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not fonud directory: $NAME"
		fi
	done

	# 克隆 GitHub 仓库
	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	# 处理克隆的仓库
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

# 调用示例
# UPDATE_PACKAGE "OpenAppFilter" "destan19/OpenAppFilter" "master" "" "custom_name1 custom_name2"
# UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "master" "" "luci-app-appfilter oaf" 这样会把原有的open-app-filter，luci-app-appfilter，oaf相关组件删除，不会出现coremark错误。

# UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "master"
# UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
# UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"
# UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master"
# UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master"
UPDATE_PACKAGE "zerotier" "sbwml/feeds_packages_net_zerotier" "main"

# UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main"
# UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
# UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"
# UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg"
# UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

# UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main"
UPDATE_PACKAGE "diskman" "lisaac/luci-app-diskman" "master"
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
# UPDATE_PACKAGE "fancontrol" "rockjake/luci-app-fancontrol" "main"
# UPDATE_PACKAGE "gecoosac" "laipeng668/luci-app-gecoosac" "main"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
# UPDATE_PACKAGE "netspeedtest" "sirpdboy/netspeedtest" "main" "" "homebox speedtest"
# UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main"
# UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main"
# UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"
# UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main"
# UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main"
# UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "luci-app-timewol luci-app-wolplus"
# UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"
UPDATE_PACKAGE "luci-app-adguardhome" "stevenjoezhang/luci-app-adguardhome" "master"
UPDATE_PACKAGE "luci-app-argon-config" "jerrykuku/luci-app-argon-config" "master"

UPDATE_PACKAGE "naiveproxy" "sbwml/openwrt_helloworld" "v5" "" "naiveproxy"

git clone https://github.com/sbwml/openwrt_helloworld.git $GITHUB_WORKSPACE/wrt/package/sbwml_helloworld

sed -i -r '/elseif szType == ("sip008"|"vmess") then/i\\t\tresult.fast_open = "1"' $GITHUB_WORKSPACE/wrt/package/sbwml_helloworld/luci-app-ssr-plus/root/usr/share/shadowsocksr/subscribe.lua
sed -i -r '/elseif szType == ("sip008"|"vmess") then/i\\t\tresult.fast_open = "1"' $GITHUB_WORKSPACE/wrt/feeds/helloworld/luci-app-ssr-plus/root/usr/share/shadowsocksr/subscribe.lua

# Use nginx instead of uhttpd
sed -i 's/+uhttpd /+luci-nginx /g' $GITHUB_WORKSPACE/wrt/feeds/luci/collections/luci/Makefile
sed -i 's/+uhttpd-mod-ubus //' $GITHUB_WORKSPACE/wrt/feeds/luci/collections/luci/Makefile
sed -i 's/+uhttpd /+luci-nginx /g' $GITHUB_WORKSPACE/wrt/feeds/luci/collections/luci-light/Makefile
sed -i "s/+luci /+luci-nginx /g" $GITHUB_WORKSPACE/wrt/feeds/luci/collections/luci-ssl-openssl/Makefile
sed -i "s/+luci /+luci-nginx /g" $GITHUB_WORKSPACE/wrt/feeds/luci/collections/luci-ssl/Makefile

# nginx - latest version
rm -rf $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx
git clone --single-branch --depth=1 https://github.com/sbwml/feeds_packages_net_nginx -b openwrt-25.12 $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx
# curl -s https://raw.githubusercontent.com/kn007/patch/e2fcf45e320bb8317042b6796b8f9dd42ffdb25c/nginx_dynamic_tls_records.patch > feeds/packages/net/nginx/patches/nginx/105-nginx_dynamic_tls_records.patch
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx/files/nginx.init
# sed -i 's/1.26.2/1.30.0/g' $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx/Makefile
# sed -i 's/627fe086209bba80a2853a0add9d958d7ebbdffa1a8467a5784c9a6b4f03d738/058188c64bf22baecaa72b809a6318a4f9ba623889c554feab03f7cb853ab31b/g' $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx/Makefile

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' $GITHUB_WORKSPACE/wrt/feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

rm -rf $GITHUB_WORKSPACE/wrt/package/system/procd
"$GITHUB_WORKSPACE/Scripts/gh-down.sh" https://github.com/immortalwrt/immortalwrt/tree/master/package/system/procd $GITHUB_WORKSPACE/wrt/package/system/procd

# openssl hwrng
sed -i "/-openwrt/iOPENSSL_OPTIONS += enable-ktls '-DDEVRANDOM=\"\\\\\"/dev/urandom\\\\\"\"\'\n" $GITHUB_WORKSPACE/wrt/package/libs/openssl/Makefile

# openssl -Ofast
sed -i "s/-O3/-Ofast/g" $GITHUB_WORKSPACE/wrt/package/libs/openssl/Makefile
# openssl -Os
# sed -i "s/-O3/-Os/g" $GITHUB_WORKSPACE/wrt/package/libs/openssl/Makefile

# nghttp3
$GITHUB_WORKSPACE/Scripts/gh-down.sh https://github.com/immortalwrt/packages/tree/master/libs/nghttp3 $GITHUB_WORKSPACE/wrt/package/libs/nghttp3

# curl - http3/quic
rm -rf $GITHUB_WORKSPACE/wrt/feeds/packages/net/curl
git clone --single-branch --depth=1 https://github.com/sbwml/feeds_packages_net_curl $GITHUB_WORKSPACE/wrt/feeds/packages/net/curl

# ngtcp2
# rm -rf $GITHUB_WORKSPACE/wrt/feeds/packages/libs/ngtcp2
git clone --single-branch --depth=1 https://github.com/sbwml/package_libs_ngtcp2 $GITHUB_WORKSPACE/wrt/package/libs/ngtcp2

# BBRv3 - linux-6.12
pushd $GITHUB_WORKSPACE/wrt/target/linux/generic/backport-6.12
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0019-x86-cfi-bpf-Add-tso_segs-and-skb_marked_lost-to-bpf_.patch
    curl -Os https://raw.githubusercontent.com/sbwml/r4s_build_script/021c0f4b77258923a7a3c735565e19d1acb410b3/openwrt/patch/kernel-6.12/bbr3/010-bbr3-0020-net-tcp_bbr-v3-silence-Wconstant-logical-operand.patch
popd

# drop mosdns and v2ray-geodata packages that come with the source
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f

git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 $GITHUB_WORKSPACE/wrt/package/mosdns
git clone --single-branch --depth=1 https://github.com/sbwml/v2ray-geodata $GITHUB_WORKSPACE/wrt/package/v2ray-geodata

# rm -rf feeds/smpackage/gost/patches
rm -rf $GITHUB_WORKSPACE/wrt/feeds/smpackage/luci-app-gost
$GITHUB_WORKSPACE/Scripts/gh-down.sh https://github.com/kenzok8/openwrt-packages/tree/master/luci-app-gost $GITHUB_WORKSPACE/wrt/feeds/smpackage/luci-app-gost

rm -rf $GITHUB_WORKSPACE/wrt/feeds/smpackage/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb,tcping}

git clone --single-branch --depth=1 https://github.com/EasyTier/luci-app-easytier.git $GITHUB_WORKSPACE/wrt/package/extra/luci-app-easytier

rm -rf $GITHUB_WORKSPACE/wrt/feeds/packages/net/microsocks
$GITHUB_WORKSPACE/Scripts/gh-down.sh https://github.com/fw876/helloworld/tree/master/microsocks $GITHUB_WORKSPACE/wrt/feeds/packages/net/microsocks

# rm -rf $GITHUB_WORKSPACE/wrt/feeds/packages/net/zerotier
# git clone --single-branch --depth=1 https://github.com/sbwml/feeds_packages_net_zerotier.git $GITHUB_WORKSPACE/wrt/feeds/packages/net/zerotier

sed -i 's/wget-any/wget/g' $GITHUB_WORKSPACE/wrt/package/luci-theme-argon/Makefile

wget -O $GITHUB_WORKSPACE/wrt/feeds/packages/net/fail2ban/patches/002-remove-setup-py-test_suite.patch https://gist.github.com/BROBIRD/5ce7782915a34442aaa9130f17952ad0/raw/353eaf0b4fede4c5e6074a5f1e3da73e205edd0a/002-remove-setup-py-test_suite.patch


#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-false}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo -e "\n$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Po "PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)" $PKG_FILE)
		local PKG_TAG=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease == $PKG_MARK)) | first | .tag_name")

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")
		local OLD_URL=$(grep -Po "PKG_SOURCE_URL:=\K.*" "$PKG_FILE")
		local OLD_FILE=$(grep -Po "PKG_SOURCE:=\K.*" "$PKG_FILE")
		local OLD_HASH=$(grep -Po "PKG_HASH:=\K.*" "$PKG_FILE")

		local PKG_URL=$([[ "$OLD_URL" == *"releases"* ]] && echo "${OLD_URL%/}/$OLD_FILE" || echo "${OLD_URL%/}")

		local NEW_VER=$(echo $PKG_TAG | sed -E 's/[^0-9]+/\./g; s/^\.|\.$//g')
		local NEW_URL=$(echo $PKG_URL | sed "s/\$(PKG_VERSION)/$NEW_VER/g; s/\$(PKG_NAME)/$PKG_NAME/g")
		local NEW_HASH=$(curl -sL "$NEW_URL" | sha256sum | cut -d ' ' -f 1)

		echo "old version: $OLD_VER $OLD_HASH"
		echo "new version: $NEW_VER $NEW_HASH"

		if [[ "$NEW_VER" =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE version has been updated!"
		else
			echo "$PKG_FILE version is already the latest!"
		fi
	done
}

#UPDATE_VERSION "软件包名" "测试版，true，可选，默认为否"
# UPDATE_VERSION "sing-box"
# UPDATE_VERSION "tailscale"

#引入私有扩展脚本
if [ -f "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh" ]; then
	source "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh"
fi
