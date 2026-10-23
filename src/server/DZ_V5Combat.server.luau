-- DEAD ZONE V5 / infectes + equipement de test
-- Serveur autoritaire, compatible avec la carte DZ_RECOVERY_WORLD.
-- Prototype: 8 infectes, couteau (F) et pistolet (clic quand equipe).
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local GAME_FOLDER="DZ_V5_GAMEPLAY"
local weaponEvent=ReplicatedStorage:FindFirstChild("DZ_V5WeaponEvent")
if not weaponEvent then
    weaponEvent=Instance.new("RemoteEvent")
    weaponEvent.Name="DZ_V5WeaponEvent"
    weaponEvent.Parent=ReplicatedStorage
end

local creatures={}
local attackTimes={}
local zombieHits={}
local MAX_ZOMBIES=9
local SPAWNS={
    {25,-115},{70,-110},{170,50},{95,150},{-60,145},
    {-165,87},{-225,-90},{165,-185},{-35,-202},
}
local rng=Random.new(20375)
local root=Workspace:FindFirstChild(GAME_FOLDER)
if not root then
    root=Instance.new("Folder")
    root.Name=GAME_FOLDER
    root.Parent=Workspace
end
local zombieFolder=root:FindFirstChild("Infectes")
if not zombieFolder then
    zombieFolder=Instance.new("Folder")
    zombieFolder.Name="Infectes"
    zombieFolder.Parent=root
end

local function terrainY(x,z)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances={Workspace.Terrain}
    params.IgnoreWater=true
    local h=Workspace:Raycast(Vector3.new(x,150,z),Vector3.new(0,-230,0),params)
    return h and h.Position.Y or 7
end
local function bodyPart(model,name,offset,size,color,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.Color=color
    p.Material=Enum.Material.Fabric
    p.Shape=shape or Enum.PartType.Block
    p.CFrame=model:GetPivot()*CFrame.new(offset)
    p.Parent=model
    return p
end
local function createZombie(i)
    local spot=SPAWNS[i]
    local x,z=spot[1]+rng:NextNumber(-6,6),spot[2]+rng:NextNumber(-6,6)
    local y=terrainY(x,z)
    local m=Instance.new("Model")
    m.Name="Infecte_"..i
    m.Parent=zombieFolder
    m:PivotTo(CFrame.new(x,y+3,z))
    local fast=i%3==0
    m:SetAttribute("DZ_Zombie",true)
    m:SetAttribute("Health",fast and 65 or 95)
    m:SetAttribute("Fast",fast)
    m:SetAttribute("Speed",fast and 7.5 or 4.3)
    local torso=bodyPart(m,"Torso",Vector3.new(0,0,0),
        Vector3.new(2.1,3,1.2),fast and Color3.fromRGB(77,64,61) or Color3.fromRGB(85,96,77))
    local head=bodyPart(m,"Head",Vector3.new(0,2.4,0),
        Vector3.new(1.7,1.7,1.7),Color3.fromRGB(124,137,108),Enum.PartType.Ball)
    bodyPart(m,"LeftArm",Vector3.new(-1.5,.1,-.3),
        Vector3.new(.75,2.9,.85),Color3.fromRGB(118,123,101))
    bodyPart(m,"RightArm",Vector3.new(1.5,.1,-.3),
        Vector3.new(.75,2.9,.85),Color3.fromRGB(115,128,100))
    for _,side in ipairs({-1,1}) do
        bodyPart(m,"Leg",Vector3.new(side*.57,-2.4,0),
            Vector3.new(.82,2,.9),Color3.fromRGB(57,61,59))
    end
    m.PrimaryPart=torso
    local billboard=Instance.new("BillboardGui")
    billboard.Name="DZHealthIndicator"
    billboard.Adornee=head
    billboard.Size=UDim2.fromOffset(65,10)
    billboard.StudsOffset=Vector3.new(0,1.6,0)
    billboard.AlwaysOnTop=true
    billboard.MaxDistance=38
    billboard.Parent=head
    local bg=Instance.new("Frame")
    bg.Size=UDim2.fromScale(1,1)
    bg.BackgroundColor3=Color3.fromRGB(33,37,35)
    bg.BorderSizePixel=0
    bg.Parent=billboard
    local bar=Instance.new("Frame")
    bar.Name="Bar"
    bar.Size=UDim2.fromScale(1,1)
    bar.BackgroundColor3=Color3.fromRGB(150,80,68)
    bar.BorderSizePixel=0
    bar.Parent=bg
    creatures[m]={spawn=Vector3.new(x,y+3,z),state="roam",lastStrike=0,lastStep=0,maxHP=m:GetAttribute("Health"),bar=bar}
    return m
end

local function damageZombie(player,zombie,amount)
    local data=creatures[zombie]
    if not data or not zombie.Parent then return end
    local hp=math.max(0,(zombie:GetAttribute("Health") or 0)-amount)
    zombie:SetAttribute("Health",hp)
    data.bar.Size=UDim2.fromScale(hp/data.maxHP,1)
    if hp==0 then
        creatures[zombie]=nil
        zombie:Destroy()
        local kills=(player:GetAttribute("DZZombieKills") or 0)+1
        player:SetAttribute("DZZombieKills",kills)
    end
end

local function getPlayerRoot(player)
    local ch=player.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health<=0 then return nil end
    return hrp,hum,ch
end
local function closestZombie(position,maxRange)
    local found,dist=nil,maxRange
    for m in pairs(creatures) do
        if m.PrimaryPart and m.Parent then
            local d=(m.PrimaryPart.Position-position).Magnitude
            if d<dist then found,dist=m,d end
        end
    end
    return found
end

local function equipTool(player,name)
    local backpack=player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild(name) or (player.Character and player.Character:FindFirstChild(name)) then return end
    local t=Instance.new("Tool")
    t.Name=name
    t.RequiresHandle=false
    t.CanBeDropped=false
    t.ToolTip=name=="DZ_Pistolet" and "Clic pour tirer | 12 munitions" or "F ou clic pour frapper"
    t.Parent=backpack
end
local function giveTools(player)
    equipTool(player,"DZ_Couteau")
    equipTool(player,"DZ_Pistolet")
    if player:GetAttribute("DZAmmo") == nil then player:SetAttribute("DZAmmo",12) end
end
local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if player.Parent then giveTools(player) end
    end)
    task.defer(giveTools,player)
end
Players.PlayerAdded:Connect(setupPlayer)
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

local function onAttack(player,action,lookDir)
    if action~="Knife" and action~="Pistol" then return end
    local hrp,_,ch=getPlayerRoot(player)
    if not hrp then return end
    local now=os.clock()
    local delayTime=action=="Pistol" and .36 or .55
    attackTimes[player]=attackTimes[player] or 0
    if now-attackTimes[player]<delayTime then return end
    if action=="Pistol" and not ch:FindFirstChild("DZ_Pistolet") then return end
    attackTimes[player]=now
    if action=="Knife" then
        local target=closestZombie(hrp.Position,8.5)
        if target then damageZombie(player,target,34) end
        return
    end
    local ammo=player:GetAttribute("DZAmmo") or 0
    if ammo<1 then weaponEvent:FireClient(player,"Message","Pistolet : plus de munitions.") return end
    player:SetAttribute("DZAmmo",ammo-1)
    if typeof(lookDir)~="Vector3" or lookDir.Magnitude<.9 or lookDir.Magnitude>1.1 then return end
    local origin=hrp.Position+Vector3.new(0,1.6,0)
    local direction=lookDir.Unit
    -- Interdit les tirs très en arrière du corps, mais reste tolérant en TPS.
    if direction:Dot(hrp.CFrame.LookVector)<-.65 then return end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={ch}
    params.IgnoreWater=true
    local hit=Workspace:Raycast(origin,direction*110,params)
    local hitPart=hit and hit.Instance
    local zombie=hitPart and hitPart:FindFirstAncestorOfClass("Model")
    if zombie and creatures[zombie] then damageZombie(player,zombie,hitPart.Name=="Head" and 72 or 42) end
end
weaponEvent.OnServerEvent:Connect(onAttack)

local tickCount=0
RunService.Heartbeat:Connect(function(dt)
    tickCount+=dt
    if tickCount<.13 then return end
    local elapsed=math.min(tickCount,.25)
    tickCount=0
    for model,data in pairs(creatures) do
        if model.Parent and model.PrimaryPart then
            local here=model.PrimaryPart.Position
            local target,nearest=nil,70
            for _,p in ipairs(Players:GetPlayers()) do
                local hrp=getPlayerRoot(p)
                if hrp then
                    local d=(hrp.Position-here).Magnitude
                    if d<nearest then target,nearest=hrp,d end
                end
            end
            if target and nearest>4 then
                local horizontal=Vector3.new(target.Position.X-here.X,0,target.Position.Z-here.Z)
                if horizontal.Magnitude>.1 then
                    local delta=horizontal.Unit*math.min(horizontal.Magnitude,model:GetAttribute("Speed")*elapsed)
                    local newX,newZ=here.X+delta.X,here.Z+delta.Z
                    local y=terrainY(newX,newZ)+3
                    local point=Vector3.new(newX,y,newZ)
                    model:PivotTo(CFrame.lookAt(point,point+horizontal.Unit))
                end
            elseif target and nearest<=4 and os.clock()-data.lastStrike>=1.7 then
                data.lastStrike=os.clock()
                local char=target.Parent
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:TakeDamage(data.maxHP<70 and 11 or 8) end
            end
        end
    end
end)

for i=1,MAX_ZOMBIES do createZombie(i) end
Players.PlayerRemoving:Connect(function(player) attackTimes[player]=nil end)
print("[DZ V5 COMBAT] "..MAX_ZOMBIES.." infectés, couteau et pistolet de test actifs.")
