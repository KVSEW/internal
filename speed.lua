local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local speedEnabled = false

local normalSpeed = 16 -- velocidade padrão do Roblox
local boostedSpeed = 50 -- velocidade quando ativado

local toggleKey = Enum.KeyCode.L -- tecla para ligar/desligar

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == toggleKey then
        speedEnabled = not speedEnabled
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if speedEnabled then
                humanoid.WalkSpeed = boostedSpeed
                print("Speed ativada!")
            else
                humanoid.WalkSpeed = normalSpeed
                print("Speed desativada!")
            end
        end
    end
end)

-- Garantir que ao spawnar o personagem a velocidade volte ao normal
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    if speedEnabled then
        humanoid.WalkSpeed = boostedSpeed
    else
        humanoid.WalkSpeed = normalSpeed
    end
end)
