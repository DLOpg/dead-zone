# DEAD ZONE — Intégration automatique des 22 nouveaux favoris

Les 22 identifiants fournis sont enregistrés dans `src/shared/DZ_ExpandedFavoritesCatalog.luau`, synchronisés avec Rojo. Le module `DZ_ExpandedFavoritesInstaller` tente de les importer et de les classer grâce aux vrais noms d'assets retournés par Roblox (pas de catégories inventées).

## Activation en une seule commande

1. Sauvegarder une **copie** de la place `.rbxl`.
2. GitHub Desktop : Fetch origin → Pull origin, puis reconnecter Rojo.
3. Dans Roblox Studio en mode **édition, Stop**, ouvrir la Command Bar.
4. Exécuter uniquement :

```lua
require(game.ServerScriptService.DZ_ExpandedFavoritesInstaller).Install()
```

Ce module :
- importe les assets accessibles sans exécuter leurs scripts tiers ;
- reconnaît les catégories à partir des noms de modèles (commissariat, médical, ferme, maison, NPC, véhicule, décor, arme) ;
- distribue prudemment les modèles identifiés sur Green Valley, autour du camp, des commerces et des bâtiments existants ;
- conserve les modèles non identifiés dans ServerStorage au lieu de les installer au hasard ;
- stocke les modèles dans `ServerStorage/DZ_EXPANDED_FAVORITES_LIBRARY` ;
- place les visuels dans `Workspace/DZ_RECOVERY_WORLD/DZ_EXPANDED_FAVORITES_V1` ;
- produit le rapport `ServerStorage/DZ_ExpandedFavoritesReport` ;
- ignore le pack `3256343670` déjà utilisé par Real Forest V2, pour éviter de planter une deuxième forêt identique.

**Aucune ancienne construction, PNJ, quête ou interaction n'est supprimée.** Les nouveaux modèles placés sont pour le moment **visuels et sans collisions**, pour éviter de rendre les missions injouables. Les armes sont stockées visuellement, sans reprendre les scripts d'armes tiers.

## Statut et restauration

Afficher le rapport :

```lua
require(game.ServerScriptService.DZ_ExpandedFavoritesInstaller).Report()
```

Supprimer seulement les nouveaux visuels et garder les modèles en réserve :

```lua
require(game.ServerScriptService.DZ_ExpandedFavoritesInstaller).Restore()
```

## Limites réelles

- GitHub et Rojo **ne contiennent pas les modèles 3D externes**. L'import réel doit être exécuté une fois dans Roblox Studio, sur la place du créateur.
- Certains assets Creator Store peuvent refuser `GetObjects` et `InsertService:LoadAsset`. Le système ne contourne pas les permissions Roblox.
- La classification basée sur les noms peut être imparfaite. Un modèle non identifié reste en bibliothèque ; il n'est pas arbitrairement attribué à Marcus, Elena ou au commissariat.
- Les positions et proportions ne sont pas validées en 3D tant que Roblox Studio n'a pas exécuté l'installation.
- Le rapport de chargement permet d'affiner les placements de façon ciblée sans recopier les 22 IDs.
