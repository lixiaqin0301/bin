#!/bin/bash
version=1.45.0
commit=d69a79b73808559a91206d73d7717ff5f798f23c

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
