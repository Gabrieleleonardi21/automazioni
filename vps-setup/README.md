# setup-vps.sh

Script di prima configurazione e messa in sicurezza di base per una VPS Ubuntu o Debian appena creata.

L'ho preparato dopo il colloquio, con l'aiuto di Claude, per studiare la parte su cui avevo risposto di non avere esperienza: la gestione di un server.

## Stato

- Verificato con controllo della sintassi (`bash -n`), analisi statica (ShellCheck) e modalità di prova (`--dry-run`).
- **Non ancora eseguito su un server reale.** Il prossimo passo è provarlo su una VPS di test e correggere quello che emerge.

## Cosa fa

1. Aggiorna il sistema e attiva gli aggiornamenti di sicurezza automatici.
2. Crea un utente normale con permessi di amministratore (sudo).
3. Copia la chiave SSH pubblica sul nuovo utente.
4. Disattiva l'accesso SSH come root e l'accesso con password.
5. Attiva il firewall (UFW) lasciando aperte solo le porte necessarie.
6. Attiva Fail2ban per bloccare chi tenta di indovinare le credenziali.
7. Installa Docker, se richiesto.
8. Stampa un riepilogo con le verifiche finali e salva un registro in `/var/log/setup-vps.log`.

## Uso

Da root, sulla VPS:

```bash
bash setup-vps.sh --user gabriele --dry-run      # mostra i passaggi senza eseguirli
bash setup-vps.sh --user gabriele                # configurazione base
bash setup-vps.sh --user gabriele --web          # apre anche le porte 80 e 443
bash setup-vps.sh --user gabriele --with-docker  # installa anche Docker
```

Opzioni: `--user NOME` (obbligatoria), `--pubkey FILE`, `--web`, `--with-docker`, `--dry-run`, `--help`.

Lo script si può rilanciare più volte: i passaggi già fatti non vengono ripetuti.

## Protezioni per non restare chiusi fuori

Il rischio principale di uno script del genere è bloccare l'accesso al server. Per questo:

- si ferma **prima** di modificare SSH se non trova una chiave pubblica valida per il nuovo utente;
- controlla la configurazione con `sshd -t` prima di riavviare il servizio e, se è sbagliata, annulla la modifica;
- legge la porta su cui SSH ascolta davvero e apre quella nel firewall, invece di dare per scontata la 22;
- alla fine ricorda di provare il nuovo accesso da un'altra finestra prima di chiudere la sessione.

## Cosa ho imparato scrivendolo

- `sshd` usa il primo valore che trova per ogni opzione: per questo il file di configurazione si chiama `00-hardening.conf`, così viene letto prima di quelli creati dal provider.
- Le porte pubblicate da Docker restano raggiungibili anche se il firewall UFW non le apre: vanno pubblicate solo quelle che servono, mai quella del database.
- Disattivare le password ha senso solo dopo aver verificato che l'accesso con chiave funziona.
- Spegnere una VPS non ferma l'addebito: per non pagare va cancellata.

## Cosa manca

- La prova su un server reale.
- Backup o snapshot automatici.
- Monitoraggio e avvisi.
- La configurazione di un dominio con certificato HTTPS.
