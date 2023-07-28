# Bootstrap

## WSL2

- Bootstrap

```sh
bash <(curl -L https://raw.githubusercontent.com/dixonwille/dotfiles/main/install.sh) -m $MACHINE
```

Replace `$MACHINE` with correct machine name.

- Make ZSH default for user

```sh
echo "$(which zsh)" | sudo tee -a /etc/shells
chsh -s "$(which zsh)"
```
