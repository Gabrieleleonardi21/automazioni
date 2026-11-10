---
name: create-ts-node-app
description: Crea un nuovo progetto TypeScript puro (senza Vite, senza framework) che compila con tsc e gira su Node. Usa quando l'utente chiede di creare/generare un progetto TypeScript da eseguire con Node, un progetto TS con tsc, un'app TypeScript backend/CLI, o esplicitamente "senza Vite".
---

# Create TS Node App

Genera un progetto TypeScript minimale che si compila con `tsc` in JavaScript ed
è eseguibile con Node. Nessun Vite, nessun framework, nessun bundler. Segui i
passaggi nell'ordine esatto.

## Passaggi

1. Chiedi all'utente la **posizione** (cartella padre; default: directory corrente)
   e il **nome** dell'app.

2. Crea la cartella del progetto ed entraci, poi inizializza `package.json`:
   ```bash
   mkdir <NOME> && cd <NOME>
   npm init -y
   ```

3. Installa TypeScript e i tipi di Node come dipendenze di sviluppo:
   ```bash
   npm install -D typescript @types/node
   ```

4. Genera il `tsconfig.json` e imposta `rootDir` su `src` e `outDir` su `dist`,
   così i sorgenti stanno in `src/` e il JS compilato in `dist/`:
   ```bash
   npx tsc --init --rootDir src --outDir dist
   ```
   Verifica che nel `tsconfig.json` risultino attive `"rootDir": "src"`,
   `"outDir": "dist"` e `"strict": true`.

5. Crea la cartella `src` con un file di ingresso `src/index.ts` minimale:
   ```ts
   const message: string = 'Hello, TypeScript!'
   console.log(message)
   ```

6. Aggiungi gli script in `package.json` per compilare ed eseguire. Gli script
   devono essere:
   ```json
   "scripts": {
     "build": "tsc",
     "start": "node dist/index.js",
     "dev": "tsc && node dist/index.js"
   }
   ```

7. Crea un file `.gitignore` (npm init non lo crea) con almeno:
   ```
   node_modules
   dist
   ```

8. Inizializza Git e fai il primo commit:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

9. Crea il repository remoto su GitHub e fai push. Richiede la **GitHub CLI**
   (`gh`) già autenticata (`gh auth login`). Chiedi all'utente il **nome del
   repo** e se deve essere `--public` o `--private`, poi:
   ```bash
   git branch -M main
   gh repo create <NOME_REPO> --private --source=. --remote=origin --push
   ```
   Se `gh` non è installato o non autenticato, avvisa l'utente e fermati (in
   alternativa può creare il repo manualmente e usare `git remote add origin
   <URL>` + `git push -u origin main`).

10. Ricorda all'utente i comandi: `npm run build` per compilare, `npm start` per
    eseguire, oppure `npm run dev` per fare entrambe le cose.
