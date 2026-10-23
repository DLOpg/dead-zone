-- DEAD ZONE | Foret realiste V2 | upgrade non destructif Green Valley
-- Utilise uniquement les modeles deja importes et autorises dans ServerStorage.
-- Command Bar, mode Edition : require(game.ServerScriptService.DZ_RealForestV2).Build()
-- Aucune suppression de Terrain, bâtiments, PNJ, prompts, loot ou gameplay.
local Workspace=game:GetService("Workspace")
local ServerStorage=game:GetService("ServerStorage")
local RunService=game:GetService("RunService")

local M={}
local ROOT_NAME="DZ_FAVORITES_VISUALS"
local FOREST_NAME="DZ_REAL_FOREST_V2"
local BACKUP_NAME="DZ_TREES_BACKUP_V1"
local LIBRARY_NAME="DZ_FAVORITES_LIBRARY"
local PREVIEW_LIB="DZ_CREATOR_ASSETS_STAGING"
local MAX_TREES=105
local PART_BUDGET=3800
local SEED=203726

local zones={
    {-175,-145,45}, {-105,-45,80}, {50,-35,48},
    {-20,100,46}, {130,95,61}, {175,-135,45},
    {-125,135,46}, {-8,-146,36}, {93,-153,38}, {36,179,36},
}
local roads={
    {{-175,-145},{-105,-45},{50,-35},{130,95}},
    {{-105,-45},{-20,100},{-125,135}},
    {{50,-35},{175,-135}},
}
local function log(s)
    print("[DZ FORET V2] "..s)
end
local function dir()
    return Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
end
local function ensure(parent,name)
    local found=parent:FindFirstChild(name)
    if not found then
        found=Instance.new("Folder")
        found.Name=name
        found.Parent=parent
    end
    return found
end
local function countParts(obj)
    local n=0
    for _,child in ipairs(obj:GetDescendants()) do
        if child:IsA("BasePart") then n+=1 end
    end
    return n
end
local function sourceTrees()
    local lib=ServerStorage:FindFirstChild(LIBRARY_NAME)
    local pack=lib and lib:FindFirstChild("realistic_trees")
    if pack and countParts(pack)>0 then return pack end
    local fallback=ServerStorage:FindFirstChild(PREVIEW_LIB)
    pack=fallback and fallback:FindFirstChild("realistic_trees")
    return pack and countParts(pack)>0 and pack or nil
end
local function box(model)
    local success,cf,size=pcall(function()
        return model:GetBoundingBox()
    end)
    return success and cf or nil,success and size or nil
end
local function candidate(obj)
    local num=countParts(obj)
    if num==0 or num>135 then return nil end
    local _,sz=box(obj)
    if not sz or sz.Y<3.5 or sz.Y>170 or math.max(sz.X,sz.Z)>120 then return nil end
    return num
end
local function variants(pack)
    local choices={}
    -- Preferer les vrais arbres autonomes du pack, pas le pack entier repete.
    for _,m in ipairs(pack:GetDescendants()) do
        if m:IsA("Model") then
            local good=candidate(m)
            if good then
                local hasChildTree=false
                for _,child in ipairs(m:GetDescendants()) do
                    if child~=m and child:IsA("Model") and candidate(child) then
                        hasChildTree=true
                        break
                    end
                end
                if not hasChildTree then
                    table.insert(choices,{asset=m,count=good})
                end
            end
        end
    end
    if #choices==0 then
        -- Certains packs distribuent chaque arbre comme un seul MeshPart.
        for _,piece in ipairs(pack:GetDescendants()) do
            if piece:IsA("MeshPart") and piece.Size.Y>=5 and piece.Size.Y<=140
                and math.max(piece.Size.X,piece.Size.Z)<=95 then
                table.insert(choices,{asset=piece,count=1})
            end
        end
    end
    if #choices==0 then
        local good=candidate(pack)
        if good then table.insert(choices,{asset=pack,count=good}) end
    end
    table.sort(choices,function(a,b)
        if a.count==b.count then
            return a.asset:GetFullName()<b.asset:GetFullName()
        end
        return a.count<b.count
    end)
    -- Eviter les packs anormaux; garder suffisamment de variantes.
    local usable={}
    for _,v in ipairs(choices) do
        if #usable>=16 then break end
        table.insert(usable,v)
    end
    return usable
end

local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={Workspace.Terrain}
params.IgnoreWater=true
local function elevation(x,z)
    local hit=Workspace:Raycast(Vector3.new(x,200,z),Vector3.new(0,-310,0),params)
    return hit and hit.Position.Y or nil
end
local function segmentDistance(x,z,a,b)
    local dx,dz=b[1]-a[1],b[2]-a[2]
    local t=math.clamp(((x-a[1])*dx+(z-a[2])*dz)/math.max(.1,dx*dx+dz*dz),0,1)
    local ax,az=a[1]+t*dx,a[2]+t*dz
    return math.sqrt((x-ax)^2+(z-az)^2)
end
local function allowed(x,z,points)
    for _,s in ipairs(zones) do
        local dx,dz=x-s[1],z-s[2]
        if dx*dx+dz*dz<s[3]*s[3] then return false end
    end
    for _,path in ipairs(roads) do
        for i=1,#path-1 do
            if segmentDistance(x,z,path[i],path[i+1])<15 then return false end
        end
    end
    -- Conserver les berges du ruisseau existant.
    if z>0 and z<194 then
        local streamX=-202+math.sin(z/45)*10
        if math.abs(x-streamX)<17 then return false end
    end
    for _,p in ipairs(points) do
        local dx,dz=x-p.X,z-p.Y
        if dx*dx+dz*dz<15*15 then return false end
    end
    return true
end
local function pickSpot(rng,points)
    for _=1,90 do
        local x,z
        if rng:NextNumber()<.7 then
            -- Forêt plus dense à la périphérie, villages et routes dégagés.
            local side=rng:NextInteger(1,4)
            if side==1 then
                x=rng:NextNumber(-228,-151)
                z=rng:NextNumber(-230,230)
            elseif side==2 then
                x=rng:NextNumber(151,228)
                z=rng:NextNumber(-230,230)
            elseif side==3 then
                x=rng:NextNumber(-230,230)
                z=rng:NextNumber(-228,-151)
            else
                x=rng:NextNumber(-230,230)
                z=rng:NextNumber(151,228)
            end
        else
            x=rng:NextNumber(-228,228)
            z=rng:NextNumber(-228,228)
        end
        if allowed(x,z,points) then
            local y=elevation(x,z)
            if y then return x,y,z end
        end
    end
    return nil
end
local function cleanVisual(model)
    for _,p in ipairs(model:GetDescendants()) do
        if p:IsA("LuaSourceContainer") or p:IsA("RemoteEvent")
            or p:IsA("RemoteFunction") or p:IsA("BindableEvent")
            or p:IsA("BindableFunction") or p:IsA("ProximityPrompt")
            or p:IsA("ClickDetector") then
            p:Destroy()
        elseif p:IsA("BasePart") then
            p.Anchored=true
            p.CanCollide=false
            p.CanTouch=false
            p.CanQuery=false
        elseif p:IsA("Sound") then
            p.Playing=false
        elseif p:IsA("ParticleEmitter") or p:IsA("Trail") then
            p.Enabled=false
        end
    end
end
local function plant(variant,parent,index,x,y,z,rng)
    -- Le Model permet de redimensionner de facon homogene MeshParts et Model.
    local tree=Instance.new("Model")
    tree.Name=string.format("Arbre_Realiste_%03d",index)
    local clone=variant.asset:Clone()
    clone.Parent=tree
    tree.Parent=parent
    cleanVisual(tree)
    local center,sz=box(tree)
    if not center or not sz or sz.Y<.1 then tree:Destroy() return false end
    local height=rng:NextNumber(12,25)
    local scale=math.clamp(height/sz.Y,.2,3.5)
    local ok,err=pcall(function() tree:ScaleTo(scale) end)
    if not ok then tree:Destroy();warn("[DZ FORET V2] ScaleTo : "..tostring(err));return false end
    local newCf,newSize=box(tree)
    if not newCf then tree:Destroy() return false end
    local yaw=rng:NextNumber(-180,180)
    local destination=CFrame.new(x,y+newSize.Y*.5-.2,z)*CFrame.Angles(0,math.rad(yaw),0)
    tree:PivotTo(destination*newCf:Inverse()*tree:GetPivot())
    tree:SetAttribute("DZ_ForestV2",true)
    tree:SetAttribute("DZ_Height",height)
    return true
end

local oldSpec={
    {folder={"Nature"},names={Tronc=true,Feuillage=true}},
    {folder={"DZ_V4_DECOR","NatureSupplementaire"},names={["Pin tronc"]=true,["Pin branches"]=true}},
    {folder={"DZ_V5_DETAILS","ForetFougeresEtRoches"},names={
        ["Tronc bouleau"]=true,Houppier=true,["Houppier secondaire"]=true,
    }},
}
local function oldTrees(world,restore)
    local count=0
    for _,spec in ipairs(oldSpec) do
        local f=world
        for _,name in ipairs(spec.folder) do
            f=f and f:FindFirstChild(name)
        end
        if f then
            for _,p in ipairs(f:GetDescendants()) do
                if p:IsA("BasePart") and spec.names[p.Name] then
                    if restore then
                        local trans=p:GetAttribute("DZ_TreeOldTransparency")
                        if trans~=nil then
                            p.Transparency=trans
                            p.CanCollide=p:GetAttribute("DZ_TreeOldCollide")==true
                            p.CanQuery=p:GetAttribute("DZ_TreeOldQuery")==true
                            p.CastShadow=p:GetAttribute("DZ_TreeOldShadow")==true
                            p:SetAttribute("DZ_TreeOldTransparency",nil)
                            p:SetAttribute("DZ_TreeOldCollide",nil)
                            p:SetAttribute("DZ_TreeOldQuery",nil)
                            p:SetAttribute("DZ_TreeOldShadow",nil)
                            count+=1
                        end
                    else
                        if p:GetAttribute("DZ_TreeOldTransparency")==nil then
                            p:SetAttribute("DZ_TreeOldTransparency",p.Transparency)
                            p:SetAttribute("DZ_TreeOldCollide",p.CanCollide)
                            p:SetAttribute("DZ_TreeOldQuery",p.CanQuery)
                            p:SetAttribute("DZ_TreeOldShadow",p.CastShadow)
                            count+=1
                        end
                        p.Transparency=1
                        p.CanCollide=false
                        p.CanQuery=false
                        p.CastShadow=false
                    end
                end
            end
        end
    end
    return count
end
function M.HideOld()
    local world=dir()
    if not world then return 0 end
    local visuals=world:FindFirstChild(ROOT_NAME)
    if not visuals or not visuals:FindFirstChild(FOREST_NAME) then
        return 0 -- Ne jamais cacher l'ancienne foret sans nouvelle foret.
    end
    return oldTrees(world,false)
end

function M.Build(requested)
    assert(RunService:IsStudio() and not RunService:IsRunning(),
        "A lancer via Command Bar en mode Edition, pas pendant Play.")
    local world=dir()
    if not world then warn("[DZ FORET V2] Green Valley absente.");return false end
    local pack=sourceTrees()
    if not pack then
        warn("[DZ FORET V2] Pack Realistic Trees introuvable dans ServerStorage. Lance d'abord Install() puis reessaie.")
        return false
    end
    local all=variants(pack)
    if #all==0 then
        warn("[DZ FORET V2] Pack présent mais aucune variante d'arbre exploitable.")
        return false
    end
    local visuals=ensure(world,ROOT_NAME)
    local previous=visuals:FindFirstChild(FOREST_NAME)
    if previous and previous:GetAttribute("DZ_Completed")==true then
        local changed=M.HideOld()
        log("Foret deja installee : "..#previous:GetChildren().." arbres, "..changed.." anciens elements masques.")
        return true
    end
    if previous then
        warn("[DZ FORET V2] Foret partielle deja presente, aucune modification. Sauvegarde et controle son dossier.")
        return false
    end
    local amount=math.clamp(math.floor(tonumber(requested) or MAX_TREES),45,145)
    local treeFolder=Instance.new("Folder")
    treeFolder.Name=FOREST_NAME
    treeFolder.Parent=visuals
    local selected={}
    local rng=Random.new(SEED)
    local planted=0
    local used=0
    -- Ne pas laisser un pack enorme produire des milliers de Parts.
    for index=1,amount do
        local possible={}
        for _,option in ipairs(all) do
            if option.count+used<=PART_BUDGET then
                table.insert(possible,option)
            end
        end
        if #possible==0 then break end
        local x,y,z=pickSpot(rng,selected)
        if not x then break end
        local option=possible[rng:NextInteger(1,#possible)]
        if plant(option,treeFolder,index,x,y,z,rng) then
            planted+=1
            used+=option.count
            table.insert(selected,Vector2.new(x,z))
        end
    end
    if planted<25 then
        treeFolder:Destroy()
        warn("[DZ FORET V2] Plantation insuffisante. Rien n'a ete masque ni retire.")
        return false
    end

    -- Conserver les 20 arbres de la premiere passe hors Workspace pour retour arriere.
    local backup=ensure(ServerStorage,BACKUP_NAME)
    for _,obj in ipairs(visuals:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("Folder"))
            and string.match(obj.Name,"^DZ_tree_%d+$") then
            obj.Parent=backup
        end
    end
    treeFolder:SetAttribute("DZ_Completed",true)
    treeFolder:SetAttribute("DZ_Trees",planted)
    treeFolder:SetAttribute("DZ_Parts",used)
    treeFolder:SetAttribute("DZ_Variants",#all)
    local hidden=M.HideOld()
    log(planted.." arbres reels, "..#all.." variantes, "..used.." parts et "
        ..hidden.." anciennes pieces d'arbres masquees. Routes et batiments preserves.")
    return true
end

function M.Restore()
    assert(RunService:IsStudio() and not RunService:IsRunning(),
        "Restauration uniquement en mode Edition.")
    local world=dir()
    if not world then return false end
    local count=oldTrees(world,true)
    local visuals=world:FindFirstChild(ROOT_NAME)
    if visuals then
        local forest=visuals:FindFirstChild(FOREST_NAME)
        if forest then forest:Destroy() end
        local backup=ServerStorage:FindFirstChild(BACKUP_NAME)
        if backup then
            for _,obj in ipairs(backup:GetChildren()) do
                obj.Parent=visuals
            end
        end
    end
    log("Restauration terminee : "..count.." parties d'anciens arbres reaffichees.")
    return true
end

return M
