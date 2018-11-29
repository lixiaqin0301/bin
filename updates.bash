#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name=$(basename "${BASH_SOURCE[0]}")
sh_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)
export sh_full_path="$sh_dir/$sh_name"

cd "$sh_dir" || exit 1

# Packages
rpm -qa | grep -q squid && rpm -e squid
if which dnf >&/dev/null; then
    dnfyum=dnf
else
    dnfyum=yum
fi
$dnfyum update -y
$dnfyum upgrade -y

# pip2
if ! which pip2; then
    $dnfyum reinstall python-pip -y
fi
if which pip2; then
    tmpfile=$(mktemp)
    pip2=$(which pip2)
    "$pip2" list >/dev/null 2> "$tmpfile"
    if [[ -s "$tmpfile" ]]; then
        "$pip2" install -U --user pip
    fi
    for pkg in $(pip2 list -o | awk '{print $1}' | grep -v '^-' | grep 'Package' -v); do
        [[ "$pkg" == pycurl ]] && export PYCURL_SSL_LIBRARY=nss
        "$pip2" install -U --user "$pkg"
    done
    rm -f "$tmpfile"
fi

# pip3
if ! which pip3; then
    $dnfyum reinstall python3-pip -y
fi
if which pip3; then
    pip3=$(which pip3)
    tmpfile=$(mktemp)
    "$pip3" list >/dev/null 2> "$tmpfile"
    if [[ -s "$tmpfile" ]]; then
        "$pip3" install -U --user pip
    fi
    for pkg in $(pip3 list -o --trusted-host mirrors.ustc.edu.cn | awk '{print $1}' | grep -v '^-' | grep 'Package' -v); do
        "$pip3" install -U --user "$pkg"
    done
    rm -f "$tmpfile"
fi

# .emacs.d .vim selfscripts
for d in /root/.vim/bundle/*/ /root/lixq-config/ /home/lixq/toolchains/selfscripts/bin/; do
    [[ -d "$d/.git" ]] || continue
    cd "$d" || exit 1
    pwd
    git pull
done

# robot framework
for d in /usr/local/wstest /home/squid_test; do
    svn update "$(dirname $d)"
done

# code
for d in $(find /home/lixq/vod /home/lixq/eclipse-workspace -name .svn | sort -u); do
    svn update "$(dirname "$d")"
done

grep -q ^lixq: /etc/passwd && chown lixq:wheel -R /home/lixq
