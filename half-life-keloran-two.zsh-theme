# prompt style and colors based on Steve Losh's Prose theme:
# http://github.com/sjl/oh-my-zsh/blob/master/themes/prose.zsh-theme
#
# vcs_info modifications from Bart Trojanowski's zsh prompt:
# http://www.jukie.net/bart/blog/pimping-out-zsh-prompt
#
# git untracked files modification from Brian Carper:
# http://briancarper.net/blog/570/git-info-in-your-zsh-prompt

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

#use extended color pallete if available
if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    turquoise="%F{81}"
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
else
    turquoise="$fg[cyan]"
    orange="$fg[yellow]"
    purple="$fg[magenta]"
    hotpink="$fg[red]"
    limegreen="$fg[green]"
fi

# Globals
KEL_WHALE="🐳"
KEL_CLEAN="%{$reset_color%}"

KEL_SUFFIX="%{$orange%}λ$KEL_CLEAN "

KEL_TIME="[%*]"

KEL_HOST=""

KEL_GIT_PREFIX="🌀"
KEL_GIT_ACTION=" performing a %{$limegreen%}%a${PR_RST}"
KEL_GIT_UNSTAGED="🔸"
KEL_GIT_UNTRACKED="💠"
KEL_GIT_STAGED="🔹"
KEL_GIT_BEHIND="🔽"
KEL_GIT_AHEAD="🔼"
KEL_GIT_CLEAN="✅"
KEL_GIT_UNMERGED="🔴"
KEL_GIT_DIVERGED="🔃"
KEL_GIT_STASHED="📦"

# Docker
keloran_get_docker_host() {
    local _docker=$DOCKER_HOST
    local _ldocker="local"
    local _docker_local="${KEL_WHALE}  %{$fg_bold[cyan]%}$_ldocker"
    local _docker_remote="${KEL_WHALE}  %{$fg_bold[red]%}$_docker"
    local _docker_status="$_docker_remote"

    # No Docker at all
    if [[ -z $_docker ]]; then
        _docker_status=""
    fi

    # Local Docker
    if [ -e "/var/run/docker.sock" ]; then
        _docker_status="$_docker_local"
    fi

    echo "${_docker_status} $KEL_CLEAN"
}

# GIT
keloran_git_status() {
  _STATUS=""
  _INDEX=$(command git status --porcelain 2> /dev/null)

  local _staged=false
  local _unstaged=false
  local _unmerged=false

  # Files
  if [[ -n $_INDEX ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
        _STATUS="$_STATUS$KEL_GIT_STAGED"
        _staged=true
    fi

    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _unstaged=true
      if [[ _staged ]]; then
        _STATUS="$_STATUS $KEL_GIT_UNSTAGED"
      else
        _STATUS="$_STATUS$KEL_GIT_UNSTAGED"
      fi
    fi

    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _unmerged=true

      if [[ _unstaged ]]; then
        _STATUS="$_STATUS $KEL_GIT_UNMERGED"
      else
        _STATUS="$_STATUS$KEL_GIT_UNMERGED"
      fi
    fi

    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      if [[ _unmerged ]]; then
        _STATUS="$_STATUS $KEL_GIT_UNTRACKED"
      else
        _STATUS="$_STATUS$KEL_GIT_UNTRACKED"
      fi
    fi
  else
      _STATUS="$_STATUS$KEL_GIT_CLEAN"
  fi

  # Repo
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
      _STATUS="$_STATUS $KEL_GIT_AHEAD"
  fi

  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
      _STATUS="$_STATUS $KEL_GIT_BEHIND"
  fi

  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
      _STATUS="$_STATUS $KEL_GIT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
      _STATUS="$_STATUS $KEL_GIT_STASHED"
  fi

  echo " $_STATUS"
}

keloran_git_branch() {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

keloran_git_prompt() {
  local _branch=$(keloran_git_branch)
  local _status=$(keloran_git_status)
  local _result=""

  if [[ "${_branch}x" != "x" ]]; then
    _result="$KEL_GIT_PREFIX  %{$fg[cyan]%}$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result$_status"
    fi
    _result=" on $_result $KEL_CLEAN"
  fi

  echo $_result
}

keloran_get_space() {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  # for i in {0..$LENGTH}
  # do
  #   SPACES="$SPACES "
  # done

  echo $SPACES
}

keloran_get_machine() {
  local _loc_machine="%{$hotpink%}%m%{$reset_color%}::%{$purple%}%n$KEL_CLEAN"
  echo $_loc_machine
}

keloran_get_location() {
    pwd_root=$PWD
    while [[ $pwd_root != / && ! -e $pwd_root/.git ]]; do
        pwd_root=$pwd_root:h
    done
    if [[ $pwd_root = / ]]; then
        unset $pwd_root
        prompt_short_dir=%~
    else
        parent=${pwd_root%\/*}
        prompt_short_dir=${PWD#$parent/}
    fi
    echo " in %{$limegreen%}$prompt_short_dir$KEL_CLEAN"
}

function keloran_precmd {
    _SPACES=`keloran_get_space`
}

setopt prompt_subst
PROMPT='$(keloran_get_machine)$(keloran_get_location)$(keloran_git_prompt) $KEL_SUFFIX'
RPROMPT='$(nvm_prompt_info) $(keloran_get_docker_host)[%*]'

autoload -U add-zsh-hook
add-zsh-hook precmd keloran_precmd
