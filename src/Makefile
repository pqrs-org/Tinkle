all:
	xcodebuild -configuration Release SYMROOT="$(CURDIR)/build"

clean:
	rm -rf build

xcode:
	open Tinkle.xcodeproj/

run:
	bash ../scripts/codesign.sh build/Release
	open build/Release/Tinkle.app
