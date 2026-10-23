# DEAD ZONE — Tes 4 favoris Creator Store / installation assistée

Le code d'installation est sur GitHub mais **les fichiers 3D ne peuvent pas être transmis par Rojo** : Roblox Studio doit importer les modèles dans ton expérience. La commande ci-dessous est la plus courte possible.

## 1. Dans Roblox Studio, en mode EDITION

- Sauvegarde **une copie de ta map .rbxl**.
- GitHub Desktop : **Fetch origin → Pull origin**.
- Redémarre Rojo et reconnecte-toi à Studio.
- Vérifie `ServerScriptService/DZ_UserFavoritesInstaller` et `ReplicatedStorage/DZ_UserFavoritesCatalog`.
- Arrête **Play** avant d'exécuter la commande.

## 2. Installation en UNE commande

Dans **Command Bar** :

```lua
require(game.ServerScriptService.DZ_UserFavoritesInstaller).Install()
```

Le système essaie de récupérer ces 4 modèles **sélectionnés par toi** :

- `133440927408852` — New Horror Game House Building → Ferme du réveil
- `3256343670` — Realistic Trees → 20 emplacements dans Green Valley (variantes si le pack le permet)
- `8054188120` — Village House → Maison Miller
- `8640678553` — Working Pistol Gun WORKING Fixed Server → apparence de `DZ_Pistolet` au prochain Play

Si les deux maisons chargent, leurs constructions provisoires sont rendues **transparentes** (elles restent présentes : collisions et systèmes de quêtes sont conservés).

Les modèles récupérés sont gardés dans `ServerStorage/DZ_FAVORITES_LIBRARY`, et les nouvelles constructions dans `Workspace/DZ_RECOVERY_WORLD/DZ_FAVORITES_VISUALS`. Le visuel d'arme nettoyé est dans `ServerStorage/DZ_V5_WEAPON_VISUALS`.

**Très important :** L'outil supprime scripts et détecteurs importés, mais ne garantit pas qu'un asset ou son contenu soit adapté ni autorisé par Roblox. Un modèle non accessible n'est pas installé, et les constructions existantes restent en place. Les sources Roblox doivent être inspectées et optimisées avant publication.

## 3. Tester

Clique **Play**. Le pistolet `DZ_Pistolet` utilise le nouveau visuel s'il a pu être importé ; sa mécanique de tir existante reste contrôlée par les scripts DEAD ZONE. Les modèles de maisons sont purement visuels et ne remplacent pas les portes ou interactions déjà présentes.

La taille, l'orientation, les collisions des intérieurs et la forme du pack d'arbres devront être ajustées après un premier rendu Studio. **Code non exécuté dans Studio par l'assistant.**

## 4. Revenir à l'ancienne carte (sans supprimer les assets téléchargés)

Arrête Play et exécute en **Command Bar, mode édition** :

```lua
require(game.ServerScriptService.DZ_UserFavoritesInstaller).Restore()
```

Cela réaffiche les bâtiments provisoires et supprime uniquement les visuels ajoutés. N'efface pas les modèles gardés dans ServerStorage.

## Permissions

La tentative de chargement passe par `game:GetObjects()` puis `InsertService:LoadAsset()`, et **ces deux méthodes peuvent être interdites pour des assets tiers**, même publics. Ni GitHub, ni Rojo, ni ce script ne contournent les permissions Roblox. Le message `[DZ FAVORIS] Refused ...` en Output permet d'identifier les refus. Dans ce cas, les assets devront être obtenus depuis Studio Toolbox ou rendus accessibles au jeu par leur auteur ou leurs permissions.

Les quatre liens d'origine sont dans `src/shared/DZ_UserFavoritesCatalog.luau`.
