<div align="center">

# AltTab

<a href="https://alt-tab.app/"><img src="docs/readme/main.svg" alt="AltTab Pro — 7.4M downloads — 15K GitHub stars — Get AltTab"/></a>

<a href="https://jb.gg/OpenSource"><img src="docs/readme/sponsor.svg" alt="Sponsored by JetBrains" width="900"/></a>

## MCMonad integration

This adds integration with MCMonad, a tiling window manager for macOS.

MCMonad writes the exact window IDs on the currently focused workspace to
`~/.config/mcmonad/workspace-windows.json` on every layout update. AltTab reads that file and
filters the switcher's window list down to exactly that set. When MCMonad is not running, AltTab
behaves as normal.

---

[Upstream](https://github.com/lwouis/alt-tab-macos)

</div>
