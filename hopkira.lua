local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local PlaceId = game.PlaceId
local JobId = game.JobId

local autoHopEnabled = false
local maxThreshold = 1

-- Fungsi Server Hop Utama
local function SafeServerHop(maxPlayersThreshold)
    maxPlayersThreshold = tonumber(maxPlayersThreshold) or 1
    
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
            
            local tpSuccess, tpErr = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId)
            end)

            if not tpSuccess then
                task.wait(2)
                SafeServerHop(maxPlayersThreshold)
            end
        else
            task.wait(2)
            SafeServerHop(maxPlayersThreshold)
        end
    else
        task.wait(2)
        SafeServerHop(maxPlayersThreshold)
    end
end

-- ===============================================
-- MONOCHROME GUI CREATION
-- ===============================================

-- Hapus GUI lama jika ada
if CoreGui:FindFirstChild("KiraServerHopGui") then
    CoreGui.KiraServerHopGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiraServerHopGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Bingkai Utama (Frame Hitam dengan Border Tipis)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 270)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 50)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Header Title (Hitam Putih Clean)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 40)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 5)
Title.Size = UDim2.new(1, -24, 0, 18)
Title.Font = Enum.Font.GothamBold
Title.Text = "KIRA SERVER HOPPER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = Header
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 12, 0, 22)
Subtitle.Size = UDim2.new(1, -24, 0, 14)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Status: Idle"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Info Jumlah Player
local InfoFrame = Instance.new("Frame")
InfoFrame.Parent = MainFrame
InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InfoFrame.BorderSizePixel = 0
InfoFrame.Position = UDim2.new(0, 12, 0, 50)
InfoFrame.Size = UDim2.new(1, -24, 0, 30)

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoFrame

local PlayerCountLabel = Instance.new("TextLabel")
PlayerCountLabel.Parent = InfoFrame
PlayerCountLabel.BackgroundTransparency = 1
PlayerCountLabel.Size = UDim2.new(1, 0, 1, 0)
PlayerCountLabel.Font = Enum.Font.GothamMedium
PlayerCountLabel.Text = "Players in Server: " .. #Players:GetPlayers()
PlayerCountLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
PlayerCountLabel.TextSize = 11

Players.PlayerAdded:Connect(function()
    PlayerCountLabel.Text = "Players in Server: " .. #Players:GetPlayers()
end)
Players.PlayerRemoving:Connect(function()
    PlayerCountLabel.Text = "Players in Server: " .. #Players:GetPlayers()
end)

-- Section Threshold Max Player
local ThresholdLabel = Instance.new("TextLabel")
ThresholdLabel.Parent = MainFrame
ThresholdLabel.BackgroundTransparency = 1
ThresholdLabel.Position = UDim2.new(0, 12, 0, 88)
ThresholdLabel.Size = UDim2.new(0, 130, 0, 25)
ThresholdLabel.Font = Enum.Font.Gotham
ThresholdLabel.Text = "Max Players Limit:"
ThresholdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ThresholdLabel.TextSize = 11
ThresholdLabel.TextXAlignment = Enum.TextXAlignment.Left

local InputBox = Instance.new("TextBox")
InputBox.Parent = MainFrame
InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputBox.Position = UDim2.new(1, -62, 0, 88)
InputBox.Size = UDim2.new(0, 50, 0, 25)
InputBox.Font = Enum.Font.GothamBold
InputBox.Text = "1"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 12

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 4)
InputCorner.Parent = InputBox

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(70, 70, 70)
InputStroke.Thickness = 1
InputStroke.Parent = InputBox

InputBox.FocusLost:Connect(function()
    local val = tonumber(InputBox.Text)
    if val then
        maxThreshold = val
    else
        InputBox.Text = tostring(maxThreshold)
    end
end)

-- Tombol Hop Server (Kontras Putih)
local HopButton = Instance.new("TextButton")
HopButton.Parent = MainFrame
HopButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
HopButton.Position = UDim2.new(0, 12, 0, 125)
HopButton.Size = UDim2.new(1, -24, 0, 35)
HopButton.Font = Enum.Font.GothamBold
HopButton.Text = "HOP SERVER"
HopButton.TextColor3 = Color3.fromRGB(10, 10, 10)
HopButton.TextSize = 12

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = HopButton

HopButton.MouseButton1Click:Connect(function()
    Subtitle.Text = "Status: Searching Server..."
    HopButton.Text = "SEARCHING..."
    SafeServerHop(maxThreshold)
end)

-- Tombol Auto Hop
local AutoHopButton = Instance.new("TextButton")
AutoHopButton.Parent = MainFrame
AutoHopButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
AutoHopButton.Position = UDim2.new(0, 12, 0, 170)
AutoHopButton.Size = UDim2.new(1, -24, 0, 35)
AutoHopButton.Font = Enum.Font.GothamBold
AutoHopButton.Text = "AUTO HOP [OFF]"
AutoHopButton.TextColor3 = Color3.fromRGB(150, 150, 150)
AutoHopButton.TextSize = 12

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoHopButton

local AutoStroke = Instance.new("UIStroke")
AutoStroke.Color = Color3.fromRGB(50, 50, 50)
AutoStroke.Thickness = 1
AutoStroke.Parent = AutoHopButton

AutoHopButton.MouseButton1Click:Connect(function()
    autoHopEnabled = not autoHopEnabled
    if autoHopEnabled then
        AutoHopButton.Text = "AUTO HOP [ON]"
        AutoHopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        AutoHopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        AutoStroke.Color = Color3.fromRGB(255, 255, 255)
        Subtitle.Text = "Status: Auto-Hop Active"
        
        task.spawn(function()
            while autoHopEnabled do
                task.wait(4)
                if #Players:GetPlayers() > maxThreshold then
                    Subtitle.Text = "Status: Hopping..."
                    SafeServerHop(maxThreshold)
                    break
                end
            end
        end)
    else
        AutoHopButton.Text = "AUTO HOP [OFF]"
        AutoHopButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        AutoHopButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        AutoStroke.Color = Color3.fromRGB(50, 50, 50)
        Subtitle.Text = "Status: Idle"
    end
end)

-- Footer Info
local Footer = Instance.new("TextLabel")
Footer.Parent = MainFrame
Footer.BackgroundTransparency = 1
Footer.Position = UDim2.new(0, 12, 0, 240)
Footer.Size = UDim2.new(1, -24, 0, 15)
Footer.Font = Enum.Font.Gotham
Footer.Text = "KIR4A Loader v1.0"
Footer.TextColor3 = Color3.fromRGB(80, 80, 80)
Footer.TextSize = 9

-- Error Handling
TeleportService.TeleportInitFailed:Connect(function()
    Subtitle.Text = "Status: Retrying..."
    task.wait(1)
    SafeServerHop(maxThreshold)
end)
