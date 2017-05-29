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

# use extended color pallete if available
turquoise=""
orange=""
purple=""
hotpink=""
limegreen=""
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
KEL_SEGMENT=" "
KEL_ARROW=""

KEL_JOBS_JOB="⚙️"
KEL_JOBS_LIGHTNING="⚡"
KEL_JOBS_CROSS="❌"

KEL_GIT_ACTION=" performing a %{$limegreen%}%a${PR_RST}"
KEL_GIT_UNSTAGED="🔸"
KEL_GIT_UNTRACKED="💠"
KEL_GIT_STAGED="🔹"
KEL_GIT_BEHIND="🔽"
KEL_GIT_AHEAD="🔼"
KEL_GIT_CLEAN="✅"
KEL_GIT_UNMERGED="🔴"
KEL_GIT_DIVERGED="↪️"
KEL_GIT_STASHED="📦"

# Set the icons based on the font
function icon_set() {
    if [[ $(defaults read com.googlecode.iterm2 | grep "Normal Font" | grep "NerdFont") ]]; then
        KEL_WHALE="\ue7b0"
        KEL_SEGMENT="\ue0c0"
        #KEL_JOBS_JOB="\ue
    fi
}

# Segments
CURRENT_BG='NONE'
PRIMARY_FG=""
if [[ -z "$PRIMARY_FG" ]]; then
  PRIMARY_FG=black
fi

# Begin Segment
prompt_segment() {
  local bg fg
  if [[ -n $1 ]]; then
    bg="%K{$1}"
  else
    bg="%k"
  fi

  if [[ -n $2 ]]; then
    fg="%F{$2}"
  else
    fg="%f"
  fi

  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
      print -n "%{$bg%F{$CURRENT_BG}%}$KEL_SEGMENT%{$fg%}"
  else
    print -n "%{$bg%}%{$fg%}"
  fi

  CURRENT_BG=$1
  if [[ -n $3 ]]; then
      print -n " $3 "
  fi
}

# End Segment
end_prompt() {
  if [[ -n $CURRENT_BG ]]; then
    print -n "%{%k%F{$CURRENT_BG}%}$KEL_SEGMENT"
  else
    print -n "%{%k%}"
  fi

  print -n "%{%f%} "
  CURRENT_BG=''
}

extra_segment() {
    local bg
    if [[ -n $1 ]]; then
      bg="%K{161}"
    else
      bg="%k"
    fi

    print -n "%{$bg%F{$1}%}$KEL_SEGMENT"
}

# Docker
keloran_get_docker_host() {
    local _docker=$DOCKER_HOST
    local _ldocker="local"
    local _docker_local="%{$fg_bold[cyan]%}${KEL_WHALE} $_ldocker"
    local _docker_remote="%{$fg_bold[red]%}${KEL_WHALE} $_docker"
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
    _result="$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result$_status"
    fi
    _result="$_result"
  fi

  if [[ -n $_result ]]; then
      prompt_segment 93 default $_result
  fi
}

# Spaces
keloran_get_space() {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  for i in {0..$LENGTH}
  do
    SPACES="$SPACES "
  done

  echo $SPACES
}

# General
keloran_get_machine() {
  prompt_segment 161 default "%m"

  local user=`whoami`
  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
   prompt_segment 124 default " %(!.%{%F{yellow}%}.)$user"
 fi
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
    prompt_segment 57 default $prompt_short_dir
}

keloran_get_jobs() {
  local symbols
  symbols=()

  if [[ $RETVAL -ne 0 ]]; then
    symbols+="%{%F{red}%}$KEL_JOBS_CROSS"
  fi

  if [[ $UID -eq 0 ]]; then
    symbols+="%{%F{yellow}%}$KEL_JOBS_LIGHTNING"
  fi

  if [[ $(jobs -l | wc -l) -gt 0 ]]; then
    symbols+="%{%F{cyan}%}$KEL_JOBS_JOB"
  fi

  if [[ -n "$symbols" ]]; then
    prompt_segment $PRIMARY_FG default " $symbols "
  fi
}

keloran_nice_exit() {
    local _fail=$(nice_exit_code)
    if [[ -n "${_fail}" ]]; then
        prompt_segment 99 default $_fail
        extra_segment 99
    fi
}

function keloran_command() {
    RETVAL=$?
    CURRENT_BG='NONE'
    keloran_get_jobs
    keloran_get_machine
    keloran_get_location
    keloran_git_prompt
    end_prompt
}

keloran_remote() {
    if [[ $SSH_CONNECTION ]]; then
        echo ":: %{$limegreen%}Remote Server$KEL_CLEAN"
    fi
}

function keloran_precmd {
    _SPACES=`keloran_get_space`

    setopt prompt_subst
    PROMPT='$(keloran_nice_exit)$(keloran_command)$KEL_CLEAN'
    RPROMPT='$(nvm_prompt_info)$(keloran_get_docker_host)$(keloran_remote)[%*]'
}

kel_setup() {
  icon_set
  autoload -U add-zsh-hook
  add-zsh-hook precmd keloran_precmd
}

kel_setup "$@"
