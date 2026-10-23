-- DEAD ZONE / Favoris Roblox - intégration en une seule commande, mode édition uniquement.
-- Les modèles ne sont pas stockés sur GitHub: cette commande les importe dans la place Roblox.
-- Sur les échecs de permissions, conserve les décors précédents sans les effacer.
local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Catalog = require(ReplicatedStorage:WaitForChild("DZ_UserFavoritesCatalog"))
local M = {}
local LIB = "DZ_FAVORITES_LIBRARY"
local VIEW = "DZ_FAVORITES_VISUALS"

local function log(s) print("[DZ FAVORIS] "..s) end
local function contain(parent,name)
    local f=parent:FindFirstChild(name)
    if not f then f=Instance.new("Folder"); f.Name=name; f.Parent=parent end
    return f
end

local function sanitize(root)
    local removed=0
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("LuaSourceContainer") or v:IsA("RemoteEvent") or v:IsA("RemoteFunction")
            or v:IsA("BindableEvent") or v:IsA("BindableFunction")
            or v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
            if v:IsA("LuaSourceContainer") then removed+=1 end
            v:Destroy()
        elseif v:IsA("BasePart") then
            v.Anchored=true
            v.CanCollide=false
            v.CanTouch=false
            v.CanQuery=false
        elseif v:IsA("Sound") then
            v.Playing=false
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled=false
        end
    end
    return removed
end

local function numberParts(model)
    local n=0
    for _,v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then n+=1 end
    end
    return n
end

local function load(item)
    local library=contain(ServerStorage,LIB)
    local old=library:FindFirstChild(item.key)
    if old then return old,"already imported" end

    local created,errors=nil,{}
    -- GetObjects is available in Studio edit contexts, depending on permissions.
    local ok,a=pcall(function() return game:GetObjects("rbxassetid://"..tostring(item.id)) end)
    if ok and type(a)=="table" and #a>0 then
        created=Instance.new("Model")
        created.Name=item.key
        for _,object in ipairs(a) do object.Parent=created end
    else
        table.insert(errors,"GetObjects: "..tostring(a))
    end
    if not created then
        local success,value=pcall(function() return InsertService:LoadAsset(item.id) end)
        if success and value then created=value;created.Name=item.key
        else table.insert(errors,"InsertService: "..tostring(value)) end
    end
    if not created then return nil,table.concat(errors," | ") end

    local count=numberParts(created)
    if count==0 or count>3000 then
        created:Destroy()
        return nil,"model size rejected ("..count.." pieces)"
    end
    local scripts=sanitize(created)
    created.Name=item.key
    created:SetAttribute("DZ_FavoriteId",tostring(item.id))
    created:SetAttribute("DZ_Parts",count)
    created:SetAttribute("DZ_RemovedScripts",scripts)
    created.Parent=library
    return created,"imported "..count.." parts, "..scripts.." scripts removed"
end

local function gY(x,z)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances={Workspace.Terrain}
    params.IgnoreWater=true
    local r=Workspace:Raycast(Vector3.new(x,250,z),Vector3.new(0,-360,0),params)
    return r and r.Position.Y or 6
end

local function modelFromAsset(asset)
    local m=Instance.new("Model")
    m.Name=asset.Name.."_visual"
    -- Children rather than the container model lets us scale all of the asset
    -- while keeping the original untouched.
    local cloned=asset:Clone()
    cloned.Parent=m
    return m
end

local function visual(parent,asset,name,x,z,span,angle)
    if parent:FindFirstChild(name) then return parent[name] end
    local m=modelFromAsset(asset)
    m.Name=name
    sanitize(m)
    m.Parent=parent
    local _,size=m:GetBoundingBox()
    local biggest=math.max(size.X,size.Z,0.1)
    local scale=math.clamp(span/biggest,.12,6)
    pcall(function() m:ScaleTo(scale) end)
    local boxCf,now=m:GetBoundingBox()
    local y=gY(x,z)
    local target=CFrame.new(x,y+now.Y/2,z)*CFrame.Angles(0,math.rad(angle or 0),0)
    m:PivotTo(target*boxCf:Inverse()*m:GetPivot())
    return m
end

local function hideOriginalBuilding(world, buildingName)
    local buildings=world:FindFirstChild("Batiments")
    local original=buildings and buildings:FindFirstChild(buildingName)
    if not original then return end
    for _,part in ipairs(original:GetDescendants()) do
        if part:IsA("BasePart") and part.Name~="Plancher" then
            if part:GetAttribute("DZ_OldTransparency")==nil then
                part:SetAttribute("DZ_OldTransparency",part.Transparency)
            end
            part.Transparency=1
            -- Les anciennes collisions restent en place pour protéger l'intérieur.
        end
    end
end

local function firstRenderable(root)
    -- For a pack of varied tree models, prefer independent children; if there
    -- aren't any, use the asset container as one variation.
    local candidates={}
    for _,child in ipairs(root:GetDescendants()) do
        if child:IsA("Model") and child~=root and numberParts(child)>=1 then
            if child.Parent==root or child.Parent.Parent==root then
                table.insert(candidates,child)
            end
        end
    end
    if #candidates==0 then candidates={root} end
    local filtered={}
    for _,m in ipairs(candidates) do
        if numberParts(m)<=220 then table.insert(filtered,m) end
        if #filtered>=10 then break end
    end
    if #filtered==0 then return {root} end
    return filtered
end

local function vegetation(view,asset)
    local variants=firstRenderable(asset)
    local rng=Random.new(746984)
    local areas={
        {-219,-214},{-226,-155},{-214,-74},{-200,42},{-196,180},
        {-151,196},{-70,211},{18,215},{95,209},{202,186},
        {214,124},{204,22},{202,-75},{217,-185},{92,-210},
        {10,-211},{-66,-209},{-221,93},{-160,64},{117,175}
    }
    for i,pos in ipairs(areas) do
        local node=variants[(i-1)%#variants+1]
        local x=pos[1]+rng:NextNumber(-5,5)
        local z=pos[2]+rng:NextNumber(-5,5)
        visual(view,node,"DZ_tree_"..i,x,z,rng:NextNumber(10,17),rng:NextNumber(0,360))
    end
    return #areas
end

local function weaponVisual(asset)
    local template=contain(ServerStorage,"DZ_V5_WEAPON_VISUALS")
    if template:FindFirstChild("DZ_PistoletVisual") then return true,"weapon visual already stored" end
    local copy=asset:Clone()
    sanitize(copy)
    copy.Name="DZ_PistoletVisual"
    -- Don't equip a pack: select the MeshPart named Handle if present.
    -- Otherwise try the biggest MeshPart, or the first BasePart.
    local handle=copy:FindFirstChild("Handle",true)
    if not (handle and handle:IsA("BasePart")) then
        for _,v in ipairs(copy:GetDescendants()) do
            if v:IsA("MeshPart") then handle=v; break end
        end
    end
    if not handle then handle=copy:FindFirstChildWhichIsA("BasePart",true) end
    if not handle then return false,"no weapon mesh found" end
    local gun=Instance.new("Model")
    gun.Name="DZ_PistoletVisual"
    local h=handle:Clone()
    h.Name="Handle"
    h.Anchored=false
    h.CanCollide=false
    h.Massless=true
    h.Parent=gun
    gun.Parent=template
    return true,"weapon handle prepared (visual only)"
end

function M.Install()
    assert(RunService:IsStudio() and not RunService:IsRunning(),
        "Only run this command from Roblox Studio in Edit mode (Stop).")
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    if not world then
        warn("[DZ FAVORIS] DZ_RECOVERY_WORLD missing: open the working Green Valley place.")
        return false
    end
    local container=contain(world,VIEW)
    local success=0
    local blocked={}
    for _,item in ipairs(Catalog) do
        local asset,msg=load(item)
        if not asset then
            table.insert(blocked,item.key..": "..msg)
            warn("[DZ FAVORIS] Refused "..item.key..": "..msg)
        else
            log(item.key..": "..msg)
            local ok,err=pcall(function()
                if item.key=="horror_house_building" then
                    visual(container,asset,"DZ_HorrorHouse", -175,-145,30,0)
                    hideOriginalBuilding(world,"Ferme du reveil")
                elseif item.key=="village_house" then
                    visual(container,asset,"DZ_VillageHouse", -125,135,30,0)
                    hideOriginalBuilding(world,"Maison Miller")
                elseif item.key=="realistic_trees" then
                    vegetation(container,asset)
                elseif item.key=="pistol_visual" then
                    local ready,reason=weaponVisual(asset)
                    if not ready then error(reason) end
                end
            end)
            if ok then success+=1
            else
                warn("[DZ FAVORIS] Loaded but not placed "..item.key..": "..tostring(err))
            end
        end
    end
    world:SetAttribute("DZ_FavoritesImportCount",success)
    log(success.."/"..#Catalog.." assets prepared or placed.")
    if #blocked>0 then
        warn("[DZ FAVORIS] Asset permissions blocked "..#blocked.." items. No previous map content was deleted.")
    end
    return success>0
end

function M.Restore()
    assert(RunService:IsStudio() and not RunService:IsRunning(),
        "Restauration uniquement en mode Edition.")
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    if not world then return false end
    local buildings=world:FindFirstChild("Batiments")
    if buildings then
        for _,part in ipairs(buildings:GetDescendants()) do
            if part:IsA("BasePart") then
                local previous=part:GetAttribute("DZ_OldTransparency")
                if previous~=nil then
                    part.Transparency=previous
                    part:SetAttribute("DZ_OldTransparency",nil)
                end
            end
        end
    end
    local visuals=world:FindFirstChild(VIEW)
    if visuals then visuals:Destroy() end
    log("Anciens batiments retrouves ; visuels favoris retires.")
    return true
end

return M
