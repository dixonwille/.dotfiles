---
name: custom-scripts
description: Custom scripts in bin/.local/bin/. Use when creating new scripts or understanding existing utilities like tmux-sessionizer.
---

# Custom Scripts

Scripts are stored in `bin/.local/bin/` and stowed to `~/.local/bin/`.

## Key Scripts

### tmux-sessionizer

Quick tmux session switching using fzf.

| Property | Value |
|----------|-------|
| Location | `bin/.local/bin/tmux-sessionizer` |
| Keybind | `Ctrl+f` in zsh and nvim |
| Searches | `~/projects`, `~/.config` |

**Behavior:**
- Presents fzf list of directories
- Creates new tmux session if doesn't exist
- Switches to existing session if it does
- Session name derived from directory path

## Adding New Scripts

1. Create script in `bin/.local/bin/`:
   ```bash
   touch bin/.local/bin/my-script
   chmod +x bin/.local/bin/my-script
   ```

2. Add shebang and content:
   ```bash
   #!/usr/bin/env bash
   # Description of what script does

   # Script content...
   ```

3. If not already stowed:
   ```bash
   stow -Rt "$HOME" --no-folding bin
   ```

## Best Practices

- Use `#!/usr/bin/env bash` for portability
- Add description comment at top
- Make executable: `chmod +x`
- Test locally before committing
- The `bin` package uses `--no-folding` (has `.no-fold` file)
