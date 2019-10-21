##### Script to setup LinuxBrew and fish shell on linux ##### 

cd ~

sudo apt-get install build-essential ncurses-dev libncurses5-dev curl gettext bc autoconf git python ruby -y 
sudo yum groupinstall "Development Tools" -y
sudo yum install ncurses-devel curl -y

echo '### Custom exports for LinuxBrew ###' >> ~/.bashrc
echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >> ~/.bashrc
echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >> ~/.bashrc
echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >> ~/.bashrc
echo 'export HOMEBREW_BUILD_FROM_SOURCE=1' >> ~/.bashrc
source ~/.bashrc

##### Installs LinuxBrew and installs required packages ##### 

echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/linuxbrew/go/install)"

brew doctor
brew update
brew install coreutils binutils fish zsh htop homebrew/dupes/nano
brew cleanup

##### Compiling MTR from git HEAD and installing it #####
git clone https://github.com/traviscross/mtr.git
cd mtr
./bootstrap.sh
./configure --without-gtk
make
sudo make install
cd .. 
rm -rf mtr/

##### Adding fish and ZSH shells to shells #####
echo $(which fish) | sudo tee -a /etc/shells
echo $(which zsh) | sudo tee -a /etc/shells

##### Adding nanorc to config #####
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

##### Installing prezto #####
zsh | q
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

##### ZSH Completions #####
brew install zsh-autosuggestions zsh-history-substring-search zsh-navigation-tools zshdb zsh-completions zsh-lovers zsh-syntax-highlighting

##### Adding ZSH completions to path #####
echo "
source $HOME/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.linuxbrew/share/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$HOME/.linuxbrew/share/zsh-syntax-highlighting/highlighters
" >> ~/.zshrc

echo '
fpath+=( $HOME/.linuxbrew/share/zsh-navigation-tools )
fpath=($HOME/.linuxbrew/share/zsh-completions $fpath)
' >> ~/.zshrc

# Rebuild the z cache
rm -f ~/.zcompdump; compinit
source ~/.zshrc
zsh

##### Incase glibc install fails #####
#/bin/rm -rf ~/.linuxbrew/Cellar/glibc

##### Changing to zsh shell #####
sudo chsh -s $(which zsh) $USER

##### Creating directories for fish shell #####
mkdir -p ~/.config/fish/functions/

##### Adding custom functions to fish shell #####
echo '
function dl --description "Parallel and resumable download with aria2c"
    aria2c -c -x 4 $argv[1]
end
' > ~/.config/fish/functions/dl.fish

##### Adding custom functions to fish shell for !! #####
echo '
function sudo
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end
' > ~/.config/fish/functions/sudo.fish

##### Adding variables and paths in fish shell #####

echo '
Now run these lazy boyyy......

set -U fish_user_paths ~/.linuxbrew/bin/ $fish_user_paths
set -U fish_user_paths ~/.linuxbrew/sbin/ $fish_user_paths
set -U fish_user_paths ~/.linuxbrew/opt/ $fish_user_paths
set -U fish_user_paths ~/.linuxbrew/share/man/ $fish_user_paths
set -U fish_user_paths ~/.linuxbrew/share/info/ $fish_user_paths
set -U HOMEBREW_BUILD_FROM_SOURCE 1

curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisherman
fisher simple z fzf edc/bass omf/tab
fisher omf/plugin-brew
fisher omf/theme-l
'

echo "Now starting fish shell..."
fish
