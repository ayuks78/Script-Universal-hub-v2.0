-- [[ UNIVERSAL-HUB v2.4 - FINAL STRIKE ]]
-- @ayuks78 & @GmAI
-- Design: Black/White/Blue RGB | Animation: Central Fade

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local camera = workspace.CurrentCamera

-- [[ CONFIGURAÇÃO ]]
getgenv().Config = {
    Aimbot = false,
    Hitbox = false,
    HitSize = 15,
    Esp = false,
    Noclip = false,
    Boost = false,
    FovSize = 150,
    Smoothness = 0.15 -- Mediano (0.1 suave, 0.5 forte)
}

-- [[ SISTEMA DE FOV ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 150, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

-- [[ INTERFACE ]]
local UI = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
UI.Name = "Universal_v24"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 0, 0, 0) -- Inicia em 0 para animação
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.ClipsDescendants = true
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Barra RGB Azul em baixo
local RGBBar = Instance.new("Frame", Main)
RGBBar.Size = UDim2.new(1, 0, 0, 3)
RGBBar.Position = UDim2.new(0, 0, 1, -3)
RGBBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
RGBBar.BorderSizePixel = 0

-- Efeito Pulsante Azul
task.spawn(function()
    while task.wait() do
        for i = 0, 1, 0.01 do
            RGBBar.BackgroundColor3 = Color3.fromHSV(0.6, 0.8, 0.5 + (math.sin(tick()*2)*0.5))
            task.wait()
        end
    end
end)

-- Sidebar (Escritório)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, -20); Sidebar.Position = UDim2.new(0, 10, 0, 10); Sidebar.BackgroundTransparency = 1

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -170, 1, -40); Container.Position = UDim2.new(0, 160, 0, 15); Container.BackgroundTransparency = 1

-- [[ SISTEMA DE ABAS ]]
local Tabs = {}
function CreateTab(name)
    local P = Instance.new("ScrollingFrame", Container)
    P.Size = UDim2.new(1, 0, 1, 0); P.Visible = false; P.BackgroundTransparency = 1; P.ScrollBarThickness = 0
    Instance.new("UIListLayout", P).Padding = UDim.new(0, 8)
    
    local B = Instance.new("TextButton", Sidebar)
    B.Size = UDim2.new(1, 0, 0, 32); B.Text = name; B.BackgroundColor3 = Color3.fromRGB(15, 15, 20); B.TextColor3 = Color3.fromRGB(255, 255, 255); B.Font = "GothamBold"; B.TextSize = 10; Instance.new("UICorner", B)
    
    B.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.P.Visible = false; v.B.BackgroundColor3 = Color3.fromRGB(15, 15, 20) end
        P.Visible = true; B.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end)
    Tabs[#Tabs+1] = {P = P, B = B}
    return P
end

-- Componentes
function AddToggle(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.Text = text; l.TextColor3 = Color3.fromRGB(255, 255, 255); l.TextXAlignment = 0; l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 11
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 35, 0, 18); b.Position = UDim2.new(1, -45, 0.5, -9); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.Text = ""; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    
    b.MouseButton1Click:Connect(function()
        getgenv().Config[key] = not getgenv().Config[key]
        TS:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = getgenv().Config[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)}):Play()
        if key == "Aimbot" then FOVCircle.Visible = getgenv().Config[key] end
    end)
end

-- Criar Abas
local MainT = CreateTab("Main")
local VisualT = CreateTab("Visual")
local MiscT = CreateTab("Misc")

AddToggle(MainT, "Aimbot Magnetic (Smooth)", "Aimbot")
AddToggle(MainT, "Hitbox Physical", "Hitbox")
AddToggle(VisualT, "ESP Name/Health/Dist", "Esp")
AddToggle(MiscT, "Noclip Ghost", "Noclip")
AddToggle(MiscT, "Potato Mode (FPS)", "Boost")

-- [[ FUNÇÕES LÓGICAS (CORRIGIDAS) ]]

-- Aimbot Magnético
local function GetClosest()
    local target, closest = nil, getgenv().Config.FovSize
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < closest then target = v; closest = mag end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = getgenv().Config.FovSize
    
    if getgenv().Config.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosest()
        if target then
            local targetPos = camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            local mousePos = UIS:GetMouseLocation()
            -- Interpolação para suavidade mediana
            local finalPos = Vector2.new(
                (targetPos.X - mousePos.X) * getgenv().Config.Smoothness,
                (targetPos.Y - mousePos.Y) * getgenv().Config.Smoothness
            )
            mousemoverel(finalPos.X, finalPos.Y)
        end
    end
    
    -- Hitbox Proativa
    if getgenv().Config.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(getgenv().Config.HitSize, getgenv().Config.HitSize, getgenv().Config.HitSize)
                v.Character.HumanoidRootPart.CanCollide = false
                v.Character.HumanoidRootPart.Transparency = 0.8
            end
        end
    end
end)

-- Boost FPS Real
task.spawn(function()
    while task.wait(2) do
        if getgenv().Config.Boost then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
                if v:IsA("PostProcessEffect") or v:IsA("Atmosphere") then v:Destroy() end
            end
            settings().Rendering.QualityLevel = 1
        end
    end
end)

-- [[ ANIMAÇÃO DE ABERTURA ]]
Main.Visible = true
TS:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {Size = UDim2.new(0, 580, 0, 320)}):Play()

-- Botão de Minimizar (Lado)
local OpenBtn = Instance.new("ImageButton", UI)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22); OpenBtn.Image = "rbxassetid://6023454774"; OpenBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5); Instance.new("UICorner", OpenBtn); Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 120, 255)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

Tabs[1].P.Visible = true
print("Universal Hub v2.4 Loaded.")