#!/bin/sh

PATH=/bin:/usr/bin

cd $(dirname $0)/..

version=$(head -n 1 version)
sed "s|@TINKLE_VERSION@|$version|g" src/Tinkle/Info.plist.in >src/Tinkle/Info.plist.tmp

if cmp -s src/Tinkle/Info.plist.tmp src/Tinkle/Info.plist; then
  echo "src/Tinkle/Info.plist is skipped"
else
  cp src/Tinkle/Info.plist.tmp src/Tinkle/Info.plist
  echo "src/Tinkle/Info.plist was updated"
fi

rm -f src/Tinkle/Info.plist.tmp
