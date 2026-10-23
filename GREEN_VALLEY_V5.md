# Green Valley V5 — mise à jour via GitHub + Rojo

## Installation sécurisée

1. **Sauvegarder la Green Valley fonctionnelle** dans Roblox Studio au format `.rbxl` (Fichier → Enregistrer dans un fichier).
2. Dans GitHub Desktop, dépôt `DLOpg/dead-zone`, branche `main` : **Fetch origin**, puis **Pull origin**.
3. Dans VS Code, redémarrer le serveur Rojo avec `default.project.json`.
4. Dans Roblox Studio, **en mode édition**, reconnecter Rojo, vérifier le prévisualiseur et n'accepter **aucune suppression** de bâtiments, PNJ, terrain ou GUI.
5. Ouvrir `ServerScriptService` : vérifier les nouveaux scripts `DZ_GreenValleyV5` (ModuleScript), `DZ_GreenValleyV5Runner` et `DZ_V5Combat`.
6. Vérifier `StarterPlayer/StarterPlayerScripts/DZ_V5Weapons`.
7. Appuyer sur **Play (F5)** pour tester l'ensemble.

## Ce que la V5 ajoute réellement

- Décors **additifs** : arbustes, fougères, feuillus, rochers et herbes.
- Trois bâtiments supplémentaires avec intérieur simplifié : **diner**, **station-service**, **poste des Rangers** et une tour de guet.
- Ruisseau décoratif et berges : **l'eau est visuelle**, aucun terrain n'est excavé.
- Camp Haven enrichi avec lampes, bancs, réserves, petit potager.
- Ambiance atmosphérique, en complément de V4.
- **Neuf infectés prototypes** en poursuite de proximité ; leur déplacement est simplifié (sans PathfindingService).
- **Deux Tool de test** : `DZ_Couteau` et `DZ_Pistolet`, 12 balles au départ, dégâts validés sur le serveur.
- Petit HUD de munitions et compteur de zombies abattus.

## Test de gameplay

- Équiper `DZ_Couteau`, cliquer ou appuyer sur **F** près d'un infecté pour attaquer.
- Équiper `DZ_Pistolet`, viser un infecté et cliquer pour tirer.
- Les zombies poursuivent à proximité et infligent des dégâts.
- La mort des zombies est provisoirement **sans respawn** : relancer Play pour recommencer.
- L'interface existante, le loot et le créatif **F6** restent en place.

## Pour sauvegarder le décor V5 dans la place

Arrêter **Play**, puis dans la **Command Bar, en mode édition** :

```lua
require(game.ServerScriptService.DZ_GreenValleyV5).Build()
```

Cela crée `Workspace/DZ_RECOVERY_WORLD/DZ_V5_DETAILS`. Si le dossier existe, l'opération ne double pas les décors. Enregistrer le fichier `.rbxl` ensuite.

Pour annuler seulement le décor V5, supprimer **manuellement** `DZ_V5_DETAILS` après sauvegarde ; ne pas supprimer le terrain ni `DZ_RECOVERY_WORLD`.

## Diagnostic

Dans Output :

- `[DZ V5] Carte enrichie` : génération visuelle terminée.
- `[DZ V5 COMBAT] 9 infectés...` : combat initialisé.
- `[DZ V5] Commandes combat...` : script client présent.

**Statut :** scripts publiés sur GitHub et inspection statique, mais **pas encore testés dans Roblox Studio par ChatGPT**. Le pack V5 reste un prototype à valider, **pas un jeu final**. Modèles d'armes, sons et PNJ détaillés issus d'assets tiers ne sont **pas encore importés**. Tester d'abord la synchronisation et les interactions, puis ajouter les assets gratuits vérifiés par étapes.
