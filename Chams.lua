local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 🟢 Configurações
local TransparencyLevel = 0.7 -- 0 = visível | 1 = invisível
local BodyColor = Color3.fromRGB(0, 255, 0) -- Cor desejada (verde aqui)

-- Função que aplica cor e transparência ao personagem
local function ApplyTransparency(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = TransparencyLevel
            part.Color = BodyColor
            part.Material = Enum.Material.ForceField
            part.Reflectance = 0
            part.CastShadow = false
        elseif part:IsA("Decal") then
            part.Transparency = 1 -- Esconde rostos/texturas
        end
    end
end

-- Aplica quando o personagem nascer
local function Setup()
    if LocalPlayer.Character then
        ApplyTransparency(LocalPlayer.Character)
    end
end

-- Aplica constantemente (manter aparência)
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        ApplyTransparency(LocalPlayer.Character)
    end
end)

-- Atualiza ao respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    repeat task.wait() until char:FindFirstChild("Humanoid")
    ApplyTransparency(char)
end)

-- Primeira aplicação
Setup()
