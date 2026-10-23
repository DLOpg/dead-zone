-- DEAD ZONE Green Valley V4 : extension visuelle NON DESTRUCTIVE
-- Base attendue : la Green Valley de secours DZ_RECOVERY_WORLD.
-- En mode EDITION, pour conserver les decors dans la place :
-- require(game.ServerScriptService.DZ_GreenValleyV4).Build()
-- Au Play, le runner lance aussi Build() si les decors ne sont pas presents.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local M = {}
local VERSION = 4
local FOLDER = "DZ_V4_DECOR"

local colors = {
    trunk = Color3.fromRGB(88,72,57),
    pine = Color3.fromRGB(46,76,57),
    leaves = Color3.fromRGB(65,100,67),
    moss = Color3.fromRGB(80,107,64),
    grass = Color3.fromRGB(110,125,79),
    stone = Color3.fromRGB(88,91,87),
    wood = Color3.fromRGB(124,98,73),
    iron = Color3.fromRGB(89,94,87),
    rust = Color3.fromRGB(122,81,58),
    light = Color3.fromRGB(239,186,109),
}

-- Centres et rayon d'exclusion : ne pas bloquer les bâtiments.
local zones = {
    {-175,-145,42}, {-105,-45,77}, {50,-35,44},
    {-20,100,45}, {130,95,56}, {175,-135,40}, {-125,135,42},
}
local routes = {
    {{-175,-145},{-105,-45},{50,-35},{130,95}},
    {{-105,-45},{-20,100},{-125,135}},
    {{50,-35},{175,-135}},
}
local rng = Random.new(2037)

local function part(parent,name,pos,size,color,material,shape)
    local obj=Instance.new("Part")
    obj.Name=name
    obj.Anchored=true
    obj.CanCollide=false
    obj.CanTouch=false
    obj.CanQuery=false
    obj.CastShadow=size.Magnitude>9
    obj.Size=size
    obj.Position=pos
    obj.Color=color
    obj.Material=material or Enum.Material.Wood
    obj.Shape=shape or Enum.PartType.Block
    obj.TopSurface=Enum.SurfaceType.Smooth
    obj.BottomSurface=Enum.SurfaceType.Smooth
    obj.Parent=parent
    return obj
end

local function ball(parent,name,pos,size,color,material)
    return part(parent,name,pos,size,color,material,Enum.PartType.Ball)
end

local function ground(x,z)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances={Workspace.Terrain}
    params.IgnoreWater=true
    local hit=Workspace:Raycast(Vector3.new(x,190,z),Vector3.new(0,-290,0),params)
    return hit and hit.Position.Y or nil
end

local function roadDistance(x,z,a,b)
    local dx=b[1]-a[1]
    local dz=b[2]-a[2]
    local t=math.clamp(((x-a[1])*dx+(z-a[2])*dz)/math.max(.01,dx*dx+dz*dz),0,1)
    local px=a[1]+dx*t
    local pz=a[2]+dz*t
    return math.sqrt((x-px)^2+(z-pz)^2)
end

local function free(x,z,roadMargin)
    for _,s in ipairs(zones) do
        local dx=x-s[1]
        local dz=z-s[2]
        if dx*dx+dz*dz<s[3]*s[3] then return false end
    end
    for _,path in ipairs(routes) do
        for i=1,#path-1 do
            if roadDistance(x,z,path[i],path[i+1])<roadMargin then return false end
        end
    end
    return true
end

local function shrub(folder,x,y,z,scale)
    ball(folder,"Buisson naturel",Vector3.new(x,y+scale*.6,z),
        Vector3.new(scale*2,scale*1.3,scale*1.7),colors.leaves,Enum.Material.Grass)
    ball(folder,"Fougeres",Vector3.new(x+scale*.5,y+scale*.55,z-.4),
        Vector3.new(scale*1.6,scale,scale*1.5),colors.moss,Enum.Material.Grass)
end

local function boulder(folder,x,y,z,scale)
    local p=ball(folder,"Roche",Vector3.new(x,y+scale*.32,z),
        Vector3.new(scale*1.5,scale*.7,scale),colors.stone,Enum.Material.Slate)
    p.CFrame=p.CFrame*CFrame.Angles(rng:NextNumber(-.2,.2),rng:NextNumber(0,3),rng:NextNumber(-.2,.2))
    if rng:NextNumber()>.48 then
        ball(folder,"Mousse sur roche",Vector3.new(x,y+scale*.65,z),
            Vector3.new(scale,.15,scale*.7),colors.moss,Enum.Material.Grass)
    end
end

local function tallGrass(folder,x,y,z)
    local h=rng:NextNumber(1.1,2.4)
    for i=1,2 do
        local p=part(folder,"Herbes hautes",Vector3.new(x,y+h*.47,z),
            Vector3.new(.15,h,1.3),i==1 and colors.grass or colors.moss,Enum.Material.Grass)
        p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,rng:NextNumber(0,math.pi),rng:NextNumber(-.16,.16))
    end
end

local function pine(folder,x,y,z,height)
    part(folder,"Pin tronc",Vector3.new(x,y+height*.44,z),
        Vector3.new(1.25,height*.88,1.25),colors.trunk,Enum.Material.Wood)
    for i=1,3 do
        local width=(4-i)*2.4
        ball(folder,"Pin branches",Vector3.new(x,y+height*(.33+i*.17),z),
            Vector3.new(width,height*.31,width),i==3 and colors.leaves or colors.pine,Enum.Material.Grass)
    end
end

local function placeScenery(folder)
    local nature=Instance.new("Folder")
    nature.Name="NatureSupplementaire"
    nature.Parent=folder
    local total=0
    local function scatter(target,margin,create)
        local found=0
        for _=1,target*15 do
            if found>=target then break end
            local x=rng:NextNumber(-233,233)
            local z=rng:NextNumber(-233,233)
            if free(x,z,margin) then
                local y=ground(x,z)
                if y then
                    create(nature,x,y,z)
                    total+=1
                    found+=1
                end
            end
        end
    end
    scatter(160,6,function(f,x,y,z) tallGrass(f,x,y,z) end)
    scatter(70,9,function(f,x,y,z) shrub(f,x,y,z,rng:NextNumber(1.2,3)) end)
    scatter(50,8,function(f,x,y,z) boulder(f,x,y,z,rng:NextNumber(2,6)) end)
    scatter(32,12,function(f,x,y,z) pine(f,x,y,z,rng:NextNumber(12,22)) end)
    scatter(28,12,function(f,x,y,z)
        part(f,"Souche",Vector3.new(x,y+.8,z),Vector3.new(2.3,1.6,2.3),colors.trunk,Enum.Material.Wood)
        shrub(f,x+2,y,z+1,1.2)
    end)
    return total
end

local function crate(folder,x,y,z,s)
    part(folder,"Caisse en bois",Vector3.new(x,y+s/2,z),Vector3.new(s,s,s),
        colors.wood,Enum.Material.WoodPlanks)
    for _,dx in ipairs({-.3,.3}) do
        part(folder,"Armature",Vector3.new(x+dx*s,y+s/2,z-s/2-.1),
            Vector3.new(.13,s*.9,.15),colors.trunk,Enum.Material.Wood)
    end
end

local function barrel(folder,x,y,z)
    part(folder,"Baril",Vector3.new(x,y+1.6,z),Vector3.new(2.6,3.2,2.6),
        colors.rust,Enum.Material.Metal)
    for _,height in ipairs({.55,2.65}) do
        part(folder,"Bord baril",Vector3.new(x,y+height,z),
            Vector3.new(2.8,.2,2.8),colors.iron,Enum.Material.Metal)
    end
end

local function lamp(folder,x,y,z)
    part(folder,"Mât",Vector3.new(x,y+4,z),Vector3.new(.35,8,.35),
        colors.iron,Enum.Material.Metal)
    part(folder,"Bras",Vector3.new(x+1,y+7.8,z),Vector3.new(2,.2,.2),
        colors.iron,Enum.Material.Metal)
    local globe=ball(folder,"Lanterne",Vector3.new(x+2,y+7.3,z),
        Vector3.new(1.25,1.3,1.25),colors.light,Enum.Material.Neon)
    local light=Instance.new("PointLight")
    light.Color=colors.light
    light.Brightness=1
    light.Range=17
    light.Shadows=false
    light.Parent=globe
end

local function campDetails(root)
    local folder=Instance.new("Folder")
    folder.Name="CampHavenDetails"
    folder.Parent=root
    local items={
        {-105,-45,"lamp"},{-118,-25,"lamp"},{-90,-25,"lamp"},
        {-135,-58,"barrel"},{-133,-60,"barrel"},{-78,-43,"barrel"},
        {-126,-30,"crate"},{-117,-29,"crate"},{-86,-31,"crate"},{-94,-60,"crate"},
    }
    for _,v in ipairs(items) do
        local y=ground(v[1],v[2])
        if y then
            if v[3]=="lamp" then lamp(folder,v[1],y,v[2])
            elseif v[3]=="barrel" then barrel(folder,v[1],y,v[2])
            else crate(folder,v[1],y,v[2],2.4) end
        end
    end
    local y=ground(-106,-43)
    if y then
        part(folder,"Brasero",Vector3.new(-106,y+.8,-43),
            Vector3.new(3.5,1.4,3.5),colors.rust,Enum.Material.Metal)
        local embers=ball(folder,"Braises",Vector3.new(-106,y+1.55,-43),
            Vector3.new(2.5,.16,2.5),Color3.fromRGB(188,98,60),Enum.Material.Neon)
        embers.Transparency=.4
    end
    for _,v in ipairs({{-132,-26},{-84,-63},{-76,-26}}) do
        local yy=ground(v[1],v[2])
        if yy then
            for i=-1,1 do
                part(folder,"Palette",Vector3.new(v[1],yy+.15,v[2]+i*.95),
                    Vector3.new(4.5,.3,.6),colors.wood,Enum.Material.WoodPlanks)
            end
        end
    end
    local ry=ground(-83,-27) or 6
    part(folder,"Mât radio de Lina",Vector3.new(-83,ry+8,-27),
        Vector3.new(.4,16,.4),colors.iron,Enum.Material.Metal)
    part(folder,"Antenne radio",Vector3.new(-83,ry+15,-27),
        Vector3.new(5.5,.16,.16),colors.iron,Enum.Material.Metal)
end

local function facadeDetails(root,builds)
    local folder=Instance.new("Folder")
    folder.Name="FaçadesEtRuines"
    folder.Parent=root
    local info={
        {"Ferme du reveil",-175,-145,32,26,11},
        {"Maison Miller",-125,135,32,29,12},
        {"Superette",50,-35,39,28,11},
        {"Garage de Frank",-20,100,38,30,12},
        {"Hopital",130,95,47,39,18},
        {"Bunker ECHO-7",175,-135,35,31,12},
    }
    for _,v in ipairs(info) do
        if builds:FindFirstChild(v[1]) then
            local x,z,w,d,h=v[2],v[3],v[4],v[5],v[6]
            local y=ground(x,z) or 6
            local front=z-d/2-1
            for _,side in ipairs({-1,1}) do
                local xx=x+side*(w/2-2)
                part(folder,"Gouttière",Vector3.new(xx,y+h*.65,front+.25),
                    Vector3.new(.22,h*.7,.22),colors.iron,Enum.Material.Metal)
                shrub(folder,xx,y,front+.8,1.7)
                ball(folder,"Lierre mur",Vector3.new(xx,y+4,front+.8),
                    Vector3.new(2.4,6,1.9),colors.moss,Enum.Material.Grass)
                part(folder,"Encadrement",Vector3.new(x+side*w*.32,y+6.8,front+.15),
                    Vector3.new(4.5,.25,.35),colors.trunk,Enum.Material.Wood)
            end
            local p=part(folder,"Auvent",Vector3.new(x,y+h*.75,front-2.4),
                Vector3.new(w*.46,.45,4.5),colors.trunk,Enum.Material.WoodPlanks)
            p.CFrame=p.CFrame*CFrame.Angles(math.rad(-6),0,0)
            for _,side in ipairs({-1,1}) do
                part(folder,"Poteau porche",Vector3.new(x+side*w*.21,y+h*.4,front-3.4),
                    Vector3.new(.32,h*.75,.32),colors.iron,Enum.Material.Metal)
            end
            local yy=ground(x+w*.38,front-7)
            if yy then
                if v[1]=="Superette" or v[1]=="Garage de Frank" then
                    barrel(folder,x+w*.38,yy,front-7)
                else
                    boulder(folder,x+w*.38,yy,front-7,3)
                end
            end
        end
    end
end

local function styleCharacters(root,people)
    local folder=Instance.new("Folder")
    folder.Name="AccessoiresPersonnages"
    folder.Parent=root
    local spec={
        ["Marcus Hale"]={Color3.fromRGB(66,86,63),"cap"},
        ["Elena Ward"]={Color3.fromRGB(210,213,193),"medic"},
        ["Ethan Brooks"]={Color3.fromRGB(112,83,63),"mechanic"},
        ["Lina"]={Color3.fromRGB(122,79,90),"radio"},
    }
    for name,setting in pairs(spec) do
        local npc=people:FindFirstChild(name)
        local head=npc and npc:FindFirstChild("Tete")
        local torso=npc and npc:FindFirstChild("Corps")
        if head and head:IsA("BasePart") and torso and torso:IsA("BasePart") then
            torso.Color=setting[1]
            local h,b=head.Position,torso.Position
            if setting[2]=="cap" then
                ball(folder,"Casquette Marcus",h+Vector3.new(0,.94,0),
                    Vector3.new(2.2,.5,2.1),colors.pine,Enum.Material.Fabric)
                part(folder,"Visière",h+Vector3.new(0,.8,-.9),
                    Vector3.new(2,.16,.9),colors.pine,Enum.Material.Fabric)
                part(folder,"Sac tactique",b+Vector3.new(0,0,1),
                    Vector3.new(1.6,2,.6),colors.trunk,Enum.Material.Fabric)
            elseif setting[2]=="medic" then
                part(folder,"Blouse Elena",b+Vector3.new(0,-.3,-.75),
                    Vector3.new(2.5,2.5,.25),Color3.fromRGB(211,210,197),Enum.Material.Fabric)
                part(folder,"Insigne médical",b+Vector3.new(.6,.5,-.92),
                    Vector3.new(.6,.15,.1),Color3.fromRGB(160,66,62),Enum.Material.SmoothPlastic)
            elseif setting[2]=="mechanic" then
                ball(folder,"Bonnet Ethan",h+Vector3.new(0,.87,0),
                    Vector3.new(2,.7,2),colors.iron,Enum.Material.Fabric)
                part(folder,"Sac outils",b+Vector3.new(-1.1,-.85,.1),
                    Vector3.new(.7,1.4,.7),colors.rust,Enum.Material.Fabric)
            elseif setting[2]=="radio" then
                for _,side in ipairs({-1,1}) do
                    ball(folder,"Casque Lina",h+Vector3.new(side,0,0),
                        Vector3.new(.5,1,1),colors.iron,Enum.Material.Metal)
                end
                part(folder,"Arceau",h+Vector3.new(0,1.1,0),
                    Vector3.new(2,.2,.4),colors.iron,Enum.Material.Metal)
                part(folder,"Sac radio",b+Vector3.new(0,-.2,1),
                    Vector3.new(1.6,1.6,.8),colors.trunk,Enum.Material.Fabric)
            end
        end
    end
end

local function lightGrade()
    if not Lighting:FindFirstChild("DZ_V4_Color") then
        local cc=Instance.new("ColorCorrectionEffect")
        cc.Name="DZ_V4_Color"
        cc.TintColor=Color3.fromRGB(235,231,218)
        cc.Contrast=.08
        cc.Saturation=-.1
        cc.Parent=Lighting
    end
    if not Lighting:FindFirstChild("DZ_V4_Bloom") then
        local b=Instance.new("BloomEffect")
        b.Name="DZ_V4_Bloom"
        b.Intensity=.14
        b.Size=12
        b.Threshold=1.35
        b.Parent=Lighting
    end
end

function M.Build()
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    if not world then
        warn("[DZ V4] Monde de secours absent. Ouvre la Green Valley fonctionnelle.")
        return nil
    end
    local previous=world:FindFirstChild(FOLDER)
    if previous then
        print("[DZ V4] Décors déjà installés : aucune duplication.")
        return previous
    end
    local builds=world:FindFirstChild("Batiments")
    local people=world:FindFirstChild("Personnages")
    if not builds or not people then
        warn("[DZ V4] Batiments ou Personnages manquant : pas de modification.")
        return nil
    end
    local folder=Instance.new("Folder")
    folder.Name=FOLDER
    folder.Parent=world
    local ok,errorMessage=pcall(function()
        local count=placeScenery(folder)
        facadeDetails(folder,builds)
        campDetails(folder)
        styleCharacters(folder,people)
        lightGrade()
        folder:SetAttribute("Version",VERSION)
        print("[DZ V4] Nature et relief existant enrichis : "..count.." touffes/arbustes/roches/arbres/souches.")
        print("[DZ V4] Camp Haven, façades et 4 PNJ principaux améliorés.")
    end)
    if not ok then
        folder:SetAttribute("Erreur",tostring(errorMessage))
        warn("[DZ V4] Erreur de génération : "..tostring(errorMessage))
    end
    return folder
end

return M
