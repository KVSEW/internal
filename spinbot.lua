ts doesnt have a interface, soo you can control the velocity on the own script


local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Configuração da velocidade (em rad/s)
local spinSpeedDegreesPerSecond = 180 -- 180 graus por segundo (meio giro por segundo)
local spinSpeedRad = math.rad(spinSpeedDegreesPerSecond)

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Remove spin antigo se existir
if hrp:FindFirstChild("SpinBotAngularVelocity") then
    hrp.SpinBotAngularVelocity:Destroy()
end

local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
BodyAngularVelocity.Name = "SpinBotAngularVelocity"
BodyAngularVelocity.Parent = hrp
BodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0) -- só gira no eixo Y
BodyAngularVelocity.AngularVelocity = Vector3.new(0, spinSpeedRad, 0)
