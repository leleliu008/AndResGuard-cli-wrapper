#!/bin/sh

COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;34m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

print() {
    printf "%b" "$*"
}

echo() {
    print "$*\n"
}

info() {
    echo "$COLOR_PURPLE==>$COLOR_OFF $COLOR_GREEN$@$COLOR_OFF"
}

success() {
    print "${COLOR_GREEN}[✔] $*\n${COLOR_OFF}"
}

warn() {
    print "${COLOR_YELLOW}🔥  $*\n${COLOR_OFF}" >&2
}

error() {
    print "${COLOR_RED}[✘] $*\n${COLOR_OFF}" >&2
}

die() {
    print "${COLOR_RED}[✘] $*\n${COLOR_OFF}" >&2
    exit 1
}

# check if file exists
# $1 FILEPATH
file_exists() {
    [ -n "$1" ] && [ -e "$1" ]
}

# check if command exists in filesystem
# $1 command name or path
command_exists_in_filesystem() {
    case $1 in
        */*) executable "$1" ;;
        *)   command -v "$1" > /dev/null
    esac
}

executable() {
    file_exists "$1" && [ -x "$1" ]
}

die_if_file_is_not_exist() {
    file_exists "$1" || die "$1 is not exists."
}

die_if_not_executable() {
    executable "$1" || die "$1 is not executable."
}

step() {
    STEP_NUM=$(expr ${STEP_NUM-0} + 1)
    STEP_MESSAGE="$@"
    echo
    echo "${COLOR_PURPLE}=>> STEP ${STEP_NUM} : ${STEP_MESSAGE} ${COLOR_OFF}"
}

run() {
    info "$*"
    eval "$*"
}

sed_in_place() {
    if command -v gsed > /dev/null ; then
        unset SED_IN_PLACE_ACTION
        SED_IN_PLACE_ACTION="$1"
        shift
        # contains ' but not contains \'
        if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
            run gsed -i "\"$SED_IN_PLACE_ACTION\"" $@
        else
            run gsed -i "'$SED_IN_PLACE_ACTION'" $@
        fi
    elif command -v sed  > /dev/null ; then
        if sed -i 's/a/b/g' $(mktemp) 2> /dev/null ; then
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i "'$SED_IN_PLACE_ACTION'" $@
            fi
        else
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i '""' "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i '""' "'$SED_IN_PLACE_ACTION'" $@
            fi
        fi
    else
        die "please install sed utility."
    fi
}

#examples:
# printf ss | sha256sum
# cat FILE  | sha256sum
# sha256sum < FILE
sha256sum() {
    if [ $# -eq 0 ] ; then
        if echo | command sha256sum > /dev/null 2>&1 ; then
             command sha256sum | cut -d ' ' -f1
        elif command -v openssl > /dev/null ; then
             openssl sha256 | rev | cut -d ' ' -f1 | rev
        else
            return 1
        fi
    else
        die_if_file_is_not_exist "$1"
        if command -v openssl > /dev/null ; then
             openssl sha256    "$1" | cut -d ' ' -f2
        elif echo | command sha256sum > /dev/null 2>&1 ; then
             command sha256sum "$1" | cut -d ' ' -f1
        else
            die "please install openssl or GNU CoreUtils."
        fi
    fi
}

main() {
    set -e

    command -v makepkg > /dev/null || die "please install makepkg."

    unset RELEASE_VERSION

    unset RELEASE_JAR_FILE_NAME
    unset RELEASE_TAR_FILE_NAME
    unset RELEASE_TAR_FILE_SHA256SUM

    RELEASE_VERSION=$(bin/andresguard --version)

    BASE_URL="https://github.com/leleliu008/AndResGuard-cli-wrapper/releases/download/v$RELEASE_VERSION"

    RELEASE_JAR_FILE_NAME="AndResGuard-cli-$RELEASE_VERSION.jar"
    RELEASE_TAR_FILE_NAME="AndResGuard-cli-$RELEASE_VERSION.tar.gz"
    RELEASE_TAR_URL="$BASE_URL/$RELEASE_TAR_FILE_NAME"

    MSYS2_PKG_FILE_NAME="AndResGuard-cli-$RELEASE_VERSION-1-any.pkg.tar.gz"
    MSYS2_PKG_URL="$BASE_URL/$MSYS2_PKG_FILE_NAME"

    HOMEBREW_FORMULA_FINENAME='andresguard-cli.rb'

    run tar zvcf "$RELEASE_TAR_FILE_NAME" bin/andresguard zsh-completion/_andresguard lib/$RELEASE_JAR_FILE_NAME

    RELEASE_TAR_FILE_SHA256SUM=$(sha256sum "$RELEASE_TAR_FILE_NAME")
    
    success "sha256sum($RELEASE_TAR_FILE_NAME)=$RELEASE_TAR_FILE_SHA256SUM"

    sed_in_place "s|sha256sums=(.*)|sha256sums=(\'$RELEASE_TAR_FILE_SHA256SUM\')|" PKGBUILD
    sed_in_place "s|pkgver=.*|pkgver=\'$RELEASE_VERSION\'|"                        PKGBUILD

    sed_in_place "s|VERSION='[0-9].[0-9].[0-9][0-9]'|VERSION='$RELEASE_VERSION'|" install.sh

    sed_in_place "s|v[0-9].[0-9].[0-9][0-9]|v$RELEASE_VERSION|"                                README.md
    sed_in_place "s|AndResGuard-cli-[0-9].[0-9].[0-9][0-9]|AndResGuard-cli-$RELEASE_VERSION|g" README.md

    run makepkg

    run git add PKGBUILD README.md install.sh
    run git commit -m "'publish new version $RELEASE_VERSION'"
    run git push origin master

    run gh release create v"$RELEASE_VERSION" "$RELEASE_TAR_FILE_NAME" "$MSYS2_PKG_FILE_NAME" --notes "'release $RELEASE_VERSION'"

    run git clone git@github.com:leleliu008/homebrew-fpliu.git
    run cd homebrew-fpliu/Formula

    sed_in_place "/url/c    \  sha256   \"$RELEASE_TAR_FILE_SHA256SUM\"" $HOMEBREW_FORMULA_FINENAME
    sed_in_place "/sha256/c \  url      \"$RELEASE_TAR_URL\""            $HOMEBREW_FORMULA_FINENAME

    run git add $HOMEBREW_FORMULA_FINENAME
    run git commit -m "'publish new version andresguard-cli $RELEASE_VERSION'"
    run git push origin master

    run cd -

    run rm -rf homebrew-fpliu
    run rm -f  "$RELEASE_TAR_FILE_NAME"
    run rm -f    "$MSYS2_PKG_FILE_NAME"
    run rm -rf pkg
    run rm -rf src
}

main $@
