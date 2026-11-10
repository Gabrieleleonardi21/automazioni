---
name: create-vanilla-ts-app
description: Crea una nuova app TypeScript con Vite (template vanilla-ts, senza framework) seguendo una procedura fissa. Usa quando l'utente chiede di creare/generare una nuova app o progetto TypeScript, un progetto Vite vanilla in TypeScript, o di fare lo scaffold di un'app TS per il browser (non React).
---

# Create Vanilla TS App

Genera un progetto TypeScript con Vite usando il template `vanilla-ts` (nessun
framework: solo TS + Vite per il browser). Segui i passaggi nell'ordine esatto.
Non aggiungere React, altri framework o librerie non richieste.

## Passaggi

1. Chiedi all'utente la **posizione** (cartella padre; default: directory corrente)
   e il **nome** dell'app.

2. Genera l'app con il template `vanilla-ts` e installa le dipendenze:
   ```bash
   npm create vite@latest <NOME> -- --template vanilla-ts
   cd <NOME> && npm install
   ```
   Nota: se `create-vite` propone la scelta del linter e include **oxlint**,
   e serve ESLint, seleziona **ESLint** (non oxlint). Il template `vanilla-ts`
   base non installa un linter di default.

3. Svuota `src/style.css` (file vuoto). È l'unico file CSS del template.

4. Elimina il file di esempio `src/counter.ts` (non serve).

5. Sovrascrivi `src/main.ts` con questa struttura minima:
   ```ts
   import './style.css'
   ```

6. Sovrascrivi `index.html` lasciando solo il contenitore `#app`, senza i
   riferimenti agli asset di esempio:
   ```html
   <!doctype html>
   <html lang="en">
     <head>
       <meta charset="UTF-8" />
       <meta name="viewport" content="width=device-width, initial-scale=1.0" />
       <title>Vite + TS</title>
     </head>
     <body>
       <div id="app"></div>
       <script type="module" src="/src/main.ts"></script>
     </body>
   </html>
   ```

7. Inizializza Git e fai il primo commit (Vite crea già un `.gitignore`):
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

8. Crea il repository remoto su GitHub e fai push. Richiede la **GitHub CLI**
   (`gh`) già autenticata (`gh auth login`). Chiedi all'utente il **nome del
   repo** e se deve essere `--public` o `--private`, poi:
   ```bash
   git branch -M main
   gh repo create <NOME_REPO> --private --source=. --remote=origin --push
   ```
   Il comando crea il repo su GitHub, lo collega come `origin` e fa il push in
   un solo passaggio. Se `gh` non è installato o non autenticato, avvisa
   l'utente e fermati (in alternativa può creare il repo manualmente e usare
   `git remote add origin <URL>` + `git push -u origin main`).

9. Ricorda all'utente: `cd <NOME>` e `npm run dev`.
