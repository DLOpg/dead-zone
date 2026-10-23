local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local pl=Players.LocalPlayer
local gui=pl:WaitForChild('PlayerGui'):WaitForChild('DZ_RecoveryHUD')
local Rep=game:GetService('ReplicatedStorage')
local evt=Rep:WaitForChild('DZ_RecoveryEvent')
local stats=gui:WaitForChild('Status');local quest=gui:WaitForChild('Mission');local dialog=gui:WaitForChild('Dialogue')
local function update()
 stats.Text='DEAD ZONE • GREEN VALLEY\nSanté '..tostring(pl:GetAttribute('DZHealth') or 100)..' | Faim '..tostring(pl:GetAttribute('DZHunger') or 100)..' | Soif '..tostring(pl:GetAttribute('DZThirst') or 100)..'\nEau '..tostring(pl:GetAttribute('DZWater') or 0)..' • Nourriture '..tostring(pl:GetAttribute('DZFood') or 0)..' • Bois '..tostring(pl:GetAttribute('DZWood') or 0)..' • Ferraille '..tostring(pl:GetAttribute('DZMetal') or 0)
 quest.Text='MISSION\n'..tostring(pl:GetAttribute('DZQuest') or 'Survis dans la vallée.')
end
for _,attr in ipairs({'DZHealth','DZHunger','DZThirst','DZWater','DZFood','DZWood','DZMetal','DZQuest'}) do
 pl:GetAttributeChangedSignal(attr):Connect(update)
end
update()
evt.OnClientEvent:Connect(function(kind,message) if kind=='Dialogue' then dialog.Text=message end end)
UIS.InputBegan:Connect(function(key,processed)
 if processed then return end
 if key.KeyCode==Enum.KeyCode.F6 then gui.Creative.Visible=not gui.Creative.Visible end
 if key.KeyCode==Enum.KeyCode.F then evt:FireServer('Attack') end
end)
for _,name in ipairs({'Heal','Supplies','Camp','Farm'}) do
 gui.Creative[name].Activated:Connect(function() evt:FireServer(name) end)
end
print('[DZ SECOURS] HUD client actif, F6 disponible.')
