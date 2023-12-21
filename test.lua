print('executed')

local Players = game:GetService("Players")
local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Players.LocalPlayer.PlayerScripts["Idle Tracking"].Disabled = true

local function serverHop()
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
    local req = request({ Url = string.format(sfUrl, game.placeId, "Desc", 100) })
    local body = HttpService:JSONDecode(req.Body)
    --req = request({ Url = string.format( sfUrl .. "&cursor=" .. body.nextPageCursor, config.placeId, config.servers.sort, config.servers.count ), })
    task.wait(0.1)
    local servers = {}
    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing > 40 and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end

    local randomCount = #servers
    if not randomCount then
        randomCount = 2
    end

    TeleportService:TeleportToPlaceInstance(game.placeId, servers[math.random(1, randomCount)], Players.LocalPlayer)
end

local function checklisting(uid, gems, item, version, shiny, amount, username, playerid)
    gems = tonumber(gems)
    if string.find(item, "Huge") and gems <= getgenv().Settings.HugePrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    elseif item == "X-Large Christmas Present" and gems <= getgenv().Settings.ChristmasPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    elseif string.find(item, "Titanic") and gems <= getgenv().Settings.TitanicPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    elseif string.find(item, "Exclusive") and gems <= getgenv().Settings.ExclusivePrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    elseif gems <= getgenv().Settings.Anything then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    end
end

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    local playerID = message['PlayerID']
    if type(message) == "table" then
        local listing = message["Listings"]
        for key, value in pairs(listing) do
            if type(value) == "table" then
                local uid = key
                local gems = value["DiamondCost"]
                local itemdata = value["ItemData"]
                if itemdata then
                    local data = itemdata["data"]
                    if data then
                        local item = data["id"]
                        local version = data["pt"]
                        local shiny = data["sh"]
                        local amount = data["_am"]
                        checklisting(uid, gems, item, version, shiny, amount, username , playerID)
                    end
                end
            end
        end
    end
end)

local isServerDead = coroutine.create(function ()
    while 1 do
        wait(10)
        local Players = game:GetService("Players"):GetPlayers()
        local count = #Players

        if count <= getgenv().Settings.num_of_players_to_tp then
            pcall(serverHop)
        end
    end
end)
coroutine.resume(isServerDead)
