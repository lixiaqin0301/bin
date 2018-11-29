#!/bin/sh
echo '#include <errno.h>' | cpp -dM | sed -n -e '/#define  *E/s/#define  *//p' | sort -k2n | awk '{print $2,$1}'

