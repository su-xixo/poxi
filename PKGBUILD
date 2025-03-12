# Maintainer: Your Name <your.email@example.com>
pkgname=poxi
pkgver=0.1.0
pkgrel=1
pkgdesc="A package manager helper for Arch Linux"
arch=('any')
url="https://github.com/su-xixo/poxi" # Replace with your repo URL
license=('MIT') # Update if using different license
depends=('bash' 'jq' 'fzf' 'pacman') # Add more if dependencies is more
optdepends=('paru: for AUR support'
            'yay: for AUR support')
source=("${pkgname}-${pkgver}.tar.gz::https://github.com/su-xixo/poxi/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('SKIP') # Generate checksum and update here
# backup=('/etc/poxi/packages.json')

package() {
  install -d "${pkgdir}/usr/bin"
  install -Dm755 "poxi.sh" "${pkgdir}/usr/bin/poxi"

  install -d "${pkgdir}/usr/share/poxi/src"
  cp -r src/* "${pkgdir}/usr/share/poxi/src"

  install -d "${pkgdir}/usr/share/poxi"
  install -Dm644 packages.json "${pkgdir}/usr/share/poxi/packages.json"

  install -d "${pkgdir}/usr/share/doc/${pkgname}"
  install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md" # optional
}
