# server-bash

Einheitliche ZSH-Konfiguration für alle Server. Ein einziger Befehl richtet ZSH, Oh-My-Zsh, Powerlevel10k, Plugins und tmux vollständig ein.

## Installation

```bash
git clone https://github.com/nickalexej/server-bash.git && cd server-bash && ./setup.sh
```

> Nach der Installation eine neue ZSH-Session starten: `exec zsh`

## Was wird installiert?

| Tool | Beschreibung |
|---|---|
| **ZSH** | Shell (via Paketmanager, falls nicht vorhanden) |
| **Oh-My-Zsh** | ZSH Framework |
| **Powerlevel10k** | Prompt Theme (ASCII-Modus, kein Nerd Font nötig) |
| **zsh-autosuggestions** | Befehlsvorschläge aus der History |
| **zsh-syntax-highlighting** | Syntax-Highlighting in der Shell |
| **tmux** | Terminal Multiplexer |
| **tpm** | Tmux Plugin Manager |
| **glow** | Markdown Renderer im Terminal |

## Enthaltene Konfigurationen

| Datei | Beschreibung |
|---|---|
| `config/zshrc` | ZSH-Konfiguration mit Oh-My-Zsh und Plugins |
| `config/p10k.zsh` | Powerlevel10k Prompt (server-optimiert, kein Nerd Font) |
| `config/aliases.zsh` | Shell-Aliases (git, npm, yarn, docker, ...) + `mdp`/`mdl` für glow |
| `config/tmux.conf` | tmux mit Dracula Theme und TPM |

## Unterstützte Systeme

- Ubuntu / Debian (`apt`)
- CentOS / RHEL / AlmaLinux (`yum` / `dnf`)
- Fedora (`dnf`)
- Arch Linux (`pacman`)

## Prompt

Kein Nerd Font erforderlich. Der Prompt zeigt:

```
[user@hostname] [~/current/dir] git:main *           ✘ 1  3.2s  14:30
❯ _
```

- Links: `user@hostname`, Verzeichnis, Git-Status
- Rechts: Exit-Code (bei Fehler), Ausführungszeit, Uhrzeit
- Root-User erscheint in **Rot**

Nach der Installation kann der Prompt mit `p10k configure` weiter angepasst werden.

## tmux Plugins installieren

Nach dem ersten Start von tmux:

```
Ctrl+l dann I
```

Installiert: `tmux-sensible` und `dracula/tmux` (Statusbar-Theme).

## Bestehende Configs

Vorhandene Dateien werden automatisch gesichert (`.bak`), bevor sie überschrieben werden:

- `~/.zshrc` → `~/.zshrc.bak`
- `~/.p10k.zsh` → `~/.p10k.zsh.bak`
- `~/.tmux.conf` → `~/.tmux.conf.bak`

## Aufbau

```
server-bash/
├── setup.sh          # Installer
└── config/
    ├── zshrc         # ZSH Konfiguration
    ├── p10k.zsh      # Powerlevel10k Config
    ├── aliases.zsh   # Shell Aliases
    └── tmux.conf     # tmux Konfiguration
```
