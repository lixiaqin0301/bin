#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

version=1.44.2
commit=ff915844119ce9485abfe8aa9076ec76b5300ddd

[[ -d "$sh_dir/downloads" ]] || mkdir -p "$sh_dir/downloads"
cd "$sh_dir/downloads" || exit 1
if [[ ! -f "vscode-server-${version}.linux-x64.tar.gz" ]]; then
    until wget "https://update.code.visualstudio.com/commit:${commit}/server-linux-x64/stable" -O "vscode-server-${version}.linux-x64.tar.gz"; do
        rm -rf "vscode-server-${version}.linux-x64.tar.gz"*
    done
fi

cat << EOF
/bin/cp ~/.vscode-server/data/Machine/settings.json /tmp/
rm -rfv ~/.vscode-server
mkdir -p ~/.vscode-server/bin/${commit}
tar -xvf "vscode-server-${version}.linux-x64.tar.gz" -C ~/.vscode-server/bin/${commit} --strip 1
touch ~/.vscode-server/bin/${commit}/0
mkdir -p ~/.vscode-server/data/Machine
cp /tmp/settings.json ~/.vscode-server/data/Machine
EOF
