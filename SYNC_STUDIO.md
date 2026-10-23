# DEAD ZONE — Synchronisation avec Roblox Studio

**Source :** le script `DEAD_ZONE_SECOURS_TEST_GREEN_VALLEY.lua`, que le créateur a testé et déclaré fonctionnel dans Roblox Studio.

## Ce qui est synchronisé

- `src/server/DZ_RecoveryServer.server.luau` : PNJ, loot, survie, actions créatives.
- `src/client/DZ_RecoveryClient.client.luau` : HUD, objectifs, dialogues, panneau F6.

**La carte, les bâtiments, le terrain, les PNJ physiques, le HUD ScreenGui et le RemoteEvent ne sont PAS encore dans GitHub.** Ils ont été créés dans le fichier `.rbxl` local par l'installateur de secours. Les deux scripts ci-dessus en dépendent.

## Première étape : sauvegarde

Dans Roblox Studio : ouvrir **la place de Green Valley qui fonctionne** → **Fichier > Enregistrer dans un fichier...** → sauvegarder une copie `DEAD_ZONE_GREEN_VALLEY_BACKUP.rbxl`.

**Ne pas lancer les anciens installateurs et ne pas partir d'une Baseplate vide.**

## Récupérer les fichiers

Dans GitHub Desktop, ouvrir le dépôt `DLOpg/dead-zone` puis **Fetch origin** → **Pull origin**. Vérifier l'apparition de `src/` et `default.project.json` dans le dossier du dépôt.

## Synchroniser (étape suivante)

Rojo est prévu par `default.project.json`. Installer Rojo CLI et l'extension/plugin Roblox Studio compatible avant de lancer une synchronisation.

**Précaution :** ne pas synchroniser sans avoir vérifié la portée des modifications : la place contient déjà `ServerScriptService/DZ_RecoveryServer` et `StarterPlayer/StarterPlayerScripts/DZ_RecoveryClient`. Une synchronisation doit cibler ces scripts existants et ne doit pas supprimer le reste de la place.

Commandes CLI lorsque Rojo est installé (depuis le dossier du dépôt) :

```powershell
rojo serve default.project.json
```

Connecter ensuite le plugin Rojo dans Studio à la session locale. En premier lieu, consulter l'aperçu des modifications proposé par le plugin; n'appliquer les changements que s'ils se limitent aux scripts attendus.

## Limites

- Ce dépôt ne contient pas encore tout le jeu et ne permet pas de lancer une place Roblox de façon autonome.
- Le mode F6 n'est disponible que dans l'interface créée par l'installateur de secours.
- L'action **F** est une attaque de démonstration, pas un combat zombie abouti.
- Les objets visibles en créatif sont limités aux ressources de ce prototype.

## GitHub

Le dépôt est actuellement **public**. Ne pas y committer de mots de passe, jetons ou données privées.
