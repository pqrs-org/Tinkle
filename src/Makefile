all:
	xcodegen generate --use-cache --spec project-with-codesign.yml
	xcodebuild -configuration Release SYMROOT="$(CURDIR)/build"

clean:
	rm -rf Tinkle.xcodeproj
	rm -rf build

xcode:
	open Tinkle.xcodeproj/

run:
	bash ../scripts/codesign.sh build/Release
	open build/Release/Tinkle.app
