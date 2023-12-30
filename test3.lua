repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local getPlayers = Players:GetPlayers()
local PlayerInServer = #getPlayers
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild('Library'))
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")

for i = 1, PlayerInServer do
    for ii = 1,#alts do
        if getPlayers[i].Name == alts[ii] and alts[ii] ~= Players.LocalPlayer.Name then
            serverHop(place)
        end
    end
end

 local function processListingInfo(uid, gems, item, version, shiny, amount, boughtFrom, boughtStatus, mention, timeTook)
    local gemamount = Players.LocalPlayer.leaderstats["💎 Diamonds"].Value
    local snipeMessage = Players.LocalPlayer.Name .. " just sniped a "
    local weburl, webContent, webcolor
    if version then
        if version == 2 then
            version = "Rainbow"
        elseif version == 1 then
            version = "Golden"
        end
    else
       version = "Normal"
    end

    snipeMessage = snipeMessage .. version

    if shiny then
        snipeMessage = snipeMessage .. " Shiny"
    end
  
    snipeMessage = snipeMessage .. " " .. (item)

    if boughtStatus then
	    webcolor = tonumber(0x32CD32)
	    weburl = snipeSuccess
	    if mention then 
            webContent = "<@".. userid ..">"
        else
	        webContent = ""
	    end
    else
	    weburl = snipeFail
        webcolor = tonumber(0xFF0000)
    end

    local message1 = {
        ['content'] = webContent,
        ['embeds'] = {
            {
                ['title'] = snipeMessage,
                ["color"] = webcolor,
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "PRICE:",
                        ['value'] = tostring(gems) .. " GEMS",
                    },
                    {
                        ['name'] = "BOUGHT FROM:",
                        ['value'] = tostring(boughtFrom),
                    },
                    {
                        ['name'] = "AMOUNT:",
                        ['value'] = tostring(amount),
                    },
                    {
                        ['name'] = "REMAINING GEMS:",
                        ['value'] = tostring(gemamount),
                    },
                    {
                        ['name'] = "PETID:",
                        ['value'] = tostring(uid),
                    },
                    {
                        ['name'] = "TIME TOOK:",
                        ['value'] = tostring(timeTook)
                    }
                },
            },
        }
    }

    local jsonMessage = HttpService:JSONEncode(message1)
    local success, webMessage = pcall(function()
	    HttpService:PostAsync(weburl, jsonMessage)
    end)
    if success == false then
        local response = request({
            Url = weburl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonMessage
        })
    end
end

local function checklisting(uid, cost, item, version, shiny, amount, username, playerid)
    local purchase = ReplicatedStorage.Network.Booths_RequestPurchase
    gems = tonumber(gems)
    local ping = false
    local type = {}
    pcall(function()
        type = Library.Directory.Pets[item]
    end)

    if amount == nil then
        amount = 1
    end

    if type.huge and cost <= 1000000 then
        local startTick = os.clock()
        local boughtPet = purchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        if boughtPet then
            ping = true
        end
        processListingInfo(uid, cost, item, version, shiny, amount, username, boughtPet, ping, endTick)
    elseif type.exclusiveLevel and not string.find(item, "Banana") and not string.find(item, "Coin") and cost <= 10000 then
        local startTick = os.clock()
        local boughtPet = purchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        processListingInfo(uid, cost, item, version, shiny, amount, username, boughtPet, ping, endTick)
    elseif type.titanic and cost <= 1000000 then
        local startTick = os.clock()
        local boughtPet = purchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        if boughtPet then
            ping = true
        end
        processListingInfo(uid, cost, item, version, shiny, amount, username, boughtPet, ping, endTick)
    elseif item == "Titanic Christmas Present" and cost <= 25000 then
        local startTick = os.clock()
        local boughtPet = purchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        processListingInfo(uid, cost, item, version, shiny, amount, username, boughtPet, ping, endTick)
    elseif string.find(item, "Exclusive") and cost <= 50000 then
        local startTick = os.clock()
        local boughtPet = purchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        processListingInfo(uid, cost, item, version, shiny, amount, username, boughtPet, ping, endTick)
    end
end

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    if message ~= nil then
        if type(message) == "table" then
			local playerID = message['PlayerID']
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
                            checklisting(uid, gems, item, version, shiny, amount, username, playerID)
                        end
                    end
                end
            end
        end
    end
end)

--//TP FUNCTION
local function serverHop(id)
    local deep
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s"
    local req = request({ Url = string.format(sfUrl, id, "Desc", 100) })
    local body = HttpService:JSONDecode(req.Body)
    if id == 15502339080 then
        deep = math.random(1, 4)
    else
        deep = 1
    end
    if deep > 1 then
        for i = 1, deep, 1 do
             req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, id, "Desc", 100) }) 
             body = http:JSONDecode(req.Body)
             task.wait(0.1)
        end
    end
    task.wait(0.1)
    local servers = {}
    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing >= 35 and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end

    local randomCount = #servers
    if not randomCount then
        randomCount = 2
    end

    TeleportService:TeleportToPlaceInstance(id, servers[math.random(1, randomCount)], Players.LocalPlayer)
end

game:GetService("RunService").Stepped:Connect(function()
    PlayerInServer = #getPlayers
    if PlayerInServer < 25 then
        serverHop(place)
    end
end)
