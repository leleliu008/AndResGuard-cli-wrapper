# Maintainer: fpliu <leleliu008@gmail.com>

pkgname=('andresguard-cli')
pkgver='1.2.16'
pkgrel=1
pkgdesc="Proguard resource for Android by wechat team"
arch=('any')
license=('custom')
url="https://github.com/leleliu008/andresguard-cli-wrapper"
makedepends=()
source=("https://github.com/leleliu008/AndResGuard-cli-wrapper/releases/download/v${pkgver}/AndResGuard-cli-${pkgver}.tar.gz")
sha256sums=('69b1e5fe31d0441db951506627d74f808424488d08a7d26c3c74cb54f7ae8fdb')

build() {
    true
}

check() {
    cd "${srcdir}"
    bin/andresguard -v
}

package() {
    depends=('p7zip')
    
    mkdir -p ${pkgdir}/usr/local/bin
    mkdir -p ${pkgdir}/usr/local/lib
    mkdir -p ${pkgdir}/usr/local/share/zsh/site-functions
    
    cp -f ${srcdir}/lib/AndResGuard-cli-${pkgver}.jar ${pkgdir}/usr/local/lib/
    cp -f ${srcdir}/zsh-completion/_andresguard ${pkgdir}/usr/local/share/zsh/site-functions/

    cat > ${pkgdir}/usr/local/bin/andresguard <<EOF
#!/bin/sh

resguard() {
    java -jar /usr/local/lib/AndResGuard-cli-${pkgver}.jar \$@
}

main() {
    case \$1 in
        -v|--version)
            printf "${pkgver}\n"
            ;;
        -guard)
            shift
            resguard \$@
            ;;
        *)  resguard \$@
    esac
}

main \$@
EOF
    chmod 755 ${pkgdir}/usr/local/bin/andresguard
}
