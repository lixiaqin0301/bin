#!/bin/bash
version=1.50.1
commit=d2e414d9e4239a252d1ab117bd7067f125afd80a

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
