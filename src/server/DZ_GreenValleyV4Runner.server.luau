-- DEAD ZONE : V4 / démarrage robuste
-- Si la place ne contient pas le monde de secours, le Bootstrap le crée.
-- Si le monde existe déjà, aucune reconstruction : V4 ajoute seulement ses décors.
-- Aucun effacement de la map ni du HUD.
local bootstrap = script.Parent:WaitForChild("DZ_GreenValleyBootstrap", 15)
if not bootstrap then
    warn("[DZ START] DZ_GreenValleyBootstrap absent : Pull origin et synchronisation Rojo requis.")
    return
end

local ok, worldOrError = pcall(function()
    return require(bootstrap).Build()
end)
if not ok or not worldOrError then
    warn("[DZ START] Échec génération Green Valley : " .. tostring(worldOrError))
    return
end

local module = script.Parent:WaitForChild("DZ_GreenValleyV4", 15)
if not module then
    warn("[DZ START] DZ_GreenValleyV4 absent : seule la carte de secours a été générée.")
    return
end

local v4ok, v4err = pcall(function()
    require(module).Build()
end)
if not v4ok then
    warn("[DZ START] Échec détails V4 : " .. tostring(v4err))
else
    print("[DZ START] Green Valley présente. Décors V4 exécutés.")
end
