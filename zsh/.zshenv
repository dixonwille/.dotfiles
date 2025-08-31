if [ -d /etc/environment.d ]; then
  set -a
  for i in /etc/environment.d/*.conf; do
    if [ -r $i ]; then
      . $i
    fi
  done
  set +a
  unset i
fi

if [ -d $HOME/.config/environment.d ]; then
  set -a
  for i in $HOME/.config/environment.d/*.conf; do
    if [ -r $i ]; then
      . $i
    fi
  done
  set +a
  unset i
fi

export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

## TODO: Probably should move to a Rust module
if [ -d $HOME/.cargo/bin ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

case ":${PATH}:" in
  *:"$HOME/.local/bin":*)
    ;;
  *)
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac

if [[ -n "$TMPDIR" ]]; then
  mkdir -p "$TMPDIR"
fi
