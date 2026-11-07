# Tell WezTerm the current directory (OSC 7), so new splits and tabs open in it.
# Ghostty's shell integration does this itself. oh-my-posh's "pwd" setting
# can't do it from WSL: it sends the Windows path (//wsl.localhost/...), and
# WezTerm's WSL domain wants the Linux one.
#
# It's sent before each prompt rather than on chpwd: a chpwd hook's output goes
# wherever the cd's did (cd foo >/dev/null), and cd -q and pushd -q skip it.
_osc7_cwd() {
  local LC_ALL=C url= c i hex
  for (( i = 1; i <= ${#PWD}; i++ )); do
    c=${PWD[i]}
    if [[ $c == [-/._~A-Za-z0-9] ]]; then
      url+=$c
    else
      printf -v hex '%%%02X' "'$c"
      url+=$hex
    fi
  done
  printf '\e]7;file://%s%s\e\\' "$HOST" "$url"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _osc7_cwd
