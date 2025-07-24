local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Função para forçar terceira pessoa e zoom
local function ForceThirdPerson()
    pcall(function()
        StarterPlayer.CameraMode = Enum.CameraMode.Classic
        UserGameSettings.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end)

    LocalPlayer.CameraMaxZoomDistance = 10
    LocalPlayer.CameraMinZoomDistance = 5

    Camera.CameraType = Enum.CameraType.Custom
end

-- Função para esconder partes bugadas (armas e braços)
local function HideBuggedParts()
    -- Esconde braços do personagem
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():find("arm") or part.Name:lower():find("viewmodel")) then
                part.LocalTransparencyModifier = 1
                part.CastShadow = false
            end
        end
    end

    -- Esconde ViewModels que o jogo renderiza na câmera (ex: armas)
    for _, obj in pairs(Camera:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():find("viewmodel") then
            obj:Destroy()
        end
    end
end

-- Função principal que aplica tudo
local function ApplyFixes()
    ForceThirdPerson()

    RunService.RenderStepped:Connect(function()
        ForceThirdPerson()
        HideBuggedParts()
    end)
end

-- Executa ao spawnar
if LocalPlayer.Character then
    ApplyFixes()
end

LocalPlayer.CharacterAdded:Connect(function(char)
    repeat task.wait() until char:FindFirstChild("Humanoid")
    ApplyFixes()
end)
