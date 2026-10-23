-- DEAD ZONE | Creator Store Asset Pipeline
-- ModuleScript à appeler dans la Command Bar EN MODE EDITION uniquement.
-- Les modèles sont importés en quarantaine dans ServerStorage. Aucune suppression.
-- Pour le chargement automatique, activer Allow Loading Third Party Assets si Studio le permet.
local AssetService=game:GetService("AssetService")
local ServerStorage=game:GetService("ServerStorage")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local Catalog=require(ReplicatedStorage:WaitForChild("DZ_CreatorStoreCatalog"))
local M={}
local POOL_NAME="DZ_CREATOR_ASSETS_STAGING"
local PREVIEW_NAME="DZ_CREATOR_PREVIEW"
local statuses={}

local function pool()
    local folder=ServerStorage:FindFirstChild(POOL_NAME)
    if not folder then
        folder=Instance.new("Folder")
        folder.Name=POOL_NAME
        folder.Parent=ServerStorage
    end
    return folder
end

local function report(message)
    print("[DZ CREATOR] "..message)
end

local function purgeScripts(source)
    local removed=0
    for _,v in ipairs(source:GetDescendants()) do
        if v:IsA("LuaSourceContainer") then
            if v:IsA('Script') or v:IsA('LocalScript') then v.Disabled=true end
            v:Destroy()
            removed+=1
        elseif v:IsA("RemoteEvent") or v:IsA("RemoteFunction")
            or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
            v:Destroy()
        elseif v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
            v:Destroy()
        end
    end
    return removed
end

local function visualize(source)
    local parts=0
    for _,v in ipairs(source:GetDescendants()) do
        if v:IsA("BasePart") then
            parts+=1
            v.Anchored=true
            v.CanCollide=false
            v.CanTouch=false
            v.CanQuery=false
            v.Massless=true
            if v:IsA("MeshPart") then
                -- Décors : pas de texture ni mesh arbitraire hors Roblox.
                v.CastShadow=true
            end
        elseif v:IsA("Sound") then
            v.Playing=false
        elseif v:IsA("ParticleEmitter") then
            v.Enabled=false
        elseif v:IsA("Trail") then
            v.Enabled=false
        end
    end
    return parts
end

local function childParts(model)
    local n=0
    for _,v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then n+=1 end
    end
    return n
end

local function importOne(item)
    local storage=pool()
    if storage:FindFirstChild(item.key) then
        return true,"déjà présent"
    end
    local ok,container=pcall(function()
        return AssetService:LoadAssetAsync(item.id)
    end)
    if not ok or not container then
        return false,tostring(container)
    end
    -- Le modèle importé est inspectable sans être mis dans Workspace.
    local count=childParts(container)
    if count==0 or count>2000 then
        container:Destroy()
        return false,"nombre de pièces hors limites ("..count..")"
    end
    local scripts=purgeScripts(container)
    visualize(container)
    container.Name=item.key
    container:SetAttribute("DZ_AssetId",tostring(item.id))
    container:SetAttribute("DZ_CreatorTitle",item.title)
    container:SetAttribute("DZ_ScriptsRemoved",scripts)
    container:SetAttribute("DZ_Approved",false)
    container.Parent=storage
    return true,"pièces "..count.." ; scripts retirés "..scripts
end

function M.Import(limit)
    assert(RunService:IsStudio() and not RunService:IsRunning(),"Import Creator Store réservé à Studio en mode ÉDITION")
    local total=0
    limit=math.clamp(tonumber(limit) or 4,1,17)
    for _,item in ipairs(Catalog) do
        if total>=limit then break end
        if item.status=="candidate" then
            local ok,msg=importOne(item)
            statuses[item.key]={ok=ok,message=msg}
            if ok then total+=1 end
            report(item.key.." : "..(ok and "OK" or "IMPOSSIBLE").." - "..msg)
        end
    end
    report("Bibliothèque: ServerStorage/"..POOL_NAME)
    return statuses
end

function M.ImportKey(key)
    assert(RunService:IsStudio() and not RunService:IsRunning(),"Import réservé au mode ÉDITION")
    for _,item in ipairs(Catalog) do
        if item.key==key then
            local ok,msg=importOne(item)
            report(key.." : "..msg)
            return ok,msg
        end
    end
    return false,"clé inconnue"
end

function M.AttachToolbox(key,object)
    assert(RunService:IsStudio() and not RunService:IsRunning(),"Réservé à Studio en mode ÉDITION")
    assert(typeof(object)=="Instance" and object:IsDescendantOf(game),"Passer un modèle déjà dans Studio")
    local storage=pool()
    local copy=object:Clone()
    if childParts(copy)==0 then copy:Destroy() return false end
    purgeScripts(copy)
    visualize(copy)
    copy.Name=key
    copy:SetAttribute("DZ_AssetId","Toolbox")
    copy:SetAttribute("DZ_Approved",false)
    copy.Parent=storage
    report(key.." importé depuis Toolbox, en attente de validation.")
    return true
end

function M.Approve(key)
    assert(RunService:IsStudio() and not RunService:IsRunning(),"Réservé à Studio en mode ÉDITION")
    local source=pool():FindFirstChild(key)
    if not source then return false,"modèle manquant" end
    purgeScripts(source)
    visualize(source)
    source:SetAttribute("DZ_Approved",true)
    report(key.." : approuvé pour prévisualisation.")
    return true
end

local function ground(x,z)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances={Workspace.Terrain}
    params.IgnoreWater=true
    local hit=Workspace:Raycast(Vector3.new(x,210,z),Vector3.new(0,-330,0),params)
    return hit and hit.Position.Y or 6
end

local function findModel(container)
    -- Certains modèles importés sont enveloppés d'un Model racine.
    local first=container:FindFirstChildWhichIsA("Model")
    return first or container
end

local function putModel(destination,source,key,x,z,targetWidth,rotation)
    local visual=findModel(source):Clone()
    visual.Name="DZ_VISUAL_"..key
    purgeScripts(visual)
    visualize(visual)
    visual.Parent=destination
    local _,size=visual:GetBoundingBox()
    local span=math.max(size.X,size.Z,1)
    local scale=math.clamp(targetWidth/span,.08,6)
    local ok=pcall(function() visual:ScaleTo(scale) end)
    if not ok then
        warn("[DZ CREATOR] "..key.." : ScaleTo impossible ; taille d'origine.")
    end
    local cf,bounds=visual:GetBoundingBox()
    local y=ground(x,z)
    -- Aligne la partie inférieure de la boîte 3D à la hauteur du sol.
    local target=CFrame.new(x,y+bounds.Y/2,z)*CFrame.Angles(0,math.rad(rotation or 0),0)
    visual:PivotTo(target)
    visual:SetAttribute("DZ_AssetKey",key)
    visual:SetAttribute("DZ_VisualOnly",true)
    return visual
end

local TARGETS={
    -- Prévisualisation sans remplacement automatique des bâtiments jouables.
    {key="abandoned_house",x=-146,z=-198,width=26,rotation=15},
    {key="abandoned_house_light",x=-210,z=125,width=27,rotation=-20},
    {key="derelict_gas",x=93,z=-153,width=36,rotation=0},
    {key="hospital",x=130,z=95,width=43,rotation=0},
    {key="pine_quenty",x=-220,z=-220,width=14,rotation=10},
    {key="pine_lowpoly",x=-204,z=186,width=16,rotation=30},
    {key="oak",x=205,z=160,width=16,rotation=0},
    {key="motobike",x=-45,z=96,width=7,rotation=90},
}
local NPCS={
    marcus_military="Marcus Hale",
    lina_girl="Lina",
}
local function modelAtLocation(source,key,container,position,width)
    local clone=findModel(source):Clone()
    clone.Name="DZ_NPC_VISUAL_"..key
    purgeScripts(clone)
    visualize(clone)
    clone.Parent=container
    local cf,size=clone:GetBoundingBox()
    local scale=math.clamp(width/math.max(size.Y,1),.2,4)
    pcall(function() clone:ScaleTo(scale) end)
    local _,newSize=clone:GetBoundingBox()
    clone:PivotTo(CFrame.new(position.X,position.Y+newSize.Y*.5,position.Z))
    clone:SetAttribute("DZ_PreviewRole",key)
    return clone
end

function M.Preview()
    assert(RunService:IsStudio() and not RunService:IsRunning(),"Réservé à Studio en mode ÉDITION")
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    if not world then return false,"DZ_RECOVERY_WORLD absent. Générer la map avant." end
    local staging=pool()
    local view=world:FindFirstChild(PREVIEW_NAME)
    if view then return true,"prévisualisation déjà créée" end
    view=Instance.new("Folder")
    view.Name=PREVIEW_NAME
    view.Parent=world
    local count=0
    for _,item in ipairs(TARGETS) do
        local src=staging:FindFirstChild(item.key)
        if src and src:GetAttribute("DZ_Approved")==true then
            local ok,err=pcall(function()
                putModel(view,src,item.key,item.x,item.z,item.width,item.rotation)
            end)
            if ok then count+=1 else warn("[DZ CREATOR] "..item.key..": "..tostring(err)) end
        end
    end
    local people=world:FindFirstChild("Personnages")
    if people then
        for key,name in pairs(NPCS) do
            local src=staging:FindFirstChild(key)
            local npc=people:FindFirstChild(name)
            local head=npc and npc:FindFirstChild("Tete")
            if src and head and src:GetAttribute("DZ_Approved")==true then
                local ok,err=pcall(function()
                    modelAtLocation(src,key,view,head.Position+Vector3.new(0,-5.3,0),6)
                end)
                if ok then count+=1 else warn("[DZ CREATOR] NPC "..name.." : "..tostring(err)) end
            end
        end
    end
    report(count.." visuels en aperçu. Les anciens modèles et prompts sont conservés.")
    return true,count
end

function M.List()
    for _,item in ipairs(Catalog) do
        local src=pool():FindFirstChild(item.key)
        local state=src and (src:GetAttribute("DZ_Approved") and "approuvé" or "à examiner") or "absent"
        report(item.key.." | "..tostring(item.id).." | "..item.role.." | "..state)
    end
end

return M
