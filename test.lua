--//WAIT UNTIL GAME LOADS PROPERLY
repeat wait() until game:IsLoaded()
if not game.PlaceId == 8737899170 or not game.PlaceId == 15502339080 or not game.PlaceId == 15588442388 then wait(9e9) end
print('executed')

wait(20)

--//VARIABLES
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local lighting = game.Lighting
local terrain = game.Workspace.Terrain
local serverStats = game:GetService("Stats").Network.ServerStatsItem
local dataPing = serverStats["Data Ping"]:GetValueString()
local pingValue = tonumber(dataPing:match("(%d+)"))
local p = tostring(Players.LocalPlayer)
local Library = require(game.ReplicatedStorage:WaitForChild('Library'))
local NiggasToAvoid = {
    "shwalalala1",
    "ShwaDev",
    "ShwaDevZ",
    "ShwaDevY",
    "ShwaDevX",
    "ShwaDevW",
    "historianaverage",
    "centerunlikely",
    "MrIppo"
}
local thingsTosnipe = {
    ["Fortune"] = getgenv().Settings.Books.FortunePrice,
    ["Chest Mimic"] = getgenv().Settings.Books.ChestMimicPrice,
    ["Lucky Block"] = getgenv().Settings.Books.LuckyBlockPrice,
    ["Shiny Hunter"] = getgenv().Settings.Books.ShinyHunterPrice,
    ["Huge Hunter"] = getgenv().Settings.Books.HugeHunterPrice,
    ["Titanic Christmas Present"] = getgenv().Settings.Present.TitanicPresentPrice,
    ["X-Large Christmas Present"] = getgenv().Settings.Present.XLargeChristmasPrice
}
local keywords = {
    ["Royalty"] = getgenv().Settings.Charm.RoyaltyPrice,
    ["Exclusive"] = getgenv().Settings.Pets.EggPrice,
    ["Spinny"]= getgenv().Settings.Other.SpinnyPrice,
    ["Upper"] = getgenv().Settings.Other.UpperKey,
    ["Lower"] = getgenv().Settings.Other.LowerKey
}

--//TP FUNCTION
local function serverHop(id)
    repeat
        local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s"
        local req = request({ Url = string.format(sfUrl, id, "Desc", 100) })
        local body = HttpService:JSONDecode(req.Body)
        req = request({ Url = string.format( sfUrl .. "&cursor=" .. body.nextPageCursor, id, "Desc", 100), })
        body = HttpService:JSONDecode(req.Body)
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
    until game.placeId ~= 8737899170
end

--//TP TO PLAZA
wait(20)
if game.placeId ~= getgenv().Settings.place then
    pcall(serverHop, getgenv().Settings.place)
    wait(60)
end

wait(10)
local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")

--//AVOID ALTS
for i, v in pairs(game:GetService("Players"):GetChildren()) do
    for _, username in ipairs(NiggasToAvoid) do
        if v.Name == username and p ~= username then
            pcall(serverHop, getgenv().Settings.place)
            wait(60)
        end
    end
end

--//FUNCTION REGION
local function formatNumber(number)
    return tostring(number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function sendUpdate(webhook, user, item, gems, version, isSniped, timeTook)
    local gemamount = tonumber(game:GetService("Players").LocalPlayer.leaderstats["💎 Diamonds"].Value)
    local embed
    if version then
        if version == 1 then
            version = "Golden"
        elseif version == 2 then
            version = "Rainbow"
        else
            version = "Normal"
        end
        embed = {
            {
                ['title'] = "Sniped! | Took: " ..tostring(timeTook),
                ["color"] = tonumber(0x32CD32),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "**USER:**",
                        ['value'] = tostring(user),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**ITEM:**",
                        ['value'] = tostring(item),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**PET VERSION:**",
                        ['value'] = tostring(version),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**COST:**",
                        ['value'] = formatNumber(gems),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**REMAINING :gem:: **",
                        ['value'] = formatNumber(gemamount)
                    }
                }
            }
        }
    else
        embed = {
            {
                ['title'] = "Sniped! | Took: " ..tostring(timeTook),
                ["color"] = tonumber(0x32CD32),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "**USER:**",
                        ['value'] = tostring(user),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**ITEM:**",
                        ['value'] = tostring(item),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**PET VERSION:**",
                        ['value'] = "Normal",
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**COST:**",
                        ['value'] = formatNumber(gems),
                        ['inline'] = true
                    },
                    {
                        ['name'] = "**REMAINING :gem:: **",
                        ['value'] = formatNumber(gemamount)
                    }
                }
            }
        }
    end
    local message = {
        ['content'] = "@everyone",
        ['embeds'] = embed
    }

    local messageFail = {
        ['content'] = "",
        ['embeds'] = {
            {
                ['title'] = "Failed to Snipe!",
                ["color"] = tonumber(0xFF0000),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "**ITEM:**",
                        ['value'] = tostring(item)
                    },
                    {
                        ['name'] = "**COST:**",
                        ['value'] = formatNumber(gems)
                    }
                }
            }
        }
    }

    if isSniped == true then
        local jsonMessage = HttpService:JSONEncode(message)
        HttpService:PostAsync(webhook, jsonMessage)
    else
        local jsonMessage = HttpService:JSONEncode(messageFail)
        HttpService:PostAsync(webhook, jsonMessage)
    end
end

local function checklisting(uid, gems, item, version, playerid)
    gems = tonumber(gems)
    local type = {}
    pcall(function()
      type = Library.Directory.Pets[item]
    end)
    
    if type.huge and gems <= getgenv().Settings.Pets.HugePrice then
        local startTick = os.clock()
        local shwa = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        sendUpdate(getgenv().Settings.webhook, p, item, gems, version, shwa, endTick)
        print('Successfully Sniped ', item)
    elseif type.titanic and gems <= getgenv().Settings.Pets.TitanicPetPrice then
        local startTick = os.clock()
        local shwa = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        sendUpdate(getgenv().Settings.webhook, p, item, gems, version, shwa, endTick)
        print('Successfully Sniped ', item)
    elseif type.exclusiveLevel and not string.find(item, 'Coin') and not string.find(item, 'Banana') and gems <= getgenv().Settings.Pets.ExclusivePetPrice then
        local startTick = os.clock()
        local shwa = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        local endTick = os.clock() - startTick
        sendUpdate(getgenv().Settings.webhook, p, item, gems, version, shwa, endTick)
        print('Successfully Sniped ', item)
    end
    for i, v in pairs(keywords) do
        if string.find(item, i) and gems <= v then
            buyItem(playerid, uid)
            print('Successfully Sniped ', item)
        end
    end
    for i, v in pairs(thingsTosnipe) do
        if item == i and gems <= v then
            local startTick = os.clock()
            local shwa = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
            local endTick = os.clock() - startTick
            sendUpdate(getgenv().Settings.webhook, p, item, gems, version, shwa, endTick)
            print('Successfully Sniped ', item)
        end
    end
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

--//CHECKS BOOTH FOR SALE
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
                            checklisting(uid, gems, item, version, playerID)
                        end
                    end
                end
            end
        end
    end
end)

--//JUMP
local niggaJump = coroutine.create(function ()
    while 1 do
        wait(5)
        game.Players.LocalPlayer.Character.Humanoid.Jump = true
    end
end)
coroutine.resume(niggaJump)

--//Anti AFK
local VirtualUser=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

--//AUTO RECONNECT CUZ ISP BEING GAY
task.spawn(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        game.Players.LocalPlayer:Kick("Found An Error, Reconnecting...")
        print("Found An Error, Reonnecting...")
        wait(0.1)
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end);
end)

--//OPTIMIZATION
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 0
lighting.GlobalShadows = false
lighting.FogStart = 0
lighting.FogEnd = 0
lighting.Brightness = 0
settings().Rendering.QualityLevel = "Level01"
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

--//DEAD SERVER CHECK
local isServerDead = coroutine.create(function ()
    local isDead = false
    while not isDead do
        wait(10)
        local Playerss = Players:GetPlayers()
        local count = #Playerss

        if count <= getgenv().Settings.num_of_players_to_tp then
            isDead = true
            pcall(serverHop, getgenv().Settings.place)
            wait(60)
        end
    end
end)
coroutine.resume(isServerDead)

--//TP TO ANOTHER SERVER AFTER 40MINS
-- wait(2400)
--repeat
--    pcall(serverHop, getgenv().Settings.place)
--    wait(5)
--until game.placeId ~= getgenv().Settings.place
