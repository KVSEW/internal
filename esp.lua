-- ESP com Caixa, Nome, Barra de Vida, Team Check, Skeleton e Círculo Inteligente na Cabeça
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "ESP: OFF"
ToggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 18

local espEnabled = false
local drawings = {}

local function createSkeletonLines()
    local parts = {}
    for _ = 1, 6 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Color = Color3.new(1, 1, 1)
        line.Visible = false
        table.insert(parts, line)
    end
    return parts
end

local function createESP(player)
    if player == LocalPlayer then return end

    local esp = {
        Name = Drawing.new("Text"),
        BoxLines = {},
        HealthBar = Drawing.new("Line"),
        Skeleton = createSkeletonLines(),
        HeadCircle = Drawing.new("Circle")
    }

    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Visible = false
    esp.Name.Text = player.Name

    for _ = 1, 4 do
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
        table.insert(esp.BoxLines, line)
    end

    esp.HealthBar.Thickness = 2
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Visible = false

    esp.HeadCircle.Radius = 5
    esp.HeadCircle.Thickness = 1.5
    esp.HeadCircle.Transparency = 1
    esp.HeadCircle.Color = Color3.new(1, 1, 1)
    esp.HeadCircle.Filled = false
    esp.HeadCircle.Visible = false

    drawings[player] = esp
end

Players.PlayerRemoving:Connect(function(player)
    if drawings[player] then
        drawings[player].Name:Remove()
        for _, line in ipairs(drawings[player].BoxLines) do line:Remove() end
        for _, line in ipairs(drawings[player].Skeleton) do line:Remove() end
        drawings[player].HealthBar:Remove()
        drawings[player].HeadCircle:Remove()
        drawings[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, esp in pairs(drawings) do
            esp.Name.Visible = false
            for _, line in ipairs(esp.BoxLines) do line.Visible = false end
            for _, line in ipairs(esp.Skeleton) do line.Visible = false end
            esp.HealthBar.Visible = false
            esp.HeadCircle.Visible = false
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
            local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
            local lLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
            local rLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso")

            if not humanoid or humanoid.Health <= 0 or not hrp or not head or not torso then
                if drawings[player] then
                    drawings[player].Name.Visible = false
                    for _, line in ipairs(drawings[player].BoxLines) do line.Visible = false end
                    for _, line in ipairs(drawings[player].Skeleton) do line.Visible = false end
                    drawings[player].HealthBar.Visible = false
                    drawings[player].HeadCircle.Visible = false
                end
                continue
            end

            if player.Team == LocalPlayer.Team then
                if drawings[player] then
                    drawings[player].Name.Visible = false
                    for _, line in ipairs(drawings[player].BoxLines) do line.Visible = false end
                    for _, line in ipairs(drawings[player].Skeleton) do line.Visible = false end
                    drawings[player].HealthBar.Visible = false
                    drawings[player].HeadCircle.Visible = false
                end
                continue
            end

            if not drawings[player] then
                createESP(player)
            end

            local esp = drawings[player]
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
            local torsoPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))

            local height = math.abs(headPos.Y - torsoPos.Y)
            local width = height / 2

            local topLeft = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
            local bottomLeft = Vector2.new(pos.X - width / 2, pos.Y + height / 2)
            local topRight = Vector2.new(pos.X + width / 2, pos.Y - height / 2)
            local bottomRight = Vector2.new(pos.X + width / 2, pos.Y + height / 2)

            local lines = esp.BoxLines
            lines[1].From = topLeft
            lines[1].To = topRight
            lines[2].From = topRight
            lines[2].To = bottomRight
            lines[3].From = bottomRight
            lines[3].To = bottomLeft
            lines[4].From = bottomLeft
            lines[4].To = topLeft

            for _, line in ipairs(lines) do line.Visible = onScreen end

            esp.Name.Position = Vector2.new(pos.X, topLeft.Y - 15)
            esp.Name.Visible = onScreen

            local healthPerc = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = height * healthPerc
            local barTop = Vector2.new(topLeft.X - 4, topLeft.Y)
            local barBottom = Vector2.new(topLeft.X - 4, bottomLeft.Y)
            local currentBottom = Vector2.new(barTop.X, barBottom.Y - barHeight)

            esp.HealthBar.From = barBottom
            esp.HealthBar.To = currentBottom
            esp.HealthBar.Visible = onScreen
            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPerc), 255 * healthPerc, 0)

            local function getPos(part)
                if part then
                    local p, vis = Camera:WorldToViewportPoint(part.Position)
                    return Vector2.new(p.X, p.Y), vis
                end
                return nil, false
            end

            local head2D, hVis = getPos(head)
            local torso2D, tVis = getPos(torso)
            local lArm2D, laVis = getPos(lArm)
            local rArm2D, raVis = getPos(rArm)
            local lLeg2D, llVis = getPos(lLeg)
            local rLeg2D, rlVis = getPos(rLeg)

            local skel = esp.Skeleton
            local i = 1

            if head2D and torso2D then
                skel[i].From = head2D
                skel[i].To = torso2D
                skel[i].Visible = hVis and tVis and onScreen
                i += 1
            end
            if torso2D and lArm2D then
                skel[i].From = torso2D
                skel[i].To = lArm2D
                skel[i].Visible = tVis and laVis and onScreen
                i += 1
            end
            if torso2D and rArm2D then
                skel[i].From = torso2D
                skel[i].To = rArm2D
                skel[i].Visible = tVis and raVis and onScreen
                i += 1
            end
            if torso2D and lLeg2D then
                skel[i].From = torso2D
                skel[i].To = lLeg2D
                skel[i].Visible = tVis and llVis and onScreen
                i += 1
            end
            if torso2D and rLeg2D then
                skel[i].From = torso2D
                skel[i].To = rLeg2D
                skel[i].Visible = tVis and rlVis and onScreen
                i += 1
            end

            -- Círculo na cabeça com raio proporcional ao tamanho visual da cabeça
            if head2D and hVis and onScreen then
                local topOfHead = head.Position + Vector3.new(0, head.Size.Y / 2, 0)
                local top2D = Camera:WorldToViewportPoint(topOfHead)
                
                local radius = (head2D - Vector2.new(top2D.X, top2D.Y)).Magnitude

                esp.HeadCircle.Position = head2D
                esp.HeadCircle.Radius = radius
                esp.HeadCircle.Visible = true
            else
                esp.HeadCircle.Visible = false
            end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ToggleButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    ToggleButton.BackgroundColor3 = espEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)
