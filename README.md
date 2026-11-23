# noctalia-rsync-status

Noctalia bar plugin (`local/rsync-status`) and CLI/configuration backend (`noctalia-rsync-status`) for per-target `rsync` backups with graphical target, root, and exclude editing.

## Usage

- **Noctalia plugin source**: add this repository as a Noctalia plugin source (`catalog.toml` + `rsync-status/`).
- **Nix flake**: provides `packages.x86_64-linux.helper`, `packages.x86_64-linux.plugin`, `lib.pluginDir`, and `checks.x86_64-linux.{helper,plugin}`.
