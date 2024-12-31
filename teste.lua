local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetTeam = "Militar"
local targetColor = Color3.new(0, 1, 0)

local selectedPlayer = nil
local aimbotActive = false

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

local function enableAimbot()
    aimbotActive = not aimbotActive
    print(aimbotActive and "Aimbot ativado!" or "Aimbot desativado!")
end

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

RunService.RenderStepped:Connect(function()
    if aimbotActive then
        local targetPlayer = getTargetFromTeam()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetHead = targetPlayer.Character.Head
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
        end
    end
end)

UserInputService.TouchTap:Connect(function(touchPositions, processed)
    if processed then return end

    local touchPosition = touchPositions[1] -- Usar a primeira posição de toque

    if touchPosition then
        -- Alternar aimbot
        if aimbotActive then
            enableAimbot()
        end

        -- Teletransportar para jogador selecionado
        if selectedPlayer then
            teleportToPlayer(selectedPlayer)
        else
            print("Nenhum jogador selecionado!")
        end

        -- Testar seleção de jogador pelo nome
        selectPlayer("Militar")
    end
end)
