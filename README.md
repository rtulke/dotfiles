# dotfiles — Robert Tulke

Persönliche Shell-Konfiguration für **bash** und **zsh**, optimiert für den Einsatz auf **macOS und Linux** (Debian).  
Enthält eine umfangreiche Funktionsbibliothek für Entwicklung, DevOps, Ansible, Docker, tmux und Raspberry Pi.

---

## Dateien

| Datei | Beschreibung |
|---|---|
| `.bashrc` | Bash-Konfiguration (Linux-Standard) |
| `.zshrc` | Zsh-Konfiguration (macOS-Standard) |

---

## Installation

```bash
# Symlinks im Home-Verzeichnis setzen
ln -sf ~/dev/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dev/dotfiles/.zshrc  ~/.zshrc

# Shell neu laden
source ~/.bashrc   # oder: source ~/.zshrc
```

Nach dem Laden steht `git-setup` zur Verfügung, um die globale Git-Konfiguration einzurichten:

```bash
git-setup
```

---

## Plattform-Unterschiede

Beide Dateien sind weitgehend identisch. Folgende Stellen unterscheiden sich bewusst:

| Stelle | `.bashrc` (Linux) | `.zshrc` (macOS) |
|---|---|---|
| `update` | `apt update && apt upgrade` | `softwareupdate -i -a` |
| `copy` / `paste` | `xclip` / `xsel` | `pbcopy` / `pbpaste` |
| `sysinfo` RAM | `free -h` | `vm_stat` |
| `git-setup` read | `read -rp "prompt" var` | `read -r "var?prompt"` |
| `confirm` lowercase | `${var,,}` | `${var:l}` |
| History | `shopt`, `HISTFILESIZE` | `setopt`, `SAVEHIST` |

Funktionen die Plattform-Unterschiede intern behandeln (kein manuelles Eingreifen nötig):  
`copy`, `paste`, `sysinfo`, `disk`, `openports`, `epoch2date`, `git-setup` (credential.helper)

---

## Funktionsübersicht

### Navigation & Bookmarks

| Funktion | Beschreibung |
|---|---|
| `mkcd <dir>` | Verzeichnis erstellen und direkt hineinwechseln |
| `cl <dir>` | `cd` + sofortiges `ls -lAh` |
| `up [n]` | n Ebenen hoch (`up 3` → `cd ../../..`) |
| `root` | Zum Git-Root des aktuellen Projekts springen |
| `bm [name]` | Aktuelles Verzeichnis bookmarken (Standard: Verzeichnisname) |
| `bj <name>` | Zu einem Bookmark springen |
| `bls` | Alle gesetzten Bookmarks auflisten |
| `bdel <name>` | Bookmark löschen |

Bookmarks werden in `~/.shell_bookmarks` gespeichert.

```bash
# Beispiel
cd /var/log/nginx && bm logs
cd /etc/ansible   && bm ansible
bls               # zeigt alle Bookmarks
bj logs           # springt zu /var/log/nginx
```

---

### Dateien & Archive

| Funktion | Beschreibung |
|---|---|
| `extract <datei>` | Universeller Entpacker (tar, zip, gz, bz2, xz, 7z, rar) |
| `pack <verzeichnis>` | Verzeichnis als `.tar.gz` packen |
| `bak <datei>` | Backup mit Datumsstempel anlegen (`datei.bak.2026-04-05`) |
| `biggest [dir]` | Top-20 größte Dateien/Ordner |
| `trash <datei>` | Datei in `~/.Trash/` verschieben statt löschen |

---

### Suche & Text

| Funktion | Beschreibung |
|---|---|
| `f <muster> [dir]` | Rekursive, case-insensitive Volltextsuche |
| `ff <name> [dir]` | Datei nach Name suchen |
| `port <nr>` | Zeigt welcher Prozess auf einem Port lauscht |
| `cheat <befehl>` | Spickzettel von cheat.sh abrufen (`cheat tar`) |
| `weather [ort]` | Wettervorhersage im Terminal (`weather Berlin`) |

---

### Git

| Funktion | Beschreibung |
|---|---|
| `git-setup` | Globale Git-Konfiguration interaktiv einrichten |
| `gs` | Kompakter Status (`git status -sb`) |
| `gl [n]` | Grafischer Log, Standard: letzte 20 Commits |
| `gbr` | Alle Branches sortiert nach letztem Commit |
| `gc "<msg>"` | `git add -A` + `git commit -m` in einem Schritt |
| `gpush` | Aktuellen Branch pushen und Tracking setzen |
| `gundo` | Letzten Commit rückgängig machen (Änderungen bleiben) |
| `git-clean-branches` | Alle gemergten Branches löschen (außer main/master/dev) |

`git-setup` konfiguriert u.a.: `pull.rebase=true`, `diff.algorithm=histogram`, `merge.conflictstyle=zdiff3`, fsck-Sicherheitseinstellungen, und Git-Aliases (`co`, `br`, `ci`, `st`, `unstage`, `last`).

---

### Docker

| Funktion | Beschreibung |
|---|---|
| `dps` | Laufende Container übersichtlich anzeigen |
| `dsh <name> [shell]` | Shell in laufenden Container öffnen (Standard: `sh`) |
| `dlogs <name>` | Container-Logs live verfolgen (letzte 100 Zeilen) |
| `dclean` | Gestoppte Container + dangling Images aufräumen |
| `dbuild [tag]` | Image aus aktuellem Verzeichnis bauen |
| `dcup` | `docker compose up -d` |
| `dcdn [-v]` | `docker compose down` (optional mit Volumes) |

---

### Netzwerk & System

| Funktion | Beschreibung |
|---|---|
| `sysinfo` | Kompakte Systemübersicht (Host, OS, CPU, RAM, Disk) |
| `disk` | Festplattennutzung ohne tmpfs/overlay-Rauschen |
| `myip` | Externe IP-Adresse |
| `localip` | Alle lokalen IP-Adressen |
| `openports` | Alle offenen Ports anzeigen |
| `port <nr>` | Prozess auf Port anzeigen |
| `killport <nr>` | Prozess auf Port beenden |
| `scan [subnet]` | Netzwerk-Scan via nmap (Standard: `192.168.1.0/24`) |
| `dns <domain>` | DNS-Lookup (`dig +short`) |
| `headers <url>` | HTTP-Header einer URL anzeigen |
| `serve [port]` | Python-HTTP-Server im aktuellen Verzeichnis (Standard: 8080) |

---

### Prozesse

| Funktion | Beschreibung |
|---|---|
| `psg <name>` | Prozess nach Name in der Prozessliste suchen |
| `killp <name>` | Prozess nach Name beenden (`pgrep` + `kill`) |
| `topcpu` | Top-10 CPU-intensivste Prozesse |
| `topmem` | Top-10 speicherintensivste Prozesse |

---

### Entwicklung

| Funktion | Beschreibung |
|---|---|
| `venv [name]` | Python venv erstellen (falls nötig) und aktivieren (Standard: `.venv`) |
| `voff` | Aktives venv deaktivieren |
| `pyclean` | `__pycache__`-Ordner und `.pyc`-Dateien rekursiv entfernen |
| `pip-upgrade` | Alle veralteten pip-Pakete upgraden |
| `npmls` | Globale npm-Pakete auflisten |
| `jsonp [json]` | JSON pretty-print (Argument oder stdin) |
| `cert <domain>` | TLS-Zertifikat einer Domain prüfen |
| `md2man [pfad]` | Markdown-Datei(en) als Man-Page rendern (benötigt pandoc) |

---

### tmux

| Funktion | Beschreibung |
|---|---|
| `tns [name]` | Neue Session erstellen (Standard: `main`) |
| `ta [name]` | An Session anhängen (ohne Name: letzte Session) |
| `tls` | Alle aktiven Sessions auflisten |
| `tks [name]` | Session beenden |
| `tka` | Alle Sessions und tmux-Server beenden |
| `tsplit` | Aktuelles Fenster horizontal teilen |
| `tnw [name]` | Neues Fenster in aktueller Session |

---

### Ansible

| Funktion | Beschreibung |
|---|---|
| `ap <playbook> [opts]` | Playbook ausführen (`ansible-playbook`) |
| `acheck <playbook>` | Playbook im Dry-Run (`--check --diff`) |
| `aping [hosts] [opts]` | Hosts anpingen (Standard: `all`) |
| `ainv [inventory]` | Inventar als formatiertes JSON anzeigen |
| `afacts <host>` | Ansible-Facts eines Hosts abrufen |
| `arun <hosts> "<cmd>"` | Ad-hoc-Shell-Befehl auf Hosts ausführen |

```bash
# Beispiele
ap site.yml -i inventories/prod
acheck deploy.yml -i inventories/staging
aping webservers -i inventory.ini
arun all "df -h" -i inventory.ini
```

---

### SSH & Raspberry Pi

| Funktion | Beschreibung |
|---|---|
| `sshcopy <user@host>` | SSH-Public-Key auf Remote-Host kopieren |
| `sshfp [keyfile]` | Fingerprint des eigenen SSH-Keys anzeigen |
| `tunnel <local> <rhost> <rport> <gateway>` | SSH-Tunnel aufbauen |
| `rpi-scan [subnet]` | Raspberry Pi im Netz finden via MAC-Prefix (benötigt nmap) |
| `rpi <hostname>` | SSH-Verbindung als User `pi` |

```bash
# SSH-Tunnel: lokaler Port 5432 → DB auf remote-host:5432 via Jump-Host
tunnel 5432 db-server 5432 user@jump-host

# Alle RPis im lokalen Netz finden
rpi-scan 192.168.178.0/24

# Raspberry Pi verbinden
rpi raspberrypi.local
```

Erkannte Raspberry Pi MAC-Prefixe: `b8:27:eb`, `dc:a6:32`, `e4:5f:01`, `d8:3a:dd`

---

### Utilities

| Funktion | Beschreibung |
|---|---|
| `retry [max] <cmd>` | Befehl bis zu n-mal wiederholen (Standard: 5, Pause: 2s) |
| `bench <cmd>` | Laufzeit eines Befehls messen |
| `countdown [sek]` | Countdown-Timer im Terminal (Standard: 10s) |
| `timestamp` | Aktuellen Unix-Timestamp ausgeben |
| `epoch2date <ts>` | Unix-Timestamp in lesbares Datum umrechnen |
| `note <text>` | Schnelle Notiz in `~/.notes` speichern |
| `notes` | Alle Notizen anzeigen |
| `note-clear` | Alle Notizen löschen |
| `confirm "<frage>"` | Interaktive j/N-Abfrage |
| `mkpass [länge]` | Zufälliges Passwort generieren (Standard: 24 Zeichen) |
| `copy` | Stdin in Clipboard kopieren (pbcopy / xclip / xsel) |
| `paste` | Clipboard-Inhalt ausgeben |
| `path` | PATH-Einträge nummeriert ausgeben |
| `reload` | Shell-Konfiguration neu laden |

```bash
# Beispiele
retry 3 curl https://example.com/large-file.zip
confirm "Server neustarten?" && sudo reboot
note "Morgen Deployment um 10 Uhr"
notes
epoch2date 1700000000
```

---

## Aliases

| Alias | Beschreibung |
|---|---|
| `ll` | `ls -lAh` |
| `home` | `cd ~` |
| `update` | System-Updates (apt auf Linux, softwareupdate auf macOS) |
| `getpyline` | Zeilenzahl aller `.py`-Dateien (exkl. `.venv`) |
| `getpychars` | Zeichenzahl aller `.py`-Dateien (exkl. `.venv`) |
| `mdless` | Markdown als Man-Page rendern (benötigt pandoc) |

---

## Abhängigkeiten

Folgende Tools werden von einzelnen Funktionen benötigt, sind aber nicht zwingend erforderlich:

| Tool | Benötigt von | Installation |
|---|---|---|
| `nmap` | `scan`, `rpi-scan` | `apt install nmap` / `brew install nmap` |
| `pandoc` | `md2man`, `mdless` | `apt install pandoc` / `brew install pandoc` |
| `dig` | `dns` | `apt install dnsutils` / vorinstalliert auf macOS |
| `xclip` oder `xsel` | `copy`, `paste` (Linux) | `apt install xclip` |
| `docker` | alle `d*`-Funktionen | docker.com |
| `ansible` | alle `a*`-Funktionen | `apt install ansible` / `pip install ansible` |
| `tmux` | alle `t*`-Funktionen | `apt install tmux` / `brew install tmux` |
