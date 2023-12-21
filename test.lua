print('executed')

local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

function sendUpdate(uid, gems, item, version, shiny, amount, boughtFrom)
	request({
	Url = getgenv().Settings.Webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = game:GetService("HttpService"):JSONEncode{
            ["content"] = "",
            ["embeds"] = {
			    {
			      ["title"] = "Successful Snipe",
			      ["description"] = "",
			      ["color"] = 5814783,
			      ["fields"] = {
			        {
			          ["name"] = "Stats: ",
			          ["value"] = "**nigga you sniped a:** ``"..item.."`` | **cost:** ``"..gems.."`` ",
                    }
			      },
			      ["author"] = {
			        ["name"] = "Sniper notif"
			      }
			    }
			}
		}
	})
end

local function checklisting(uid, gems, item, version, shiny, amount, username, playerid)
    gems = tonumber(gems)
    if string.find(item, "Huge") and gems <= getgenv().Settings.HugePrice then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        sendUpdate(uid, gems, item, version, shiny, amount, username)
    elseif item == "X-Large Christmas Present" and gems <= 50000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        sendUpdate(uid, gems, item, version, shiny, amount, username)
    elseif string.find(item, "Titanic") and gems <= 50000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        sendUpdate(uid, gems, item, version, shiny, amount, username)
    elseif string.find(item, "Exclusive") and gems <= 500000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        sendUpdate(uid, gems, item, version, shiny, amount, username)
    elseif gems <= 25 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        sendUpdate(uid, gems, item, version, shiny, amount, username)
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

while true do wait(5)
    game.Players.LocalPlayer.Character.Humanoid.Jump = true
end
