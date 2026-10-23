-- DEAD ZONE V5 | Lance les détails environnementaux sur la Green Valley existante.
-- Additif : ne modifie pas les scripts existants, ne supprime aucun élément.
local world=workspace:WaitForChild("DZ_RECOVERY_WORLD",30)
if not world then warn("[DZ V5] Green Valley introuvable : runner arrêté.") return end
local mod=script.Parent:WaitForChild("DZ_GreenValleyV5",20)
if not mod then warn("[DZ V5] Module décor absent.") return end
local ok,res=pcall(function() return require(mod).Build() end)
if not ok then
    warn("[DZ V5] Génération échouée : "..tostring(res))
elseif not res then
    warn("[DZ V5] Décors non ajoutés : regarde les avertissements précédents.")
else
    print("[DZ V5] Décors vérifiés dans DZ_RECOVERY_WORLD/DZ_V5_DETAILS.")
end
