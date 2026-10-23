local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Rep=game:GetService('ReplicatedStorage')
local evt=Rep:WaitForChild('DZ_RecoveryEvent')
local world=workspace:WaitForChild('DZ_RECOVERY_WORLD')
local function init(pl)
 pl:SetAttribute('DZHealth',100);pl:SetAttribute('DZHunger',100);pl:SetAttribute('DZThirst',100)
 pl:SetAttribute('DZFood',0);pl:SetAttribute('DZWater',0);pl:SetAttribute('DZWood',0);pl:SetAttribute('DZMetal',0)
 pl:SetAttribute('DZQuest','Fouille la ferme : récupère eau et nourriture.')
end
Players.PlayerAdded:Connect(init)
for _,pl in ipairs(Players:GetPlayers()) do init(pl) end
for _,v in ipairs(world:GetDescendants()) do
 if v:IsA('ProximityPrompt') then
  v.Triggered:Connect(function(pl)
   local p=v.Parent
   if p:GetAttribute('DZType')=='NPC' then
    evt:FireClient(pl,'Dialogue',v.ObjectText..' : '..(p:GetAttribute('DZMessage') or 'Bonjour.'))
    if v.ObjectText=='Marcus Hale' then
     pl:SetAttribute('DZQuest','Parle à Ethan, à son atelier.');evt:FireClient(pl,'Dialogue','Marcus : Bienvenue à Camp Haven. Retrouve Ethan à l atelier.')
    elseif v.ObjectText=='Ethan Brooks' then
     pl:SetAttribute('DZQuest','Explore Green Valley, retrouve du bois et de la ferraille.')
    end
   elseif p:GetAttribute('DZType')=='LOOT' then
    local item=p:GetAttribute('DZItem')
    local key=({Nourriture='DZFood',Eau='DZWater',Bois='DZWood',Ferraille='DZMetal'})[item]
    if key then pl:SetAttribute(key,(pl:GetAttribute(key) or 0)+1) end
    evt:FireClient(pl,'Dialogue','Récupéré : '..tostring(item))
    if (pl:GetAttribute('DZFood') or 0)>0 and (pl:GetAttribute('DZWater') or 0)>0 then
     if string.find(pl:GetAttribute('DZQuest') or '','Fouille la ferme',1,true) then
      pl:SetAttribute('DZQuest','Rejoins Marcus à Camp Haven et parle-lui.')
     end
    end
   end
  end)
 end
end
local spots={Camp=Vector3.new(-105,15,-45),Farm=Vector3.new(-190,15,-170)}
evt.OnServerEvent:Connect(function(pl,action)
 if action=='Attack' then
  evt:FireClient(pl,'Dialogue','Attaque de test : les zombies seront ajoutés au prochain lot.')
 elseif RunService:IsStudio() and type(action)=='string' then
  if action=='Heal' then
   pl:SetAttribute('DZHealth',100);pl:SetAttribute('DZHunger',100);pl:SetAttribute('DZThirst',100)
  elseif action=='Supplies' then
   for _,a in ipairs({'DZFood','DZWater','DZWood','DZMetal'}) do pl:SetAttribute(a,(pl:GetAttribute(a) or 0)+5) end
  elseif spots[action] and pl.Character then
   pl.Character:PivotTo(CFrame.new(spots[action]))
  end
 end
end)
task.spawn(function()
 while true do
  task.wait(15)
  for _,pl in ipairs(Players:GetPlayers()) do
   pl:SetAttribute('DZHunger',math.max(0,(pl:GetAttribute('DZHunger') or 100)-1))
   pl:SetAttribute('DZThirst',math.max(0,(pl:GetAttribute('DZThirst') or 100)-2))
  end
 end
end)
print('[DZ SECOURS] Serveur prêt : PNJ, ressources, mode creatif.')
