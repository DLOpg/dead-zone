# DEAD ZONE — Creator Store : bibliothèque de modèles V6 (première livraison)

Cette mise à jour prépare les **vrais modèles 3D** du Creator Store pour Green Valley, sans remplacer aveuglément les constructions et les dialogues existants.

## Statut réel

- ✅ Catalogue de **17 références ou packs candidats** ajouté au dépôt.
- ✅ Importateur Luau pour **Roblox Studio en mode édition**.
- ✅ Nettoyage des scripts, des événements et des prompts des modèles tiers importés en staging.
- ✅ Prévisualisation non destructive de maisons, arbres, station-service, hôpital et candidats PNJ.
- ⚠️ Les modèles ne peuvent pas être injectés par GitHub seul : **ils doivent être chargés depuis Studio, sur ton PC**, selon leurs permissions.
- ⚠️ Tous les IDs du catalogue ne sont pas encore validés en Studio, et certains packs sont à importer séparément depuis Toolbox puis à découper manuellement.
- ⚠️ Aucun modèle d'arme ni avatar tiers n'est pour le moment intégré à la mécanique finale des Tools. Les scripts combat V5 restent actifs indépendamment.

## Conserver la carte fonctionnelle

1. Dans Roblox Studio, sauvegarder une copie de Green Valley en `.rbxl`.
2. Dans GitHub Desktop : **Fetch origin → Pull origin**.
3. Dans VS Code : redémarrer Rojo, reconnecter Roblox Studio **en mode édition**.
4. Vérifier ces Modules :
   - `ReplicatedStorage/DZ_CreatorStoreCatalog`
   - `ServerScriptService/DZ_CreatorStoreImporter`

Les modèles mis en réserve apparaîtront dans `ServerStorage/DZ_CREATOR_ASSETS_STAGING`.

## Étape 1 — Importer un premier lot

Dans Roblox Studio **en mode édition** (Stop, pas Play), ouvrir **Command Bar** :

```lua
local imp = require(game.ServerScriptService.DZ_CreatorStoreImporter)
imp.Import(4)
```

L'outil tente de charger quatre assets gratuits candidats accessibles à ton compte. Voir **Output** pour `[DZ CREATOR]`.

L'import peut échouer : Roblox peut demander **Experience Settings → Security → Allow Loading Third Party Assets**. Selon le compte et l'asset, un refus reste possible. Ce n'est pas une erreur fatale : l'asset indisponible est ignoré.

Important : cette autorisation s'applique au chargement dans Studio; vérifie le modèle et les permissions avant de le placer dans le jeu.

## Étape 2 — Examiner les modèles

Dans **Explorer → ServerStorage → DZ_CREATOR_ASSETS_STAGING** :

- Examine chaque modèle 3D, la taille, les meshes, et les textures.
- Les scripts importés ont été retirés automatiquement par l'importateur.
- Les modèles ne sont pas encore approuvés : le système ne les place pas automatiquement.

Exemple : approuver un pin et un arbre de feuillage (seulement s'ils ont bien été importés) :

```lua
local imp = require(game.ServerScriptService.DZ_CreatorStoreImporter)
imp.Approve("pine_quenty")
imp.Approve("oak")
```

Pour importer une référence précise :

```lua
require(game.ServerScriptService.DZ_CreatorStoreImporter).ImportKey("abandoned_house")
```

## Étape 3 — Prévisualiser sur la map

Toujours dans la **Command Bar en mode édition** :

```lua
local imp = require(game.ServerScriptService.DZ_CreatorStoreImporter)
imp.Preview()
```

Les objets prévisualisés, lorsqu'ils sont approuvés, apparaissent dans :

`Workspace/DZ_RECOVERY_WORLD/DZ_CREATOR_PREVIEW`

Les bâtiments et personnages de gameplay d'origine ne sont **pas supprimés**, et leurs prompts restent actifs.

**Si tu approuves d'autres modèles après un premier aperçu**, supprime uniquement le dossier `DZ_CREATOR_PREVIEW` (après sauvegarde) puis relance `imp.Preview()`.

## Étape 4 — Si un modèle ne se charge pas par ID

Tu peux insérer le modèle manuellement depuis **Toolbox → Creator Store**, examiner ce que tu as placé dans Studio, puis copier ce modèle dans la réserve :

```lua
local model = game.Selection:Get()[1]
require(game.ServerScriptService.DZ_CreatorStoreImporter).AttachToolbox("abandoned_house", model)
```

Attention : `game.Selection` n'existe pas dans ce contexte sur toutes les versions de Studio. Si nécessaire, sélectionne le modèle dans Explorer et utilise le service Selection :

```lua
local selection = game:GetService("Selection"):Get()[1]
if selection then
  require(game.ServerScriptService.DZ_CreatorStoreImporter).AttachToolbox("abandoned_house", selection)
end
```

Ne lance pas Play avant d'avoir neutralisé les scripts des modèles tiers; importe-les de préférence d'abord dans une place vide ou directement dans ServerStorage.

## Candidats PNJ

La **Bible V5** fixe les rôles :
- **Marcus Hale :** ancien militaire, chef de Camp Haven → modèle militaire comme base.
- **Elena Ward :** médecin et ancienne chercheuse NÉCROS → avatar médical ou scientifique à personnaliser.
- **Ethan Brooks :** mécanicien → avatar ouvrier avec tenue de garage personnalisée.
- **Lina :** adolescente, passionnée de radio → avatar jeunesse crédible, casque radio.
- **Le Veilleur :** personne masquée et énigmatique → à garder en apparitions scénarisées.

Les descriptions officielles ne donnent **pas de portraits physiques détaillés**. Ne pas prétendre qu'un modèle de Creator Store correspond à une image officielle qui n'existe pas.

Les modèles `marcus_military` et `lina_girl` ne sont que des **candidats visuels**, à valider avant insertion. Elena et Ethan n'ont pas encore de candidat suffisamment convaincant confirmé.

## Modèles gratuitement consultables

- Pine Tree de Quenty : https://create.roblox.com/store/asset/183435411
- pine tree de lulufev : https://create.roblox.com/store/asset/2309193275
- Pistol officiel Roblox : https://create.roblox.com/store/asset/4842197274 (comporte **6 scripts**, ils ne doivent pas remplacer le système de combat de DEAD ZONE)
- Ultimate Low Poly Asset Pack : https://create.roblox.com/store/asset/9492405836 (pack gratuit **très lourd**, plus d'un million de vertices; à découper et optimiser avant usage)

D'autres IDs candidats se trouvent dans `src/shared/DZ_CreatorStoreCatalog.luau`. Un ID dans notre catalogue n'est **pas** une garantie de disponibilité ni de qualité, même si une fiche web existe.

## Performance, sécurité et retour arrière

- Pas d'exécution de scripts tiers importés.
- Les modèles de prévisualisation sont ancrés, sans collisions, pour ne pas bloquer les quêtes.
- Le dossier `DZ_CREATOR_PREVIEW` peut être supprimé pour revenir aux décors précédents.
- Les modèles approuvés et leurs métadonnées restent dans `ServerStorage` lorsque tu sauvegardes le fichier `.rbxl`.
- Pour les packs volumineux, utiliser des variantes simplifiées et limiter les répétitions.

**Je ne peux pas vérifier depuis ChatGPT que Roblox Studio a effectivement chargé chaque asset.** Après import et prévisualisation, envoyer une capture de Studio et les éventuels messages `[DZ CREATOR]` permet d’ajuster les positions, les dimensions et les avatars.
