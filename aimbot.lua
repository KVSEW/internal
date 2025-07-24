-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Settings
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local AimbotEnabled = false
local TeamCheck = true
local AimParts = {"Head", "HumanoidRootPart", "LeftArm", "RightLeg"}
local Smoothness = 1.0 -- Valor entre 0.05 (mais rápido) e 1 (mais lento)

-- Config
local TOGGLE_KEY = Enum.KeyCode.Q

-- Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        AimbotEnabled = not AimbotEnabled
        print("Aimbot: " .. (AimbotEnabled and "Ativado" or "Desativado"))
    end
end)

-- Visibilidade
local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (part.Position - origin).Unit * 500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})

    return hit and hit:IsDescendantOf(part.Parent)
end

-- Alvo mais próximo
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.Humanoid.Health > 0 then
                if not TeamCheck or player.Team ~= LocalPlayer.Team then
                    local partName = AimParts[math.random(1, #AimParts)]
                    local part = player.Character:FindFirstChild(partName)
                    if part and IsVisible(part) then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude

                            if distance < shortestDistance then
                                shortestDistance = distance
                                closest = part
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

-- Aimbot loop com suavização
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local targetPart = GetClosestPlayer()
        if targetPart then
            local targetPos = targetPart.Position
            local direction = (targetPos - Camera.CFrame.Position).Unit
            local newLook = Camera.CFrame.Position + direction

            -- Suavização aplicada à rotação da câmera
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, newLook), Smoothness)
        end
    end
end)
