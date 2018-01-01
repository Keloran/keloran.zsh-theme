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
KEL_SEGMENT=">"
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
    # Nerd Font
    local NERD_FONT=false

    if [[ -e "/Applications/iTerm2.app" ]]; then
        if [[ $(defaults read com.googlecode.iterm2 | grep "Normal Font" | grep "NerdFont") ]]; then
            NERD_FONT=true
        fi
    fi

    if [[ -e "/Applications/Hyper.app" ]]; then
        local whoDir="/Users/$(whoami)"

        if [[ $(cat "${whoDir}/.hyper.js" | grep "Nerd Font") ]]; then
            NERD_FONT=true
        fi
    fi


    if [[ $NERD_FONT ]]; then
        KEL_WHALE="\ue7b0"

        KEL_SEGMENT_FLAMES="\ue0c0"
        KEL_SEGMENT_LITTLE_BLOCKS="\ue0c4"
        KEL_SEGMENT_BIG_BLOCKS="\ue0c6"
        KEL_SEGMENT_SPIKES="\ue0c8"
        KEL_SEGMENT_LEGO="\ue0ce"
        KEL_SEGMENT_HEX="\ue0cc"
        KEL_SEGMENT_FILED_CURVE="\ue0b4"
        KEL_SEGMENT_FILED_ARROW="\ue0b0"
        KEL_SEGMENT=$KEL_SEGMENT_FLAMES

        KEL_JOBS_JOB="\uf1d1"
        KEL_JOBS_LIGHTNING="\uf135"
        KEL_JOBS_CROSS="\ue752"
        KEL_GIT_UNSTAGED="\uf06a"
        KEL_GIT_UNTRACKED="\uf059"
        KEL_GIT_STAGED="\uf05a"
        KEL_GIT_BEHIND="\uf060"
        KEL_GIT_AHEAD="\uf061"
        KEL_GIT_CLEAN="\uf058"
        KEL_GIT_UNMERGED="\uf057"
        KEL_GIT_DIVERGED="\ue727"
        KEL_GIT_STASHED="\ue79b"
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
  local bg fg segment randnum
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

  randnum=$(((RANDOM % 7) + 1))
  case $randnum in
    1)
      segment=$KEL_SEGMENT_FLAMES
      ;;
    2)
      segment=$KEL_SEGMENT_LITTLE_BLOCKS
      ;;
    3)
      segment=$KEL_SEGMENT_BIG_BLOCKS
      ;;
    4)
      segment=$KEL_SEGMENT_SPIKES
      ;;
    5)
      segment=$KEL_SEGMENT_HEX
      ;;
    6)
      segment=$KEL_SEGMENT_FILED_CURVE
      ;;
    7)
      segment=$KEL_SEGMENT_FILED_ARROW
      ;;
    *)
      segment=$KEL_SEGMENT
      ;;
  esac

  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
      print -n "%{$bg%F{$CURRENT_BG}%}$segment%{$fg%}"
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
  local segment randnum

  randnum=$(((RANDOM % 7) + 1))
  case $randnum in
    1)
      segment=$KEL_SEGMENT_FLAMES
      ;;
    2)
      segment=$KEL_SEGMENT_LITTLE_BLOCKS
      ;;
    3)
      segment=$KEL_SEGMENT_BIG_BLOCKS
      ;;
    4)
      segment=$KEL_SEGMENT_SPIKES
      ;;
    5)
      segment=$KEL_SEGMENT_HEX
      ;;
    6)
      segment=$KEL_SEGMENT_FILED_CURVE
      ;;
    7)
      segment=$KEL_SEGMENT_FILED_ARROW
      ;;
    *)
      segment=$KEL_SEGMENT
      ;;
  esac

  if [[ -n $CURRENT_BG ]]; then
    print -n "%{%k%F{$CURRENT_BG}%}$segment"
  else
    print -n "%{%k%}$segment"
  fi

  print -n "%{%f%} "

  CURRENT_BG=''
}

extra_segment() {
    local bg
    if [[ -n $1 ]]; then
      bg="%K{99}"
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
  local GIT_INSTALLED=true
  if [[ $(which git | grep "not found") ]]; then
    GIT_INSTALLED=false
  fi

  local _STATUS=""
  local _INDEX=$(command git status --porcelain 2> /dev/null)

  local _staged=false
  local _unstaged=false
  local _unmerged=false

  if [[ $GIT_INSTALLED ]]; then
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
  prompt_segment 8 default "%m"

  local user=$(whoami)
  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
   prompt_segment 56 default " %(!.%{%F{yellow}%}.)$user"
 fi
}

keloran_get_location() {
    pwd_root=$PWD
    while [[ $pwd_root != / && ! -e $pwd_root/.git ]]; do
        pwd_root=$pwd_root:h
    done
    if [[ $pwd_root = / ]]; then
        unset pwd_root
        prompt_short_dir=%~
    else
        parent=${pwd_root%\/*}
        prompt_short_dir=${PWD#$parent/}
    fi
    prompt_segment 66 default $prompt_short_dir
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
    local _fail
    if [[ $(type -f nice_exit | grep "not found") ]]; then
        _fail=false
    else
        _fail=$(nice_exit_code)
    fi

    if [[ -z $_fail ]]; then
        if [[ -n "${_fail}" ]]; then
            prompt_segment 99 default $_fail
            extra_segment 99
        fi
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
