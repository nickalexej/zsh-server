# CLAUDE.md — zsh-server

## Projektübersicht
Einheitliche ZSH-Shell-Konfiguration für Linux-Server. Basiert auf den macOS-Dotfiles unter `~/.dotfile/` (ohne 's'), angepasst für Server ohne Nerd Fonts und ohne macOS-spezifische Tools.

## Repo
- GitHub: `git@github.com:nickalexej/zsh-server.git`

## Wichtige Regeln

### Configs aktualisieren
Wenn Configs geändert werden (z.B. neue tmux Bindings aus `~/.dotfile/`):
1. Datei in `config/` anpassen
2. README.md aktualisieren falls Keybindings/Verhalten sich ändert
3. Commit + Push
4. Auf Servern via `update.sh` ausrollen

### Config aus Dotfiles übernehmen
Vorlage immer aus `~/.dotfile/` holen. Folgendes beim Übertragen entfernen:
- `/opt/homebrew` und andere macOS-Pfade
- iTerm2, Xcode, App Store Referenzen
- `POWERLEVEL9K_MODE="nerdfont-complete"` → bleibt `ascii`
- macOS-spezifische Aliases (open, defaults, killall Finder etc.)

### Nie ins Repo
- Persönliche Daten (Name, E-Mail, API Keys)
- `.bak` Dateien
- `.env` / Secrets

## Häufige Fehler
- Script mit `sudo` ausführen → warnt jetzt, aber trotzdem vermeiden
- tmux Prefix-Wechsel: `update.sh` entbindet alte Prefixes vor dem Reload
- glow Binary: `find` statt direktem Pfad, da tar-Struktur variieren kann

## Befehle
```bash
# Erstinstallation auf Server
git clone git@github.com:nickalexej/zsh-server.git && cd zsh-server && ./setup.sh

# Config-Update auf Server (ohne Neuinstallation)
curl -fsSL https://raw.githubusercontent.com/nickalexej/zsh-server/main/update.sh | bash
```
