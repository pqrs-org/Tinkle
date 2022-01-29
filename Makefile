VERSION = `head -n 1 version`
DMG_IDENTITY = 'Developer ID Application: Fumihiko Takayama (G43BCU2T37)'

all:
	@echo 'Type `make package`'

package:
	git clean -x -d -f
	$(MAKE) -C src all

	rm -f Tinkle-$(VERSION).dmg
	rm -rf tmp
	mkdir -p tmp
	rsync -a src/build/Release/Tinkle.app tmp
	-bash scripts/codesign.sh tmp
	create-dmg --overwrite --identity=$(DMG_IDENTITY) tmp/Tinkle.app
	rm -rf tmp
	mv "Tinkle $(VERSION).dmg" Tinkle-$(VERSION).dmg

clean:
	rm -f *.dmg
	$(MAKE) -C src clean

notarize:
	xcrun notarytool \
		submit Tinkle-$(VERSION).dmg \
		--keychain-profile "pqrs.org notarization" \
		--wait
	$(MAKE) staple
	say "notarization completed"

staple:
	xcrun stapler staple Tinkle-$(VERSION).dmg

swift-format:
	find . -name '*.swift' -print0 | xargs -0 swift-format -i
