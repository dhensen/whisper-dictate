AUR_REPO := $(HOME)/work/whisper-dictate-git

.PHONY: package install clean aur

package:
	makepkg -sf

install: package
	makepkg -si

clean:
	rm -rf pkg src whisper-dictate-git *.pkg.tar.zst

aur:
	cp PKGBUILD $(AUR_REPO)/PKGBUILD
	makepkg --printsrcinfo > $(AUR_REPO)/.SRCINFO
