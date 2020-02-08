VERSION = `head -n 1 version`

all:
	@echo 'Type `make package`'

update-info-plist:
	bash scripts/update-info-plist.sh

package:
	$(MAKE) update-info-plist
	$(MAKE) -C src clean all

	rm -rf Tinkle-$(VERSION)
	mkdir -p Tinkle-$(VERSION)
	rsync -a src/build/Release/Tinkle.app Tinkle-$(VERSION)
	-bash scripts/codesign.sh Tinkle-$(VERSION)
	hdiutil create -nospotlight Tinkle-$(VERSION).dmg -srcfolder Tinkle-$(VERSION) -fs 'Journaled HFS+'
	rm -rf Tinkle-$(VERSION)

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
