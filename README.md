# Automazioni

Raccolta delle automazioni di Gabriele Leonardi: le skill per Claude Code che avviano un nuovo progetto e uno script di prima configurazione per una VPS.

| Cartella | Contenuto | Stato |
|---|---|---|
| [`skills/`](skills) | Cinque skill per Claude Code che creano un progetto pronto, con Git e repository GitHub | Costruite a luglio 2026, durante il master |
| [`vps-setup/`](vps-setup) | Script di messa in sicurezza di base per una VPS Ubuntu o Debian | Scritto a novembre 2026, non ancora provato su un server reale |

## Skill per Claude Code

Una skill è un file `SKILL.md` che spiega a Claude Code come svolgere un compito ripetitivo, sempre con gli stessi passaggi. Queste le ho costruite lavorando con Claude, per non ripetere a mano la stessa sequenza a ogni nuovo progetto.

| Skill | Cosa crea |
|---|---|
| `create-react-vite-app` | App React con Vite, JavaScript ed ESLint |
| `create-vanilla-ts-app` | App TypeScript con Vite, senza framework |
| `create-ts-node-app` | Progetto TypeScript che compila con `tsc` e gira su Node |
| `create-ts-tsx-app` | Progetto TypeScript eseguito direttamente con `tsx`, con riavvio automatico |
| `create-ts-browser-app` | Progetto TypeScript per il browser, senza bundler, da provare con Live Server |

Tutte seguono lo stesso schema:

1. chiedono la posizione e il nome del progetto;
2. generano il progetto e installano le dipendenze;
3. tolgono i file di esempio e lasciano una base pulita;
4. inizializzano Git e fanno il primo commit;
5. creano il repository su GitHub con la GitHub CLI e fanno il primo push.

### Installazione e uso

```bash
cp -R skills/* ~/.claude/skills/
```

Poi, in Claude Code, basta una richiesta come "crea una nuova app React" oppure "crea un progetto TypeScript con tsx": Claude Code sceglie la skill dalla descrizione e ne segue i passaggi.

### Due dettagli che ho dovuto gestire

- Le versioni recenti di `create-vite` propongono oxlint al posto di ESLint. La skill React ora chiede esplicitamente ESLint e verifica che nel progetto ci sia `eslint.config.js`.
- In un progetto TypeScript per il browser senza bundler, gli `import` devono puntare al file `.js` compilato e non al `.ts`. La skill lo spiega, perché è un errore facile da fare.

### Limiti

- Non configurano un framework di test.
- Richiedono la GitHub CLI (`gh`) installata e autenticata; se manca, la skill si ferma e avvisa.
- Sono volutamente minimali: solo il file `SKILL.md`, senza script di supporto.

## Script di setup per VPS

`vps-setup/setup-vps.sh` automatizza la prima configurazione di un server: aggiornamenti, utente con sudo, accesso SSH solo con chiave, firewall e Fail2ban. I dettagli, le protezioni e lo stato delle verifiche sono nel [README della cartella](vps-setup/README.md).
