all:
	/usr/bin/python3 ../scripts/update-version.py
	bash run-xcodegen.sh
	xcodebuild -configuration Release SYMROOT="$(CURDIR)/build"

clean:
	rm -rf Tinkle.xcodeproj
	rm -rf build

purge-swift-package-manager-cache:
	rm -rf ~/Library/Developer/Xcode/DerivedData/Tinkle-*
	rm -rf ~/Library/Caches/org.swift.swiftpm/repositories/Sparkle-*

xcode:
	open Tinkle.xcodeproj/

run:
	bash ../scripts/codesign.sh build/Release
	open build/Release/Tinkle.app

install:
	bash ../scripts/codesign.sh build/Release
	rsync -a --delete build/Release/Tinkle.app /Applications
