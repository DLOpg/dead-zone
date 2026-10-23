-- DEAD ZONE V5 - GREEN VALLEY : WORLD ART PASS
-- Additif et idempotent. Ne supprime ni Terrain, ni instances du gameplay.
-- Le decor reste dans DZ_V5_DETAILS pour faciliter l'annulation.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local M = {}
local rng = Random.new(203705)
local C = {
    fir = Color3.fromRGB(43,72,55), leaf = Color3.fromRGB(67,94,63),
    moss = Color3.fromRGB(82,99,62), bark = Color3.fromRGB(90,76,59),
    wood = Color3.fromRGB(112,85,64), rust = Color3.fromRGB(135,88,64),
    wall = Color3.fromRGB(151,140,122), concrete = Color3.fromRGB(105,111,104),
    metal = Color3.fromRGB(79,85,82), glass = Color3.fromRGB(73,104,107),
    asphalt = Color3.fromRGB(69,69,67), water = Color3.fromRGB(57,106,112),
    warm = Color3.fromRGB(247,186,116), dirt = Color3.fromRGB(112,100,76),
}
local landmarks = {
    {-175,-145,42},{-105,-45,77},{50,-35,45},{-20,100,42},
    {130,95,55},{175,-135,41},{-125,135,43},
    {-8,-146,31},{93,-153,31},{36,179,27},
}
local routes = {
    {{-175,-145},{-105,-45},{50,-35},{130,95}},
    {{-105,-45},{-20,100},{-125,135}},
    {{50,-35},{175,-135}},
}
local function add(parent,name,pos,size,color,material,collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = collide == true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Material = material or Enum.Material.Concrete
    p.Color = color
    p.Size = size
    p.Position = pos
    p.Parent = parent
    return p
end
local function sphere(parent,name,pos,size,color,material)
    local p=add(parent,name,pos,size,color,material,false)
    p.Shape=Enum.PartType.Ball
    return p
end
local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={Workspace.Terrain}
params.IgnoreWater=true
local function ground(x,z)
    local hit=Workspace:Raycast(Vector3.new(x,225,z),Vector3.new(0,-320,0),params)
    return hit and hit.Position.Y or nil
end
local function folder(parent,name)
    local f=Instance.new("Folder")
    f.Name=name
    f.Parent=parent
    return f
end
local function distToSegment(x,z,a,b)
    local dx,dz=b[1]-a[1],b[2]-a[2]
    local t=math.clamp(((x-a[1])*dx+(z-a[2])*dz)/math.max(1,dx*dx+dz*dz),0,1)
    return (Vector2.new(x,z)-Vector2.new(a[1]+dx*t,a[2]+dz*t)).Magnitude
end
local function clear(x,z)
    for _,v in ipairs(landmarks) do
        local d=(Vector2.new(x,z)-Vector2.new(v[1],v[2])).Magnitude
        if d<v[3] then return false end
    end
    for _,road in ipairs(routes) do
        for i=1,#road-1 do
            if distToSegment(x,z,road[i],road[i+1])<10 then return false end
        end
    end
    return true
end
local function plant(parent,x,y,z,s)
    sphere(parent,"Buisson de sous-bois",Vector3.new(x,y+s*.7,z),
        Vector3.new(s*2.1,s*1.5,s*1.7),C.leaf,Enum.Material.Grass)
    sphere(parent,"Fougère",Vector3.new(x+s*.55,y+s*.25,z-.4),
        Vector3.new(s*1.5,s*.65,s*1.3),C.moss,Enum.Material.Grass)
end
local function tree(parent,x,y,z,h)
    add(parent,"Tronc bouleau",Vector3.new(x,y+h*.45,z),
        Vector3.new(1.5,h*.9,1.5),C.bark,Enum.Material.Wood,true)
    sphere(parent,"Houppier",Vector3.new(x,y+h*.92,z),
        Vector3.new(h*.68,h*.5,h*.68),C.leaf,Enum.Material.Grass)
    sphere(parent,"Houppier secondaire",Vector3.new(x+2,y+h*.8,z-1),
        Vector3.new(h*.46,h*.42,h*.5),C.fir,Enum.Material.Grass)
end
local function rock(parent,x,y,z,s)
    local p=sphere(parent,"Bloc de schiste",Vector3.new(x,y+s*.31,z),
        Vector3.new(s*1.6,s*.72,s*1.2),C.concrete,Enum.Material.Slate)
    p.CFrame=p.CFrame*CFrame.Angles(rng:NextNumber(-.2,.2),rng:NextNumber(0,6),.1)
    if rng:NextNumber()>.5 then
        sphere(parent,"Mousse",Vector3.new(x,y+s*.57,z),
            Vector3.new(s*.9,.17,s*.8),C.moss,Enum.Material.Grass)
    end
end
local function naturalize(root)
    local f=folder(root,"ForetFougeresEtRoches")
    local count=0
    for _=1,660 do
        local x,z=rng:NextNumber(-231,231),rng:NextNumber(-231,231)
        if clear(x,z) and not (x< -180 and z>0 and z<195) then
            local y=ground(x,z)
            if y then
                local dice=rng:NextNumber()
                if dice<.18 then tree(f,x,y,z,rng:NextNumber(10,18))
                elseif dice<.46 then plant(f,x,y,z,rng:NextNumber(1.1,2.3))
                elseif dice<.59 then rock(f,x,y,z,rng:NextNumber(2.6,7))
                else
                    local h=rng:NextNumber(.9,2.1)
                    local p=add(f,"Touffe d'herbes",Vector3.new(x,y+h*.46,z),
                        Vector3.new(.1,h,1.2),C.moss,Enum.Material.Grass)
                    p.CFrame=p.CFrame*CFrame.Angles(0,rng:NextNumber(0,6),0)
                end
                count+=1
            end
        end
    end
    return count
end
local function lamp(parent,x,y,z)
    add(parent,"Poteau",Vector3.new(x,y+4.5,z),
        Vector3.new(.3,9,.3),C.metal,Enum.Material.Metal)
    add(parent,"Bras",Vector3.new(x+1,y+8.7,z),
        Vector3.new(2,.25,.25),C.metal,Enum.Material.Metal)
    local globe=sphere(parent,"Lampe",Vector3.new(x+2,y+8.5,z),
        Vector3.new(1.1,1.1,1.1),C.warm,Enum.Material.Neon)
    local light=Instance.new("PointLight")
    light.Range=15
    light.Brightness=1.15
    light.Color=C.warm
    light.Parent=globe
end
local function crate(parent,x,y,z,s)
    add(parent,"Boîte de provisions",Vector3.new(x,y+s/2,z),
        Vector3.new(s,s,s),C.wood,Enum.Material.WoodPlanks,true)
    for _,dx in ipairs({-.35,.35}) do
        add(parent,"Renfort caisse",Vector3.new(x+dx*s,y+s/2,z-s/2-.1),
            Vector3.new(.14,s*.92,.17),C.bark,Enum.Material.Wood)
    end
end
local function house(parent,name,x,z,w,d,h,kind)
    local f=folder(parent,name)
    local y=ground(x,z) or 6
    local wall=kind=="diner" and C.rust or (kind=="gas" and C.concrete or C.wood)
    -- Intérieur ouvert et entrée accessible au sud.
    add(f,"Plancher",Vector3.new(x,y+.27,z),
        Vector3.new(w,.55,d),C.wood,Enum.Material.WoodPlanks,true)
    add(f,"Façade arrière",Vector3.new(x,y+h*.5,z+d*.5),
        Vector3.new(w,h,1),wall,Enum.Material.Concrete,true)
    for _,side in ipairs({-1,1}) do
        add(f,"Mur lateral",Vector3.new(x+side*w*.5,y+h*.5,z),
            Vector3.new(1,h,d),wall,Enum.Material.Concrete,true)
        add(f,"Façade vitrée",Vector3.new(x+side*w*.36,y+h*.6,z-d*.5),
            Vector3.new(w*.27,h*.8,.35),C.glass,Enum.Material.Glass,true)
        add(f,"Montant",Vector3.new(x+side*w*.22,y+h*.5,z-d*.5),
            Vector3.new(.36,h,.45),C.metal,Enum.Material.Metal,true)
    end
    add(f,"Linteau",Vector3.new(x,y+h-1,z-d*.5),
        Vector3.new(w,2,.6),wall,Enum.Material.Concrete,true)
    if kind=="diner" then
        add(f,"Toit plat",Vector3.new(x,y+h+.7,z),
            Vector3.new(w+3,1,d+3),C.rust,Enum.Material.Metal,true)
        for _,v in ipairs({{-w*.25,0},{w*.25,0}}) do
            add(f,"Banquette",Vector3.new(x+v[1],y+1.2,z+v[2]+3),
                Vector3.new(7,2.3,3),C.rust,Enum.Material.Fabric,true)
            add(f,"Table de diner",Vector3.new(x+v[1],y+2,z+v[2]-1),
                Vector3.new(6,.35,4),C.wood,Enum.Material.Wood,true)
        end
        lamp(f,x+w*.55,y,z-d*.65)
    elseif kind=="gas" then
        add(f,"Toit de station",Vector3.new(x,y+h+.6,z),
            Vector3.new(w+1,1,d+1),C.metal,Enum.Material.Metal,true)
        add(f,"Auvent carburant",Vector3.new(x,y+h*.65,z-d*.5-11),
            Vector3.new(w+8,.65,14),C.rust,Enum.Material.Metal,true)
        for _,side in ipairs({-1,1}) do
            local xx=x+side*(w*.33)
            add(f,"Pilier pompe",Vector3.new(xx,y+2.6,z-d*.5-12),
                Vector3.new(2.7,5.2,2.7),C.rust,Enum.Material.Metal,true)
            add(f,"Pistolet carburant",Vector3.new(xx+.9,y+3,z-d*.5-13.5),
                Vector3.new(.2,1.8,.3),C.metal,Enum.Material.Metal)
        end
    else
        for _,side in ipairs({-1,1}) do
            local roof=add(f,"Toit en pente",Vector3.new(x+side*w*.25,y+h+2,z),
                Vector3.new(w*.6,.7,d+3),C.asphalt,Enum.Material.Slate,true)
            roof.CFrame=roof.CFrame*CFrame.Angles(0,0,math.rad(-side*21))
        end
        add(f,"Porche",Vector3.new(x,y+.25,z-d*.5-3),
            Vector3.new(w*.6,.5,5),C.wood,Enum.Material.WoodPlanks,true)
    end
    crate(f,x+w*.33,y,z+d*.34,2)
    return f
end
local function structures(root)
    local f=folder(root,"ArchitectureEtInterieurs")
    house(f,"Diner du vieux carrefour",-8,-146,29,24,10,"diner")
    house(f,"Station service de Green Valley",93,-153,30,25,11,"gas")
    house(f,"Maison des Rangers",36,179,25,22,11,"ranger")
    local x,z=36,204
    local y=ground(x,z) or 6
    for _,side in ipairs({-1,1}) do
        local xx=x+side*8
        add(f,"Pied tour de guet",Vector3.new(xx,y+8,z),
            Vector3.new(1.8,16,1.8),C.wood,Enum.Material.Wood,true)
    end
    add(f,"Plancher tour",Vector3.new(x,y+15,z),
        Vector3.new(19,1.5,17),C.wood,Enum.Material.WoodPlanks,true)
    add(f,"Couverture tour",Vector3.new(x,y+21,z),
        Vector3.new(21,.65,19),C.asphalt,Enum.Material.Slate,true)
    return f
end
local function stream(root)
    -- Eau décorative NON baignable ; ne modifie pas le terrain existant.
    local f=folder(root,"RuisseauEtRives")
    local segments=0
    for z=8,190,13 do
        local x=-202+math.sin(z/45)*10
        local y=ground(x,z)
        if y then
            local dx=math.cos(z/45)*10/45
            local c=add(f,"Eau calme",Vector3.new(x,y+.19,z),
                Vector3.new(12,.12,15),C.water,Enum.Material.Glass)
            c.Transparency=.28
            c.Reflectance=.13
            c.CFrame=CFrame.new(c.Position)*CFrame.Angles(0,math.atan(dx),0)
            for _,side in ipairs({-1,1}) do
                rock(f,x+side*8,y,z,rng:NextNumber(1.7,3.4))
                plant(f,x+side*9,y,z+3,1.2)
            end
            segments+=1
        end
    end
    return segments
end
local function campHaven(root)
    local f=folder(root,"CampHavenV5")
    -- Les éléments sont essentiellement sous la palissade originale, sans bloquer les PNJ.
    for _,p in ipairs({{-137,-68},{-76,-63},{-136,-29},{-78,-29}}) do
        local x,z=p[1],p[2]
        local y=ground(x,z)
        if y then lamp(f,x,y,z) end
    end
    for _,p in ipairs({{-121,-68},{-115,-68},{-92,-66},{-84,-66}}) do
        local x,z=p[1],p[2]
        local y=ground(x,z)
        if y then crate(f,x,y,z,2.5) end
    end
    local x,z=-102,-16
    local y=ground(x,z)
    if y then
        add(f,"Espace potager",Vector3.new(x,y+.15,z),
            Vector3.new(15,.3,9),C.dirt,Enum.Material.Ground)
        for i=-2,2 do
            for j=-1,1 do
                plant(f,x+i*2.4,y,z+j*2.3,.58)
            end
        end
    end
    for _,v in ipairs({{-128,-60},{-84,-51}}) do
        local xx,zz=v[1],v[2]
        local yy=ground(xx,zz)
        if yy then
            add(f,"Banc communautaire",Vector3.new(xx,yy+1.4,zz),
                Vector3.new(7,.5,2),C.wood,Enum.Material.WoodPlanks,true)
        end
    end
end
local function ambience()
    if not Lighting:FindFirstChild("DZ_V5_Haze") then
        local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
        if not atmosphere then
            local a=Instance.new("Atmosphere")
            a.Name="DZ_V5_Haze"
            a.Density=.22
            a.Haze=1.1
            a.Color=Color3.fromRGB(195,205,187)
            a.Parent=Lighting
        else
            atmosphere.Haze=math.max(atmosphere.Haze,1.1)
        end
    end
end
function M.Build()
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    if not world then
        warn("[DZ V5] DZ_RECOVERY_WORLD absent. Lance d'abord DZ_GreenValleyBootstrap.")
        return nil
    end
    local old=world:FindFirstChild("DZ_V5_DETAILS")
    if old then
        print("[DZ V5] Déjà installé - aucune duplication.")
        return old
    end
    local root=folder(world,"DZ_V5_DETAILS")
    local ok,err=pcall(function()
        local count=naturalize(root)
        local streamCount=stream(root)
        structures(root)
        campHaven(root)
        ambience()
        root:SetAttribute("Version",5)
        print("[DZ V5] Carte enrichie : "..count.." éléments de nature, "..streamCount.." tronçons d'eau, 3 bâtiments, détails du camp.")
    end)
    if not ok then
        root:SetAttribute("BuildError",tostring(err))
        warn("[DZ V5] Erreur décor : "..tostring(err))
    end
    return root
end
return M
