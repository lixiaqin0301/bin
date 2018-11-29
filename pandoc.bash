#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

filepath="$1"
filename="$(basename "$filepath")"
title="$(grep "^title: " "$1" | cut -b 8- | head -n 1 | sed "s/^%\s*\(.*\S\)\s*$/\1/")"
[[ -z "$title" ]] && title=${filename%.*}

tmpdir=$(mktemp -d)
pandoc -f markdown+raw_html -t html5 -s --toc --self-contained -c "$sh_dir/data/github-syntax-highlight.css" -c "$sh_dir/data/github-markdown.css" -B "$sh_dir/data/pandoc_b" -A "$sh_dir/data/pandoc_a" -H "$sh_dir/data/pandoc_h" -T "$title" "$filepath" -o "$tmpdir/${title}.html"
cur_dir=$(pwd)
cd "$tmpdir" || exit 1
tar -cvf "${title}.html.tar" "${title}.html"
echo "$tmpdir/${title}.html"
cd "$cur_dir" || exit 1
