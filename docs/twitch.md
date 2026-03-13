# Configuration Twitch

Cette application utilise Twitch pour :

- interroger l'API Twitch
- créer des abonnements EventSub
- afficher une popup live globale quand la chaîne configurée est en direct

## Est-ce gratuit ?

Oui, pour ce cas d'usage, l'intégration Twitch API + EventSub est gratuite.

Important :

- Twitch impose des limites techniques et un système de `cost` EventSub, mais ce n'est pas une facturation monétaire.
- Je n'ai trouvé aucune tarification payante officielle pour l'usage standard de l'API Twitch et d'EventSub dans la documentation développeur officielle.
- La documentation Twitch indique qu'un compte Twitch suffit pour démarrer côté développeur.

Sources officielles :

- https://dev.twitch.tv/docs/api/get-started
- https://dev.twitch.tv/docs/authentication/register-app
- https://dev.twitch.tv/docs/eventsub/manage-subscriptions/

## Variables d'environnement attendues

L'intégration a besoin de ces variables :

- `TWITCH_CLIENT_ID`
- `TWITCH_CLIENT_SECRET`
- `TWITCH_EVENTSUB_SECRET`
- `TWITCH_EVENTSUB_CALLBACK_URL`

Alternative :

- `APP_BASE_URL` peut remplacer `TWITCH_EVENTSUB_CALLBACK_URL`

Dans ce cas, l'application construit automatiquement l'URL `https://ton-domaine/twitch/eventsub`.

## 1. Créer l'application Twitch

1. Connecte-toi avec le compte Twitch qui servira au développement.
2. Ouvre le portail développeur Twitch : https://dev.twitch.tv/console/apps
3. Clique sur `Register Your Application`.
4. Renseigne :
   - `Name` : le nom de ton application
   - `OAuth Redirect URLs` : tu peux mettre une URL temporaire, par exemple `http://localhost:3000`
   - `Category` : `Website Integration` ou une catégorie proche
5. Valide la création.

Une fois l'application créée :

- le `Client ID` est visible dans l'écran de gestion de l'application
- le `Client Secret` se génère avec le bouton `New Secret`

## 2. Récupérer `TWITCH_CLIENT_ID`

`TWITCH_CLIENT_ID` = la valeur `Client ID` affichée dans la console développeur Twitch.

Chemin :

1. https://dev.twitch.tv/console/apps
2. Ouvre ton application
3. Clique sur `Manage`
4. Copie le `Client ID`

Exemple :

```bash
export TWITCH_CLIENT_ID="xxxxxxxxxxxxxxxxxxxxxx"
```

## 3. Récupérer `TWITCH_CLIENT_SECRET`

`TWITCH_CLIENT_SECRET` = le secret généré par Twitch pour ton application.

Chemin :

1. https://dev.twitch.tv/console/apps
2. Ouvre ton application
3. Clique sur `Manage`
4. Clique sur `New Secret`
5. Copie la valeur immédiatement

Attention :

- Twitch n'affiche pas ce secret comme une valeur publique permanente
- si tu regénères un secret, l'ancien devient invalide
- ne jamais exposer cette valeur côté frontend

Exemple :

```bash
export TWITCH_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## 4. Créer `TWITCH_EVENTSUB_SECRET`

Cette valeur n'est pas fournie par Twitch.

Tu la génères toi-même. Elle sert à vérifier la signature HMAC envoyée par Twitch sur les webhooks EventSub.

Tu peux générer une valeur aléatoire avec :

```bash
openssl rand -hex 32
```

Exemple :

```bash
export TWITCH_EVENTSUB_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

Recommandation :

- utilise une longue valeur aléatoire
- garde-la privée comme un mot de passe
- si tu la changes, pense à resynchroniser les abonnements Twitch

## 5. Définir `TWITCH_EVENTSUB_CALLBACK_URL`

Twitch doit pouvoir appeler publiquement ton webhook en HTTPS.

La route attendue par l'application est :

```text
/twitch/eventsub
```

Donc en production, la variable doit ressembler à :

```bash
export TWITCH_EVENTSUB_CALLBACK_URL="https://ton-domaine.com/twitch/eventsub"
```

Contraintes Twitch importantes :

- URL publique
- HTTPS obligatoire
- port 443 côté webhook public

Si tu préfères, tu peux définir :

```bash
export APP_BASE_URL="https://ton-domaine.com"
```

et laisser l'application construire l'URL complète.

## 6. Configurer l'app Rails

Une fois les variables en place :

1. démarre l'application
2. va dans l'admin
3. ouvre `Informations entreprise` -> `Streaming Twitch`
4. coche l'activation
5. renseigne le login Twitch de la chaîne
6. enregistre

L'application va alors :

- résoudre l'identité de la chaîne
- créer les abonnements EventSub `stream.online` et `stream.offline`
- synchroniser l'état live courant

## 7. Vérifier que tout fonctionne

Tu peux aussi resynchroniser à la main :

```bash
bin/rails twitch:sync
```

Et forcer un refresh d'état :

```bash
bin/rails twitch:refresh_state
```

## 8. Développement local

En local pur, Twitch ne pourra pas appeler `http://localhost`.

Il faut soit :

- exposer l'application avec un tunnel HTTPS public
- utiliser le Twitch CLI pour simuler les événements

Docs officielles utiles :

- CLI : https://dev.twitch.tv/docs/cli/
- Vérification webhook : https://dev.twitch.tv/docs/eventsub/handling-webhook-events
- Gestion des subscriptions : https://dev.twitch.tv/docs/eventsub/manage-subscriptions/

## Résumé rapide

- `TWITCH_CLIENT_ID` : donné par Twitch dans la console développeur
- `TWITCH_CLIENT_SECRET` : généré par Twitch via `New Secret`
- `TWITCH_EVENTSUB_SECRET` : généré par toi
- `TWITCH_EVENTSUB_CALLBACK_URL` : URL publique HTTPS de ton webhook
