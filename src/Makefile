all:
	/usr/bin/python3 ../scripts/update-version.py
	bash run-xcodegen.sh
	xcodebuild -configuration Release SYMROOT="$(CURDIR)/build"

clean:
	rm -rf Tinkle.xcodeproj
	rm -rf build

xcode:
	open Tinkle.xcodeproj/

run:
	bash ../scripts/codesign.sh build/Release
	open build/Release/Tinkle.app
