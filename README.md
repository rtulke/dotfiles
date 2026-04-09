# dotfiles — Robert Tulke

Persönliche Shell-Konfiguration für **bash** und **zsh**, optimiert für den Einsatz auf **macOS und Linux** (Debian).  

---

## Dateien

| Datei | Beschreibung |
|---|---|
| `.bashrc` | Bash-Konfiguration (Linux-Standard) |
| `.zshrc` | Zsh-Konfiguration (macOS-Standard) |

---

## Installation

```bash
# git clone
mkdir ~/dev/
git clone https://github.com/rtulke/dotfiles.git

# Symlinks im Home-Verzeichnis setzen
ln -sf ~/dev/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dev/dotfiles/.zshrc  ~/.zshrc

# Shell neu laden
source ~/.bashrc   # oder: source ~/.zshrc
```

Nach dem Laden steht `setup-git` zur Verfügung, um die globale Git-Konfiguration einzurichten:

```bash
setup-git
```

---

## Plattform-Unterschiede

Beide Dateien sind weitgehend identisch. Folgende Stellen unterscheiden sich bewusst:

| Stelle | `.bashrc` (Linux) | `.zshrc` (macOS) |
|---|---|---|
| `update` | `apt update && apt upgrade` | `softwareupdate -i -a` |
| `copy` / `paste` | `xclip` / `xsel` | `pbcopy` / `pbpaste` |
| `sysinfo` RAM | `free -h` | `vm_stat` |
| `setup-git` read | `read -rp "prompt" var` | `read -r "var?prompt"` |
| `confirm` lowercase | `${var,,}` | `${var:l}` |
| History | `shopt`, `HISTFILESIZE` | `setopt`, `SAVEHIST` |
| `ls` Farben | `--color=auto` + `dircolors` (GNU) | `-G` + `CLICOLOR`/`LSCOLORS` (BSD) |
| `log` | `journalctl` (systemd) | Meldung: nicht verfügbar |

**Nur `.bashrc`:** Interactive-Shell-Guard, farbiger PS1-Prompt, `checkwinsize`, `TERM=xterm-256color`, Bash Completion (`/usr/share/bash-completion`)

Funktionen die Plattform-Unterschiede intern behandeln (kein manuelles Eingreifen nötig):  
`copy`, `paste`, `sysinfo`, `cpuinfo`, `disk`, `openports`, `epoch2date`, `log`, `setup-git` (credential.helper)

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
| `setup-git` | Globale Git-Konfiguration interaktiv einrichten |
| `gs` | Kompakter Status (`git status -sb`) |
| `gl [n]` | Grafischer Log, Standard: letzte 20 Commits |
| `gbr` | Alle Branches sortiert nach letztem Commit |
| `gc "<msg>"` | `git add -A` + `git commit -m` in einem Schritt |
| `gpush` | Aktuellen Branch pushen und Tracking setzen |
| `gundo` | Letzten Commit rückgängig machen (Änderungen bleiben) |
| `git-clean-branches` | Alle gemergten Branches löschen (außer main/master/dev) |

`setup-git` konfiguriert u.a.: `pull.rebase=true`, `diff.algorithm=histogram`, `merge.conflictstyle=zdiff3`, fsck-Sicherheitseinstellungen, und Git-Aliases (`co`, `br`, `ci`, `st`, `unstage`, `last`).

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
| `cpuinfo` | Detaillierte CPU-Infos: Modell, Kerne, Threads, Frequenz, Cache (Linux inkl. RPi & macOS) |
| `disk` | Festplattennutzung ohne tmpfs/overlay-Rauschen |
| `myip` | Externe IP-Adresse (api.ipify.org) |
| `netip` | Externe IP mit Fallback über 5 Anbieter (zeigt welcher antwortet) |
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
| `setup-vim` | Vim prüfen, Plugins installieren, Colorschemes laden und `~/.vimrc` anlegen |

`setup-vim` richtet eine vollständige Vim-Umgebung ein. Zu Beginn werden folgende Fragen gestellt:

```
Proxy-URL (leer = kein Proxy, z.B. http://proxy.example.com:3128):
Code Completion aktivieren? (coc.nvim, benötigt Node.js/npm) [j/N]
```

Falls `HTTP_PROXY` oder `HTTPS_PROXY` bereits als Umgebungsvariable gesetzt sind, wird der Proxy automatisch erkannt — ohne Nachfrage. Der Proxy gilt für `curl`, `git` und `npm` innerhalb der Funktion, ohne dauerhafte Änderungen an `~/.npmrc` oder `git config`.

**Colorschemes** (nach `~/.vim/colors/`):
- **distinguished** — aktives Colorscheme ([Lokaltog/vim-distinguished](https://github.com/Lokaltog/vim-distinguished))
- **solarized** — optional, `g:solarized_termcolors=256` ist bereits gesetzt ([altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized))

**Plugin-Manager:** [vim-plug](https://github.com/junegunn/vim-plug) wird nach `~/.vim/autoload/plug.vim` installiert.

**Plugins — immer** (via `vim +PlugInstall`):
- [vim-polyglot](https://github.com/sheerun/vim-polyglot) — Syntax-Highlighting für viele Sprachen (inkl. Perl, Ruby, Ansible)
- [ALE](https://github.com/dense-analysis/ale) — Asynchrones Linting, nur beim Speichern (`Ctrl+j`/`Ctrl+k` zur Fehlernavigation)
- [lightline.vim](https://github.com/itchyny/lightline.vim) — Statusleiste

**Plugin — optional** (nur wenn Code Completion mit `j` bestätigt, benötigt Node.js):
- [coc.nvim](https://github.com/neoclide/coc.nvim) — LSP-basierte Code Completion wie in VSCode

| Taste | Funktion (coc) |
|---|---|
| `Tab` / `Shift+Tab` | Vorschlag auswählen |
| `Enter` | Vorschlag bestätigen |
| `K` | Hover-Dokumentation |
| `gd` | Go to Definition |
| `gr` | Referenzen anzeigen |
| `Space` + `e` | Dateibaum (coc-explorer) öffnen/schließen |

Installierte coc-Extensions: `coc-pyright`, `coc-clangd`, `coc-yaml`, `coc-sh`, `coc-json`, `coc-perl`, `coc-solargraph`, `coc-docker`, `coc-markdownlint`, `coc-terraform`, `coc-go`, `coc-tsserver`, `coc-rust-analyzer`, `coc-explorer`

**Filetype-spezifische Einstellungen** in der `~/.vimrc`:

| Dateityp | Einstellung |
|---|---|
| Python | `shiftwidth=4`, `colorcolumn=79` (PEP 8) |
| YAML / Ansible | `shiftwidth=2` |
| JSON | `shiftwidth=2`, `conceallevel=0` |
| HTML / CSS | `shiftwidth=2` |
| C / C++ | `cindent`, `colorcolumn=80` |
| Bash / Shell | `shiftwidth=4` |
| conf / ini | `shiftwidth=4` |
| Perl | `shiftwidth=4` |
| Ruby | `shiftwidth=2` |
| Dockerfile | `shiftwidth=2` |
| Makefile | `noexpandtab` (echte Tabs — make-Pflicht!) |
| Markdown | `shiftwidth=2`, `wrap`, `linebreak` |
| Terraform / HCL | `shiftwidth=2` |
| Go | `noexpandtab` (gofmt-Standard) |
| SQL | `shiftwidth=2` |
| XML | `shiftwidth=2` |
| Nginx | `shiftwidth=4` |
| JS / TS / JSX / TSX | `shiftwidth=2` |
| Rust | `shiftwidth=4`, `colorcolumn=100` (Style Guide) |
| TOML | `shiftwidth=2` |
| Jinja2 / `.j2` | `shiftwidth=2` |
| Protocol Buffers | `shiftwidth=2` |

**ALE-Linter:** `flake8` (Python), `shellcheck` (Bash), `yamllint` (YAML), `gcc` (C/C++), `jsonlint` (JSON), `perl` (Perl), `rubocop` (Ruby), `hadolint` (Dockerfile), `markdownlint` (Markdown), `tflint` (Terraform), `golangci-lint` (Go), `sqlint` (SQL), `xmllint` (XML), `eslint` (JS/TS), `cargo` (Rust), `buf` (Proto)

TOML und Jinja2 benötigen keinen externen Linter — vim-polyglot liefert Syntax-Highlighting.

Falls eine bestehende `~/.vimrc` gefunden wird, wird vor dem Überschreiben ein Backup angelegt (`~/.vimrc.bak.DATUM`).

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

## Aliases & Shell-Funktionen

| Alias / Funktion | Beschreibung |
|---|---|
| `ls` | Farbige Ausgabe (`-G` auf macOS, `--color=auto` auf Linux) |
| `ll` | `ls -lAh` mit Farbe |
| `grep` / `fgrep` / `egrep` | Farbige Trefferausgabe (`--color=auto`) |
| `home` | `cd ~` |
| `..` | `cd ..` |
| `....` | `cd ../..` |
| `......` | `cd ../../..` |
| `update` | System-Updates (apt auf Linux, softwareupdate auf macOS) |
| `getpyline` | Zeilenzahl aller `.py`-Dateien (exkl. `.venv`) |
| `getpychars` | Zeichenzahl aller `.py`-Dateien (exkl. `.venv`) |
| `mdless` | Markdown als Man-Page rendern (benötigt pandoc) |
| `log [service]` | Systemd-Journal anzeigen: letzte 50 Zeilen, optional gefiltert nach Service |

```bash
log              # letzte 50 Zeilen des Journals
log nginx        # Logs des nginx-Service
log ssh          # Logs des SSH-Daemon
```

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
| `curl` | `setup-vim` (vim-plug + Colorschemes) | vorinstalliert |
| `flake8` | ALE Python-Linting | `pip install flake8` |
| `shellcheck` | ALE Shell-Linting | `apt install shellcheck` / `brew install shellcheck` |
| `yamllint` | ALE YAML-Linting | `pip install yamllint` |
| `jsonlint` | ALE JSON-Linting | `npm install -g jsonlint` |
| `gcc` | ALE C/C++-Linting | `apt install build-essential` / `xcode-select --install` |
| `rubocop` | ALE Ruby-Linting | `gem install rubocop` |
| `Perl::Critic` | ALE Perl-Linting | `cpanm Perl::Critic` |
| Node.js + npm | `setup-vim` (coc.nvim, optional) | `apt install nodejs npm` / `brew install node` |
| `pyright` | coc Python-LSP | `npm i -g pyright` |
| `clangd` | coc C/C++-LSP | `apt install clangd` / `brew install llvm` |
| `bash-language-server` | coc Bash-LSP | `npm i -g bash-language-server` |
| `solargraph` | coc Ruby-LSP | `gem install solargraph` |
| `Perl::LanguageServer` | coc Perl-LSP | `cpanm Perl::LanguageServer` |
| `hadolint` | ALE Dockerfile-Linting | `brew install hadolint` / `apt install hadolint` |
| `markdownlint-cli` | ALE Markdown-Linting | `npm install -g markdownlint-cli` |
| `tflint` | ALE Terraform-Linting | `brew install tflint` |
| `golangci-lint` | ALE Go-Linting | `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` |
| `sqlint` | ALE SQL-Linting | `gem install sqlint` |
| `xmllint` | ALE XML-Linting | `apt install libxml2-utils` / vorinstalliert auf macOS |
| `eslint` | ALE JS/TS-Linting | `npm install -g eslint` |
| `gopls` | coc Go-LSP | via `coc-go` automatisch |
| `typescript-language-server` | coc JS/TS-LSP | via `coc-tsserver` automatisch |
| `rust-analyzer` | ALE + coc Rust-LSP | `rustup component add rust-analyzer` |
| `buf` | ALE Proto-Linting | `brew install buf` / `apt install protobuf-compiler` |
