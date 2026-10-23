# DEAD ZONE — Real Forest V2 (Green Valley)

Cette passe utilise **le pack Realistic Trees déjà importé** depuis le Creator Store (asset 3256343670).

## Résultat visé
- Jusqu'à **105 arbres réalistes** ; échelles comprises entre 12 et 25 studs, rotations variées.
- Jusqu'à **16 variantes de sous-modèles** du pack si elles existent. Un pack ne proposant qu'un arbre n'en fournira pas artificiellement seize.
- Concentration dans les massifs forestiers et à la périphérie ; exclusion des routes, Camp Haven, lieux de quêtes et ruisseau.
- **Anciennes formes d'arbres masquées sans destruction** : `Nature/Tronc`, `Nature/Feuillage`, pins du `DZ_V4_DECOR` et feuillus du `DZ_V5_DETAILS`.
- Les anciennes plantes basses, herbes hautes, rochers et buissons ne sont **pas supprimés**.
- Les 20 arbres déjà placés `DZ_tree_N` sont sauvegardés dans `ServerStorage/DZ_TREES_BACKUP_V1`.

## Installation
1. Sauvegarder une copie de ta place `.rbxl`.
2. GitHub Desktop → **Fetch origin**, puis **Pull origin**.
3. VS Code → redémarrer Rojo et reconnecter Roblox Studio en mode **édition**.
4. Vérifier dans `ServerScriptService` que `DZ_RealForestV2` existe.
5. Cliquer Stop, ouvrir **Command Bar** et lancer :

```lua
require(game.ServerScriptService.DZ_RealForestV2).Build()
```

Si tu veux volontairement limiter les arbres, exemple : `.Build(75)`. La fonction n'ajoute pas de doublons si elle a déjà terminé.

## Logs
Dans Output : `[DZ FORET V2]` indique le nombre d'arbres, le nombre de variantes trouvées et le nombre de pièces masquées.

Si l'import du pack est manquant ou n'est pas reconnaissable, le module ne masque **aucun** arbre ancien.

## Retour arrière
En **mode édition** :

```lua
require(game.ServerScriptService.DZ_RealForestV2).Restore()
```

Restaure la transparence et les collisions des anciens arbres, retire `DZ_REAL_FOREST_V2` et remet les 20 arbres de la passe précédente en place. Le pack stocké dans ServerStorage est conservé.

## Limites
Le code a été vérifié sur GitHub, mais **pas exécuté dans Roblox Studio** par l'assistant. Les variantes effectives dépendent du contenu du pack déjà importé. La végétation est décorative et sans collisions. Ne pas lancer la commande pendant Play, car le résultat ne serait pas conservé dans le fichier `.rbxl`.
