#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver=1.0.1
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
set -euo pipefail

Install_tj(){

	function prompt() {
    while true; do
        read -p "$1 [y/N] " yn
        case $yn in
            [Yy] ) return 0;;
            [Nn]|"" ) return 1;;
        esac
    done
	}

if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

if [[ $(uname -m 2> /dev/null) != x86_64 ]]; then
    echo Please run this script on x86_64 machine.
    exit 1
fi

NAME=trojan
VERSION=$(curl -fsSL https://api.github.com/repos/trojan-gfw/trojan/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
TARBALL="$NAME-$VERSION-linux-amd64.tar.xz"
DOWNLOADURL="https://github.com/trojan-gfw/$NAME/releases/download/v$VERSION/$TARBALL"
TMPDIR="$(mktemp -d)"
INSTALLPREFIX=/usr/local
SYSTEMDPREFIX=/etc/systemd/system

BINARYPATH="$INSTALLPREFIX/bin/$NAME"
CONFIGPATH="$INSTALLPREFIX/etc/$NAME/default.json"
SYSTEMDPATH="$SYSTEMDPREFIX/$NAME@.service"

echo Entering temp directory $TMPDIR...
cd "$TMPDIR"

echo Downloading $NAME $VERSION...
curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

echo Unpacking $NAME $VERSION...
tar xf "$TARBALL"
cd "$NAME"

echo Installing $NAME $VERSION to $BINARYPATH...
install -Dm755 "$NAME" "$BINARYPATH"

echo Installing $NAME server config to $CONFIGPATH...
if ! [[ -f "$CONFIGPATH" ]] || prompt "The server config already exists in $CONFIGPATH, overwrite?"; then
    install -Dm644 examples/server.json-example "$CONFIGPATH"
else
    echo Skipping installing $NAME server config...
fi
`wget -N  --no-check-certificate https://raw.githubusercontent.com/SNSLogty/Tunnel-backup/master/Trojan-cpp/trojan@.service  && chmod -R 777 trojan@.service && mv trojan@.service /usr/lib/systemd/system`

echo Reloading systemd daemon...
systemctl daemon-reload
 

echo Deleting temp directory $TMPDIR...
rm -rf "$TMPDIR"

echo Done!
}

echo && echo -e "  trojan 一键管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- CLIENT BY sncat    ----
  ---- 2020/6-------------
  
 ${Green_font_prefix}1.${Font_color_suffix} 安装 trojan
 ${Green_font_prefix}2.${Font_color_suffix} 卸载 trojan[没写]
————————————
 ${Green_font_prefix}3.${Font_color_suffix} 启动 trojan[没写]
 ${Green_font_prefix}4.${Font_color_suffix} 停止 trojan[没写]
 ${Green_font_prefix}5.${Font_color_suffix} 重启 trojan[没写]
————————————
 ${Green_font_prefix}6.${Font_color_suffix} 设置 trojan中转端[没写]
 ${Green_font_prefix}7.${Font_color_suffix} 设置 trojan客户端[没写]
————————————" && echo
read -e -p " 请输入数字 [1-7]:" num
case "$num" in
	1)
	Install_tj
	;;
	2)
	Uninstall_ct
	;;
	3)
	Start_ct
	;;
	4)
	Stop_ct
	;;
	5)
	Restart_ct
	;;
	6)
	WEBSOCKET_M
	;;
	7)
	ADDCILENT_ct
	;;	
	*)
	echo "请输入正确数字 [1-5]"
	;;
esac

