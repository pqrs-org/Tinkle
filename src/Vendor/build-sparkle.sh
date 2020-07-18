#!/bin/bash

cd "$(dirname $0)"

#
# Sparkle
#

build=$(pwd)/Sparkle/build

if [[ -d "$build" ]]; then
    echo "Sparkle is already built."
else
    cd Sparkle && xcodebuild -scheme Distribution -configuration Release -derivedDataPath "$build" build
fi
