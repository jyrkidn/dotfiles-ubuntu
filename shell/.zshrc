# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
zplug "zpm-zsh/material-colors", use:material-colors.plugin.zsh, from:github, as:plugin
zplug "romkatv/powerlevel10k", as:theme, depth:1

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

case $TERM in
  xterm*)
    precmd () {print -Pn "\e]0;%~\a"}
    ;;
esac

alias cat="bat"
alias satis="ssh fuchikoma 'alfons run_satis_build' && notify-send 'Satis build is finished!'"

merge() {
    current=$(git rev-parse --abbrev-ref HEAD)
    branch=$1
    git checkout $branch
    git pull origin $branch
    git merge $current
    git push origin $branch
    git checkout $current
}

tag() {
    tag=$1
    git tag -a $tag -m "Released $tag" && git push -u origin $tag
}

dirty_folders() {
  START=`pwd`; find . -type d | egrep "\.git$" | while read git_folder; do s=`cd $git_folder; cd ..; git status -sb`; count=`echo $s | wc -l`; [ ! $count -eq 1 ] && echo $git_folder | sed 's/\.git//g'; cd $START; done
}

# zz - smart directory changer
# 14dec2015  +chris+
# 15dec2015  +chris+ clean up nonexisting paths
chpwd_zz() {
  print -P '0\t%D{%s}\t1\t%~' >>~/.zz
}
zz() {
  awk -v ${(%):-now='%D{%s}'} <~/.zz '
    function r(t,f) {
      age = now - t
      return (age<3600) ? f*4 : (age<86400) ? f*2 : (age<604800) ? f/2 : f/4
    }
    { f[$4]+=$3; if ($2>l[$4]) l[$4]=$2 }
    END { for(i in f) printf("%d\t%d\t%d\t%s\n",r(l[i],f[i]),l[i],f[i],i) }' |
      sort -k2 -n -r | sed 9000q | sort -n -r -o ~/.zz
  if (( $# )); then
    local p=$(awk 'NR != FNR { exit }  # exit after first file argument
                   { for (i = 3; i < ARGC; i++) if ($4 !~ ARGV[i]) next
                     print $4; exit }' ~/.zz ~/.zz "$@")
    [[ $p ]] || return 1
    local op=print
    [[ -t 1 ]] && op=cd
    if [[ -d ${~p} ]]; then
      $op ${~p}
    else
      # clean nonexisting paths and retry
      while read -r line; do
        [[ -d ${~${line#*$'\t'*$'\t'*$'\t'}} ]] && print -r $line
      done <~/.zz | sort -n -r -o ~/.zz
      zz "$@"
    fi
  else
    sed 10q ~/.zz
  fi
}
alias z=' zz'

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

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# collect all chpwd_* hooks
chpwd_functions=( ${(kM)functions:#chpwd?*} )

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
