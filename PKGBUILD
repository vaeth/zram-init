# Maintainer: Guillaume DELVIT <guiguid@free.fr>

pkgname=zram-init
pkgver=1
pkgrel=1
pkgdesc="Sets up zram-based tmpfs and swap devices on boot"
arch=('any')
url="http://en.wikipedia.org/wiki/ZRam"
license=('GPL')
depends=('bash')
backup=("modprobe.d/zram.conf")
source=("zramctrl"
        "modprobe.d/zram.conf"
        "zramswap.service")
#md5sums=('cc76c38d050983583cd7db06bbf14dbe'
#         '20f7b479830c9511b972268df8479c26'
#         'a6c029dc942c85704b0f6ac1ca078a24'
#         ''
#         '')

package() {
  install -Dm755 sbin/zram-init $pkgdir/usr/bin/zram-init
  install -Dm644 modprobe.d/zram.conf $pkgdir/modprobe.d/zram.conf
  install -Dm644 systemd/system/zram_swap.service $pkgdir/usr/lib/systemd/system/zram_swap.service
  install -Dm644 systemd/system/zram_tmp.service $pkgdir/usr/lib/systemd/system/zram_tmp.service
  install -Dm644 systemd/system/zram_var_tmp.service $pkgdir/usr/lib/systemd/system/zram_var_tmp.service 
}
