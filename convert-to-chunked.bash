#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

curdir=$(pwd)
filepath=$1
dstpath=$2
filename=$(basename "$filepath")
tmpdir=$(mktemp -d)
cp "$filepath" "$tmpdir"
cd "$tmpdir" || exit 1
split -l 10 "$filename"
rm "$filename"
tmpfile=$(mktemp)
{
    printf "HTTP/1.0 200 OK\r\n"
    printf "Transfer-Encoding: chunked\r\n"
    printf "Content-Type: application/x-mpegURL\r\n"
    printf "Accept-Ranges: bytes\r\n"
    printf 'ETag: "4038726998"\r\n'
    printf "Last-Modified: Fri, 21 Jul 2017 02:26:13 GMT\r\n"
    printf "Connection: keep-alive\r\n"
    printf "Date: Mon, 24 Jul 2017 06:33:29 GMT\r\n"
    printf "Server: lighttpd/1.4.45\r\n"
    printf "\r\n"
} > "$tmpfile"

for f in *; do
    printf "%x\r\n" "$(wc -c < "$f")"
    cat "$f"
    printf "\r\n"
done >> "$tmpfile"
printf "0\r\n\r\n" >> "$tmpfile"
cd "$curdir" || exit 1
rm -rf "$tmpdir"
if [[ -n "$dstpath" ]]; then
    cp "$tmpfile" "$dstpath"
else
    echo "$tmpfile"
fi

