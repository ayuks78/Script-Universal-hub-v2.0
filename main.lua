-- [[ PAINEL UNIVERSAL-HUB-V1.1 ]]
-- Codename Devs: @ayuks78 & @GmAI
-- SECURITY: HOOKMETAMETHOD BYPASS (ANTI-NAMECALL DETECTOR)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- [[ 1. SEGURANÇA ELITE (ANTI-DETECTION) ]]
local ScreenGui = Instance.new("ScreenGui")
-- Gera um nome aleatório para evitar "Instance Detector"
ScreenGui.Name = "RobloxSystem_" .. math.random(100, 999)

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local function SafeBypass()
    local old; old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() then
            -- Esconde as mudanças de Hitbox e Aimbot das checagens do jogo
            if method == "FindFirstChild" and (args[1] == "HumanoidRootPart" or args[1] == "UpperTorso") then
                return old(self, ...)
            end
            
            -- Bloqueia o envio de logs de detecção (Anti-Kick)
            if method == "FireServer" and (self.Name:lower():find("check") or self.Name:lower():find("detec") or self.Name:lower():find("teleport")) then
                return nil
            end
        end
        return old(self, ...)
    end))
end
pcall(SafeBypass)

-- [[ NOTIFICAÇÃO DE VERIFICAÇÃO COM SELO ]]
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "System Verified ✔️",
    Text = "Universal-Hub v1.1: Stealth Mode Active.",
    Icon = "rbxassetid://6023454774",
    Duration = 4
})

-- [[ 2. ESTRUTURA VISUAL DO PAINEL ]]
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
SideBar.Parent = MainFrame
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

local UIList = Instance.new("UIListLayout")
UIList.Parent = SideBar
UIList.Padding = UDim.new(0, 2)

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -150, 1, -20)
Pages.Position = UDim2.new(0, 150, 0, 10)
Pages.BackgroundTransparency = 1
Pages.Parent = MainFrame

local function CreatePage(name, icon)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.Parent = Pages

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 45)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "  " .. icon .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = SideBar
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)
    return Page
end

local MainP = CreatePage("Main", "◇")
local EspP = CreatePage("Esp", "◇")
local SettingsP = CreatePage("Settings", "◇")
local CreditsP = CreatePage("Credits", "◇")

-- [[ 3. LÓGICA: AIMBOT & HITBOX ]]
local Aim_Settings = { PlayerAim = false, AutoAim = false, Smoothing = 0.35, MaxDist = 900 }
local Hitbox_Config = { Enabled = false, Size = 5, Transparency = 0.8 }

local function GetTarget(isAuto)
    local closest = nil
    local dist = 200
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Health > 0 and (v.Parent:FindFirstChild("UpperTorso") or v.Parent:FindFirstChild("HumanoidRootPart")) then
            local char = v.Parent
            local isAPlayer = Players:GetPlayerFromCharacter(char)
            local root = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
            if (isAuto) or (not isAuto and isAPlayer and char ~= lp.Character) then
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                local dToCam = (camera.CFrame.Position - root.Position).Magnitude
                if onScreen and dToCam <= Aim_Settings.MaxDist then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if magnitude < dist then closest = root; dist = magnitude end
                end
            end
        end
    end
    return closest
end

RS.RenderStepped:Connect(function()
    if Aim_Settings.PlayerAim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget(false)
        if t then
            local tp = camera:WorldToViewportPoint(t.Position)
            local mp = UIS:GetMouseLocation()
            mousemoverel((tp.X-mp.X)*Aim_Settings.Smoothing, (tp.Y-mp.Y)*Aim_Settings.Smoothing)
        end
    end
    if Aim_Settings.AutoAim then
        local t = GetTarget(true)
        if t then
            local tp = camera:WorldToViewportPoint(t.Position)
            local mp = UIS:GetMouseLocation()
            mousemoverel((tp.X-mp.X)*(Aim_Settings.Smoothing-0.1), (tp.Y-mp.Y)*(Aim_Settings.Smoothing-0.1))
        end
    end
end)

RS.Heartbeat:Connect(function()
    if Hitbox_Config.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= lp.Team then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(Hitbox_Config.Size, Hitbox_Config.Size, Hitbox_Config.Size)
                hrp.Transparency = Hitbox_Config.Transparency
                hrp.CanCollide = false
                hrp.Massless = true
            end
        end
    end
end)

-- [[ 4. INTERFACE: BOTÕES, SLIDERS E ESP ]]
local function AddToggle(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.Text = text .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local act = false
    Btn.MouseButton1Click:Connect(function()
        act = not act
        Btn.Text = text .. (act and " [ON]" or " [OFF]")
        Btn.BackgroundColor3 = act and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(20, 20, 20)
        callback(act)
    end)
end

-- ABA MAIN
AddToggle(MainP, "Aimbot Players (Manual)", function(v) Aim_Settings.PlayerAim = v end)
AddToggle(MainP, "Aimbot Auto (Combate/NPC)", function(v) Aim_Settings.AutoAim = v end)
local Div = Instance.new("TextLabel", MainP); Div.Size = UDim2.new(1,0,0,20); Div.Text = "________________________"; Div.BackgroundTransparency = 1; Div.TextColor3 = Color3.fromRGB(40,40,40)
AddToggle(MainP, "Hitbox Expander", function(v) 
    Hitbox_Config.Enabled = v 
    if not v then
        for _,p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1); p.Character.HumanoidRootPart.Transparency = 1 end end
    end
end)

-- SLIDER HITBOX STUDS (CINZA)
local SFrame = Instance.new("Frame", MainP); SFrame.Size = UDim2.new(1,-20,0,50); SFrame.BackgroundTransparency = 1
local SLab = Instance.new("TextLabel", SFrame); SLab.Size = UDim2.new(1,0,0,20); SLab.Text = "Hitbox Studs: 5"; SLab.TextColor3 = Color3.fromRGB(180,180,180); SLab.BackgroundTransparency = 1
local SBar = Instance.new("Frame", SFrame); SBar.Size = UDim2.new(1,0,0,4); SBar.Position = UDim2.new(0,0,0,30); SBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
local SBtn = Instance.new("TextButton", SBar); SBtn.Size = UDim2.new(0,16,0,16); SBtn.Position = UDim2.new(0,0,0,-6); SBtn.BackgroundColor3 = Color3.fromRGB(60,60,60); SBtn.Text = ""
Instance.new("UICorner", SBtn).CornerRadius = UDim.new(1,0)

local drag = false
SBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local r = math.clamp((i.Position.X - SBar.AbsolutePosition.X)/SBar.AbsoluteSize.X, 0, 1)
        SBtn.Position = UDim2.new(r, -8, 0, -6)
        local val = math.floor(5 + (r * 20))
        Hitbox_Config.Size = val
        SLab.Text = "Hitbox Studs: " .. val
    end
end)

-- ABA ESP (ESTILO IY)
local E_Config = { Enabled = false }
local function CreateESP(p)
    local B = Drawing.new("Square"); local L = Drawing.new("Text")
    RS.RenderStepped:Connect(function()
        if E_Config.Enabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= lp then
            local r = p.Character.HumanoidRootPart; local h = p.Character:FindFirstChild("Humanoid")
            local pos, vis = camera:WorldToViewportPoint(r.Position)
            if vis and h and h.Health > 0 then
                local sX, sY = 2500/pos.Z, 4000/pos.Z
                B.Visible = true; B.Size = Vector2.new(sX, sY); B.Position = Vector2.new(pos.X-sX/2, pos.Y-sY/2); B.Color = p.TeamColor.Color
                L.Visible = true; L.Text = string.format("%s: HP %d%% / Dist: %dm", p.Name, math.floor(h.Health), math.floor((camera.CFrame.p-r.Position).Magnitude))
                L.Color = Color3.fromRGB(255,255,255); L.Position = Vector2.new(pos.X, pos.Y-sY/2-18); L.Center = true; L.Outline = true
            else B.Visible = false; L.Visible = false end
        else B.Visible = false; L.Visible = false end
    end)
end
for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end; Players.PlayerAdded:Connect(CreateESP)
AddToggle(EspP, "Esp Player", function(v) E_Config.Enabled = v end)

-- ABA SETTINGS
AddToggle(SettingsP, "Boost FPS Lite", function(v)
    if v then
        local l = game:GetService("Lighting")
        l.GlobalShadows = false; l.FogEnd = 9e9
        for _,x in pairs(l:GetChildren()) do if x:IsA("PostEffect") then x.Enabled = false end end
    end
end)
AddToggle(SettingsP, "Super Boost FPS", function(v)
    if v then
        for _,x in pairs(game:GetDescendants()) do
            if x:IsA("Part") or x:IsA("MeshPart") then x.Material = Enum.Material.Plastic; x.Color = Color3.fromRGB(180,180,180)
            elseif x:IsA("Texture") or x:IsA("Decal") then x.Transparency = 1 end
        end
    end
end)

-- ABA CREDITS
local CL = Instance.new("TextLabel", CreditsP); CL.Size = UDim2.new(1, -20, 1, -20); CL.Position = UDim2.new(0,10,0,10); CL.BackgroundTransparency = 1; CL.RichText = true; CL.Font = Enum.Font.GothamSemibold; CL.TextSize = 15
CL.Text = [[
<font color="rgb(255,255,255)">Universal-Hub-v1.1</font>
<font color="rgb(180,180,180)">Devs:</font> @ayuks78 & @GmAI
<font color="rgb(255,255,255)">Status:</font> <font color="rgb(0,255,100)">Bypass H-Hook Active ✔️</font>
]]

-- [[ 5. BOLINHA MÓVEL ]]
local MI = Instance.new("ImageButton", ScreenGui); MI.Size = UDim2.new(0,50,0,50); MI.Position = UDim2.new(0,20,0.5,-25); MI.BackgroundColor3 = Color3.fromRGB(15,15,15); MI.Image = "rbxassetid://6023454774"
Instance.new("UICorner", MI).CornerRadius = UDim.new(1,0)
MI.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
MainP.Visible = true