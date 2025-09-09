# PATH management

# Cargo/Rust binaries
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Local user binaries
case ":${PATH}:" in
  *:"$HOME/.local/bin":*)
    ;;
  *)
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac