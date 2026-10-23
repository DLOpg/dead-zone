-- DEAD ZONE | Green Valley Bootstrap V1
-- Génère la carte de secours sur une Baseplate si Workspace/DZ_RECOVERY_WORLD manque.
-- Compatible avec les scripts DZ_RecoveryServer / DZ_RecoveryClient et la V4.
-- Aucun Destroy, aucune suppression, aucun asset externe.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Bootstrap = {}
local WORLD_NAME = "DZ_RECOVERY_WORLD"

local locations = {
    {-175, -145, 32}, {-105, -45, 67}, {50, -35, 34},
    {-20, 100, 33}, {130, 95, 43}, {175, -135, 26}, {-125, 135, 32},
}
local palette = {
    wood = Color3.fromRGB(122, 93, 67),
    stone = Color3.fromRGB(125, 122, 109),
    roof = Color3.fromRGB(78, 86, 82),
    rust = Color3.fromRGB(123, 83, 60),
    forest = Color3.fromRGB(56, 92, 58),
    dark = Color3.fromRGB(50, 58, 54),
    light = Color3.fromRGB(163, 154, 133),
    grass = Color3.fromRGB(87, 108, 75),
}

local function folder(parent, name)
    local object = Instance.new("Folder")
    object.Name = name
    object.Parent = parent
    return object
end

local function part(parent, name, position, size, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material or Enum.Material.Concrete
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function height(x, z)
    local v = 5 + math.noise(x / 110, z / 110, 8) * 8
        + math.noise(x / 48, z / 54, 19) * 3
        + ((math.abs(x) + math.abs(z)) / 480)^2 * 11
    for _, site in ipairs(locations) do
        local d = math.sqrt((x - site[1])^2 + (z - site[2])^2)
        local t = math.clamp((d - site[3]) / 24, 0, 1)
        local smooth = t * t * (3 - 2 * t)
        v = v * smooth + 6 * (1 - smooth)
    end
    return math.max(3, v)
end

local function buildTerrain()
    local count = 0
    for x = -240, 240, 24 do
        for z = -240, 240, 24 do
            local y = height(x, z)
            Workspace.Terrain:FillBlock(
                CFrame.new(x, (y - 14) / 2, z),
                Vector3.new(25, y + 14, 25),
                Enum.Material.Grass
            )
            count += 1
        end
    end
    return count
end

local function buildRoads(parent)
    local routes = {
        {{-175, -145}, {-105, -45}, {50, -35}, {130, 95}},
        {{-105, -45}, {-20, 100}, {-125, 135}},
        {{50, -35}, {175, -135}},
    }
    for _, path in ipairs(routes) do
        for index = 1, #path - 1 do
            local a, b = path[index], path[index + 1]
            local dx, dz = b[1] - a[1], b[2] - a[2]
            local distance = math.sqrt(dx * dx + dz * dz)
            local steps = math.ceil(distance / 12)
            for step = 1, steps do
                local t = (step - .5) / steps
                local x, z = a[1] + dx * t, a[2] + dz * t
                local p = part(
                    parent, "Route", Vector3.new(x, height(x, z) + .22, z),
                    Vector3.new(10, .35, distance / steps + 2),
                    Color3.fromRGB(83, 81, 72), Enum.Material.Ground
                )
                p.CFrame = CFrame.lookAt(
                    p.Position, Vector3.new(x + dx, p.Position.Y, z + dz)
                )
            end
        end
    end
end

local function buildNature(parent)
    local rng = Random.new(2037)
    for _ = 1, 125 do
        local x = rng:NextNumber(-225, 225)
        local z = rng:NextNumber(-225, 225)
        local free = true
        for _, site in ipairs(locations) do
            if (Vector2.new(x, z) - Vector2.new(site[1], site[2])).Magnitude < site[3] + 12 then
                free = false
                break
            end
        end
        if free then
            local y, h = height(x, z), rng:NextNumber(11, 22)
            part(parent, "Tronc", Vector3.new(x, y + h * .5, z),
                Vector3.new(2.4, h, 2.4), palette.wood, Enum.Material.Wood)
            for i = 1, 2 do
                local crown = part(
                    parent, "Feuillage",
                    Vector3.new(x + rng:NextNumber(-2, 2), y + h + i * 3, z),
                    Vector3.new(12 + i * 2, 9 + i * 2, 12 + i * 2),
                    palette.forest, Enum.Material.Grass
                )
                crown.Shape = Enum.PartType.Ball
                crown.CanCollide = false
            end
        end
    end
    for _ = 1, 75 do
        local x, z = rng:NextNumber(-220, 220), rng:NextNumber(-220, 220)
        local p = part(parent, "Buisson", Vector3.new(x, height(x, z) + 1.2, z),
            Vector3.new(3.5, 2.8, 3.5), palette.grass, Enum.Material.Grass)
        p.Shape = Enum.PartType.Ball
        p.CanCollide = false
    end
end

local function roofBuilding(parent, name, x, z, width, depth, wallHeight, color)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    local y = height(x, z)
    part(model, "Plancher", Vector3.new(x, y + .3, z),
        Vector3.new(width, .6, depth), palette.wood, Enum.Material.WoodPlanks)
    part(model, "Mur arriere", Vector3.new(x, y + wallHeight / 2, z + depth / 2),
        Vector3.new(width, wallHeight, 1), color)
    for _, side in ipairs({-1, 1}) do
        part(model, "Mur lateral", Vector3.new(x + side * width / 2, y + wallHeight / 2, z),
            Vector3.new(1, wallHeight, depth), color)
        part(model, "Mur facade", Vector3.new(x + side * (width / 4 + 4),
            y + wallHeight / 2, z - depth / 2),
            Vector3.new(width / 2 - 8, wallHeight, 1), color)
        part(model, "Fenetre", Vector3.new(x + side * width * .32, y + 5, z - depth / 2 - .7),
            Vector3.new(4, 4, .18), Color3.fromRGB(73, 105, 113), Enum.Material.Glass)
    end
    part(model, "Linteau", Vector3.new(x, y + wallHeight - 2, z - depth / 2),
        Vector3.new(8, 4, 1), color)
    for _, side in ipairs({-1, 1}) do
        local roof = part(model, "Toiture", Vector3.new(x + side * width / 4,
            y + wallHeight + 3, z),
            Vector3.new(width * .61, 1, depth + 4), palette.roof, Enum.Material.Slate)
        roof.CFrame = CFrame.new(roof.Position)
            * CFrame.Angles(0, 0, math.rad(-side * 24))
    end
    part(model, "Porche", Vector3.new(x, y + .4, z - depth / 2 - 3),
        Vector3.new(width * .55, .7, 6), palette.wood, Enum.Material.WoodPlanks)
    part(model, "Table interieure", Vector3.new(x + 3, y + 2, z + 4),
        Vector3.new(6, 1, 3), palette.wood, Enum.Material.Wood)
end

local function camp(parent)
    local hx, hz = -105, -45
    local hy = height(hx, hz)
    for _, dims in ipairs({
        {hx - 37, hz, 2, 50}, {hx + 37, hz, 2, 50},
        {hx, hz - 26, 74, 2}, {hx - 24, hz + 26, 26, 2},
        {hx + 25, hz + 26, 24, 2}
    }) do
        part(parent, "Palissade Haven",
            Vector3.new(dims[1], hy + 5, dims[2]),
            Vector3.new(dims[3], 10, dims[4]),
            palette.wood, Enum.Material.WoodPlanks)
    end
    for _, building in ipairs({
        {hx - 20, hz - 10, "Commandement"},
        {hx + 16, hz - 10, "Infirmerie"},
        {hx - 20, hz + 15, "Atelier Ethan"},
        {hx + 16, hz + 15, "Poste radio"},
    }) do
        part(parent, building[3], Vector3.new(building[1], hy + 3, building[2]),
            Vector3.new(14, 6, 12), palette.stone, Enum.Material.WoodPlanks)
    end
end

local function npc(parent, name, x, z, color, message)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent
    local y = height(x, z)
    part(m, "Corps", Vector3.new(x, y + 3, z),
        Vector3.new(2.4, 3.2, 1.35), color, Enum.Material.Fabric)
    for _, side in ipairs({-1, 1}) do
        part(m, "Jambe", Vector3.new(x + side * .65, y + .8, z),
            Vector3.new(.9, 1.7, 1), palette.dark, Enum.Material.Fabric)
        part(m, "Bras", Vector3.new(x + side * 1.65, y + 3, z),
            Vector3.new(.8, 2.8, 1), color, Enum.Material.Fabric)
    end
    local head = part(m, "Tete", Vector3.new(x, y + 5.5, z),
        Vector3.new(1.9, 1.9, 1.9), Color3.fromRGB(186, 152, 118),
        Enum.Material.SmoothPlastic)
    head.Shape = Enum.PartType.Ball
    head:SetAttribute("DZType", "NPC")
    head:SetAttribute("DZMessage", message)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Parler"
    prompt.ObjectText = name
    prompt.MaxActivationDistance = 13
    prompt.RequiresLineOfSight = false
    prompt.Parent = head
end

local function loot(parent, name, x, z, item)
    local y = height(x, z)
    local box = part(parent, name, Vector3.new(x, y + 1.1, z),
        Vector3.new(3, 2.2, 2.6), palette.wood, Enum.Material.WoodPlanks)
    box:SetAttribute("DZType", "LOOT")
    box:SetAttribute("DZItem", item)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Fouiller"
    prompt.ObjectText = name
    prompt.MaxActivationDistance = 12
    prompt.Parent = box
end

local function guiLabel(parent, name, message, size, position)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = message
    label.Size = size
    label.Position = position
    label.BackgroundColor3 = Color3.fromRGB(30, 39, 36)
    label.BackgroundTransparency = .12
    label.TextColor3 = Color3.fromRGB(228, 229, 215)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 16
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BorderSizePixel = 0
    label.Parent = parent
    return label
end

local function ensureGui()
    local gui = StarterGui:FindFirstChild("DZ_RecoveryHUD")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "DZ_RecoveryHUD"
        gui.ResetOnSpawn = false
        gui.Parent = StarterGui
        guiLabel(gui, "Status",
            "DEAD ZONE - GREEN VALLEY\nSante 100 | Faim 100 | Soif 100",
            UDim2.fromOffset(335, 67), UDim2.fromOffset(15, 65))
        guiLabel(gui, "Mission",
            "MISSION : Fouille la ferme, puis rejoins Marcus a Camp Haven.",
            UDim2.fromOffset(385, 72), UDim2.new(1, -401, 0, 65))
        guiLabel(gui, "Dialogue",
            "E - Interagir      F - Attaquer      F6 - Creatif",
            UDim2.fromOffset(440, 50), UDim2.new(.5, -220, 1, -78))
        local creative = Instance.new("Frame")
        creative.Name = "Creative"
        creative.Size = UDim2.fromOffset(320, 280)
        creative.Position = UDim2.new(1, -333, .5, -140)
        creative.BackgroundColor3 = Color3.fromRGB(33, 45, 39)
        creative.Visible = false
        creative.Parent = gui
        guiLabel(creative, "Titre", "MODE CREATIF - STUDIO",
            UDim2.new(1, 0, 0, 42), UDim2.fromOffset(0, 0))
        for i, pair in ipairs({
            {"Soigner", "Heal"}, {"Ressources +5", "Supplies"},
            {"Camp Haven", "Camp"}, {"Ferme", "Farm"}
        }) do
            local button = Instance.new("TextButton")
            button.Name = pair[2]
            button.Text = pair[1]
            button.Size = UDim2.fromOffset(275, 40)
            button.Position = UDim2.fromOffset(22, 45 + (i - 1) * 51)
            button.BackgroundColor3 = Color3.fromRGB(74, 91, 70)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.Gotham
            button.TextSize = 18
            button.Parent = creative
        end
    end
    -- Si l'interface a ete creee apres le spawn en Play, la copier aux joueurs.
    for _, pl in ipairs(Players:GetPlayers()) do
        local pg = pl:FindFirstChildOfClass("PlayerGui")
        if pg and not pg:FindFirstChild(gui.Name) then
            local clone = gui:Clone()
            clone.Parent = pg
        end
    end
end

local function ensureRemotes()
    local event = ReplicatedStorage:FindFirstChild("DZ_RecoveryEvent")
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = "DZ_RecoveryEvent"
        event.Parent = ReplicatedStorage
    end
end

local function lights()
    Lighting.ClockTime = 16.3
    Lighting.Brightness = 2.2
    Lighting.GlobalShadows = true
    if not Lighting:FindFirstChild("DZ_RecoveryAtmosphere") then
        local a = Instance.new("Atmosphere")
        a.Name = "DZ_RecoveryAtmosphere"
        a.Density = .24
        a.Color = Color3.fromRGB(193, 202, 186)
        a.Decay = Color3.fromRGB(125, 132, 116)
        a.Parent = Lighting
    end
end

function Bootstrap.Build()
    local existing = Workspace:FindFirstChild(WORLD_NAME)
    if existing then
        ensureRemotes()
        ensureGui()
        print("[DZ BOOTSTRAP] Carte existante conservee ; elements reseau/UI verifies.")
        return existing
    end
    print("[DZ BOOTSTRAP] Carte absente : generation autonome de Green Valley.")
    local world = Instance.new("Folder")
    world.Name = WORLD_NAME
    -- Construire hors Workspace pour eviter que d'autres scripts recuperent
    -- une carte partiellement creee.
    local roads = folder(world, "TerrainEtRoutes")
    local nature = folder(world, "Nature")
    local buildings = folder(world, "Batiments")
    local people = folder(world, "Personnages")
    local interactions = folder(world, "Interactions")

    local success, err = pcall(function()
        local tiles = buildTerrain()
        print("[DZ BOOTSTRAP] Relief Roblox genere : " .. tostring(tiles) .. " cellules.")
        buildRoads(roads)
        buildNature(nature)
        roofBuilding(buildings, "Ferme du reveil", -175, -145, 32, 26, 11, palette.light)
        roofBuilding(buildings, "Maison Miller", -125, 135, 32, 29, 12, palette.stone)
        roofBuilding(buildings, "Superette", 50, -35, 39, 28, 11, palette.rust)
        roofBuilding(buildings, "Garage de Frank", -20, 100, 38, 30, 12, palette.dark)
        roofBuilding(buildings, "Hopital", 130, 95, 47, 39, 18, palette.light)
        roofBuilding(buildings, "Bunker ECHO-7", 175, -135, 35, 31, 12, palette.stone)
        camp(buildings)
        npc(people, "Marcus Hale", -125, -64, Color3.fromRGB(63, 81, 66),
            "Bienvenue a Camp Haven. Nous avons besoin de vivres.")
        npc(people, "Elena Ward", -89, -64, Color3.fromRGB(175, 181, 166),
            "L'eau de la vallee n'est plus sure.")
        npc(people, "Ethan Brooks", -125, -40, Color3.fromRGB(116, 83, 60),
            "Je peux t'aider avec la moto si tu trouves des pieces.")
        npc(people, "Lina", -89, -40, Color3.fromRGB(121, 81, 84),
            "Je capte une frequence qui parle de Miriam.")
        loot(interactions, "Provision ferme", -179, -159, "Nourriture")
        loot(interactions, "Gourde ferme", -166, -159, "Eau")
        loot(interactions, "Ferraille garage", -23, 84, "Ferraille")
        loot(interactions, "Bois cabane", -120, 120, "Bois")

        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "DZ_RECOVERY_SPAWN"
        spawn.Size = Vector3.new(9, 1, 9)
        spawn.Position = Vector3.new(-190, height(-190, -170) + 2, -170)
        spawn.Transparency = .15
        spawn.Color = Color3.fromRGB(102, 132, 98)
        spawn.Anchored = true
        spawn.Neutral = true
        spawn.Parent = world

        ensureRemotes()
        ensureGui()
        lights()
    end)
    if not success then
        warn("[DZ BOOTSTRAP] ERREUR pendant la creation : " .. tostring(err))
        return nil
    end

    world.Parent = Workspace
    local oldSpawn = Workspace:FindFirstChild("SpawnLocation")
    if oldSpawn and oldSpawn:IsA("SpawnLocation") then
        oldSpawn.Enabled = false
    end
    -- Si un joueur est deja apparu sur Baseplate, l'amener a la ferme.
    for _, pl in ipairs(Players:GetPlayers()) do
        local char = pl.Character
        if char then
            char:PivotTo(CFrame.new(-190, height(-190, -170) + 8, -170))
        end
    end
    print("[DZ BOOTSTRAP] OK : Green Valley, Camp Haven, 4 PNJ, loot, HUD, spawn.")
    return world
end

return Bootstrap
