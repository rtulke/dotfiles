# ╔═════════════════════════════════════════════╗
#  .zshrc — Robert Tulke
#  Sections:
#    1. Zsh Options & Completion
#    2. History
#    3. Aliases
#    4. Navigation & Bookmarks
#    5. Dateien & Archive
#    6. Suche & Text
#    7. Git
#    8. Docker
#    9. Netzwerk & System
#   10. Prozesse
#   11. Entwicklung (Python, Node, Docs)
#   12. tmux
#   13. Ansible
#   14. SSH & Raspberry Pi
#   15. Utilities
# ╚═════════════════════════════════════════════╝


# ─────────────────────────────────────────────
#  1. Zsh Options & Completion
# ─────────────────────────────────────────────
autoload -Uz compinit && compinit   # Tab-Completion aktivieren
autoload -Uz colors && colors       # Farb-Support

setopt AUTO_CD                      # Verzeichnisname = cd
setopt CORRECT                      # Rechtschreibkorrektur für Befehle
setopt GLOB_DOTS                    # Dotfiles in Glob-Patterns einschließen
setopt NO_CASE_GLOB                 # Case-insensitive Globbing
setopt INTERACTIVE_COMMENTS         # # Kommentare in interaktiver Shell erlaubt

# Completion: Menü + Farben + Case-insensitiv
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


# ─────────────────────────────────────────────
#  2. History
# ─────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=20000

setopt HIST_IGNORE_ALL_DUPS         # Duplikate nicht speichern
setopt HIST_IGNORE_SPACE            # Befehle mit führendem Space nicht speichern
setopt INC_APPEND_HISTORY           # Sofort wegschreiben (nicht beim Shell-Exit)
setopt SHARE_HISTORY                # History über alle Zsh-Sessions teilen


# ─────────────────────────────────────────────
#  3. Aliases
# ─────────────────────────────────────────────

# ls Farben (macOS BSD ls)
export CLICOLOR=1
export LSCOLORS="ExGxFxdxCxegedabagacad"
# LS_COLORS für zsh-Completion (GNU-Format)
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.xz=01;31:*.jpg=01;35:*.png=01;35:*.gif=01;35:*.py=00;33:*.sh=00;32:*.md=00;36"
alias ls='ls -G'
alias ll='ls -lAhG'
alias home='cd ~'
alias update='sudo softwareupdate -i -a'

# Schnelle Verzeichnis-Navigation
alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'

# Systemd-Journal anzeigen: log [service]
log() {
    if command -v journalctl &>/dev/null; then
        if [[ -n "$1" ]]; then
            journalctl -u "$1" -n 50 -e
        else
            journalctl -n 50 -e
        fi
    else
        echo "journalctl nicht verfügbar (nur Linux/systemd)." >&2
    fi
}

# Python-Statistiken (exkl. .venv)
alias getpyline="find . -path './.venv' -prune -o -name '*.py' -print0 | xargs -0 wc -l"
alias getpychars='find . -name "*.py" ! -path "./.venv/*" -print0 | xargs -0 wc -c'

# Markdown als Man-Page rendern (benötigt pandoc)
alias mdless='pandoc -s -f markdown -t man *.md | groff -T utf8 -man | less'


# ─────────────────────────────────────────────
#  4. Navigation & Bookmarks
# ─────────────────────────────────────────────

# mkdir + cd in einem Schritt
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# cd und sofort ls
cl() {
    cd "$1" && ls -lAh
}

# Schnell n Ebenen hoch: up 3 → cd ../../..
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do
        d="../$d"
    done
    cd "$d" || return
}

# Zurück zum Git-Root des Projekts
root() {
    cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
}

# ── Verzeichnis-Bookmarks ─────────────────────
BOOKMARKS_FILE="$HOME/.shell_bookmarks"

# Aktuelles Verzeichnis bookmarken: bm [name]
bm() {
    local name="${1:-$(basename "$PWD")}"
    echo "${name}=${PWD}" >> "$BOOKMARKS_FILE"
    echo "Bookmark gesetzt: $name → $PWD"
}

# Zu Bookmark springen: bj name
bj() {
    local target
    target=$(grep "^${1}=" "$BOOKMARKS_FILE" 2>/dev/null | tail -1 | cut -d= -f2-)
    if [[ -z "$target" ]]; then
        echo "Bookmark '$1' nicht gefunden. Alle Bookmarks: bls"
        return 1
    fi
    cd "$target"
}

# Alle Bookmarks anzeigen
bls() {
    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        echo "Keine Bookmarks gesetzt. Bookmark anlegen: bm [name]"
        return
    fi
    nl "$BOOKMARKS_FILE"
}

# Bookmark löschen: bdel name
bdel() {
    local tmp
    tmp=$(mktemp)
    grep -v "^${1}=" "$BOOKMARKS_FILE" > "$tmp" && mv "$tmp" "$BOOKMARKS_FILE"
    echo "Bookmark '$1' gelöscht."
}


# ─────────────────────────────────────────────
#  5. Dateien & Archive
# ─────────────────────────────────────────────

# Universeller Entpacker: extract foo.tar.gz
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"    ;;
            *.tar.gz)   tar xzf "$1"    ;;
            *.tar.xz)   tar xJf "$1"    ;;
            *.tar)      tar xf  "$1"    ;;
            *.bz2)      bunzip2 "$1"    ;;
            *.gz)       gunzip  "$1"    ;;
            *.zip)      unzip   "$1"    ;;
            *.7z)       7z x    "$1"    ;;
            *.rar)      unrar x "$1"    ;;
            *)          echo "Unbekanntes Format: $1" ;;
        esac
    else
        echo "'$1' ist keine Datei."
    fi
}

# Schnelles Backup mit Datumsstempel: bak server.conf
bak() {
    cp -a "$1" "${1}.bak.$(date +%F)"
}

# Größte Dateien/Ordner: biggest [dir]
biggest() {
    du -ah "${1:-.}" | sort -rh | head -20
}

# Verzeichnis packen: pack foo/ → foo.tar.gz
pack() {
    tar czf "${1%/}.tar.gz" "${1%/}"
    echo "Erstellt: ${1%/}.tar.gz"
}

# Datei sicher löschen (in Papierkorb statt rm)
trash() {
    mv "$@" ~/.Trash/
}


# ─────────────────────────────────────────────
#  6. Suche & Text
# ─────────────────────────────────────────────

# Rekursive Case-Insensitive Suche mit Kontext
f() {
    grep -rni "$1" "${2:-.}"
}

# Datei nach Name suchen: ff nginx
ff() {
    find "${2:-.}" -iname "*$1*" 2>/dev/null
}

# Port belegt? Zeig welcher Prozess: port 8080
port() {
    lsof -i :"$1"
}

# Spickzettel zu einem Befehl: cheat tar
cheat() {
    curl -s "https://cheat.sh/$1"
}

# Wetter: weather Berlin
weather() {
    curl -s "https://wttr.in/${1:-}"
}


# ─────────────────────────────────────────────
#  7. Git
# ─────────────────────────────────────────────

# Globale Git-Standardkonfiguration einrichten
setup-git() {
    if ! command -v git &>/dev/null; then
        echo "Fehler: git ist nicht installiert." >&2
        return 1
    fi

    # Bestehende Werte auslesen
    local _cur_name _cur_email _cur_editor
    _cur_name="$(git config --global user.name 2>/dev/null)"
    _cur_email="$(git config --global user.email 2>/dev/null)"
    _cur_editor="$(git config --global core.editor 2>/dev/null)"
    _cur_editor="${_cur_editor:-vim}"

    echo "── Git Setup ──────────────────────────────"
    echo "  Enter = bestehenden Wert übernehmen"
    echo ""

    local _git_name _git_email _git_editor
    read -r "_git_name?Benutzername [${_cur_name}]: "
    _git_name="${_git_name:-$_cur_name}"

    read -r "_git_email?E-Mail       [${_cur_email}]: "
    _git_email="${_git_email:-$_cur_email}"

    read -r "_git_editor?Editor       [${_cur_editor}]: "
    _git_editor="${_git_editor:-$_cur_editor}"

    if [[ -z "$_git_name" || -z "$_git_email" ]]; then
        echo "Abgebrochen: Name und E-Mail dürfen nicht leer sein." >&2
        return 1
    fi

    # Identität
    git config --global user.name           "$_git_name"
    git config --global user.email          "$_git_email"
    git config --global core.editor         "$_git_editor"

    # Workflow
    git config --global pull.rebase         true
    git config --global push.default        current
    git config --global init.defaultBranch  main

    # Diff & Merge
    git config --global diff.algorithm      histogram
    git config --global diff.renames        true
    git config --global merge.conflictstyle zdiff3

    # Core
    git config --global color.ui            auto
    git config --global core.autocrlf       input
    git config --global core.whitespace     trailing-space,space-before-tab

    # Credential helper (platform-aware)
    if [[ "$(uname)" == "Darwin" ]]; then
        git config --global credential.helper osxkeychain
    else
        git config --global credential.helper "cache --timeout=3600"
    fi

    # Sicherheit: Objektintegrität prüfen
    git config --global transfer.fsckobjects true
    git config --global fetch.fsckobjects    true
    git config --global receive.fsckobjects  true

    # Aliases
    git config --global alias.co       checkout
    git config --global alias.br       branch
    git config --global alias.ci       commit
    git config --global alias.st       status
    git config --global alias.unstage  'reset HEAD --'
    git config --global alias.last     'log -1 HEAD'

    echo ""
    echo "── Aktuelle Konfiguration ─────────────────"
    git config --global --list
}

# Kompakter Status mit Branch-Info
gs() {
    git status -sb
}

# Branches sortiert nach letztem Commit
gbr() {
    git for-each-ref --sort=-committerdate refs/heads/ \
        --format='%(committerdate:short)  %(refname:short)  %(subject)'
}

# Schnell committen: gc "Fix login bug"
gc() {
    git add -A && git commit -m "$*"
}

# Grafischer Log: gl [n]
gl() {
    if [[ $# -eq 0 ]]; then
        git log --oneline --graph --decorate -20
    else
        git log --oneline --graph --decorate "$@"
    fi
}

# Gemergte Branches löschen (außer main/master/dev)
git-clean-branches() {
    git branch --merged | grep -vE '^\*|main|master|dev' | xargs -r git branch -d
}

# Aktuellen Branch auf Remote pushen und Tracking setzen
gpush() {
    git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
}

# Letzten Commit rückgängig machen (Änderungen behalten)
gundo() {
    git reset --soft HEAD~1
}


# ─────────────────────────────────────────────
#  8. Docker
# ─────────────────────────────────────────────

# Shell in laufenden Container: dsh myapp [bash]
dsh() {
    docker exec -it "$1" "${2:-sh}"
}

# Logs eines Containers verfolgen: dlogs myapp
dlogs() {
    docker logs -f --tail=100 "$1"
}

# Laufende Container übersichtlich anzeigen
dps() {
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# Gestoppte Container + verwaiste Images aufräumen
dclean() {
    echo "Entferne gestoppte Container..."
    docker container prune -f
    echo "Entferne dangling Images..."
    docker image prune -f
}

# Image für aktuelles Verzeichnis bauen: dbuild myapp:latest
dbuild() {
    docker build -t "${1:-app}" .
}

# docker-compose Shortcut: up im Hintergrund
dcup() {
    docker compose up -d "$@"
}

# docker-compose down + optional volumes: dcdn [-v]
dcdn() {
    docker compose down "$@"
}


# ─────────────────────────────────────────────
#  9. Netzwerk & System
# ─────────────────────────────────────────────

# Externe IP (einzelner Anbieter)
myip() {
    curl -s https://api.ipify.org && echo
}

# Externe IP mit Fallback über mehrere Anbieter
netip() {
    local providers=(
        "https://api.ipify.org"
        "https://icanhazip.com"
        "https://ifconfig.me"
        "https://ipecho.net/plain"
        "https://api4.my-ip.io/ip"
    )
    for url in "${providers[@]}"; do
        local ip
        ip=$(curl -s --max-time 3 "$url" 2>/dev/null | tr -d '[:space:]')
        if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$ip  (via $url)"
            return
        fi
    done
    echo "Keine externe IP ermittelbar – alle Anbieter nicht erreichbar." >&2
    return 1
}

# Lokale IPs
localip() {
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
}

# HTTP-Header anzeigen: headers https://example.com
headers() {
    curl -sI "$1"
}

# Einfacher HTTP-Server: serve [port]
serve() {
    local port="${1:-8080}"
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port"
}

# DNS-Lookup kompakt: dns google.com
dns() {
    dig +short "$1"
}

# Offene Ports auf dem System anzeigen
openports() {
    if command -v ss &>/dev/null; then
        ss -tulpn
    else
        netstat -an | grep LISTEN
    fi
}

# Prozess auf einem Port beenden: killport 8080
killport() {
    local pid
    pid=$(lsof -ti :"$1")
    if [[ -z "$pid" ]]; then
        echo "Kein Prozess auf Port $1"
    else
        echo "Beende Prozess $pid auf Port $1"
        kill "$pid"
    fi
}

# Netzwerk-Scan (benötigt nmap): scan [subnet]
scan() {
    if ! command -v nmap &>/dev/null; then
        echo "nmap nicht installiert." >&2; return 1
    fi
    nmap -sn "${1:-192.168.1.0/24}"
}

# Kompakte Systemübersicht (macOS & Linux)
sysinfo() {
    echo "────────────────────────────────────"
    printf "  %-8s %s\n" "Host:"  "$(hostname)"
    printf "  %-8s %s\n" "OS:"    "$(uname -s) $(uname -r)"
    printf "  %-8s %s\n" "Arch:"  "$(uname -m)"
    if [[ -f /proc/cpuinfo ]]; then
        printf "  %-8s %s\n" "CPU:" \
            "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    elif command -v sysctl &>/dev/null; then
        printf "  %-8s %s\n" "CPU:" \
            "$(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
    fi
    if command -v free &>/dev/null; then
        free -h | awk '/^Mem:/ {printf "  %-8s %s gesamt, %s verfügbar\n","RAM:",$2,$7}'
    fi
    df -h / | awk 'NR==2 {printf "  %-8s %s / %s (%s belegt)\n","Disk:",$3,$2,$5}'
    echo "────────────────────────────────────"
}

# Detaillierte CPU-Informationen (macOS & Linux inkl. Raspberry Pi)
cpuinfo() {
    echo "────────────────────────────────────"
    printf "  %-16s %s\n" "Architektur:" "$(uname -m)"

    if [[ -f /proc/cpuinfo ]]; then
        # Linux (x86, ARM, Raspberry Pi)
        local model threads cores freq cache
        model=$(grep -m1 -iE '^model name\s*:' /proc/cpuinfo | cut -d: -f2 | xargs)
        # Fallback für ARM / Raspberry Pi (kein 'model name'-Feld)
        [[ -z "$model" ]] && model=$(grep -m1 'Hardware' /proc/cpuinfo | cut -d: -f2 | xargs)
        threads=$(grep -c '^processor' /proc/cpuinfo)
        cores=$(grep -m1 'cpu cores' /proc/cpuinfo | awk '{print $NF}')
        [[ -z "$cores" ]] && cores=$threads
        freq=$(grep -m1 'cpu MHz' /proc/cpuinfo | awk '{printf "%.0f", $NF}')
        cache=$(grep -m1 'cache size' /proc/cpuinfo | cut -d: -f2 | xargs)

        [[ -n "$model" ]] && printf "  %-16s %s\n"     "Modell:"   "$model"
        printf                      "  %-16s %s\n"     "Kerne:"    "$cores"
        printf                      "  %-16s %s\n"     "Threads:"  "$threads"
        [[ -n "$freq" ]]  && printf "  %-16s %s MHz\n" "Frequenz:" "$freq"
        [[ -n "$cache" ]] && printf "  %-16s %s\n"     "Cache:"    "$cache"

    elif command -v sysctl &>/dev/null; then
        # macOS (Intel & Apple Silicon)
        local model cores threads freq cache
        model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
        cores=$(sysctl -n hw.physicalcpu 2>/dev/null)
        threads=$(sysctl -n hw.logicalcpu 2>/dev/null)
        freq=$(sysctl -n hw.cpufrequency 2>/dev/null)      # leer bei Apple Silicon
        cache=$(sysctl -n hw.l3cachesize 2>/dev/null)

        [[ -n "$model" ]]   && printf "  %-16s %s\n"     "Modell:"    "$model"
        [[ -n "$cores" ]]   && printf "  %-16s %s\n"     "Kerne:"     "$cores"
        [[ -n "$threads" ]] && printf "  %-16s %s\n"     "Threads:"   "$threads"
        if [[ -n "$freq" && "$freq" -gt 0 ]]; then
            printf "  %-16s %s MHz\n" "Frequenz:" "$((freq / 1000000))"
        fi
        if [[ -n "$cache" && "$cache" -gt 0 ]]; then
            printf "  %-16s %s MB\n"  "Cache (L3):" "$((cache / 1048576))"
        fi
    else
        echo "  Keine CPU-Informationen verfügbar." >&2
    fi
    echo "────────────────────────────────────"
}

# Festplattennutzung ohne tmpfs/overlay
disk() {
    df -h | grep -vE '^tmpfs|^udev|^overlay|^shm'
}


# ─────────────────────────────────────────────
#  10. Prozesse
# ─────────────────────────────────────────────

# Prozess nach Name suchen: psg nginx
psg() {
    ps aux | grep -i "$1" | grep -v grep
}

# Prozess nach Name beenden: killp nginx
killp() {
    local pid
    pid=$(pgrep -i "$1")
    if [[ -z "$pid" ]]; then
        echo "Kein Prozess gefunden: $1"
    else
        echo "Beende Prozess(e): $pid"
        kill "$pid"
    fi
}

# Top-10 CPU-Fresser (macOS & Linux kompatibel)
topcpu() {
    ps aux | sort -k3 -rn | head -11
}

# Top-10 RAM-Fresser (macOS & Linux kompatibel)
topmem() {
    ps aux | sort -k4 -rn | head -11
}


# ─────────────────────────────────────────────
#  11. Entwicklung
# ─────────────────────────────────────────────

# Python venv erstellen und aktivieren: venv [name]
unalias venv 2>/dev/null
venv() {
    local name="${1:-.venv}"
    if [[ ! -d "$name" ]]; then
        echo "Erstelle venv: $(pwd)/$name"
        python3 -m venv "$name" || return 1
    else
        echo "venv '$name' existiert bereits – aktiviere..."
    fi
    source "$name/bin/activate"
    echo "venv '$name' aktiviert."
}

# Aktives venv deaktivieren
voff() {
    deactivate 2>/dev/null && echo "venv deaktiviert." || echo "Kein aktives venv."
}

# __pycache__ und .pyc-Dateien entfernen
pyclean() {
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
    find . -name "*.pyc" -delete 2>/dev/null
    echo "Python-Cache bereinigt."
}

# Alle veralteten pip-Pakete upgraden
pip-upgrade() {
    pip list --outdated --format=freeze | cut -d= -f1 | xargs -r pip install --upgrade
}

# Globale npm-Pakete auflisten
npmls() {
    npm list -g --depth=0
}

# JSON pretty-print: jsonp '{"a":1}'  oder  cat file.json | jsonp
jsonp() {
    if [[ -n "$1" ]]; then
        echo "$1" | python3 -m json.tool
    else
        python3 -m json.tool
    fi
}

# Zertifikat einer Domain prüfen: cert google.com
cert() {
    echo | openssl s_client -connect "${1}:443" -servername "$1" 2>/dev/null \
        | openssl x509 -noout -subject -dates
}

# Markdown-Datei(en) als Man-Page anzeigen: md2man [file|dir]
md2man() {
    local target="${1:-.}"
    if [[ -d "$target" ]]; then
        local files=("$target"/*.md)
        if [[ "${files[1]}" == "$target"/*.md ]]; then
            echo "md2man: keine .md-Dateien gefunden in: $target" >&2
            return 1
        fi
        pandoc -s -f markdown -t man "${files[@]}" | groff -T utf8 -man | less
    elif [[ -f "$target" ]]; then
        pandoc -s -f markdown -t man "$target" | groff -T utf8 -man | less
    else
        echo "md2man: kein gültiger Pfad: $target" >&2
        return 1
    fi
}

# Vim einrichten, Colorschemes laden und ~/.vimrc anlegen
setup-vim() {
    # Prüfen ob vim installiert ist
    if ! command -v vim &>/dev/null; then
        echo "Vim ist nicht installiert." >&2
        if [[ "$(uname)" == "Darwin" ]]; then
            echo "  Installation: brew install vim" >&2
        else
            echo "  Installation: sudo apt install vim" >&2
        fi
        return 1
    fi
    echo "Vim gefunden: $(vim --version | head -1)"
    echo ""

    # Code Completion (coc.nvim) aktivieren?
    read -r "_coc?Code Completion aktivieren? (coc.nvim, benötigt Node.js/npm) [j/N] "

    # ~/.vimrc: Backup und Bestätigung falls bereits vorhanden
    if [[ -f "$HOME/.vimrc" ]]; then
        read -r "_ans?~/.vimrc existiert bereits. Überschreiben? [j/N] "
        if [[ "${_ans:l}" != "j" ]]; then
            echo "Abgebrochen."
            return 0
        fi
        bak "$HOME/.vimrc"
        echo "Backup angelegt: ~/.vimrc.bak.$(date +%F)"
    fi

    # Node.js prüfen falls coc gewünscht
    if [[ "${_coc:l}" == "j" ]]; then
        if ! command -v node &>/dev/null; then
            echo "Warnung: Node.js nicht gefunden – Code Completion wird übersprungen." >&2
            if [[ "$(uname)" == "Darwin" ]]; then
                echo "  Installation: brew install node" >&2
            else
                echo "  Installation: sudo apt install nodejs npm" >&2
            fi
            _coc="n"
        else
            echo "Node.js gefunden: $(node --version)"
        fi
    fi

    # ~/.vim/colors/ Verzeichnis sicherstellen
    mkdir -p "$HOME/.vim/colors"

    # Colorscheme: distinguished (wird in vimrc als Standard gesetzt)
    echo "Lade Colorscheme: distinguished..."
    if ! curl -fsSL \
        "https://raw.githubusercontent.com/Lokaltog/vim-distinguished/develop/colors/distinguished.vim" \
        -o "$HOME/.vim/colors/distinguished.vim"; then
        echo "Fehler: distinguished.vim konnte nicht geladen werden." >&2
        return 1
    fi
    echo "  -> distinguished.vim installiert"

    # Colorscheme: solarized (optional, g:solarized_termcolors in vimrc gesetzt)
    echo "Lade Colorscheme: solarized..."
    if curl -fsSL \
        "https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim" \
        -o "$HOME/.vim/colors/solarized.vim"; then
        echo "  -> solarized.vim installiert"
    else
        echo "  Warnung: solarized.vim konnte nicht geladen werden (optional)." >&2
    fi

    # vim-plug Plugin-Manager herunterladen
    echo "Lade vim-plug Plugin-Manager..."
    if ! curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"; then
        echo "Fehler: vim-plug konnte nicht geladen werden." >&2
        return 1
    fi
    echo "  -> vim-plug installiert"

    # ── ~/.vimrc Teil 1: Basiseinstellungen + Filetype + Plug-Block ──
    cat > "$HOME/.vimrc" << 'VIMRC_BASE'
" ─────────────────────────────────────────────
"  ~/.vimrc — Robert Tulke
" ─────────────────────────────────────────────

" ── Allgemein ────────────────────────────────
syntax enable
set encoding=utf-8
set number
set cursorline
set scrolloff=5
set wildmenu
set showmatch
set backspace=indent,eol,start
set ruler
set laststatus=2

" ── Darstellung ──────────────────────────────
if has('gui_running')
    set background=light
else
    set background=dark
endif

let g:solarized_termcolors=256
colorscheme distinguished

" Tabs und trailing Whitespace sichtbar machen
set list
set listchars=tab:»·,trail:·

" ── Suche ────────────────────────────────────
set incsearch
set hlsearch
set ignorecase
set smartcase

" ── Einrückung (Standard) ────────────────────
set modeline
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
filetype indent on

" ── Einrückung pro Dateityp ──────────────────
" Python (PEP 8: 4 Leerzeichen, max. 79 Zeichen)
autocmd FileType python setlocal shiftwidth=4 tabstop=4 softtabstop=4
    \ expandtab colorcolumn=79

" YAML / Ansible (2 Leerzeichen)
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" JSON (2 Leerzeichen, Anführungszeichen nicht verbergen)
autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=2
    \ expandtab conceallevel=0

" HTML / CSS (2 Leerzeichen)
autocmd FileType html,css setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" C / C++ (4 Leerzeichen, C-Einrückung, 80-Zeichen-Spalte)
autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4 softtabstop=4
    \ expandtab cindent colorcolumn=80

" Bash / Shell (4 Leerzeichen)
autocmd FileType sh setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab

" Config / INI-Dateien
autocmd FileType conf,ini setlocal shiftwidth=4 tabstop=4

" Perl (4 Leerzeichen)
autocmd FileType perl setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab

" Ruby (2 Leerzeichen, Community-Standard)
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Dockerfile (2 Leerzeichen)
autocmd FileType dockerfile setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Makefile (echte Tabs erforderlich – make bricht sonst ab!)
autocmd FileType make setlocal noexpandtab shiftwidth=4 tabstop=4

" Markdown (Zeilenumbruch aktiviert)
autocmd FileType markdown setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab wrap linebreak

" Terraform / HCL (2 Leerzeichen)
autocmd FileType terraform,hcl setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Go (Tabs, offizieller Standard von gofmt)
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4

" SQL (2 Leerzeichen)
autocmd FileType sql setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" XML (2 Leerzeichen)
autocmd FileType xml setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Nginx-Konfiguration (4 Leerzeichen)
autocmd FileType nginx setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab

" JavaScript / TypeScript / JSX / TSX (2 Leerzeichen, Community-Standard)
autocmd FileType javascript,typescript,javascriptreact,typescriptreact
    \ setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Rust (4 Leerzeichen, 100-Zeichen-Spalte laut Style Guide)
autocmd FileType rust setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab colorcolumn=100

" TOML (2 Leerzeichen, z.B. Cargo.toml, pyproject.toml)
autocmd FileType toml setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Jinja2 / Ansible-Templates (.j2, .jinja, .jinja2)
autocmd FileType jinja,jinja2,htmljinja,htmljinja2
    \ setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Protocol Buffers / gRPC (.proto)
autocmd FileType proto setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" ── Plugins (vim-plug) ───────────────────────
call plug#begin('~/.vim/plugged')

" Syntax-Highlighting für viele Sprachen (inkl. Perl, Ruby, Ansible, ...)
Plug 'sheerun/vim-polyglot'

" Asynchrones Linting
Plug 'dense-analysis/ale'

" Statusleiste
Plug 'itchyny/lightline.vim'
VIMRC_BASE

    # coc.nvim optional hinzufügen
    if [[ "${_coc:l}" == "j" ]]; then
        cat >> "$HOME/.vimrc" << 'VIMRC_COC_PLUG'

" Code Completion via Language Server Protocol
Plug 'neoclide/coc.nvim', {'branch': 'release'}
VIMRC_COC_PLUG
    fi

    # ── ~/.vimrc Teil 2: ALE + Lightline ──
    cat >> "$HOME/.vimrc" << 'VIMRC_ALE'

call plug#end()

" ── ALE Linting ──────────────────────────────
let g:ale_linters = {
\   'python':  ['flake8'],
\   'sh':      ['shellcheck'],
\   'yaml':    ['yamllint'],
\   'c':       ['gcc'],
\   'cpp':     ['gcc'],
\   'json':    ['jsonlint'],
\   'perl':        ['perl'],
\   'ruby':        ['rubocop'],
\   'dockerfile':  ['hadolint'],
\   'markdown':    ['markdownlint'],
\   'terraform':   ['tflint'],
\   'go':          ['golangci-lint'],
\   'sql':         ['sqlint'],
\   'xml':         ['xmllint'],
\   'javascript':  ['eslint'],
\   'typescript':  ['eslint'],
\   'rust':        ['cargo'],
\   'proto':       ['buf'],
\}
let g:ale_sign_error   = '>>'
let g:ale_sign_warning = '--'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0

" Fehler-Navigation: Ctrl+j / Ctrl+k
nmap <C-j> <Plug>(ale_next_wrap)
nmap <C-k> <Plug>(ale_previous_wrap)

" ── Lightline ────────────────────────────────
let g:lightline = { 'colorscheme': 'wombat' }
set noshowmode
VIMRC_ALE

    # ── ~/.vimrc Teil 3: coc.nvim Konfiguration (optional) ──
    if [[ "${_coc:l}" == "j" ]]; then
        cat >> "$HOME/.vimrc" << 'VIMRC_COC'

" ── coc.nvim Code Completion ─────────────────
" Tab / Shift+Tab zur Navigation in der Vorschlagsliste
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Enter bestätigt den ausgewählten Vorschlag
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" K zeigt Hover-Dokumentation
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" Definition und Referenzen springen
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
VIMRC_COC
    fi

    # Plugins installieren
    echo ""
    echo "Installiere vim-Plugins (kann einen Moment dauern)..."
    vim +PlugInstall +qall 2>/dev/null

    # coc Extensions installieren
    if [[ "${_coc:l}" == "j" ]]; then
        echo "Installiere coc-Extensions..."
        vim +"CocInstall -sync coc-pyright coc-clangd coc-yaml coc-sh coc-json coc-perl coc-solargraph coc-docker coc-markdownlint coc-terraform coc-go coc-tsserver coc-rust-analyzer" +qall 2>/dev/null
    fi

    local plugins="vim-polyglot, ale, lightline"
    [[ "${_coc:l}" == "j" ]] && plugins="$plugins, coc.nvim"

    echo ""
    echo "── Vim Setup abgeschlossen ────────────────"
    echo "  ~/.vimrc                 angelegt"
    echo "  ~/.vim/colors/           distinguished, solarized"
    echo "  ~/.vim/autoload/         vim-plug"
    echo "  ~/.vim/plugged/          $plugins"
    echo ""
    echo "── Externe Linting-Tools (optional) ───────"
    echo "  Python : pip install flake8"
    echo "  Bash   : apt install shellcheck  /  brew install shellcheck"
    echo "  YAML   : pip install yamllint"
    echo "  JSON   : npm install -g jsonlint"
    echo "  C/C++  : apt install gcc         /  brew install gcc"
    echo "  Ruby   : gem install rubocop"
    echo "  Perl   : cpanm Perl::Critic"
    echo "  Docker : brew install hadolint  /  apt install hadolint"
    echo "  MD     : npm install -g markdownlint-cli"
    echo "  TF     : brew install tflint"
    echo "  Go     : go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
    echo "  SQL    : gem install sqlint"
    echo "  XML    : apt install libxml2-utils  /  vorinstalliert auf macOS"
    echo "  JS/TS  : npm install -g eslint"
    echo "  Rust   : rustup  (cargo kommt mit Standard-Installation)"
    echo "  Proto  : brew install buf  /  apt install protobuf-compiler"
    if [[ "${_coc:l}" == "j" ]]; then
        echo ""
        echo "── coc LSP-Server (optional) ───────────────"
        echo "  Python : npm i -g pyright"
        echo "  C/C++  : apt install clangd  /  brew install llvm"
        echo "  Bash   : npm i -g bash-language-server"
        echo "  Ruby   : gem install solargraph"
        echo "  Perl   : cpanm Perl::LanguageServer"
        echo "  Go     : via coc-go (automatisch, installiert gopls)"
        echo "  JS/TS  : via coc-tsserver (automatisch)"
        echo "  Rust   : rustup component add rust-analyzer"
        echo "  Docker : via coc-docker (automatisch)"
        echo "  YAML   : via coc-yaml (automatisch)"
        echo "  JSON   : via coc-json (automatisch)"
    fi
}


# ─────────────────────────────────────────────
#  12. tmux
# ─────────────────────────────────────────────

# Neue tmux-Session erstellen: tns projektname
tns() {
    tmux new-session -s "${1:-main}"
}

# An bestehende Session anhängen: ta [name]
ta() {
    if [[ -n "$1" ]]; then
        tmux attach-session -t "$1"
    else
        tmux attach-session 2>/dev/null || echo "Keine tmux-Session vorhanden. Neue Session: tns [name]"
    fi
}

# Alle Sessions auflisten
tls() {
    tmux list-sessions 2>/dev/null || echo "Kein tmux-Server läuft."
}

# Session beenden: tks name
tks() {
    tmux kill-session -t "${1:-main}"
}

# Alle Sessions beenden
tka() {
    tmux kill-server && echo "Alle tmux-Sessions beendet."
}

# Aktuelles Fenster horizontal teilen
tsplit() {
    tmux split-window -h
}

# Neues Fenster in aktueller Session: tnw [name]
tnw() {
    tmux new-window ${1:+-n "$1"}
}


# ─────────────────────────────────────────────
#  13. Ansible
# ─────────────────────────────────────────────

# Playbook ausführen: ap site.yml [-i inventory]
ap() {
    ansible-playbook "$@"
}

# Playbook im Dry-Run (Check-Mode): acheck site.yml
acheck() {
    ansible-playbook --check --diff "$@"
}

# Hosts anpingen: aping all [-i inventory]
aping() {
    local host="${1:-all}"
    shift 2>/dev/null
    ansible "$host" -m ping "$@"
}

# Ansible-Inventar als JSON anzeigen: ainv [inventory-datei]
ainv() {
    if [[ -n "$1" ]]; then
        ansible-inventory -i "$1" --list | python3 -m json.tool
    else
        ansible-inventory --list | python3 -m json.tool
    fi
}

# Ansible-Facts eines Hosts abrufen: afacts hostname
afacts() {
    ansible "$1" -m setup "${@:2}"
}

# Ad-hoc-Befehl auf Hosts: arun all "uptime"
arun() {
    local hosts="${1:-all}"
    local cmd="$2"
    shift 2
    ansible "$hosts" -m shell -a "$cmd" "$@"
}


# ─────────────────────────────────────────────
#  14. SSH & Raspberry Pi
# ─────────────────────────────────────────────

# SSH-Public-Key auf Remote-Host kopieren: sshcopy user@host
sshcopy() {
    ssh-copy-id "$1"
}

# Fingerprint des eigenen SSH-Keys anzeigen: sshfp [keyfile]
sshfp() {
    local key="${1:-$HOME/.ssh/id_ed25519.pub}"
    [[ -f "$key" ]] || key="$HOME/.ssh/id_rsa.pub"
    if [[ -f "$key" ]]; then
        ssh-keygen -lf "$key"
    else
        echo "Kein SSH-Key gefunden unter $key"
    fi
}

# SSH-Tunnel aufbauen: tunnel local_port remote_host remote_port gateway
# Beispiel: tunnel 5432 db-server 5432 user@jump-host
tunnel() {
    if [[ $# -lt 4 ]]; then
        echo "Verwendung: tunnel <local_port> <remote_host> <remote_port> <gateway>"
        return 1
    fi
    echo "Tunnel: localhost:$1 → $2:$3 via $4"
    ssh -NL "${1}:${2}:${3}" "$4"
}

# Raspberry Pi im Netz finden (benötigt nmap): rpi-scan [subnet]
rpi-scan() {
    if ! command -v nmap &>/dev/null; then
        echo "nmap nicht installiert. apt install nmap / brew install nmap" >&2
        return 1
    fi
    local subnet="${1:-192.168.1.0/24}"
    echo "Suche Raspberry Pi in $subnet ..."
    nmap -sn "$subnet" | grep -B2 -iE "b8:27:eb|dc:a6:32|e4:5f:01|d8:3a:dd|Raspberry"
}

# Schnelle SSH-Verbindung mit Standard-User pi: rpi hostname
rpi() {
    ssh "pi@${1}"
}


# ─────────────────────────────────────────────
#  15. Utilities
# ─────────────────────────────────────────────

# Befehl n-mal wiederholen: retry [max] <cmd>
retry() {
    local n=0
    local max="${1:-5}"; shift
    until "$@"; do
        ((n++))
        [[ $n -ge $max ]] && { echo "Fehlgeschlagen nach $max Versuchen."; return 1; }
        echo "Versuch $n/$max fehlgeschlagen – neuer Versuch in 2s..."
        sleep 2
    done
}

# Befehl timen: bench sleep 2
bench() {
    time "$@"
}

# Countdown-Timer: countdown 60
countdown() {
    local secs="${1:-10}"
    while [[ $secs -gt 0 ]]; do
        printf "\r%3d Sekunden verbleibend..." "$secs"
        sleep 1
        ((secs--))
    done
    printf "\rFertig!                        \n"
}

# Aktuellen Unix-Timestamp ausgeben
timestamp() {
    date +%s
}

# Unix-Timestamp in lesbares Datum umrechnen: epoch2date 1700000000
epoch2date() {
    if date -d "@$1" &>/dev/null 2>&1; then
        date -d "@$1"       # Linux (GNU date)
    else
        date -r "$1"        # macOS (BSD date)
    fi
}

# Schnelle Notiz anhängen: note Erinnerung XYZ
note() {
    echo "[$(date '+%F %T')] $*" >> "$HOME/.notes"
    echo "Notiz gespeichert."
}

# Alle Notizen anzeigen
notes() {
    [[ -f "$HOME/.notes" ]] && cat "$HOME/.notes" || echo "Keine Notizen vorhanden."
}

# Alle Notizen löschen
note-clear() {
    rm -f "$HOME/.notes" && echo "Notizen gelöscht."
}

# Ja/Nein-Abfrage: confirm "Wirklich löschen?" && rm file
confirm() {
    read -r "antwort?$* [j/N] "
    [[ "${antwort:l}" == "j" ]]
}

# Zufälliges Passwort generieren: mkpass [länge]
mkpass() {
    local len="${1:-24}"
    LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c "$len"; echo
}

# In Clipboard kopieren (macOS & Linux): echo "foo" | copy
copy() {
    if command -v pbcopy &>/dev/null; then
        pbcopy
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --input
    else
        echo "Kein Clipboard-Tool gefunden (pbcopy/xclip/xsel)." >&2
    fi
}

# Aus Clipboard einfügen (macOS & Linux)
paste() {
    if command -v pbpaste &>/dev/null; then
        pbpaste
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard -o
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --output
    else
        echo "Kein Clipboard-Tool gefunden." >&2
    fi
}

# PATH übersichtlich anzeigen
path() {
    echo "$PATH" | tr ':' '\n' | nl
}

# .zshrc neu laden
reload() {
    source ~/.zshrc && echo ".zshrc neu geladen."
}
