-- DEAD ZONE V5 - Controller d'armes pour le prototype
-- Le clic fonctionne seulement si une Tool correspondante est equipée.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local event=ReplicatedStorage:WaitForChild("DZ_V5WeaponEvent",30)
if not event then warn("[DZ V5] Remote armes absent.") return end

local function activate(tool)
    if tool.Name=="DZ_Couteau" then
        event:FireServer("Knife")
    elseif tool.Name=="DZ_Pistolet" then
        local camera=workspace.CurrentCamera
        if camera then event:FireServer("Pistol",camera.CFrame.LookVector) end
    end
end

local hooked={}
local function hook(tool)
    if not tool:IsA("Tool") or hooked[tool] then return end
    if tool.Name~="DZ_Couteau" and tool.Name~="DZ_Pistolet" then return end
    hooked[tool]=true
    tool.Activated:Connect(function() activate(tool) end)
    tool.Destroying:Connect(function() hooked[tool]=nil end)
end
local function watch(container)
    if not container then return end
    for _,object in ipairs(container:GetChildren()) do hook(object) end
    container.ChildAdded:Connect(hook)
end

local backpack=player:WaitForChild("Backpack")
watch(backpack)
player.CharacterAdded:Connect(watch)
if player.Character then watch(player.Character) end

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.F then event:FireServer("Knife") end
end)
event.OnClientEvent:Connect(function(kind,text)
    if kind=="Message" then
        local pg=player:FindFirstChildOfClass("PlayerGui")
        local gui=pg and pg:FindFirstChild("DZ_RecoveryHUD")
        local dialogue=gui and gui:FindFirstChild("Dialogue")
        if dialogue then dialogue.Text=tostring(text) end
    end
end)
print("[DZ V5] Commandes combat: F=couteau, clic avec pistolet équipé=tir.")
