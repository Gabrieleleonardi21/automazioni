---
name: create-ts-browser-app
description: Crea un progetto TypeScript per il browser (senza Vite, senza framework) che compila con tsc in JavaScript e si testa aprendo index.html con Live Server. Usa quando l'utente chiede un progetto TypeScript per il browser da provare con Live Server, un'app TS lato client senza bundler, o TS + HTML senza Vite.
---

# Create TS Browser App (Live Server)

Genera un progetto TypeScript lato browser: `tsc` compila i sorgenti da `src/`
in JavaScript dentro `dist/`, e un `index.html` carica il modulo compilato. Si
prova con l'estensione **Live Server** di VS Code (o equivalente). Nessun Vite,
nessun bundler, nessun framework. Segui i passaggi nell'ordine esatto.

## Passaggi

1. Chiedi all'utente la **posizione** (cartella padre; default: directory corrente)
   e il **nome** dell'app.

2. Crea la cartella del progetto ed entraci, poi inizializza `package.json`:
   ```bash
   mkdir <NOME> && cd <NOME>
   npm init -y
   ```

3. Installa TypeScript come dipendenza di sviluppo:
   ```bash
   npm install -D typescript
   ```

4. Crea un `tsconfig.json` configurato per il **browser** con moduli ES (così il
   browser può caricare l'output con `<script type="module">`). Sovrascrivi il
   file con:
   ```json
   {
     "compilerOptions": {
       "target": "ES2020",
       "module": "ES2020",
       "moduleResolution": "bundler",
       "rootDir": "src",
       "outDir": "dist",
       "strict": true,
       "sourceMap": true
     },
     "include": ["src"]
   }
   ```

5. Crea la cartella `src` con un file di ingresso `src/index.ts` minimale che
   agisce sul DOM:
   ```ts
   const message: string = 'Hello, TypeScript!'
   const el = document.querySelector<HTMLDivElement>('#app')
   if (el) el.textContent = message
   ```
   Nota importante: se in futuro si aggiungono altri moduli, negli `import`
   dentro i file `.ts` il percorso deve finire in `.js` (es.
   `import { x } from './mod.js'`), perché a runtime nel browser esiste il file
   compilato `.js`, non il `.ts`.

6. Crea `index.html` nella radice del progetto, che carica il JS compilato da
   `dist/` come modulo:
   ```html
   <!doctype html>
   <html lang="en">
     <head>
       <meta charset="UTF-8" />
       <meta name="viewport" content="width=device-width, initial-scale=1.0" />
       <title><NOME></title>
     </head>
     <body>
       <div id="app"></div>
       <script type="module" src="/dist/index.js"></script>
     </body>
   </html>
   ```

7. Aggiungi gli script in `package.json`. `build` compila una volta, `watch`
   ricompila a ogni salvataggio (da tenere in esecuzione mentre si lavora):
   ```json
   "scripts": {
     "build": "tsc",
     "watch": "tsc --watch"
   }
   ```

8. Crea un file `.gitignore` (npm init non lo crea) con almeno:
   ```
   node_modules
   dist
   ```

9. Fai una prima compilazione così `dist/` esiste subito:
   ```bash
   npm run build
   ```

10. Inizializza Git e fai il primo commit:
    ```bash
    git init
    git add .
    git commit -m "Initial commit"
    ```

11. Crea il repository remoto su GitHub e fai push. Richiede la **GitHub CLI**
    (`gh`) già autenticata (`gh auth login`). Chiedi all'utente il **nome del
    repo** e se `--public` o `--private`, poi:
    ```bash
    git branch -M main
    gh repo create <NOME_REPO> --private --source=. --remote=origin --push
    ```
    Se `gh` non è installato o non autenticato, avvisa l'utente e fermati.

12. Spiega all'utente come testare con Live Server:
    - Apri la cartella del progetto in VS Code.
    - Tieni in esecuzione `npm run watch` in un terminale (ricompila i `.ts`).
    - Con l'estensione **Live Server** installata, fai clic destro su
      `index.html` e scegli "Open with Live Server" (o "Go Live" nella barra di
      stato). Il browser si aggiorna a ogni salvataggio.

## Nota sul .gitignore e Live Server

`dist/` è nel `.gitignore`, quindi il JS compilato non viene versionato: è la
scelta corretta. Live Server però serve `dist/index.js` dal disco locale, che
esiste dopo `npm run build` / `npm run watch`, quindi funziona comunque anche se
`dist/` non è su Git.
