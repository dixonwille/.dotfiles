---
name: custom-scripts
description: Custom scripts in home/.local/bin/. Use when creating new scripts or understanding existing utilities like project-list and tmux-sessionizer.
---

# Custom Scripts

Scripts are stored in `home/.local/bin/` and stowed to `~/.local/bin/`.

## Key Scripts

### project-list

Prints project directories, one per line: children of `~/Projects` and
`~/projects`, plus `~/.dotfiles`. Shared by the zsh `project-cd` widget
(`Ctrl+f`, fzf then `cd`) and `tmux-sessionizer`.

### tmux-sessionizer

Quick tmux session switching using fzf. No keybind; run it by name when a
job must outlive the terminal.

| Property | Value |
|----------|-------|
| Location | `home/.local/bin/tmux-sessionizer` |
| Keybind | none (zsh `Ctrl+f` is `project-cd`) |
| Searches | `project-list` |

**Behavior:**
- Presents fzf list of directories
- Creates new tmux session if doesn't exist
- Switches to existing session if it does
- Session name derived from directory path

## Adding New Scripts

1. Create script in `home/.local/bin/`:
   ```bash
   touch home/.local/bin/my-script
   chmod +x home/.local/bin/my-script
   ```

2. Add shebang and content:
   ```bash
   #!/usr/bin/env bash
   # Description of what script does

   # Script content...
   ```

3. Link it (each script in `~/.local/bin` is its own link):
   ```bash
   ./install
   ```

## Best Practices

- Use `#!/usr/bin/env bash` for portability
- Add description comment at top
- Make executable: `chmod +x`
- Test locally before committing
- `~/.local/bin` stays a real directory (`./install` creates it before stowing), so each script is its own link: a new script needs `./install` to appear
