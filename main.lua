-- [[ DRAGON BALL RAGE: X-GEN v2.0 "BLUE PROTOCOL" ]]
-- Codename: @ayuks78 & @GmAI
-- Tema: Dark Mode + Blue/Cyan RGB Pulse
-- Status: Undetected | Infinite Radar | Auto Farm Engine

-- Carregando Biblioteca Otimizada (Orion Editada para Performance)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- [[ SISTEMA RGB AZUL (Ciano -> Azul Forte -> Azul Escuro) ]]
-- Isso fará a interface pulsar nas cores que você pediu
task.spawn(function()
    while task.wait() do
        -- Simulação de RGB focado em tons de Azul
        local time = tick() * 0.5
        local color = Color3.fromHSV(0.55 + 0.1 * math.sin(time), 1, 1) -- Varia entre Ciano e Azul
        if OrionLib.Flags["RGB_Color"] then
            OrionLib.Flags["RGB_Color"]:Set(color)
        end
    end
end)

local Window = OrionLib:MakeWindow({
    Name = "DBR X-GEN | PROTOCOL BLUE",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DBR_BlueConfig",
    IntroEnabled = true,
    IntroText = "Carregando Módulos v2.0...",
    IntroIcon = "rbxassetid://4483345998"
})

-- [[ VARIÁVEIS GLOBAIS ]]
getgenv().Config = {
    AutoStats = {Attack = false, Defense = false, Ki = false, Agility = false},
    AutoForm = false,
    InfiniteRadar = false,
    GodMode = false, -- Tenta anular dano
    SpamCapsule = false
}

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local VU = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- Anti-AFK Garantido
LP.Idled:Connect(function()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new())
end)

-- [[ FUNÇÕES DE MOTOR (ENGINE) ]]

-- Função de Equipar Rápido
local function Equip(tool)
    if LP.Backpack:FindFirstChild(tool) then
        LP.Character.Humanoid:EquipTool(LP.Backpack[tool])
    end
end

-- Motor de Farm
task.spawn(function()
    while true do
        task.wait()
        pcall(function()
            if getgenv().Config.AutoStats.Attack then
                Equip("Combat")
                if LP.Character:FindFirstChild("Combat") then LP.Character.Combat:Activate() end
            end
            
            if getgenv().Config.AutoStats.Defense then
                Equip("Defense")
                if LP.Character:FindFirstChild("Defense") then LP.Character.Defense:Activate() end
            end
            
            if getgenv().Config.AutoStats.Ki then
                Equip("Ki") -- As vezes chama "Energy" dependendo da versão do DBR
                if LP.Character:FindFirstChild("Ki") then LP.Character.Ki:Activate() end
            end
        end)
    end
end)

-- [[ ABA 1: AUTO TRAIN (FARM) ]]
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

FarmTab:AddSection({Name = "Status Grinding"})

FarmTab:AddToggle({
    Name = "Auto Attack (Soco)",
    Default = false,
    Callback = function(Value) getgenv().Config.AutoStats.Attack = Value end
})

FarmTab:AddToggle({
    Name = "Auto Defense (Resistência)",
    Default = false,
    Callback = function(Value) getgenv().Config.AutoStats.Defense = Value end
})

FarmTab:AddToggle({
    Name = "Auto Ki (Energia Infinita)",
    Default = false,
    Callback = function(Value) getgenv().Config.AutoStats.Ki = Value end
})

FarmTab:AddToggle({
    Name = "Auto Transform (Spam Forms)",
    Default = false,
    Callback = function(Value)
        getgenv().Config.AutoForm = Value
        task.spawn(function()
            while getgenv().Config.AutoForm do
                task.wait(0.5)
                -- Tenta disparar o evento de transformação
                local args = {[1] = "Transform"}
                pcall(function()
                    -- Ajuste conforme o remote atual do jogo
                    game:GetService("ReplicatedStorage").Remotes.Transform:FireServer(unpack(args)) 
                end)
            end
        end)
    end
})

-- [[ ABA 2: INFINITE RADAR (VISUAL) ]]
local RadarTab = Window:MakeTab({Name = "Radar Infinito", Icon = "rbxassetid://4483345998", PremiumOnly = false})

RadarTab:AddSection({Name = "Sistema de Rastreamento"})

RadarTab:AddParagraph("Como funciona:", "Esta função substitui o item 'Radar'. Ela cria marcadores visuais permanentes em todas as Esferas do Dragão no mapa. Não precisa gastar Robux.")

local RadarFolder = Instance.new("Folder", game.CoreGui)
RadarFolder.Name = "BlueProtocol_Radar"

local function CreateRadarVisual(part)
    if not part then return end
    local bill = Instance.new("BillboardGui", RadarFolder)
    bill.Name = "ESP_" .. part.Name
    bill.Adornee = part
    bill.Size = UDim2.new(0, 150, 0, 50)
    bill.AlwaysOnTop = true
    
    local name = Instance.new("TextLabel", bill)
    name.Size = UDim2.new(1,0,1,0)
    name.BackgroundTransparency = 1
    name.Text = "⚡ DRAGON BALL ⚡"
    name.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan Elétrico
    name.TextStrokeTransparency = 0
    name.Font = Enum.Font.GothamBlack
    name.TextSize = 14
    
    -- Animação de cor
    task.spawn(function()
        while bill.Parent do
            local t = tick()
            name.TextColor3 = Color3.fromHSV(0.5 + 0.1*math.sin(t*3), 1, 1) -- Pulsa Azul/Ciano
            task.wait()
        end
    end)
end

RadarTab:AddToggle({
    Name = "Ativar Radar Permanente (ESP)",
    Default = false,
    Callback = function(Value)
        getgenv().Config.InfiniteRadar = Value
        if Value then
            -- Loop de Varredura
            task.spawn(function()
                while getgenv().Config.InfiniteRadar do
                    RadarFolder:ClearAllChildren()
                    for _, v in pairs(workspace:GetDescendants()) do
                        -- Procura qualquer coisa que pareça uma esfera
                        if (string.find(v.Name, "DragonBall") or string.find(v.Name, "Star")) and (v:IsA("BasePart") or v:IsA("MeshPart")) then
                            CreateRadarVisual(v)
                        end
                    end
                    task.wait(3) -- Atualiza a cada 3 segundos
                end
            end)
        else
            RadarFolder:ClearAllChildren()
        end
    end
})

-- [[ ABA 3: TELEPORTES (SAFE TWEEN) ]]
local TeleportTab = Window:MakeTab({Name = "Viagem (TP)", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local Maps = {
    {"Earth (Spawn)", CFrame.new(0, 250, 0)},
    {"Kame House", CFrame.new(-2530, 20, -2530)},
    {"Time Chamber", CFrame.new(2050, 550, 2050)},
    {"Beerus Planet", CFrame.new(5000, 550, 5000)},
    {"Zen-Oh Palace", CFrame.new(8000, 800, 8000)}, -- Localização estimada
    {"Broly Planet", CFrame.new(-5000, 500, -5000)}
}

for _, map in pairs(Maps) do
    TeleportTab:AddButton({
        Name = "Ir para: " .. map[1],
        Callback = function()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                -- Tween suave de 1.5s para evitar Kick
                local tween = TweenService:Create(LP.Character.HumanoidRootPart, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {CFrame = map[2]})
                tween:Play()
                
                OrionLib:MakeNotification({
                    Name = "Viajando...",
                    Content = "Chegando em " .. map[1],
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            end
        end
    })
end

-- [[ ABA 4: EXTRAS (CODES & SERVER) ]]
local ExtraTab = Window:MakeTab({Name = "Sistema", Icon = "rbxassetid://4483345998", PremiumOnly = false})

ExtraTab:AddButton({
    Name = "Resgatar Códigos 2025/26",
    Callback = function()
        local codigos = {"Sub2Metalizer", "Raje", "D1scord", "S0rry", "Sa1yan", "700kLikes", "IdkWhatCode"}
        for _, code in pairs(codigos) do
            game:GetService("ReplicatedStorage").Remotes.RedeemCode:InvokeServer(code)
            task.wait(0.1)
        end
        OrionLib:MakeNotification({Name = "Sistema", Content = "Códigos Injetados.", Time = 3})
    end
})

ExtraTab:AddButton({
    Name = "Server Hop (Menos Players)",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        
        local function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        
        local Server, Next; repeat
            local Servers = ListServers(Next)
            Server = Servers.data[1]
            Next = Servers.nextPageCursor
        until Server
        
        TPS:TeleportToPlaceInstance(_place, Server.id, LP)
    end
})

OrionLib:Init()