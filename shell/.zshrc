export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

source ~/.zplug/init.zsh
source ~/.profile
source /etc/profile

# external Plugins
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"

# oh-my-zsh plugins
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "plugins/gitignore", from:oh-my-zsh
zplug "plugins/git-prompt", from:oh-my-zsh
zplug "plugins/man", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/ubuntu", from:oh-my-zsh
zplug "plugins/composer", from:oh-my-zsh
zplug "zsh-users/zsh-history-substring-search", from:github, as:plugin, use:zsh-syntax-highlighting.zsh, use:zsh-history-substring-search.zsh
zplug "jessarcher/zsh-artisan", use:artisan.plugin.zsh, from:github, as:plugin
zplug "zpm-zsh/ls", use:ls.plugin.zsh, from:github, as:plugin
zplug "zpm-zsh/dircolors-material", use:dircolors-material.plugin.zsh, from:github, as:plugin
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme

POWERLEVEL9K_PROMPT_ON_NEWLINE=true

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

case $TERM in
  xterm*)
    precmd () {print -Pn "\e]0;%~\a"}
    ;;
esac

alias cat="bat"

. ~/apps/z/z.sh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load
fpath=($fpath "/home/jyrki/.zfunctions")

export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
