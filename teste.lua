local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/kwargs_Ui_Library/main/source.lua"))()

-- Criar UI
local UI = Lib:Create{
   Theme = "Dark",
   Size = UDim2.new(0, 555, 0, 400)
}

-- Tabs principais
local Main = UI:Tab{
   Name = "Main"
}

local SettingsDivider = Main:Divider{
   Name = "Aimbot Settings"
}

local ESPDivider = Main:Divider{
   Name = "ESP Settings"
}

local QuitDivider = Main:Divider{
   Name = "Quit"
}

-- Configurações iniciais
local config = {
    aimbotEnabled = false,
    espEnabled = false,
    smoothness = 0.1, -- Suavidade da mira
    range = 300, -- Alcance máximo
    targetPart = "Head", -- Parte do corpo para mirar
    espColor = Color3.fromRGB(255, 0, 0) -- Cor do ESP
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Funções principais
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

local function smoothAim(targetPosition)
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    return currentCFrame:Lerp(targetCFrame, config.smoothness)
end

local function aimAtTarget()
    if config.aimbotEnabled then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(config.targetPart)
            if targetPart then
                Camera.CFrame = smoothAim(targetPart.Position)
            end
        end
    end
end

RunService.RenderStepped:Connect(aimAtTarget)

-- Criar ESP
local function createESP(player)
    if not config.espEnabled then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillColor = config.espColor
    highlight.OutlineColor = Color3.new(1, 1, 1)

    player:GetPropertyChangedSignal("Parent"):Connect(function()
        if not player:IsDescendantOf(Players) then
            highlight:Destroy()
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Atualizar configurações via UI
SettingsDivider:Toggle{
    Name = "Enable Aimbot",
    Callback = function(state)
        config.aimbotEnabled = state
        print("Aimbot Enabled:", state)
    end
}

SettingsDivider:Slider{
    Name = "Smoothness",
    Min = 0.1,
    Max = 1,
    Default = config.smoothness,
    Callback = function(value)
        config.smoothness = value
        print("Smoothness:", value)
    end
}

SettingsDivider:Slider{
    Name = "Range",
    Min = 100,
    Max = 1000,
    Default = config.range,
    Callback = function(value)
        config.range = value
        print("Range:", value)
    end
}

SettingsDivider:Dropdown{
    Name = "Target Part",
    Options = {"Head", "Torso", "RightArm", "LeftArm"},
    Default = config.targetPart,
    Callback = function(value)
        config.targetPart = value
        print("Target Part:", value)
    end
}

ESPDivider:Toggle{
    Name = "Enable ESP",
    Callback = function(state)
        config.espEnabled = state
        print("ESP Enabled:", state)
        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    createESP(player)
                end
            end
        end
    end
}

ESPDivider:ColorPicker{
    Name = "ESP Color",
    Default = config.espColor,
    Callback = function(color)
        config.espColor = color
        print("ESP Color:", color)
    end
}

-- Sair da UI
QuitDivider:Button{
    Name = "Quit",
    Callback = function()
        UI:Quit{
            Message = "Goodbye!",
            Length = 1
        }
    end
}
