repeat task.wait() until game:IsLoaded()
wait(30)

local Players = game:GetService("Players")
local getPlayers = Players:GetPlayers()
local PlayerInServer = #getPlayers
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")
local lighting = game.Lighting
local terrain = game.Workspace.Terrain

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
    local Library = require(ReplicatedStorage:WaitForChild('Library'))
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

local function create_platform(x, y, z)
    local p = Instance.new("Part")
    p.Anchored = true
    p.Name = "plat"
    p.Position = Vector3.new(x, y, z)
    p.Size = Vector3.new(10, 1, 10)
    p.Parent = game.Workspace
end

local function teleport(x, y, z)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Wait for the character to be available
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(x, y, z))
    end
end

--//CREATE PLATFORM BENEATH THEN TP THERE
create_platform(-922, 190, -2338)
local aa = game.Workspace:FindFirstChild("plat")
repeat
    wait()
until aa ~= nil
teleport(-922, 195, -2338)

--//Anti AFK
local VirtualUser=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

--//OPTIMIZATION
setfpscap(10)
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 0
lighting.GlobalShadows = false
lighting.FogStart = 0
lighting.FogEnd = 0
lighting.Brightness = 0
for i, v in pairs(game:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    end
end

for i, e in pairs(lighting:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end
game:GetService('RunService'):Set3dRenderingEnabled(false)

--//AUTO RECONNECT CUZ ISP BEING GAY
task.spawn(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        game.Players.LocalPlayer:Kick("Found An Error, Reconnecting...")
        print("Found An Error, Reonnecting...")
        wait(0.1)
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end);
end)

game:GetService("RunService").Stepped:Connect(function()
    PlayerInServer = #getPlayers
    if PlayerInServer < 25 then
        serverHop(place)
    end
end)
