all:
	/usr/bin/python3 ../scripts/update_version.py
	bash run-xcodegen.sh
	xcodebuild -configuration Release SYMROOT="$(CURDIR)/build"
# Copy embedded.provisionprofile
	cp Tinkle/Tinkle.provisionprofile build/Release/Tinkle.app/Contents/embedded.provisionprofile
	$(MAKE) codesign
	$(MAKE) -C .. clean-launch-services-database

clean: purge-swift-package-manager-cache
	rm -rf Tinkle.xcodeproj
	rm -rf build

codesign:
# Helper
	bash ../scripts/codesign.sh 'build/Release/Tinkle.app/Contents/XPCServices/Tinkle Helper.xpc' $(CURDIR)/Helper/Helper.entitlements
# Sparkle
	bash ../scripts/codesign.sh build/Release/Tinkle.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc
	bash ../scripts/codesign.sh build/Release/Tinkle.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc $(CURDIR)/org.sparkle-project.Downloader.entitlements
	bash ../scripts/codesign.sh build/Release/Tinkle.app/Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate
	bash ../scripts/codesign.sh build/Release/Tinkle.app/Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app
	bash ../scripts/codesign.sh build/Release/Tinkle.app/Contents/Frameworks/Sparkle.framework
# libswift_Concurrency.dylib
	bash ../scripts/codesign.sh build/Release/Tinkle.app/Contents/Frameworks/libswift_Concurrency.dylib
# Tinkle
	bash ../scripts/codesign.sh build/Release/Tinkle.app $(CURDIR)/Tinkle/Tinkle.entitlements

purge-swift-package-manager-cache:
	rm -rf ~/Library/Developer/Xcode/DerivedData/Tinkle-*
	rm -rf ~/Library/Caches/org.swift.swiftpm/repositories/Sparkle-*

xcode:
	open Tinkle.xcodeproj/

run:
	open build/Release/Tinkle.app

swift-format:
	find . -name '*.swift' -print0 | xargs -0 swift-format -i

install:
	rsync -a --delete build/Release/Tinkle.app /Applications
