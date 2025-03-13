# Maintainer: Your Name <your.email@example.com>
pkgname=poxi
pkgver=0.1.2
pkgrel=3
pkgdesc="A package manager helper for Arch Linux"
arch=('any')
url="https://github.com/su-xixo/poxi" # Replace with your repo URL
license=('MIT') # Update if using different license
depends=('bash' 'jq' 'fzf' 'moreutils') # Add more if dependencies is more
optdepends=('paru: for AUR support'
            'yay: for AUR support')
source=("${pkgname}-${pkgver}.tar.gz::https://github.com/su-xixo/poxi/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('SKIP') # Generate checksum and update here
# backup=('/etc/poxi/packages.json')

package() {
  cd "$pkgname-$pkgver"

  find . -type f -executable -exec chmod 755 {} \;
  install -d "${pkgdir}/usr/share/${pkgname}"
  cp -r * "${pkgdir}/usr/share/${pkgname}"
  # find "${pkgdir}/usr/share/${pkgname}" -type f -E -exec chmod 755 {} \;

  install -d "${pkgdir}/usr/bin"
  ln -s "/usr/share/${pkgname}/poxi" "${pkgdir}/usr/bin/${pkgname}"

}
