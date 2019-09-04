#!/bin/bash
sh_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)

filepath=$1
filename=$(basename "$filepath")
title=$(grep '^title: ' "$1" | cut -b 8- | head -n 1 | sed 's/^%\s*\(.*\S\)\s*$/\1/')
[[ -z "$title" ]] && title=${filename%.*}

rm -rf /tmp/pandoc
mkdir /tmp/pandoc
pandoc -f markdown+raw_html -t html5 -s --toc --self-contained -c "$sh_dir/data/github-syntax-highlight.css" -c "$sh_dir/data/github-markdown.css" -B "$sh_dir/data/pandoc_b" -A "$sh_dir/data/pandoc_a" -H "$sh_dir/data/pandoc_h" -T "$title" "$filepath" -o "/tmp/pandoc/${title}.html"
