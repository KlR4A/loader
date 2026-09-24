local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local JobId = game.JobId

-- State & Settings
local autoHopEnabled = false
local maxThreshold = 1
local fpsBoostActive = false
local flyGuiInstance = nil

-- Hapus UI lama jika ada
if CoreGui:FindFirstChild("KIR4A_Hub") then
    CoreGui.KIR4A_Hub:Destroy()
end

-- ===============================================
-- LOGIKA FPS BOOSTER
-- ===============================================
local function applyFPSBoost()
    if fpsBoostActive then return end
    fpsBoostActive = true

    pcall(function()
        if setfpscap then setfpscap(240) end
    end)

    pcall(function()
        local settings = settings()
        settings.Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings.Rendering.EditQualityLevel = Enum.QualityLevel.Level01
        if setscriptable then setscriptable(settings.Rendering, "QualityLevel", true) end
    end)

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    Lighting.ClockTime = 12
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.ExposureCompensation = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    for _, v in pairs(Lighting:GetChildren()) do v:Destroy() end

    local function stripToBareMinimum(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or 
           obj:IsA("PostEffect") or obj:IsA("Highlight") or obj:IsA("Explosion") then
            obj:Destroy()
        elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") or 
               obj:IsA("ShirtGraphic") or obj:IsA("Clothing") then
            obj:Destroy()
        elseif obj:IsA("Accessory") or obj:IsA("Hat") then
            obj:Destroy()
        elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
            if obj:IsA("MeshPart") then obj.TextureID = "" end
            if not obj.CanCollide and not obj:IsDescendantOf(LocalPlayer.Character) then
                if not obj:FindFirstChildOfClass("TouchTransmitter") and #obj:GetChildren() == 0 then
                    obj.Transparency = 1
                end
            end
        elseif obj:IsA("Sound") and not obj.Parent:IsA("SoundService") then
            obj:Stop()
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do stripToBareMinimum(obj) end
    Workspace.DescendantAdded:Connect(stripToBareMinimum)

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            for _, item in pairs(p.Character:GetDescendants()) do
                if item:IsA("Accoutrement") or item:IsA("LayeredClothing") then item:Destroy() end
            end
        end
    end

    task.spawn(function()
        while fpsBoostActive do
            task.wait(10)
            collectgarbage("collect")
            collectgarbage("step", 100)
        end
    end)
end

-- ===============================================
-- LOGIKA SERVER HOPPER
-- ===============================================
local function SafeServerHop(maxPlayersThreshold, statusCallback)
    maxPlayersThreshold = tonumber(maxPlayersThreshold) or 1
    if statusCallback then statusCallback("Status: Searching...") end

    local ApiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(ApiUrl))
    end)

    if success and result and result.data then
        local validServers = {}
        for _, server in ipairs(result.data) do
            if server.id ~= JobId and server.playing <= maxPlayersThreshold and server.playing < server.maxPlayers then
                table.insert(validServers, server.id)
            end
        end

        if #validServers > 0 then
            local randomServerId = validServers[math.random(1, #validServers)]
            if statusCallback then statusCallback("Status: Teleporting...") end
            
            local tpSuccess = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId)
            end)

            if not tpSuccess then
                task.wait(2)
                SafeServerHop(maxPlayersThreshold, statusCallback)
            end
        else
            if statusCallback then statusCallback("Status: Retrying...") end
            task.wait(2)
            SafeServerHop(maxPlayersThreshold, statusCallback)
        end
    else
        if statusCallback then statusCallback("Status: Retrying...") end
        task.wait(2)
        SafeServerHop(maxPlayersThreshold, statusCallback)
    end
end

-- ===============================================
-- LOGIKA FLY SCRIPT (BLACK & WHITE DESIGN)
-- ===============================================
local function loadFlyGui()
    if flyGuiInstance and flyGuiInstance.Parent then
        flyGuiInstance.Frame.Visible = not flyGuiInstance.Frame.Visible
        return
    end

    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speed = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")
    local mini = Instance.new("TextButton")
    local mini2 = Instance.new("TextButton") 

    main.Name = "KlR4A_FlyGui"
    main.Parent = LocalPlayer:WaitForChild("PlayerGui")
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false 

    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
    Frame.Size = UDim2.new(0, 190, 0, 57) 
    Frame.Active = true
    Frame.Draggable = true

    up.Name = "up"
    up.Parent = Frame
    up.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Font = Enum.Font.SourceSans
    up.Text = "UP"
    up.TextColor3 = Color3.fromRGB(255, 255, 255)
    up.TextSize = 14.000 

    down.Name = "down"
    down.Parent = Frame
    down.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    down.Position = UDim2.new(0, 0, 0.491, 0)
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Font = Enum.Font.SourceSans
    down.Text = "DOWN"
    down.TextColor3 = Color3.fromRGB(255, 255, 255)
    down.TextSize = 14.000 

    onof.Name = "onof"
    onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    onof.Position = UDim2.new(0.702, 0, 0.491, 0)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "fly"
    onof.TextColor3 = Color3.fromRGB(0, 0, 0)
    onof.TextSize = 14.000 

    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.Position = UDim2.new(0.469, 0, 0, 0)
    TextLabel.Size = UDim2.new(0, 100, 0, 28)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "KlR4A Fly"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true 

    plus.Name = "plus"
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    plus.Position = UDim2.new(0.231, 0, 0, 0)
    plus.Size = UDim2.new(0, 45, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.TextScaled = true
    plus.TextSize = 14.000

    speed.Name = "speed"
    speed.Parent = Frame
    speed.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    speed.Position = UDim2.new(0.468, 0, 0.491, 0)
    speed.Size = UDim2.new(0, 44, 0, 28)
    speed.Font = Enum.Font.SourceSans
    speed.Text = "1"
    speed.TextColor3 = Color3.fromRGB(255, 255, 255)
    speed.TextScaled = true
    speed.TextSize = 14.000

    mine.Name = "mine"
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mine.Position = UDim2.new(0.231, 0, 0.491, 0)
    mine.Size = UDim2.new(0, 45, 0, 29)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(255, 255, 255)
    mine.TextScaled = true
    mine.TextSize = 14.000

    closebutton.Name = "Close"
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    closebutton.Font = Enum.Font.SourceSans
    closebutton.Size = UDim2.new(0, 45, 0, 28)
    closebutton.Text = "X"
    closebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closebutton.TextSize = 30
    closebutton.Position = UDim2.new(0, 0, -1, 27) 

    mini.Name = "minimize"
    mini.Parent = Frame
    mini.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mini.Font = Enum.Font.SourceSans
    mini.Size = UDim2.new(0, 45, 0, 28)
    mini.Text = "-"
    mini.TextColor3 = Color3.fromRGB(255, 255, 255)
    mini.TextSize = 40
    mini.Position = UDim2.new(0, 44, -1, 27) 

    mini2.Name = "minimize2"
    mini2.Parent = Frame
    mini2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mini2.Font = Enum.Font.SourceSans
    mini2.Size = UDim2.new(0, 45, 0, 28)
    mini2.Text = "+"
    mini2.TextColor3 = Color3.fromRGB(255, 255, 255)
    mini2.TextSize = 40
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.Visible = false 

    local speeds = 1 
    local speaker = LocalPlayer 
    local nowe = false 

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { 
            Title = "KlR4A Fly",
            Text = "Fly Menu Active",
            Duration = 3
        })
    end)

    onof.MouseButton1Down:connect(function() 
        if nowe == true then
            nowe = false 
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        else 
            nowe = true
            for i = 1, speeds do
                spawn(function() 
                    local hb = game:GetService("RunService").Heartbeat
                    local tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end 
                end)
            end
            game.Players.LocalPlayer.Character.Animate.Disabled = true
            local Char = game.Players.LocalPlayer.Character
            local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController") 

            for i,v in next, Hum:GetPlayingAnimationTracks() do
                v:AdjustSpeed(0)
            end
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        local plr = game.Players.LocalPlayer
        local isR6 = plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6
        local torso = isR6 and plr.Character.Torso or plr.Character.UpperTorso

        local ctrl = {f = 0, b = 0, l = 0, r = 0}
        local lastctrl = {f = 0, b = 0, l = 0, r = 0}
        local maxspeed = 50
        local curSpeed = 0

        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = torso.CFrame
        local bv = Instance.new("BodyVelocity", torso)
        bv.velocity = Vector3.new(0,0.1,0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

        if nowe == true then
            plr.Character.Humanoid.PlatformStand = true
        end

        while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
            if isR6 then
                game:GetService("RunService").RenderStepped:Wait() 
            else
                task.wait()
            end

            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                curSpeed = curSpeed+.5+(curSpeed/maxspeed)
                if curSpeed > maxspeed then curSpeed = maxspeed end
            elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and curSpeed ~= 0 then
                curSpeed = curSpeed-1
                if curSpeed < 0 then curSpeed = 0 end
            end

            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*curSpeed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and curSpeed ~= 0 then
                bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*curSpeed
            else
                bv.velocity = Vector3.new(0,0,0)
            end
            bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*curSpeed/maxspeed),0,0)
        end

        bg:Destroy()
        bv:Destroy()
        plr.Character.Humanoid.PlatformStand = false
        game.Players.LocalPlayer.Character.Animate.Disabled = false
    end) 

    local tis 
    up.MouseButton1Down:connect(function()
        tis = up.MouseEnter:connect(function()
            while tis do
                task.wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
            end
        end)
    end) 
    up.MouseLeave:connect(function() if tis then tis:Disconnect() tis = nil end end) 

    local dis 
    down.MouseButton1Down:connect(function()
        dis = down.MouseEnter:connect(function()
            while dis do
                task.wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
            end
        end)
    end) 
    down.MouseLeave:connect(function() if dis then dis:Disconnect() dis = nil end end)

    plus.MouseButton1Down:connect(function()
        speeds = speeds + 1
        speed.Text = speeds
    end)

    mine.MouseButton1Down:connect(function()
        if speeds > 1 then
            speeds = speeds - 1
            speed.Text = speeds
        end
    end) 

    closebutton.MouseButton1Click:Connect(function() main:Destroy() end) 
    mini.MouseButton1Click:Connect(function()
        up.Visible = false; down.Visible = false; onof.Visible = false; plus.Visible = false; speed.Visible = false; mine.Visible = false; mini.Visible = false; mini2.Visible = true
        Frame.BackgroundTransparency = 1
        closebutton.Position = UDim2.new(0, 0, -1, 57)
    end) 
    mini2.MouseButton1Click:Connect(function()
        up.Visible = true; down.Visible = true; onof.Visible = true; plus.Visible = true; speed.Visible = true; mine.Visible = true; mini.Visible = true; mini2.Visible = false
        Frame.BackgroundTransparency = 0 
        closebutton.Position = UDim2.new(0, 0, -1, 27)
    end)

    flyGuiInstance = main
end

-- ===============================================
-- TAMPILAN UI MAIN HUB (MONOCHROME / DARK THEME)
-- ===============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KIR4A_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.5, -200, 0.25, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1.5

-- Top Navigation Bar
local HeaderText = Instance.new("TextLabel", MainFrame)
HeaderText.Position = UDim2.new(0, 20, 0, 16)
HeaderText.Size = UDim2.new(0, 150, 0, 30)
HeaderText.BackgroundTransparency = 1
HeaderText.Font = Enum.Font.FredokaOne
HeaderText.Text = "KIR4A"
HeaderText.TextColor3 = Color3.fromRGB(245, 245, 245)
HeaderText.TextSize = 28
HeaderText.TextXAlignment = Enum.TextXAlignment.Left

-- Header Control Buttons (Close)
local function createHeaderBtn(xOffset, text)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Position = UDim2.new(1, xOffset, 0, 16)
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 16
    return btn
end

local closeHubBtn = createHeaderBtn(-32, "✕")
closeHubBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Template Pembuat Tombol Kustom (Monochrome Style)
local function createMenuButton(yPos, numText, iconText, mainText)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.Size = UDim2.new(0, 360, 0, 58)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    btn.AutoButtonColor = true
    btn.Text = ""

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(50, 50, 55)
    stroke.Thickness = 1

    -- Icon Box
    local iconLabel = Instance.new("TextLabel", btn)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.Size = UDim2.new(0, 36, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = iconText
    iconLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    iconLabel.TextSize = 22

    -- Index Number
    local numLabel = Instance.new("TextLabel", btn)
    numLabel.Position = UDim2.new(0, 46, 0, 12)
    numLabel.Size = UDim2.new(0, 15, 0, 15)
    numLabel.BackgroundTransparency = 1
    numLabel.Font = Enum.Font.Gotham
    numLabel.Text = numText
    numLabel.TextColor3 = Color3.fromRGB(120, 120, 125)
    numLabel.TextSize = 11

    -- Text Label
    local label = Instance.new("TextLabel", btn)
    label.Position = UDim2.new(0, 75, 0, 0)
    label.Size = UDim2.new(1, -110, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = mainText
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- Arrow Indicator
    local arrow = Instance.new("TextLabel", btn)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.Size = UDim2.new(0, 15, 1, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "›"
    arrow.TextColor3 = Color3.fromRGB(140, 140, 145)
    arrow.TextSize = 18

    return btn, stroke, label
end

-- 1. TOMBOL FPS BOOSTER
local fpsBtn, fpsStroke, fpsText = createMenuButton(65, "1", "⚡", "Fps Booster")
fpsBtn.MouseButton1Click:Connect(function()
    applyFPSBoost()
    fpsText.Text = "Fps Booster [ON]"
    fpsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsStroke.Color = Color3.fromRGB(255, 255, 255)
end)

-- 2. TOMBOL SERVER HOP
local hopBtn, hopStroke, hopText = createMenuButton(135, "2", "🗄", "Server Hop")

-- 3. TOMBOL FLY (Membuka Fly GUI Anda)
local flyBtn, flyStroke, flyText = createMenuButton(205, "3", "🪽", "Fly")
flyBtn.MouseButton1Click:Connect(function()
    loadFlyGui()
end)

-- ===============================================
-- SUB-MENU SERVER HOPPER
-- ===============================================
local HopMenu = Instance.new("Frame", ScreenGui)
HopMenu.Name = "HopMenu"
HopMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
HopMenu.Position = UDim2.new(0.5, -130, 0.3, 0)
HopMenu.Size = UDim2.new(0, 260, 0, 220)
HopMenu.Visible = false
HopMenu.Active = true
HopMenu.Draggable = true

local HopMenuCorner = Instance.new("UICorner", HopMenu)
HopMenuCorner.CornerRadius = UDim.new(0, 12)

local HopMenuStroke = Instance.new("UIStroke", HopMenu)
HopMenuStroke.Color = Color3.fromRGB(60, 60, 65)
HopMenuStroke.Thickness = 1.5

local SubTitle = Instance.new("TextLabel", HopMenu)
SubTitle.Position = UDim2.new(0, 14, 0, 10)
SubTitle.Size = UDim2.new(1, -28, 0, 20)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.GothamBold
SubTitle.Text = "SERVER HOPPER"
SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SubTitle.TextSize = 14
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local StatusLbl = Instance.new("TextLabel", HopMenu)
StatusLbl.Position = UDim2.new(0, 14, 0, 30)
StatusLbl.Size = UDim2.new(1, -28, 0, 15)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.Text = "Status: Idle"
StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLbl.TextSize = 11
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

local LimitLbl = Instance.new("TextLabel", HopMenu)
LimitLbl.Position = UDim2.new(0, 14, 0, 55)
LimitLbl.Size = UDim2.new(0, 130, 0, 25)
LimitLbl.BackgroundTransparency = 1
LimitLbl.Font = Enum.Font.Gotham
LimitLbl.Text = "Max Players Limit:"
LimitLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
LimitLbl.TextSize = 11
LimitLbl.TextXAlignment = Enum.TextXAlignment.Left

local InputBox = Instance.new("TextBox", HopMenu)
InputBox.Position = UDim2.new(1, -64, 0, 55)
InputBox.Size = UDim2.new(0, 50, 0, 25)
InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
InputBox.Font = Enum.Font.GothamBold
InputBox.Text = "1"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 12

local InputCorner = Instance.new("UICorner", InputBox)
InputCorner.CornerRadius = UDim.new(0, 6)

InputBox.FocusLost:Connect(function()
    local val = tonumber(InputBox.Text)
    if val then maxThreshold = val else InputBox.Text = tostring(maxThreshold) end
end)

local DoHopBtn = Instance.new("TextButton", HopMenu)
DoHopBtn.Position = UDim2.new(0, 14, 0, 90)
DoHopBtn.Size = UDim2.new(1, -28, 0, 35)
DoHopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
DoHopBtn.Font = Enum.Font.GothamBold
DoHopBtn.Text = "HOP SERVER NOW"
DoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DoHopBtn.TextSize = 12

local DoHopCorner = Instance.new("UICorner", DoHopBtn)
DoHopCorner.CornerRadius = UDim.new(0, 6)

DoHopBtn.MouseButton1Click:Connect(function()
    SafeServerHop(maxThreshold, function(msg) StatusLbl.Text = msg end)
end)

local AutoHopBtn = Instance.new("TextButton", HopMenu)
AutoHopBtn.Position = UDim2.new(0, 14, 0, 132)
AutoHopBtn.Size = UDim2.new(1, -28, 0, 35)
AutoHopBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
AutoHopBtn.Font = Enum.Font.GothamBold
AutoHopBtn.Text = "AUTO HOP [OFF]"
AutoHopBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
AutoHopBtn.TextSize = 12

local AutoHopCorner = Instance.new("UICorner", AutoHopBtn)
AutoHopCorner.CornerRadius = UDim.new(0, 6)

AutoHopBtn.MouseButton1Click:Connect(function()
    autoHopEnabled = not autoHopEnabled
    if autoHopEnabled then
        AutoHopBtn.Text = "AUTO HOP [ON]"
        AutoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLbl.Text = "Status: Auto-Hop Active"
        task.spawn(function()
            while autoHopEnabled do
                task.wait(4)
                if #Players:GetPlayers() > maxThreshold then
                    SafeServerHop(maxThreshold, function(msg) StatusLbl.Text = msg end)
                    break
                end
            end
        end)
    else
        AutoHopBtn.Text = "AUTO HOP [OFF]"
        AutoHopBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        StatusLbl.Text = "Status: Idle"
    end
end)

local CloseBtn = Instance.new("TextButton", HopMenu)
CloseBtn.Position = UDim2.new(0, 14, 0, 175)
CloseBtn.Size = UDim2.new(1, -28, 0, 30)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "BACK TO MENU"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 11

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    HopMenu.Visible = false
    MainFrame.Visible = true
end)

hopBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    HopMenu.Visible = true
end)
