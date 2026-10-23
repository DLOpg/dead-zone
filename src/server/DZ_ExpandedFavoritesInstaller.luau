-- DEAD ZONE | Expanded Favorites V1
-- Import/placement des 22 favoris donnes par le createur.
-- Studio Command Bar (EDIT, PAS Play): require(game.ServerScriptService.DZ_ExpandedFavoritesInstaller).Install()
-- Les assets inconnus ne sont pas devines : classification via noms/metadata.
-- Ne supprime aucun batiment, aucune quete, aucun PNJ d'origine.
local RunService=game:GetService("RunService")
local InsertService=game:GetService("InsertService")
local MarketplaceService=game:GetService("MarketplaceService")
local ServerStorage=game:GetService("ServerStorage")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Catalog=require(ReplicatedStorage:WaitForChild("DZ_ExpandedFavoritesCatalog"))
local M={}
local LIB="DZ_EXPANDED_FAVORITES_LIBRARY"
local VISUAL="DZ_EXPANDED_FAVORITES_V1"
local META="DZ_ExpandedFavoritesReport"
local MAX_PARTS=1800

local function edit()
    assert(RunService:IsStudio() and not RunService:IsRunning(),
        "DZ: Commande disponible seulement dans Roblox Studio en mode EDITION.")
end
local function say(s)
    print("[DZ FAVORIS 22] "..s)
end
local function folder(parent,name)
    local f=parent:FindFirstChild(name)
    if not f then f=Instance.new("Folder");f.Name=name;f.Parent=parent end
    return f
end
local function parts(model)
    local n=0
    for _,x in ipairs(model:GetDescendants()) do
        if x:IsA("BasePart") then n+=1 end
    end
    return n
end
local function clean(root)
    local removed=0
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("LuaSourceContainer") or v:IsA("RemoteEvent")
            or v:IsA("RemoteFunction") or v:IsA("BindableEvent")
            or v:IsA("BindableFunction") or v:IsA("ProximityPrompt")
            or v:IsA("ClickDetector") then
            v:Destroy()
            removed+=1
        elseif v:IsA("BasePart") then
            v.Anchored=true
            v.CanCollide=false
            v.CanTouch=false
            v.CanQuery=false
        elseif v:IsA("Sound") then
            v.Playing=false
        elseif v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
            v.Enabled=false
        end
    end
    return removed
end
local function modelTitle(item,root)
    local name=nil
    local ok,res=pcall(function()
        return MarketplaceService:GetProductInfo(item.id,Enum.InfoType.Asset)
    end)
    if ok and type(res)=="table" and type(res.Name)=="string" and #res.Name>1 then
        name=res.Name
    end
    if not name and root then
        for _,v in ipairs(root:GetDescendants()) do
            if v:IsA("Model") and v.Name~="Model" and v.Name~="Part" then
                name=v.Name
                break
            end
        end
    end
    return name or ("Asset "..tostring(item.id))
end
local function classify(name)
    local text=string.lower(name)
    local function has(...)
        for _,s in ipairs({...}) do
            if string.find(text,s,1,true) then return true end
        end
        return false
    end
    if has("police","sheriff","precinct","commissariat","policía","polizei") then return "police" end
    if has("medic","medical","hospital tent","infirm","ambulance","first aid","clinic","doctor") then return "medical" end
    if has("farm","barn","grange","ferme","ranch","silo","stable") then return "farm" end
    if has("house","maison","cottage","cabin","village home","residential") then return "house" end
    if has("tree","forest","pine","oak","fir","sapin","arbre","foliage","bush") then return "trees" end
    if has("npc","survivor","civilian","person","avatar","human","citizen","zombie","character") then return "npc" end
    if has("pistol","gun","weapon","rifle","knife","revolver","shotgun","arme") then return "weapon" end
    if has("motorcycle","bike","car","truck","vehicle","van","jeep","voiture") then return "vehicle" end
    if has("fence","barrier","barricade","crate","barrel","trash","debris","ruin","prop","furniture","decor","tent","tente","road") then return "props" end
    return "unknown"
end
local function load(item)
    local stock=folder(ServerStorage,LIB)
    local previous=stock:FindFirstChild(item.key)
    if previous then return previous,"cached" end
    local sources=nil
    -- GetObjects est disponible dans certains contextes Studio Edition.
    local ok,obj=pcall(function()
        return game:GetObjects("rbxassetid://"..tostring(item.id))
    end)
    if ok and type(obj)=="table" and #obj>0 then
        sources=obj
    else
        local ok2,obj2=pcall(function()
            return InsertService:LoadAsset(item.id)
        end)
        if ok2 and obj2 then sources={obj2} end
    end
    if not sources then return nil,"permission refusée ou asset indisponible" end
    local root=Instance.new("Model")
    root.Name=item.key
    for _,source in ipairs(sources) do
        source.Parent=root
    end
    local amount=parts(root)
    if amount==0 or amount>MAX_PARTS then
        root:Destroy()
        return nil,"modèle vide ou trop lourd ("..amount.." pièces)"
    end
    local title=modelTitle(item,root)
    local removed=clean(root)
    root:SetAttribute("DZ_AssetId",tostring(item.id))
    root:SetAttribute("DZ_AssetTitle",title)
    root:SetAttribute("DZ_Class",item.category=="trees" and "trees" or classify(title))
    root:SetAttribute("DZ_PartCount",amount)
    root:SetAttribute("DZ_ScriptsRemoved",removed)
    root.Parent=stock
    return root,"importé "..amount.." pièces; "..removed.." éléments actifs retirés"
end
local cast=RaycastParams.new()
cast.FilterType=Enum.RaycastFilterType.Include
cast.FilterDescendantsInstances={Workspace.Terrain}
cast.IgnoreWater=true
local function ground(x,z)
    local hit=Workspace:Raycast(Vector3.new(x,220,z),Vector3.new(0,-330,0),cast)
    return hit and hit.Position.Y or 6
end

-- Places connues Green Valley, en studs. Les ajouts sont additifs.
local sites={
    police={{x=105,z=-68,w=30,a=5},{x=84,z=182,w=26,a=-12}},
    medical={{x=-90,z=-10,w=13,a=0},{x=-64,z=-27,w=13,a=-12}},
    farm={{x=-177,z=-145,w=29,a=0},{x=-153,z=-175,w=23,a=12}},
    house={{x=-125,z=135,w=27,a=0},{x=-178,z=112,w=22,a=8},{x=17,z=151,w=20,a=-8}},
    npc={{x=-117,z=-15,w=5,a=0},{x=-83,z=-16,w=5,a=0},{x=-102,z=-69,w=5,a=0}},
    vehicle={{x=-26,z=67,w=8,a=90},{x=67,z=-68,w=8,a=55}},
    props={{x=-136,z=-22,w=5,a=13},{x=-74,z=-47,w=5,a=-25},{x=8,z=-102,w=5,a=45},
        {x=-43,z=68,w=5,a=10},{x=71,z=-66,w=5,a=-10},{x=144,z=56,w=5,a=0}},
    weapon={},trees={},
}
local function createVisual(where,item,source,site,label)
    local new=Instance.new("Model")
    new.Name=label
    local copy=source:Clone()
    copy.Parent=new
    clean(new)
    new.Parent=where
    local ok,_,size=pcall(function() return new:GetBoundingBox() end)
    if not ok or size.Y<.1 then new:Destroy() return false end
    local maxdim=math.max(size.X,size.Z,.1)
    local scale=math.clamp(site.w/maxdim,.10,4)
    local success=pcall(function() new:ScaleTo(scale) end)
    if not success then new:Destroy() return false end
    local boxCf,bounds=new:GetBoundingBox()
    local y=ground(site.x,site.z)
    local desired=CFrame.new(site.x,y+bounds.Y/2,site.z)*CFrame.Angles(0,math.rad(site.a or 0),0)
    new:PivotTo(desired*boxCf:Inverse()*new:GetPivot())
    new:SetAttribute("DZ_AssetId",tostring(item.id))
    new:SetAttribute("DZ_Category",source:GetAttribute("DZ_Class"))
    new:SetAttribute("DZ_CreatorName",source:GetAttribute("DZ_AssetTitle"))
    return true
end
local function cacheWeapon(source,key)
    local visualFolder=folder(ServerStorage,"DZ_V5_WEAPON_VISUALS")
    local name="DZ_Favorite_"..key
    if visualFolder:FindFirstChild(name) then return true end
    local gun=Instance.new("Model")
    gun.Name=name
    for _,part in ipairs(source:GetDescendants()) do
        if part:IsA("MeshPart") or (part:IsA("BasePart") and part.Name=="Handle") then
            local partClone=part:Clone()
            partClone.Anchored=false
            partClone.CanCollide=false
            partClone.Massless=true
            partClone.Parent=gun
            break
        end
    end
    if parts(gun)==0 then gun:Destroy();return false end
    gun.Parent=visualFolder
    return true
end
local function placementArea(world)
    return folder(world,VISUAL)
end
function M.Install()
    edit()
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    if not world then
        warn("[DZ FAVORIS 22] Monde Green Valley absent. Arrête Play et restaure ta map.")
        return false
    end
    local locations=placementArea(world)
    local counters={}
    local successes,refusals,unclassified=0,0,0
    local library=folder(ServerStorage,LIB)
    -- Reutiliser les arbres deja presents dans le projet : pas de doublon.
    local oldTreeId="3256343670"
    local reportLines={}
    for _,item in ipairs(Catalog) do
        if tostring(item.id)==oldTreeId then
            table.insert(reportLines,"3256343670 | arbres deja installes par DZ_RealForestV2")
        else
            local model,reason=load(item)
            if not model then
                refusals+=1
                table.insert(reportLines,tostring(item.id).." | REFUS | "..reason)
                warn("[DZ FAVORIS 22] "..item.id.." : "..reason)
            else
                successes+=1
                local category=model:GetAttribute("DZ_Class") or "unknown"
                local name=model:GetAttribute("DZ_AssetTitle") or "asset inconnu"
                local target=sites[category]
                local n=counters[category] or 0
                local state="stocké, classification à valider"
                if category=="weapon" then
                    state=cacheWeapon(model,item.key) and "visuel arme mis en reserve" or "arme reserve"
                elseif category=="trees" then
                    -- La foret V2 exploite deja le pack d'arbres original.
                    state="arbres en réserve (pas de pack dupliqué)"
                elseif target and #target>0 and n<#target then
                    local point=target[n+1]
                    local tag="DZ_"..category.."_"..item.key
                    if locations:FindFirstChild(tag) then
                        state="deja place"
                    else
                        local ok,placed=pcall(function()
                            return createVisual(locations,item,model,point,tag)
                        end)
                        if ok and placed then state="place : "..category
                        else state="en réserve (placement impossible)" end
                    end
                    counters[category]=n+1
                else
                    unclassified+=1
                end
                table.insert(reportLines,tostring(item.id).." | "..name.." | "..category.." | "..state)
                say(item.id.." | "..name.." | "..state)
            end
        end
    end
    local report=ServerStorage:FindFirstChild(META)
    if not report then report=Instance.new("StringValue");report.Name=META;report.Parent=ServerStorage end
    report.Value=table.concat(reportLines,"\n")
    world:SetAttribute("DZ_ExpandedFavoritesImported",successes)
    world:SetAttribute("DZ_ExpandedFavoritesRefused",refusals)
    say("Terminé : "..successes.." imports, "..refusals.." refus, "..unclassified.." modèles en réserve.")
    say("Rapport complet : ServerStorage/"..META)
    return successes>0
end
function M.Report()
    local record=ServerStorage:FindFirstChild(META)
    if not record then say("Aucun rapport. Lance Install()."); return end
    print(record.Value)
end
function M.Restore()
    edit()
    local world=Workspace:FindFirstChild("DZ_RECOVERY_WORLD")
    local folderToRemove=world and world:FindFirstChild(VISUAL)
    if folderToRemove then folderToRemove:Destroy() end
    say("Décors ajoutés par ce module retirés ; bibliothèque en ServerStorage conservée.")
end
return M
