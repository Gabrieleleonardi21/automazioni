#!/usr/bin/env bash
#
# setup-vps.sh - Prima configurazione e messa in sicurezza di base di una VPS
#                Ubuntu o Debian appena creata.
#
# Cosa fa, nell'ordine:
#   1. aggiorna il sistema e attiva gli aggiornamenti di sicurezza automatici
#   2. crea un utente normale con permessi di amministratore (sudo)
#   3. copia la chiave SSH pubblica sul nuovo utente
#   4. disattiva l'accesso SSH come root e l'accesso con password
#   5. attiva il firewall (UFW) lasciando aperte solo le porte necessarie
#   6. attiva Fail2ban per bloccare chi tenta di indovinare le credenziali
#   7. (facoltativo) installa Docker
#   8. stampa un riepilogo con le verifiche finali
#
# Uso (da root, sulla VPS):
#   ./setup-vps.sh --user gabriele                 # configurazione base
#   ./setup-vps.sh --user gabriele --web           # apre anche le porte 80 e 443
#   ./setup-vps.sh --user gabriele --with-docker   # installa anche Docker
#   ./setup-vps.sh --user gabriele --dry-run       # mostra i passaggi senza eseguirli
#
# Opzioni:
#   --user NOME        nome dell'utente da creare (obbligatorio)
#   --pubkey FILE      file con la chiave pubblica da installare
#                      (se manca, usa le chiavi gia' presenti per root)
#   --web              apre le porte 80 (HTTP) e 443 (HTTPS)
#   --with-docker      installa Docker con lo script ufficiale
#   --dry-run          stampa i comandi senza modificare nulla
#   -h, --help         mostra questo aiuto
#
# Lo script si puo' rilanciare piu' volte: i passaggi gia' fatti non vengono ripetuti.
# IMPORTANTE: dopo l'esecuzione NON chiudere la sessione corrente prima di aver
# provato l'accesso con il nuovo utente da un'altra finestra del terminale.

set -euo pipefail

NEW_USER=""
PUBKEY_FILE=""
OPEN_WEB=0
WITH_DOCKER=0
DRY_RUN=0
LOG_FILE="/var/log/setup-vps.log"
SSHD_DROPIN="/etc/ssh/sshd_config.d/00-hardening.conf"

# ---------- funzioni di servizio ----------

info()  { printf '\n==> %s\n' "$*"; }
warn()  { printf 'ATTENZIONE: %s\n' "$*" >&2; }
fail()  { printf 'ERRORE: %s\n' "$*" >&2; exit 1; }

usage() {
  # Stampa il blocco di commenti in cima al file, senza il cancelletto.
  sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'
}

# Esegue un comando, oppure lo stampa soltanto se siamo in --dry-run.
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '   [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# Scrive su un file il testo ricevuto da standard input.
write_file() {
  local path="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '   [dry-run] scriverei %s con questo contenuto:\n' "$path"
    sed 's/^/      /'
  else
    cat > "$path"
  fi
}

# ---------- lettura delle opzioni ----------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)        NEW_USER="${2:-}"; shift 2 ;;
    --pubkey)      PUBKEY_FILE="${2:-}"; shift 2 ;;
    --web)         OPEN_WEB=1; shift ;;
    --with-docker) WITH_DOCKER=1; shift ;;
    --dry-run)     DRY_RUN=1; shift ;;
    -h|--help)     usage; exit 0 ;;
    *)             fail "opzione sconosciuta: $1 (usa --help)" ;;
  esac
done

# ---------- controlli iniziali ----------

[[ -n "$NEW_USER" ]] || fail "manca --user NOME (usa --help)"
[[ "$NEW_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || fail "nome utente non valido: $NEW_USER"
[[ "$NEW_USER" != "root" ]] || fail "l'utente da creare non puo' essere root"

if [[ "$DRY_RUN" -eq 0 ]]; then
  [[ "$EUID" -eq 0 ]] || fail "lo script va eseguito come root"
  command -v apt-get >/dev/null || fail "serve un sistema Ubuntu o Debian (apt-get non trovato)"
  # Da qui in poi tutto quello che viene stampato finisce anche nel file di registro.
  exec > >(tee -a "$LOG_FILE") 2>&1
  printf '\n--- esecuzione del %s ---\n' "$(date '+%Y-%m-%d %H:%M:%S')"
fi

if [[ -n "$PUBKEY_FILE" && ! -s "$PUBKEY_FILE" ]]; then
  fail "il file della chiave pubblica non esiste o e' vuoto: $PUBKEY_FILE"
fi

export DEBIAN_FRONTEND=noninteractive
USER_HOME="/home/$NEW_USER"
AUTH_KEYS="$USER_HOME/.ssh/authorized_keys"

# ---------- 1. aggiornamenti ----------

info "1/8 Aggiorno il sistema e installo i pacchetti necessari"
run apt-get update -y
run apt-get upgrade -y
run apt-get install -y sudo ufw fail2ban unattended-upgrades

info "    Attivo gli aggiornamenti di sicurezza automatici"
write_file /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# ---------- 2. utente amministratore ----------

info "2/8 Creo l'utente $NEW_USER con permessi sudo"
if id "$NEW_USER" >/dev/null 2>&1; then
  echo "    L'utente esiste gia': lo lascio com'e'."
else
  run adduser --disabled-password --gecos "" "$NEW_USER"
  echo "    Scegli la password di $NEW_USER (serve per usare sudo, non per entrare via SSH):"
  run passwd "$NEW_USER"
fi
run usermod -aG sudo "$NEW_USER"

# ---------- 3. chiave SSH ----------

info "3/8 Installo la chiave SSH pubblica per $NEW_USER"
if [[ -z "$PUBKEY_FILE" ]]; then
  PUBKEY_FILE="/root/.ssh/authorized_keys"
  echo "    Nessun --pubkey indicato: uso le chiavi gia' presenti per root."
fi
if [[ "$DRY_RUN" -eq 0 && ! -s "$PUBKEY_FILE" ]]; then
  fail "nessuna chiave pubblica trovata in $PUBKEY_FILE. Mi fermo PRIMA di toccare SSH, per non chiuderti fuori."
fi
run install -d -m 700 -o "$NEW_USER" -g "$NEW_USER" "$USER_HOME/.ssh"
if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '   [dry-run] aggiungerei le chiavi di %s a %s\n' "$PUBKEY_FILE" "$AUTH_KEYS"
else
  touch "$AUTH_KEYS"
  # Aggiungo solo le chiavi che non ci sono gia', cosi' rilanciare lo script non crea doppioni.
  while IFS= read -r key || [[ -n "$key" ]]; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    grep -qxF "$key" "$AUTH_KEYS" || printf '%s\n' "$key" >> "$AUTH_KEYS"
  done < "$PUBKEY_FILE"
  chown "$NEW_USER:$NEW_USER" "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
  # Controllo di sicurezza: senza una chiave valida non disattivo le password.
  grep -qE '^(ssh-|ecdsa-|sk-)' "$AUTH_KEYS" \
    || fail "in $AUTH_KEYS non c'e' nessuna chiave valida. Mi fermo PRIMA di toccare SSH."
fi

# ---------- 4. SSH ----------

info "4/8 Disattivo l'accesso SSH come root e con password"
if [[ "$DRY_RUN" -eq 0 ]] && ! grep -qiE '^\s*Include\s+/etc/ssh/sshd_config\.d/' /etc/ssh/sshd_config; then
  fail "/etc/ssh/sshd_config non include la cartella sshd_config.d: sistema non previsto, mi fermo."
fi
# Il nome inizia con 00 perche' sshd usa il PRIMO valore che trova per ogni opzione:
# cosi' questo file vince su quelli creati dal provider (es. 50-cloud-init.conf).
write_file "$SSHD_DROPIN" <<'EOF'
# Creato da setup-vps.sh
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
EOF
if [[ "$DRY_RUN" -eq 0 ]]; then
  # Verifico la configurazione prima di riavviare: se e' sbagliata, torno indietro.
  if ! sshd -t; then
    rm -f "$SSHD_DROPIN"
    fail "la configurazione SSH non e' valida: ho annullato la modifica."
  fi
fi
run systemctl restart ssh

# ---------- 5. firewall ----------

info "5/8 Configuro il firewall (UFW)"
# Leggo la porta su cui SSH ascolta davvero, per non chiudere fuori chi usa una porta diversa dalla 22.
SSH_PORTS="22"
if command -v sshd >/dev/null 2>&1 && [[ "$EUID" -eq 0 ]]; then
  SSH_PORTS="$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2}' | sort -u | tr '\n' ' ')"
  [[ -n "${SSH_PORTS// /}" ]] || SSH_PORTS="22"
fi
run ufw default deny incoming
run ufw default allow outgoing
for port in $SSH_PORTS; do
  run ufw allow "$port/tcp" comment 'SSH'
done
if [[ "$OPEN_WEB" -eq 1 ]]; then
  run ufw allow 80/tcp comment 'HTTP'
  run ufw allow 443/tcp comment 'HTTPS'
fi
run ufw --force enable

# ---------- 6. Fail2ban ----------

info "6/8 Attivo Fail2ban sulla porta SSH"
write_file /etc/fail2ban/jail.d/sshd-local.conf <<'EOF'
# Creato da setup-vps.sh: 5 tentativi falliti in 10 minuti = blocco di 1 ora
[sshd]
enabled  = true
maxretry = 5
findtime = 10m
bantime  = 1h
EOF
run systemctl enable fail2ban
run systemctl restart fail2ban

# ---------- 7. Docker (facoltativo) ----------

if [[ "$WITH_DOCKER" -eq 1 ]]; then
  info "7/8 Installo Docker"
  if command -v docker >/dev/null 2>&1; then
    echo "    Docker e' gia' installato."
  else
    run apt-get install -y curl ca-certificates
    run curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    run sh /tmp/get-docker.sh
    run rm -f /tmp/get-docker.sh
  fi
  run usermod -aG docker "$NEW_USER"
  warn "le porte pubblicate da Docker (ports: nel file compose) sono raggiungibili anche se UFW non le apre."
  warn "pubblica solo le porte che servono e non esporre mai quella del database."
else
  info "7/8 Docker non richiesto (usa --with-docker per installarlo)"
fi

# ---------- 8. riepilogo ----------

info "8/8 Riepilogo"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "    Prova completata: non e' stato modificato nulla."
  exit 0
fi

echo "--- SSH ---"
sshd -T 2>/dev/null | grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication) ' || true
echo "--- Firewall ---"
ufw status verbose
echo "--- Fail2ban ---"
if systemctl is-active --quiet fail2ban; then
  sleep 2
  fail2ban-client status sshd || warn "Fail2ban e' attivo ma la regola sshd non risponde ancora."
else
  warn "Fail2ban non e' partito: controlla con 'systemctl status fail2ban'."
fi
echo "--- Aggiornamenti automatici ---"
cat /etc/apt/apt.conf.d/20auto-upgrades

SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
cat <<EOF

Configurazione completata. Registro salvato in $LOG_FILE

PRIMA DI CHIUDERE QUESTA SESSIONE apri un'altra finestra del terminale e prova:
    ssh $NEW_USER@${SERVER_IP:-IP_DEL_SERVER}
    sudo whoami        # deve rispondere: root
Chiudi questa sessione solo se l'accesso nuovo funziona.
EOF
