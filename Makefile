.PHONY: package install clean

package:
	makepkg -sf

install: package
	makepkg -si

clean:
	rm -rf pkg src whisper-dictate-git *.pkg.tar.zst
