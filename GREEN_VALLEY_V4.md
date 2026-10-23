# Green Valley V4 — première mise à jour via Rojo

## Ce qui a été ajouté

- `src/server/DZ_GreenValleyV4.luau` : ModuleScript de décoration.
- `src/server/DZ_GreenValleyV4Runner.server.luau` : applique les décors au lancement du jeu.
- `default.project.json` : lie ces scripts à `ServerScriptService`; préserve les instances inconnues à cet emplacement.

Le module utilise **uniquement des objets Roblox**, sans modèles externes ni scripts tiers.

### Décors V4

- 160 implantations d'herbes hautes, 70 buissons, 50 roches, 32 pins et 28 souches (si les emplacements sont disponibles).
- Camp Haven : lanternes, barils, caisses, brasero, palettes et antenne.
- Façades : auvents, gouttières, lierre et détails d'extérieur.
- PNJ existants : accessoires de Marcus, Elena, Ethan et Lina, sur leurs modèles provisoires.
- Éclairage : une correction de couleur et un bloom légers.

Le relief de base est **celui du prototype de secours déjà fonctionnel**. Ce lot ne recompose pas le Terrain et ne crée pas de nouveaux bâtiments complets.

## Installer sur le PC

1. Dans Roblox Studio, sauvegarder une **copie** de la Green Valley fonctionnelle en `.rbxl`.
2. Dans GitHub Desktop, dépôt `dead-zone`, branche `main`, cliquer sur **Fetch origin**, puis **Pull origin**.
3. Vérifier dans VS Code que les fichiers V4 ont bien été téléchargés.
4. Dans VS Code, démarrer le serveur Rojo avec `default.project.json`.
5. Dans Roblox Studio **en mode édition**, connecter le plugin Rojo au serveur local.
6. Vérifier l'aperçu de synchronisation : **aucun objet de la map ne doit être supprimé**.
7. Vérifier que `ServerScriptService` contient `DZ_GreenValleyV4` et `DZ_GreenValleyV4Runner`.

## Visualiser rapidement

Cliquer sur **Play (F5)**. Le runner crée une décoration V4 pendant le test. Ouvrir **Output** et chercher :

`[DZ V4] Nature et relief existant enrichis`

Puis vérifier la forêt, les bâtiments et Camp Haven.

## Enregistrer définitivement les nouveaux décors dans Studio

Après avoir **arrêté Play**, ouvrir la Command Bar en **mode édition** et exécuter :

```lua
require(game.ServerScriptService.DZ_GreenValleyV4).Build()
```

Cela crée `Workspace/DZ_RECOVERY_WORLD/DZ_V4_DECOR` dans la place en édition, sans toucher aux décors existants. Enregistrer le fichier `.rbxl` une fois le résultat vérifié.

Répéter l'action ne duplique pas les décors : le dossier `DZ_V4_DECOR` est détecté.

Pour revenir en arrière, utiliser la sauvegarde `.rbxl` antérieure. Le dossier `DZ_V4_DECOR` contient tous les nouveaux décors; il est possible de le retirer manuellement en Studio pour revenir à l'environnement V1, après sauvegarde. Les objets d'éclairage `DZ_V4_Color` et `DZ_V4_Bloom` sont également nouveaux.

## Attention

Le code est vérifié par inspection, mais **pas exécuté dans Roblox Studio** par ChatGPT. La version reste un prototype visuel en pièces procédurales, et **n'importe pas encore de modèles gratuits professionnels**. Le rendu, la charge graphique et les collisions sont à valider en Studio.
