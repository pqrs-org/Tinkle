VERSION = `head -n 1 version`
DMG_IDENTITY = 'Developer ID Application: Fumihiko Takayama (G43BCU2T37)'

all:
	@echo 'Type `make package`'

update-info-plist:
	bash scripts/update-info-plist.sh

package:
	$(MAKE) update-info-plist
	$(MAKE) -C src clean all

	rm -f Tinkle-$(VERSION).dmg
	rm -rf tmp
	mkdir -p tmp
	rsync -a src/build/Release/Tinkle.app tmp
	-bash scripts/codesign.sh tmp
	create-dmg --overwrite --identity=$(DMG_IDENTITY) tmp/Tinkle.app
	rm -rf tmp
	mv "Tinkle $(VERSION).dmg" Tinkle-$(VERSION).dmg

clean:
	$(MAKE) -C src clean

notarize:
	xcrun altool --notarize-app \
		-t osx \
		-f Tinkle-$(VERSION).dmg \
		--primary-bundle-id 'org.pqrs.Tinkle' \
		-u 'tekezo@pqrs.org' \
		-p '@keychain:pqrs.org-notarize-app'

staple:
	xcrun stapler staple Tinkle-$(VERSION).dmg
