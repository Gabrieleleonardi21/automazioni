---
name: create-react-vite-app
description: Crea una nuova app React con Vite (JavaScript, ESLint) seguendo una procedura fissa. Usa quando l'utente chiede di creare/generare una nuova app o progetto React, o di fare lo scaffold di un'applicazione React+Vite.
---

# Create React Vite App

Segui questi passaggi nell'ordine esatto. Non aggiungere TypeScript, librerie o
configurazioni extra.

## Passaggi

1. Chiedi all'utente la **posizione** (cartella padre; default: directory corrente)
   e il **nome** dell'app.

2. Genera l'app. **Importante:** le versioni recenti di `create-vite` chiedono
   quale linter usare e propongono anche **oxlint**. Devi ottenere un progetto
   con **ESLint**, NON oxlint.

   Il modo più affidabile è generare in modalità interattiva e, alla domanda sul
   linter/code quality, selezionare **ESLint** (non oxlint):
   ```bash
   npm create vite@latest <NOME>
   ```
   Alle domande rispondi: framework = **React**, variant = **JavaScript**,
   e quando chiede il linter scegli **ESLint** (deseleziona oxlint).

   Poi installa le dipendenze:
   ```bash
   cd <NOME> && npm install
   ```

   Verifica di aver ottenuto ESLint e non oxlint: nella cartella deve esserci
   `eslint.config.js` (non `.oxlintrc.json`) e in `package.json` lo script
   `"lint": "eslint ."`. Se per errore è stato generato oxlint, rigenera il
   progetto scegliendo ESLint.

3. Svuota `src/App.css` (file vuoto).

4. Svuota `src/index.css` (file vuoto).

5. Sovrascrivi `src/main.jsx` con:
   ```jsx
   import { createRoot } from 'react-dom/client'
   import './index.css'
   import App from './App.jsx'

   createRoot(document.getElementById('root')).render(
     <App />
   )
   ```

6. Sovrascrivi `src/App.jsx` con:
   ```jsx
   import './App.css'

   function App() {
   }

   export default App
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
