# Maintainer: Dino Hensen <dino.hensen@gmail.com>
pkgname=whisper-dictate
pkgver=0.1.0
pkgrel=1
pkgdesc='Toggle local speech-to-text dictation using whisper.cpp'
arch=('any')
url='https://github.com/dhensen/whisper-dictate'
license=('MIT')
depends=('whisper.cpp' 'ydotool' 'libnotify')
source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
    install -Dm755 "$srcdir/$pkgname-$pkgver/dictate-toggle" "$pkgdir/usr/bin/dictate-toggle"
}
