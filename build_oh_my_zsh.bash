#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir"

[[ -x /bin/zsh ]] || exit 1
. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$HOME/.oh-my-zsh" -rf
[[ -d "$HOME/.oh-my-zsh" ]] && exit 0

if ! grep zsh /etc/shells; then
    echo '/bin/zsh' >> /etc/shells
fi
cd /tmp
rm /tmp/install.sh* -f
until wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh --no-check-certificate; do
    rm /tmp/install.sh* -f
done
bash /tmp/install.sh

exit 0
