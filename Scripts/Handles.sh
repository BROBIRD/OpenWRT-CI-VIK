#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

PKG_PATH="$GITHUB_WORKSPACE/wrt/package"

# #预置HomeProxy数据
# HP_DIR="$(find "$PKG_PATH" -maxdepth 3 -type d -iname '*homeproxy*' -print -quit 2>/dev/null)"
# if [ -n "$HP_DIR" ]; then
# 	echo " "

# 	HP_RESOURCES="$HP_DIR/root/etc/homeproxy/resources"
# 	HP_DASHBOARD="$HP_DIR/root/etc/homeproxy/dashboard"
# 	HP_IP_SOURCE="https://cdn.jsdelivr.net/gh/Loyalsoldier/surge-rules@release/cncidr.txt"
# 	HP_GEOSITE_SOURCE="https://cdn.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set-unstable/geosite-cn.srs"
# 	HP_IP_VERSION_URL="https://github.com/Loyalsoldier/surge-rules/releases/latest"
# 	HP_GEOSITE_VERSION_URL="https://github.com/SagerNet/sing-geosite/releases/latest"
# 	HP_DASHBOARD_SOURCE="https://codeload.github.com/SagerNet/sing-box-dashboard/zip/refs/heads/gh-pages"
# 	HP_DASHBOARD_VERSION_URL="https://github.com/SagerNet/sing-box-dashboard/commits/gh-pages.atom"
# 	HP_USER_AGENT="HomeProxy resource preset"

# 	HP_PREREQUISITES_MISSING=0
# 	for HP_COMMAND in curl awk; do
# 		command -v "$HP_COMMAND" > /dev/null 2>&1 || {
# 			echo "homeproxy resource preset requires $HP_COMMAND!"
# 			HP_PREREQUISITES_MISSING=1
# 		}
# 	done
# 	HP_PRESET_FAILED=0
# 	if [ "${HP_PREREQUISITES_MISSING:-0}" -eq 1 ]; then
# 		HP_PRESET_FAILED=1
# 	else
# 		HP_TMP="$(mktemp -d)"
# 		if [ -z "$HP_TMP" ]; then
# 			echo "failed to prepare homeproxy resource preset directory!"
# 			HP_PRESET_FAILED=1
# 		fi
# 	fi
# 	HP_DASHBOARD_STAGE="${HP_DASHBOARD}.new.$$"
# 	if [ "$HP_PRESET_FAILED" -eq 0 ]; then
# 		trap 'rm -rf "$HP_TMP" "$HP_DASHBOARD_STAGE"' EXIT INT TERM
# 	fi

# 	hp_fetch_release_version() {
# 		local effective_url version

# 		effective_url="$(curl -fsSL --compressed --retry 3 --retry-all-errors \
# 			--retry-delay 1 \
# 			--connect-timeout 10 --max-time 30 -A "$HP_USER_AGENT" \
# 			-o /dev/null -w '%{url_effective}' "$1")" || return 1
# 		version="${effective_url##*/}"
# 		case "$version" in
# 		''|*[!0-9]*) return 1 ;;
# 		esac
# 		printf '%s\n' "$version"
# 	}

# 	hp_download() {
# 		curl -fsSL --compressed --retry 3 --retry-all-errors --retry-delay 1 \
# 			--connect-timeout 10 \
# 			--max-time 60 -A "$HP_USER_AGENT" -o "$2" "$1" && [ -s "$2" ]
# 	}

# 	hp_fetch_dashboard_version() {
# 		local feed version

# 		feed="$(curl -fsSL --compressed --retry 3 --retry-all-errors \
# 			--retry-delay 1 --connect-timeout 10 --max-time 30 \
# 			-A "$HP_USER_AGENT" "$HP_DASHBOARD_VERSION_URL")" || return 1
# 		version="$(printf '%s\n' "$feed" | awk -F '[<>]' '
# 			/<updated>/ {
# 				version = $3
# 				gsub(/[-:TZ]/, "", version)
# 				print version
# 				exit
# 			}
# 		')"
# 		case "$version" in
# 		??????????????) case "$version" in *[!0-9]*) return 1 ;; esac ;;
# 		*) return 1 ;;
# 		esac
# 		printf '%s\n' "$version"
# 	}

# 	hp_replace_file() {
# 		local source_file="$1" target_file="$2" temporary_file

# 		temporary_file="${target_file}.tmp.$$"
# 		cp "$source_file" "$temporary_file" || return 1
# 		chmod 0644 "$temporary_file" || return 1
# 		mv -f "$temporary_file" "$target_file"
# 	}

# 	hp_update_ip() {
# 		local version file

# 		version="$(hp_fetch_release_version "$HP_IP_VERSION_URL")" || return 1
# 		hp_download "$HP_IP_SOURCE?v=$version" "$HP_TMP/cncidr.txt" || return 1
# 		awk -F, -v ipv4="$HP_TMP/china_ip4.txt" -v ipv6="$HP_TMP/china_ip6.txt" '
# 			$1 == "IP-CIDR" { print $2 > ipv4 }
# 			$1 == "IP-CIDR6" { print $2 > ipv6 }
# 		' "$HP_TMP/cncidr.txt" || return 1
# 		[ -s "$HP_TMP/china_ip4.txt" ] && [ -s "$HP_TMP/china_ip6.txt" ] || return 1
# 		awk '
# 			BEGIN {
# 				print "{\"version\":5,\"rules\":[{\"ip_cidr\":["
# 				first = 1
# 			}
# 			NF {
# 				printf "%s\"%s\"", first ? "" : ",", $0
# 				first = 0
# 			}
# 			END { print "]}]}" }
# 		' "$HP_TMP/china_ip4.txt" "$HP_TMP/china_ip6.txt" > "$HP_TMP/geoip_cn.json" || return 1
# 		[ -s "$HP_TMP/geoip_cn.json" ] || return 1
# 		printf '%s\n' "$version" > "$HP_TMP/china_ip4.ver"
# 		printf '%s\n' "$version" > "$HP_TMP/china_ip6.ver"
# 		for file in china_ip4.txt china_ip4.ver china_ip6.txt china_ip6.ver geoip_cn.json; do
# 			hp_replace_file "$HP_TMP/$file" "$HP_RESOURCES/$file" || return 1
# 		done
# 		echo "homeproxy resources: china_ip $version"
# 	}

# 	hp_update_geosite() {
# 		local version

# 		version="$(hp_fetch_release_version "$HP_GEOSITE_VERSION_URL")" || return 1
# 		hp_download "$HP_GEOSITE_SOURCE?v=$version" "$HP_TMP/geosite_cn.srs" || return 1
# 		printf '%s\n' "$version" > "$HP_TMP/geosite_cn.ver"
# 		hp_replace_file "$HP_TMP/geosite_cn.srs" "$HP_RESOURCES/geosite_cn.srs" || return 1
# 		hp_replace_file "$HP_TMP/geosite_cn.ver" "$HP_RESOURCES/geosite_cn.ver" || return 1
# 		echo "homeproxy resources: geosite_cn $version"
# 	}

# 	hp_update_dashboard() {
# 		local version source_dir old_dir

# 		command -v unzip > /dev/null 2>&1 || return 1
# 		command -v find > /dev/null 2>&1 || return 1
# 		version="$(hp_fetch_dashboard_version)" || return 1
# 		hp_download "$HP_DASHBOARD_SOURCE?v=$version" "$HP_TMP/dashboard.zip" || return 1
# 		unzip -q "$HP_TMP/dashboard.zip" -d "$HP_TMP/dashboard" || return 1
# 		source_dir="$(find "$HP_TMP/dashboard" -mindepth 1 -maxdepth 1 -type d -print -quit)"
# 		[ -n "$source_dir" ] && [ -f "$source_dir/index.html" ] || return 1

# 		rm -rf "$HP_DASHBOARD_STAGE"
# 		mkdir -p "$HP_DASHBOARD_STAGE" &&
# 			cp -a "$source_dir/." "$HP_DASHBOARD_STAGE/" &&
# 			printf '%s\n' "$version" > "$HP_DASHBOARD_STAGE/dashboard.ver" || return 1
# 		rm -f "$HP_DASHBOARD_STAGE/.etag"
# 		chmod -R a+rX "$HP_DASHBOARD_STAGE" || return 1

# 		old_dir="${HP_DASHBOARD}.old.$$"
# 		rm -rf "$old_dir"
# 		{ [ ! -d "$HP_DASHBOARD" ] || mv "$HP_DASHBOARD" "$old_dir"; } || return 1
# 		if mv "$HP_DASHBOARD_STAGE" "$HP_DASHBOARD"; then
# 			rm -rf "$old_dir"
# 			echo "homeproxy dashboard: $version"
# 			return 0
# 		fi
# 		rm -rf "$HP_DASHBOARD"
# 		[ ! -d "$old_dir" ] || mv "$old_dir" "$HP_DASHBOARD"
# 		return 1
# 	}

# 	if [ "$HP_PRESET_FAILED" -eq 0 ] && ! mkdir -p "$HP_RESOURCES" "$HP_DASHBOARD"; then
# 		echo "failed to prepare homeproxy resource directories!"
# 		HP_PRESET_FAILED=1
# 	fi

# 	if [ "$HP_PRESET_FAILED" -eq 0 ]; then
# 		if ! hp_update_ip; then
# 			echo "failed to update homeproxy IP resources; continuing!"
# 			HP_PRESET_FAILED=1
# 		fi

# 		if ! hp_update_geosite; then
# 			echo "failed to update homeproxy geosite; continuing!"
# 			HP_PRESET_FAILED=1
# 		fi

# 		if ! hp_update_dashboard; then
# 			echo "failed to update homeproxy dashboard; continuing!"
# 			HP_PRESET_FAILED=1
# 		fi

# 		rm -rf "$HP_TMP" "$HP_DASHBOARD_STAGE"
# 		trap - EXIT INT TERM
# 	fi

# 	if [ "$HP_PRESET_FAILED" -eq 0 ]; then
# 		echo "homeproxy data has been updated!"
# 	else
# 		echo "homeproxy resource preset completed with errors; continuing other handlers!"
# 	fi
# fi

# #修改argon主题字体和颜色
# if [ -d "$PKG_PATH/luci-theme-argon" ]; then
# 	echo " "
# 	if sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" \
# 		"$PKG_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"; then
# 		echo "theme-argon has been fixed!"
# 	else
# 		echo "theme-argon fix failed; continuing!"
# 	fi
# fi

# #修改aurora菜单式样
# if [ -d "$PKG_PATH/luci-app-aurora-config" ]; then
# 	echo " "
# 	if find "$PKG_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec \
# 		sed -i "s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +; then
# 		echo "theme-aurora has been fixed!"
# 	else
# 		echo "theme-aurora fix failed; continuing!"
# 	fi
# fi

#修改mini-diskmanager菜单位置
if [ -d "$PKG_PATH/luci-app-mini-diskmanager" ]; then
	echo " "
	if sed -i "s/services/system/g" \
		"$PKG_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"; then
		echo "mini-diskmanager has been fixed!"
	else
		echo "mini-diskmanager fix failed; continuing!"
	fi
fi

# #修复TailScale配置文件冲突
# FEEDS_PACKAGES="$PKG_PATH/../feeds/packages"
# TS_FILE="$(find "$FEEDS_PACKAGES" -maxdepth 3 -type f -wholename '*/tailscale/Makefile' -print -quit 2>/dev/null)"
# if [ -f "$TS_FILE" ]; then
# 	echo " "

# 	if sed -i '/\/files/d' "$TS_FILE"; then
# 		echo "tailscale has been fixed!"
# 	else
# 		echo "tailscale fix failed; continuing!"
# 	fi
# fi

#修复Rust编译失败
# RUST_FILE="$(find "$FEEDS_PACKAGES" -maxdepth 3 -type f -wholename '*/rust/Makefile' -print -quit 2>/dev/null)"
# if [ -f "$RUST_FILE" ]; then
# 	echo " "

# 	if sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_FILE"; then
# 		echo "rust has been fixed!"
# 	else
# 		echo "rust fix failed; continuing!"
# 	fi
# fi



#x86:按MAC绑定WAN/LAN,免疫ethN枚举顺序变化
if [ "${WRT_TARGET:-}" = "x86" ]; then
	echo " "
	UCD_DIR="$PKG_PATH/base-files/files/etc/uci-defaults"
	mkdir -p "$UCD_DIR"
	cat > "$UCD_DIR/99-fix-netorder" <<'UCD'
#!/bin/sh
# 按MAC绑定WAN/LAN,与ethN枚举顺序无关
# WAN = 板载网卡   7c:d3:0a:13:30:01 (lspci 07:00.0, HP)
# LAN = PCIE扩展卡 00:e0:4c:68:8a:51-54 (lspci 03-06:00.0)

WAN_MAC="7c:d3:0a:13:30:01"
NUM_ETH="5"

# r8168是kmod,可能在本脚本之后才加载;最多等30秒
tries=0
while [ "$(ls /sys/class/net 2>/dev/null | grep -c '^eth')" -lt "$NUM_ETH" ]; do
	tries=$((tries + 1))
	[ "$tries" -gt 60 ] && break
	sleep 0.5
done

# 按目标MAC找WAN口,其余eth口全部归入LAN
wan_dev=""
lan_ports=""
for dev in $(ls /sys/class/net 2>/dev/null | grep '^eth'); do
	mac="$(cat /sys/class/net/$dev/address 2>/dev/null)"
	if [ "$mac" = "$WAN_MAC" ]; then
		wan_dev="$dev"
	else
		lan_ports="$lan_ports $dev"
	fi
done

# 找不到板载网卡(换机器/换网卡) => 不动配置,安全回退
[ -n "$wan_dev" ] || { logger -t netorder "WAN MAC $WAN_MAC not found, skip"; exit 0; }

if [ -n "$(uci -q get network.wan)" ]; then
	# 已有wan(保留配置升级):只修正设备引用,不动协议/拨号账号
	uci set network.wan.device="$wan_dev"
	if [ "$(uci -q get network.wan.proto)" = "pppoe" ]; then
		uci set network.wan6.device="@wan"
	elif [ -n "$(uci -q get network.wan6)" ]; then
		uci set network.wan6.device="$wan_dev"
	fi
else
	# 全新安装:创建wan/wan6
	uci -q batch <<-EOF
		delete network.wan
		delete network.wan6
		set network.wan='interface'
		set network.wan.device='$wan_dev'
		set network.wan.proto='dhcp'
		set network.wan6='interface'
		set network.wan6.device='$wan_dev'
		set network.wan6.proto='dhcpv6'
	EOF
	# 如需预置PPPoE,去掉注释填入账号(注意仓库是公开的,别提交真实宽带密码)
	# uci set network.wan.proto='pppoe'
	# uci set network.wan.username='your-pppoe-username'
	# uci set network.wan.password='your-pppoe-password'
	# uci set network.wan.ipv6='1'
	# uci set network.wan6.device='@wan'
fi

# 就地重建LAN桥:全部非WAN的eth口(不动其他device段)
idx=""
i=0
while uci -q get network.@device[$i].name >/dev/null 2>&1; do
	[ "$(uci -q get network.@device[$i].name)" = "br-lan" ] && idx=$i
	i=$((i+1))
done
if [ -z "$idx" ]; then
	uci add network device
	idx=-1
fi
uci -q set network.@device[$idx].name='br-lan'
uci -q set network.@device[$idx].type='bridge'
uci -q delete network.@device[$idx].ports
for p in $lan_ports; do uci add_list network.@device[$idx].ports="$p"; done

uci commit network
logger -t netorder "WAN=$wan_dev LAN=br-lan($lan_ports)"
UCD
	chmod +x "$UCD_DIR/99-fix-netorder"
	echo "x86 netorder uci-defaults installed!"
fi