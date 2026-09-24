local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId
local JobId = game.JobId

local function SafeServerHop()
    print("[SERVER HOP] Mencari server sepi yang tersedia...")
    
    -- Mengambil daftar server publik
    local ApiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(ApiUrl))
    end)

    if success and result and result.data then
        local validServers = {}

        for _, server in ipairs(result.data) do
            -- Filter: Pilih server yang bukan server saat ini dan memiliki sisa slot aman (misal 1-3 player)
            if server.id ~= JobId and server.playing >= 1 and server.playing <= 3 and server.playing < server.maxPlayers then
                table.insert(validServers, server.id)
            end
        end

        -- Ambil salah satu server secara acak dari daftar server sepi agar tidak bertabrakan dengan player lain
        if #validServers > 0 then
            local randomServerId = validServers[math.random(1, #validServers)]
            print("[SERVER HOP] Mencoba masuk ke server target ID: " .. randomServerId)
            
            local tpSuccess, tpErr = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId)
            end)

            if not tpSuccess then
                warn("[SERVER HOP] Teleport gagal, mencoba ulang dalam 2 detik...")
                task.wait(2)
                SafeServerHop()
            end
        else
            warn("[SERVER HOP] Tidak ada server sepi yang cocok saat ini, mencoba ulang...")
            task.wait(2)
            SafeServerHop()
        end
    else
        warn("[SERVER HOP] Gagal mengambil API server, mencoba ulang...")
        task.wait(2)
        SafeServerHop()
    end
end

-- Deteksi jika Teleport Gagal saat proses pemindahan
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    warn("[SERVER HOP] Teleport Init Failed: " .. tostring(errorMessage) .. ". Mencari server baru...")
    task.wait(1)
    SafeServerHop()
end)

-- Eksekusi
SafeServerHop()
