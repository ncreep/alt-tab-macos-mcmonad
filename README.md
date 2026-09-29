<div align="center">

# AltTab

<a href="https://alt-tab.app/"><img src="docs/readme/main.svg" alt="AltTab Pro — 7.4M downloads — 15K GitHub stars — Get AltTab"/></a>

<a href="https://jb.gg/OpenSource"><img src="docs/readme/sponsor.svg" alt="Sponsored by JetBrains" width="900"/></a>

## MCMonad integration

This adds integration with MCMonad, a tiling window manager for macOS.

MCMonad hides off-workspace windows by parking them off-screen and writes their window IDs to
`~/.config/mcmonad/workspace-windows.json` on every layout update. AltTab reads that file and
filters the switcher's window list to exclude those hidden windows, so it only shows windows on
the currently visible workspace. When MCMonad is not running, AltTab behaves as normal.

---

[Upstream](https://github.com/lwouis/alt-tab-macos)

</div>
