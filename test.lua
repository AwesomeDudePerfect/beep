repeat task.wait() until game:IsLoaded()

print('executed')

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

--//Anti AFK
local VirtualUser=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

-- Players.LocalPlayer.PlayerScripts["Idle Tracking"].Disabled = true

local function serverHop(id)
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
    local req = request({ Url = string.format(sfUrl, id, "Desc", 100) })
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

if game.placeId ~= 15502339080 then
    pcall(serverHop, 15502339080)
end

local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")

local function checklisting(uid, gems, item, version, shiny, amount, username, playerid)
    gems = tonumber(gems)
    if string.find(item, "Huge") and gems <= getgenv().Settings.HugePrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif string.find(item, "Titanic") and item ~= "Titanic Christmas Present" and gems <= getgenv().Settings.TitanicPetPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif string.find(item, "Exclusive") and gems <= getgenv().Settings.ExclusivePrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "Titanic Christmas Present" and gems <= getgenv().Settings.TitanicPresentPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "X-Large Christmas Present" and gems <= getgenv().Settings.XLargeChristmasPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "Fortune" and gems <= getgenv().Settings.FortunePrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "Chest Mimic" and gems <= getgenv().Settings.ChestMimicPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "Lucky Block" and gems <= getgenv().Settings.LuckyBlockPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "Shiny Hunter" and gems <= getgenv().Settings.ShinyHunterPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif item == "Huge Hunter" and gems <= getgenv().Settings.HugeHunterPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif string.find(item, "Royalty") and gems <= getgenv().Settings.RoyaltyPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
    elseif string.find(item, "Spinny") and gems <= getgenv().Settings.SpinnyPrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print('Successfully Sniped ', item)
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

local niggaJump = coroutine.create(function ()
    while 1 do
        wait(5)
        game.Players.LocalPlayer.Character.Humanoid.Jump = true
    end
end)
coroutine.resume(niggaJump)

local isServerDead = coroutine.create(function ()
    local isDead = false
    while not isDead do
        wait(10)
        local Players = game:GetService("Players"):GetPlayers()
        local count = #Players

        if count <= getgenv().Settings.num_of_players_to_tp then
            isDead = true
            pcall(serverHop, 15502339080)
        end
    end
end)
coroutine.resume(isServerDead)
