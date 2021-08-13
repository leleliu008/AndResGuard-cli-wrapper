# AndResGuard-cli-wrapper
a POSIX sh script wrapper for [AndResGuard-cli](https://github.com/shwenzhang/AndResGuard) that helps you to use this command-line tool quickly and easily.

## Install via package manager

|OS|PackageManager|Installation Instructions|
|-|-|-|
|`macOS`|[HomeBrew](http://blog.fpliu.com/it/os/macOS/software/HomeBrew)|`brew tap leleliu008/fpliu`<br>`brew install andresguard-cli`|
|`GNU/Linux`|[LinuxBrew](http://blog.fpliu.com/it/software/LinuxBrew)|`brew tap leleliu008/fpliu`<br>`brew install andresguard-cli`|
|`ArchLinux`<br>`ArcoLinux`<br>`Manjaro Linux`<br>`Windows/msys2`|[pacman](http://blog.fpliu.com/it/software/pacman)|`curl -LO https://github.com/leleliu008/AndResGuard-cli-wrapper/releases/download/v1.2.1666/AndResGuard-cli-1.2.16-1-any.pkg.tar.gz`<br>`pacman -Syyu --noconfirm`<br>`pacman -U AndResGuard-cli-1.2.16-1-any.pkg.tar.gz`|
|`Windows/WSL`|[LinuxBrew](http://blog.fpliu.com/it/software/LinuxBrew)|`brew tap leleliu008/fpliu`<br>`brew install andresguard-cli`|

## Install using shell script
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leleliu008/AndResGuard-cli-wrapper/master/install.sh)"
```

## zsh-completion for andresguard command
I have provide a zsh-completion script for `andresguard` command. when you've typed `andresguard` then type `TAB` key, it will auto complete the rest for you.

**Note**: to apply this feature, you may need to run the command `autoload -U compinit && compinit`
