#!/bin/sh

VERSION='1.2.16'
FILE_NAME="AndResGuard-cli-${VERSION}.tar.gz"
URL="https://github.com/leleliu008/AndResGuard-cli-wrapper/releases/download/v${VERSION}/${FILE_NAME}"
INSTALL_DIR=/usr/local/opt/andresguard-cli
DEST_LINK_BIN=/usr/local/bin/andresguard
DEST_LINK_ZSH_COMPLETION=/usr/local/share/zsh/site-functions/_andresguard

Color_Red='\033[0;31m'          # Red
Color_Green='\033[0;32m'        # Green
Color_Purple='\033[0;35m'       # Purple
Color_Off='\033[0m'             # Reset

msg() {
    printf "%b\n" "$1"
}

info() {
    msg "${Color_Purple}$@${Color_Off}"
}

success() {
    msg "${Color_Green}[✔] $@${Color_Off}"
}

error_exit() {
    msg "${Color_Red}🔥 $@${Color_Off}"
    exit 1
}

own() {
    ls -ld "$1" | awk '{print $3":"$4}'
}

on_exit() {
    [ "$SUCCESS" = 'true' ] && return 0
    [ "$IS_CREATED_BY_ME_INSTALL_DIR" = 'true' ] && rm -rf "$INSTALL_DIR"
    [ "$IS_CREATED_BY_ME_LINK_BIN" = 'true' ] && rm "$DEST_LINK_BIN"
    [ "$IS_CREATED_BY_ME_LINK_ZSH_COMPLETION" = 'true' ] && rm "$DEST_LINK_ZSH_COMPLETION"
}

main() {
    unset SUCCESS
    unset IS_CREATED_BY_ME_INSTALL_DIR
    unset IS_CREATED_BY_ME_LINK_BIN
    unset IS_CREATED_BY_ME_LINK_ZSH_COMPLETION

    trap on_exit EXIT

    if command -v andresguard; then
        error_exit "andresguard-cli is already installed."
    fi
    
    if [ -d "$INSTALL_DIR" ] ; then
        error_exit "andresguard-cli is already installed. in $INSTALL_DIR"
    else
        if mkdir -p "$INSTALL_DIR" ; then
            IS_CREATED_BY_ME_INSTALL_DIR=true
            cd "$INSTALL_DIR"
        fi
    fi
    
    if command -v curl > /dev/null ; then
        info "Downloading $URL"
        curl -LO "$URL"
    elif command -v wget > /dev/null ; then
        info "Downloading $URL"
        wget "$URL"
    else
        error_exit "please install curl or wget utility."
    fi

    if [ $? -eq 0 ] ; then
        info "Downloaded at $PWD/$FILE_NAME"
    else
        error_exit "Download occured error."
    fi
    
    info "Uncompressing $PWD/$FILE_NAME"
    tar xf "$FILE_NAME"
    
    if [ $? -eq 0 ] ; then
        info "Uncompressed in $PWD"
        
        cat > bin/andresguard <<EOF
#!/bin/sh

resguard() {
    java -jar $INSTALL_DIR/lib/AndResGuard-cli-$VERSION.jar \$@
}

main() {
    case \$1 in
        -v|--version)
            printf "$VERSION\n"
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
        
        chown -R $(own .) .
        chmod 755 bin/andresguard
        chmod 444 zsh-completion/_andresguard
        
        if [ -f "$DEST_LINK_BIN" ] ; then
            error_exit "$DEST_LINK_BIN is already exist."
        else
            [ -d /usr/local/bin ] || mkdir -p /usr/local/bin
            ln -s "$INSTALL_DIR/bin/andresguard" "$DEST_LINK_BIN" &&
            IS_CREATED_BY_ME_LINK_BIN=true
        fi
        
        if [ -f "$DEST_LINK_ZSH_COMPLETION" ] ; then
            error_exit "$DEST_LINK_ZSH_COMPLETION is already exist."
        else
            [ -d /usr/local/share/zsh/site-functions ] || mkdir -p /usr/local/share/zsh/site-functions
            ln -s "$INSTALL_DIR/zsh-completion/_andresguard" "$DEST_LINK_ZSH_COMPLETION" &&
            IS_CREATED_BY_ME_LINK_ZSH_COMPLETION=true
        fi

        SUCCESS=true
        success "Installed success.\n"
        msg "${Color_Purple}Note${Color_Off} : I have provide a zsh-completion script for ${Color_Purple}andresguard${Color_Off} command. when you've typed ${Color_Purple}andresguard${Color_Off} then type ${Color_Purple}TAB${Color_Off} key, it will auto complete the rest for you. to apply this feature, you may need to run the command ${Color_Purple}autoload -U compinit && compinit${Color_Off}"
    else
        error_exit "tar vxf $FILE_NAME occured error."
    fi
}

main
