local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações iniciais
local config = {
    enabled = false,
    smoothness = 0.1, -- Suavidade da mira (0 = instantâneo, 1 = muito lento)
    range = 300, -- Alcance máximo em studs
    targetPart = "Head" -- Parte do corpo para mirar ("Head", "Torso", etc.)
}

-- Criar menu UI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "LegitAimbotMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.BorderSizePixel = 0

local EnabledButton = Instance.new("TextButton", Frame)
EnabledButton.Size = UDim2.new(1, -20, 0, 40)
EnabledButton.Position = UDim2.new(0, 10, 0, 10)
EnabledButton.Text = "Aimbot: OFF"
EnabledButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
EnabledButton.TextColor3 = Color3.new(1, 1, 1)

local SmoothnessSlider = Instance.new("TextButton", Frame)
SmoothnessSlider.Size = UDim2.new(1, -20, 0, 40)
SmoothnessSlider.Position = UDim2.new(0, 10, 0, 60)
SmoothnessSlider.Text = "Smoothness: " .. config.smoothness
SmoothnessSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
SmoothnessSlider.TextColor3 = Color3.new(1, 1, 1)

local RangeSlider = Instance.new("TextButton", Frame)
RangeSlider.Size = UDim2.new(1, -20, 0, 40)
RangeSlider.Position = UDim2.new(0, 10, 0, 110)
RangeSlider.Text = "Range: " .. config.range
RangeSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
RangeSlider.TextColor3 = Color3.new(1, 1, 1)

local TargetPartDropdown = Instance.new("TextButton", Frame)
TargetPartDropdown.Size = UDim2.new(1, -20, 0, 40)
TargetPartDropdown.Position = UDim2.new(0, 10, 0, 160)
TargetPartDropdown.Text = "Target Part: " .. config.targetPart
TargetPartDropdown.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TargetPartDropdown.TextColor3 = Color3.new(1, 1, 1)

-- Função para encontrar o jogador mais próximo
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(config.targetPart) then
            local part = player.Character[config.targetPart]
            local screenPosition, onScreen = Camera:WorldToViewportPoint(part.Position)

            if onScreen then
                local mousePosition = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude

                if distance < shortestDistance and distance <= config.range then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

-- Suavizar a mira
local function smoothAim(targetPosition)
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    return currentCFrame:Lerp(targetCFrame, config.smoothness)
end

-- Mira assistida
RunService.RenderStepped:Connect(function()
    if config.enabled then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(config.targetPart)
            if targetPart then
                Camera.CFrame = smoothAim(targetPart.Position)
            end
        end
    end
end)

-- Botões do menu
EnabledButton.MouseButton1Click:Connect(function()
    config.enabled = not config.enabled
    EnabledButton.Text = "Aimbot: " .. (config.enabled and "ON" or "OFF")
end)

SmoothnessSlider.MouseButton1Click:Connect(function()
    config.smoothness = config.smoothness + 0.1
    if config.smoothness > 1 then config.smoothness = 0 end
    SmoothnessSlider.Text = "Smoothness: " .. string.format("%.1f", config.smoothness)
end)

RangeSlider.MouseButton1Click:Connect(function()
    config.range = config.range + 50
    if config.range > 1000 then config.range = 100 end
    RangeSlider.Text = "Range: " .. config.range
end)

TargetPartDropdown.MouseButton1Click:Connect(function()
    if config.targetPart == "Head" then
        config.targetPart = "Torso"
    else
        config.targetPart = "Head"
    end
    TargetPartDropdown.Text = "Target Part: " .. config.targetPart
end)
