# Stow Examples

## Installing

```bash
# Everything (what every machine runs)
./install

# Just home/ again, verbose
stow -Rv -d . -t "$HOME" home
```

## Removing Symlinks

```bash
# Unstow everything home/ linked
stow -D -d . -t "$HOME" home
stow -D -d personal -t "$HOME" base work
```

## Adding a Config File

```bash
# 1. Put it at its $HOME path under home/
mkdir -p home/.config/new-app
cp /path/to/config home/.config/new-app/

# 2. Link it (a new top-level directory under ~/.config gets folded: one link)
./install
```

If the app also writes its own files into that directory (state, caches, other
tools' drop-ins), add the directory to `./install`'s `mkdir -p` list first, so
stow links file by file instead of folding it into the repo.

## Troubleshooting

### Conflict with existing file
```bash
# Back up the existing file first
mv ~/.config/app/config ~/.config/app/config.bak
./install
```

### Preview without making changes
```bash
stow -nRv -d . -t "$HOME" home
```

### A directory got folded that shouldn't have
```bash
# e.g. ~/.config/app is a link into the repo, but the app writes there:
rm ~/.config/app            # the link only
# add ~/.config/app to ./install's mkdir -p list, then
./install
```
