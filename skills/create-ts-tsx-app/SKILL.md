---
name: create-ts-tsx-app
description: Crea un nuovo progetto TypeScript (senza Vite, senza framework) che si esegue direttamente con tsx su Node, senza passaggio di compilazione. Usa quando l'utente chiede un progetto TypeScript eseguibile con tsx, un progetto TS con hot reload/watch senza build, o un'app TS Node veloce da avviare.
---

# Create TS App (tsx)

Genera un progetto TypeScript minimale che gira su Node tramite **tsx**, quindi
esegue i file `.ts` direttamente senza compilarli prima. Include comunque `tsc`
per il type-check e per la build di produzione opzionale. Nessun Vite, nessun
framework. Segui i passaggi nell'ordine esatto.

## Passaggi

1. Chiedi all'utente la **posizione** (cartella padre; default: directory corrente)
   e il **nome** dell'app.

2. Crea la cartella del progetto ed entraci, poi inizializza `package.json`:
   ```bash
   mkdir <NOME> && cd <NOME>
   npm init -y
   ```

3. Installa TypeScript, i tipi di Node e **tsx** come dipendenze di sviluppo:
   ```bash
   npm install -D typescript @types/node tsx
   ```

4. Genera il `tsconfig.json` con `rootDir` su `src` e `outDir` su `dist`:
   ```bash
   npx tsc --init --rootDir src --outDir dist
   ```
   Verifica che risultino attive `"rootDir": "src"`, `"outDir": "dist"` e
   `"strict": true`.

5. Crea la cartella `src` con un file di ingresso `src/index.ts` minimale:
   ```ts
   const message: string = 'Hello, TypeScript!'
   console.log(message)
   ```

6. Aggiungi gli script in `package.json`. `dev` esegue in watch mode (riavvio
   automatico a ogni salvataggio), `start` esegue una volta, `typecheck`
   controlla i tipi senza emettere file, `build` compila in `dist/`:
   ```json
   "scripts": {
     "dev": "tsx watch src/index.ts",
     "start": "tsx src/index.ts",
     "typecheck": "tsc --noEmit",
     "build": "tsc"
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

10. Ricorda all'utente i comandi: `npm run dev` per sviluppare con watch,
    `npm start` per eseguire una volta, `npm run typecheck` per controllare i
    tipi, `npm run build` per compilare in `dist/`.
