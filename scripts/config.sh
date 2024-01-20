[[ "$DOTFILESDIR" == "" ]] && DOTFILESDIR="$PWD"
[[ "$XDG_CACHE_HOME" == "" ]] && XDG_CACHE_HOME="$HOME/.cache"
[[ "$XDG_CONFIG_HOME" == "" ]] && XDG_CONFIG_HOME="$HOME/.config"
[[ "$XDG_DATA_HOME" == "" ]] && XDG_DATA_HOME="$HOME/.local/share"
[[ "$XDG_STATE_HOME" == "" ]] && XDG_STATE_HOME="$HOME/.local/state"

declare -A DFLOADED
declare -A DFCONF
DFCONF[MACHINE]="default"
DFCONF[IS_FEDORA]="0"
command -v dnf > /dev/null
[[ "$?" == "0" ]] && DFCONF[IS_FEDORA]="1"
DFCONF[IS_WSL]="0"
[[ "$(uname -r)" == *WSL2 ]] && DFCONF[IS_WSL]="1"

if [[ -f "$DOTFILESDIR/machine.sh" ]]; then
  source "$DOTFILESDIR/machine.sh"
fi

promp_missing_config(){
  if [[ -z "${DFCONF[IS_WORK]}" ]]; then
    read -p "Is this a work machine (N/y)? " -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      DFCONF[IS_WORK]="1"
    else
      DFCONF[IS_WORK]="0"
    fi
  fi

  if [[ "${DFCONF[IS_WSL]}" == "1" ]] && [[ -z "${DFCONF[WINDOWS_USER]}" ]]; then
    read -p "Windows User Name: "
    if [[ -z "$REPLY" ]]; then
      DFCONF[WINDOWS_USER]="$REPLY"
    fi
  fi
}
