# Déploiement de DATASHEET TV sur Vercel + Supabase

Ce dossier est prêt à être déployé directement sur **Vercel** (aucune configuration complexe requise : `index.html` et `vercel.json` gèrent automatiquement la route `/admin` et l'ensemble du site).

## Étape 1 : Mettre en ligne sur Vercel (Gratuit)
### Méthode A — Via GitHub (Recommandée)
1. Créez un compte gratuit sur [GitHub](https://github.com) et cliquez sur **New repository** (ex: `datasheet-tv`).
2. Cliquez sur **uploading an existing file** et glissez le contenu de ce dossier (`index.html`, `vercel.json`, `supabase/`, `README.md`), puis validez avec **Commit changes**.
3. Allez sur [Vercel](https://vercel.com), connectez-vous avec votre compte GitHub et cliquez sur **Add New... → Project**.
4. Sélectionnez votre dépôt `datasheet-tv` et cliquez sur **Deploy** : en moins de 30 secondes, votre site est en ligne avec une adresse du type `https://datasheet-tv.vercel.app` (et votre espace d'administration est accessible sur `https://datasheet-tv.vercel.app/admin`).

### Méthode B — Sans GitHub (Via Vercel CLI)
Depuis un terminal dans ce dossier :
```bash
npx vercel --prod
```

## Étape 2 : Connecter la base de données Supabase (Gratuit)
1. Créez un projet gratuit sur [Supabase](https://supabase.com).
2. Dans le menu de gauche, cliquez sur **SQL Editor** → **New query**.
3. Copiez-collez le contenu du fichier `supabase/migrations.sql` (ou cliquez sur le bouton **Voir / Copier le Schéma SQL & Politiques RLS** dans `/admin`) et cliquez sur **Run**.
4. Allez dans **Project Settings → API** sur Supabase et copiez :
   - **Project URL** (`https://xxxx.supabase.co`)
   - **anon public key** (`eyJhbGci...`)
5. Ouvrez votre site en ligne sur `/admin`, connectez-vous, allez dans l'onglet **5. Gestion du Site & Supabase**, collez ces deux clés et cliquez sur **Connecter Supabase**.
