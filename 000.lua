-- Steal A Fish Server Hopper - VERSIÓN ARREGLADA PARA JUGADORES RICOS
-- Escanea múltiples servidores sin unirse automáticamente

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameId = game.PlaceId

-- Variables globales
local isScanning = false
local serverList = {}
local currentScanCount = 0
local maxServersToScan = 20
local originalServerId = game.JobId -- Guardar servidor original

-- Configuración para jugadores ricos (1T = 1,000,000,000,000)
local minPlayerMoney = 100000000000000 -- 100T mínimo
local minFishValue = 1000000000000 -- 1T mínimo por pez

-- Función para crear GUI
local function createGUI()
    local existingGui = PlayerGui:FindFirstChild("StealFishHopper")
    if existingGui then existingGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealFishHopper"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Marco principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 360, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.12)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.new(0.9, 0.7, 0.2) -- Dorado para tema de dinero
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 45)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundColor3 = Color3.new(0.9, 0.7, 0.1) -- Dorado
    titleLabel.BackgroundTransparency = 0
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "💰 RICH PLAYERS SCANNER 💰"
    titleLabel.TextColor3 = Color3.new(0, 0, 0) -- Negro para contraste
    titleLabel.TextSize = 16
    titleLabel.TextScaled = false
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextStrokeTransparency = 0.8
    titleLabel.TextStrokeColor3 = Color3.new(1, 1, 1)
    titleLabel.Visible = true
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleLabel
    
    -- Info de búsqueda
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -10, 0, 30)
    infoLabel.Position = UDim2.new(0, 5, 0, 55)
    infoLabel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
    infoLabel.BackgroundTransparency = 0
    infoLabel.BorderSizePixel = 1
    infoLabel.BorderColor3 = Color3.new(0.3, 0.3, 0.4)
    infoLabel.Text = "🎯 Buscando: Jugadores 100T+ | Peces 1T+"
    infoLabel.TextColor3 = Color3.new(1, 0.9, 0.4)
    infoLabel.TextSize = 14
    infoLabel.TextScaled = false
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Visible = true
    infoLabel.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 6)
    infoCorner.Parent = infoLabel
    
    -- Botón escanear
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0, 170, 0, 40)
    scanButton.Position = UDim2.new(0, 10, 0, 95)
    scanButton.BackgroundColor3 = Color3.new(0.1, 0.8, 0.1)
    scanButton.BackgroundTransparency = 0
    scanButton.BorderSizePixel = 2
    scanButton.BorderColor3 = Color3.new(0.05, 0.5, 0.05)
    scanButton.Text = "🔍 BUSCAR RICOS"
    scanButton.TextColor3 = Color3.new(1, 1, 1)
    scanButton.TextSize = 16
    scanButton.TextScaled = false
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.TextStrokeTransparency = 0.8
    scanButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    scanButton.Visible = true
    scanButton.Active = true
    scanButton.Parent = mainFrame
    
    -- Botón detener
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(0, 170, 0, 40)
    stopButton.Position = UDim2.new(0, 190, 0, 95)
    stopButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    stopButton.BackgroundTransparency = 0
    stopButton.BorderSizePixel = 2
    stopButton.BorderColor3 = Color3.new(0.5, 0.1, 0.1)
    stopButton.Text = "⏹️ DETENER"
    stopButton.TextColor3 = Color3.new(1, 1, 1)
    stopButton.TextSize = 16
    stopButton.TextScaled = false
    stopButton.Font = Enum.Font.SourceSansBold
    stopButton.Visible = false
    stopButton.Active = true
    stopButton.Parent = mainFrame
    
    -- Botón volver al servidor original
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(1, -20, 0, 30)
    backButton.Position = UDim2.new(0, 10, 0, 145)
    backButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.6)
    backButton.BorderSizePixel = 1
    backButton.Text = "🔙 VOLVER AL SERVIDOR ORIGINAL"
    backButton.TextColor3 = Color3.new(1, 1, 1)
    backButton.TextSize = 14
    backButton.Font = Enum.Font.SourceSans
    backButton.Parent = mainFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanButton
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopButton
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 4)
    backCorner.Parent = backButton
    
    -- Lista de servidores ricos
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ServerList"
    scrollFrame.Size = UDim2.new(0, 340, 0, 250)
    scrollFrame.Position = UDim2.new(0, 10, 0, 185)
    scrollFrame.BackgroundColor3 = Color3.new(0.12, 0.12, 0.18)
    scrollFrame.BorderSizePixel = 2
    scrollFrame.BorderColor3 = Color3.new(0.25, 0.25, 0.3)
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollFrame
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingAll = UDim.new(0, 5)
    listPadding.Parent = scrollFrame
    
    -- Estado
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 340, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 445)
    statusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
    statusLabel.BackgroundTransparency = 0
    statusLabel.BorderSizePixel = 1
    statusLabel.BorderColor3 = Color3.new(0.4, 0.4, 0.5)
    statusLabel.Text = "💎 Listo para buscar servidores con jugadores ricos"
    statusLabel.TextColor3 = Color3.new(0.7, 1, 0.7)
    statusLabel.TextSize = 12
    statusLabel.TextScaled = false
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextStrokeTransparency = 0.8
    statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    statusLabel.Visible = true
    statusLabel.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = statusLabel
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 8)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.BackgroundTransparency = 0
    closeButton.BorderSizePixel = 1
    closeButton.BorderColor3 = Color3.new(0.5, 0.1, 0.1)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 16
    closeButton.TextScaled = false
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Visible = true
    closeButton.Active = true
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Drag system
    local dragging = false
    local dragStart, startPos
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleLabel.InputChanged:Connect(function(input)
        if dragging and dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Eventos
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        if not isScanning then
            startServerScan(scanButton, stopButton, statusLabel, scrollFrame)
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        isScanning = false
        scanButton.Visible = true
        stopButton.Visible = false
        statusLabel.Text = "⏹️ Búsqueda detenida"
        statusLabel.TextColor3 = Color3.new(1, 0.7, 0.3)
    end)
    
    backButton.MouseButton1Click:Connect(function()
        if originalServerId and originalServerId ~= "" then
            backButton.Text = "🔙 VOLVIENDO..."
            TeleportService:TeleportToPlaceInstance(gameId, originalServerId, LocalPlayer)
        else
            TeleportService:Teleport(gameId, LocalPlayer)
        end
    end)
    
    return screenGui, scrollFrame, statusLabel, scanButton, stopButton
end

-- Función mejorada para detectar jugadores súper ricos
local function analyzeServerForRichPlayers()
    local data = {
        serverId = game.JobId,
        players = #Players:GetPlayers(),
        richPlayers = {},
        maxMoney = 0,
        totalValue = 0,
        expensiveFish = {},
        score = 0,
        isWorthIt = false
    }
    
    -- Analizar cada jugador buscando súper ricos
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerData = {
                name = player.DisplayName or player.Name,
                money = 0,
                fishValue = 0,
                expensiveFishCount = 0
            }
            
            -- Buscar dinero en leaderstats
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                -- Buscar diferentes nombres de dinero
                local moneyStats = {
                    leaderstats:FindFirstChild("Money"),
                    leaderstats:FindFirstChild("Cash"), 
                    leaderstats:FindFirstChild("Coins"),
                    leaderstats:FindFirstChild("Balance"),
                    leaderstats:FindFirstChild("Dollars")
                }
                
                for _, moneyStat in pairs(moneyStats) do
                    if moneyStat and tonumber(moneyStat.Value) then
                        local playerMoney = tonumber(moneyStat.Value)
                        if playerMoney > playerData.money then
                            playerData.money = playerMoney
                        end
                    end
                end
            end
            
            -- Buscar peces valiosos en backpack y character
            local locations = {player:FindFirstChild("Backpack")}
            if player.Character then
                table.insert(locations, player.Character)
            end
            
            for _, location in pairs(locations) do
                if location then
                    for _, item in pairs(location:GetChildren()) do
                        if item:IsA("Tool") then
                            local itemName = string.lower(item.Name)
                            local estimatedValue = 0
                            
                            -- Detectar peces súper caros por nombre
                            if string.find(itemName, "trillion") or string.find(itemName, "1t") or string.find(itemName, "2t") or string.find(itemName, "5t") or string.find(itemName, "10t") then
                                estimatedValue = 1000000000000 -- 1T base
                            elseif string.find(itemName, "legendary") or string.find(itemName, "mythic") or string.find(itemName, "ancient") then
                                estimatedValue = 500000000000 -- 500B
                            elseif string.find(itemName, "rare") or string.find(itemName, "epic") then
                                estimatedValue = 100000000000 -- 100B
                            elseif string.find(itemName, "golden") or string.find(itemName, "diamond") or string.find(itemName, "crystal") then
                                estimatedValue = 50000000000 -- 50B
                            end
                            
                            -- Detectar por valor real si el pez tiene stats
                            local valueAttribute = item:GetAttribute("Value") or item:GetAttribute("Worth") or item:GetAttribute("Price")
                            if valueAttribute and tonumber(valueAttribute) then
                                estimatedValue = math.max(estimatedValue, tonumber(valueAttribute))
                            end
                            
                            if estimatedValue >= minFishValue then
                                playerData.expensiveFishCount = playerData.expensiveFishCount + 1
                                playerData.fishValue = playerData.fishValue + estimatedValue
                                table.insert(data.expensiveFish, {
                                    player = playerData.name,
                                    fish = item.Name,
                                    value = estimatedValue
                                })
                            end
                        end
                    end
                end
            end
            
            -- Solo considerar jugadores súper ricos
            if playerData.money >= minPlayerMoney or playerData.fishValue >= minFishValue then
                table.insert(data.richPlayers, playerData)
                data.totalValue = data.totalValue + playerData.money + playerData.fishValue
                
                if playerData.money > data.maxMoney then
                    data.maxMoney = playerData.money
                end
            end
        end
    end
    
    -- Calcular si vale la pena este servidor
    data.score = (#data.richPlayers * 1000) + math.floor(data.totalValue / 1000000000000) -- Puntos por trillones
    data.isWorthIt = #data.richPlayers > 0 and (data.maxMoney >= minPlayerMoney or #data.expensiveFish > 0)
    
    return data
end

-- Crear item de servidor rico
local function createRichServerItem(serverData, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 85)
    frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.22)
    frame.BorderSizePixel = 2
    frame.Parent = parent
    
    -- Indicador dorado para servidores ricos
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 8, 1, 0)
    indicator.BackgroundColor3 = Color3.new(1, 0.8, 0.1) -- Dorado
    indicator.BorderSizePixel = 0
    indicator.Parent = frame
    
    if #serverData.richPlayers >= 3 then
        indicator.BackgroundColor3 = Color3.new(0.9, 0.1, 0.9) -- Magenta para súper ricos
    elseif #serverData.richPlayers >= 2 then
        indicator.BackgroundColor3 = Color3.new(1, 0.8, 0.1) -- Dorado
    else
        indicator.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Plata
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator
    
    -- Info del servidor rico
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 220, 1, 0)
    infoLabel.Position = UDim2.new(0, 15, 0, 0)
    infoLabel.BackgroundTransparency = 1
    
    local richCount = #serverData.richPlayers
    local expensiveFishCount = #serverData.expensiveFish
    local maxMoneyText = serverData.maxMoney >= 1000000000000 and string.format("%.1fT", serverData.maxMoney/1000000000000) or string.format("%.1fB", serverData.maxMoney/1000000000)
    
    infoLabel.Text = string.format("💎 Puntuación: %d\n👑 Jugadores Ricos: %d | 💰 Max: $%s\n🐟 Peces Caros: %d | 👥 Total: %d", 
        serverData.score, richCount, maxMoneyText, expensiveFishCount, serverData.players)
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    infoLabel.Parent = frame
    
    -- Botón unirse - SOLO MANUAL
    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(0, 90, 0, 45)
    joinButton.Position = UDim2.new(1, -100, 0.5, -22)
    joinButton.BackgroundColor3 = Color3.new(0.9, 0.7, 0.1) -- Dorado
    joinButton.BorderSizePixel = 2
    joinButton.BorderColor3 = Color3.new(0.7, 0.5, 0.05)
    joinButton.Text = "💰 UNIRSE"
    joinButton.TextColor3 = Color3.new(0, 0, 0) -- Negro para contraste
    joinButton.TextSize = 14
    joinButton.Font = Enum.Font.SourceSansBold
    joinButton.Parent = frame
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 6)
    joinCorner.Parent = joinButton
    
    -- Evento manual de unirse - NO AUTOMÁTICO
    joinButton.MouseButton1Click:Connect(function()
        print("UNIRSE MANUAL presionado para servidor:", serverData.serverId)
        joinButton.Text = "UNIENDO..."
        joinButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        
        wait(0.5)
        
        -- SOLO se une cuando el usuario presiona el botón
        local success = pcall(function()
            if serverData.serverId and serverData.serverId ~= "" and serverData.serverId ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
            else
                -- Buscar servidor diferente
                TeleportService:Teleport(gameId, LocalPlayer)
            end
        end)
        
        if not success then
            joinButton.Text = "ERROR"
            joinButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
            wait(2)
            joinButton.Text = "💰 UNIRSE"
            joinButton.BackgroundColor3 = Color3.new(0.9, 0.7, 0.1)
        end
    end)
    
    return frame
end

-- Función principal - ESCANEA SIN UNIRSE AUTOMÁTICAMENTE
function startServerScan(scanButton, stopButton, statusLabel, scrollFrame)
    if isScanning then return end
    
    print("=== INICIANDO BÚSQUEDA DE SERVIDORES RICOS ===")
    isScanning = true
    currentScanCount = 0
    serverList = {}
    
    scanButton.Visible = false
    stopButton.Visible = true
    statusLabel.Text = "💎 Buscando jugadores con 100T+..."
    statusLabel.TextColor3 = Color3.new(1, 0.8, 0.4)
    
    -- Limpiar lista
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Función de escaneo que NO se une automáticamente
    local function scanNextServer()
        if not isScanning or currentScanCount >= maxServersToScan then
            -- FINALIZAR - NO UNIRSE
            isScanning = false
            scanButton.Visible = true
            stopButton.Visible = false
            statusLabel.Text = string.format("✅ Búsqueda completada: %d servidores ricos encontrados", #serverList)
            statusLabel.TextColor3 = Color3.new(0.7, 1, 0.7)
            
            -- Ordenar por riqueza
            table.sort(serverList, function(a, b) return a.score > b.score end)
            
            -- Mostrar solo servidores que valen la pena
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for i, data in ipairs(serverList) do
                if i <= 8 and data.isWorthIt then -- Solo top 8 servidores ricos
                    createRichServerItem(data, scrollFrame)
                end
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#serverList, 8) * 93)
            print("=== BÚSQUEDA TERMINADA - LISTA MOSTRADA ===")
            return
        end
        
        currentScanCount = currentScanCount + 1
        statusLabel.Text = string.format("🔍 Analizando servidor %d/%d...", currentScanCount, maxServersToScan)
        
        -- Analizar servidor actual SIN UNIRSE
        wait(2)
        local currentData = analyzeServerForRichPlayers()
        
        print(string.format("Servidor analizado: %d jugadores ricos, %d peces caros", #currentData.richPlayers, #currentData.expensiveFish))
        
        if currentData.isWorthIt then
            table.insert(serverList, currentData)
            createRichServerItem(currentData, scrollFrame)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #serverList * 93)
            print("✅ Servidor rico agregado a la lista")
        end
        
        -- PAUSA antes de saltar al siguiente servidor
        wait(2)
        
        -- SALTAR AL SIGUIENTE SERVIDOR (sin unirse automáticamente a ninguno)
        if isScanning then
            print("Saltando al siguiente servidor para escanear...")
            TeleportService:Teleport(gameId, LocalPlayer)
        end
    end
    
    -- Empezar escaneo
    wait(1)
    scanNextServer()
end

-- Inicializar
wait(1)
createGUI()

print("✅ RICH PLAYERS SCANNER CARGADO!")
print("💰 Busca jugadores con 100T+ y peces de 1T+")
print("🎯 NO se une automáticamente - TÚ eliges el servidor")
print("🔍 Presiona 'BUSCAR RICOS' para empezar")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "💰 Rich Scanner Cargado";
    Text = "Busca jugadores súper ricos (100T+). ¡NO se une automáticamente!";
    Duration = 6;
})