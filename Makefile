VERSION = `head -n 1 version`

all:
	@echo 'Type `make package`'

package:
	$(MAKE) -C src
	
	rm -rf Tinkle-$(VERSION)
	mkdir -p Tinkle-$(VERSION)
	rsync -a src/build/Release/Tinkle.app Tinkle-$(VERSION)
	bash scripts/codesign.sh Tinkle-$(VERSION)
	hdiutil create -nospotlight Tinkle-$(VERSION).dmg -srcfolder Tinkle-$(VERSION) -fs 'Journaled HFS+'
	rm -rf Tinkle-$(VERSION)

	rm -rf dist
	mkdir -p dist
	mv Tinkle-*.dmg dist

clean:
	$(MAKE) -C src clean

notarize:
	xcrun altool --notarize-app \
		-t osx \
		-f dist/Tinkle-*.dmg \
		--primary-bundle-id 'org.pqrs.Tinkle' \
		-u 'tekezo@pqrs.org' \
		-p '@keychain:pqrs.org-notarize-app'

staple:
	xcrun stapler staple dist/Tinkle-*.dmg
