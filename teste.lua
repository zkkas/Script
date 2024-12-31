local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetTeam = "Militar"
local targetColor = Color3.new(0, 1, 0)

local selectedPlayer = nil
local aimbotActive = false

-- Função para teletransportar até um jogador
local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Jogador inválido para teletransporte!")
        return
    end

    local character = localPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        print("Teletransportado para " .. targetPlayer.Name)
    end
end

-- Selecionar jogador pelo nome
local function selectPlayer(name)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name:lower()) then
            selectedPlayer = player
            print("Jogador selecionado: " .. player.Name)
            return
        end
    end
    warn("Jogador não encontrado!")
end

-- Função para ativar o aimbot
local function enableAimbot()
    aimbotActive = not aimbotActive
    print(aimbotActive and "Aimbot ativado!" or "Aimbot desativado!")
end

-- Detectar jogadores do time alvo
local function getTargetFromTeam()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Team and player.Team.Name == targetTeam then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                return player
            end
        end
    end
    return nil
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if aimbotActive then
        local targetPlayer = getTargetFromTeam()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetHead = targetPlayer.Character.Head
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- Criar GUI
local screenGui = Instance.new("ScreenGui")
local aimbotButton = Instance.new("TextButton")
local teleportButton = Instance.new("TextButton")
local selectPlayerBox = Instance.new("TextBox")

screenGui.Parent = StarterGui

aimbotButton.Size = UDim2.new(0, 200, 0, 50)
aimbotButton.Position = UDim2.new(0, 50, 0, 50)
aimbotButton.Text = "Alternar Aimbot"
aimbotButton.Parent = screenGui

teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0, 50, 0, 150)
teleportButton.Text = "Teletransportar para Seleção"
teleportButton.Parent = screenGui

selectPlayerBox.Size = UDim2.new(0, 200, 0, 50)
selectPlayerBox.Position = UDim2.new(0, 50, 0, 250)
selectPlayerBox.PlaceholderText = "Nome do Jogador"
selectPlayerBox.Parent = screenGui

-- Conectar botões a funções
aimbotButton.MouseButton1Click:Connect(function()
    enableAimbot()
end)

teleportButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        teleportToPlayer(selectedPlayer)
    else
        print("Nenhum jogador selecionado!")
    end
end)

selectPlayerBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        selectPlayer(selectPlayerBox.Text)
    end
end)
