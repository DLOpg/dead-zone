-- DEAD ZONE | Green Valley V4
-- Passe artistique additive au lancement, compatible avec le projet de secours.
-- Pour enregistrer les decors dans Studio en mode Edition :
-- require(game.ServerScriptService.DZ_GreenValleyV4).Build()
local world = workspace:WaitForChild("DZ_RECOVERY_WORLD", 20)
if not world then
    warn("[DZ V4] Carte Green Valley introuvable. Aucun décor ajouté.")
    return
end
local ok, err = pcall(function()
    require(script.Parent:WaitForChild("DZ_GreenValleyV4", 10)).Build()
end)
if not ok then
    warn("[DZ V4] Échec de l'amélioration visuelle : " .. tostring(err))
end
