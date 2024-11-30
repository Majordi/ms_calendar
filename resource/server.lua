ESX = exports['es_extended']:getSharedObject()

Calendar.rewardsClaimed = {}

function getCurrentServerDay()
    local timestamp = os.time() + (Calendar.UtcOffset * 3600)
    return os.date("%d", timestamp)
end

RegisterNetEvent("calendar:open", function()
    local currentNumberServerDay = getCurrentServerDay()
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if Calendar.rewardsClaimed[identifier] and Calendar.rewardsClaimed[identifier][currentNumberServerDay] then
        TriggerClientEvent("calendar:open", source, 0)
    else
        TriggerClientEvent("calendar:open", source, currentNumberServerDay)
    end
end)

RegisterNetEvent("calendar:claim", function()
    local currentNumberServerDay = getCurrentServerDay()
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if not Calendar.rewardsClaimed[identifier] then
        Calendar.rewardsClaimed[identifier] = {}
    end

    if not Calendar.rewardsClaimed[identifier][currentNumberServerDay] then
        Calendar.rewardsClaimed[identifier][currentNumberServerDay] = true

        MySQL.Async.execute("INSERT INTO calendar (identifier, days) VALUES (@identifier, @days)", {
            ["@identifier"] = identifier,
            ["@days"] = json.encode(Calendar.rewardsClaimed[identifier])
        }, function()
            for _, v in pairs(Calendar.Gifts[currentNumberServerDay].rewards) do
                xPlayer.addInventoryItem(v.name, v.quantity)
            end
        end)
    end
end)

MySQL.ready(function() 
    MySQL.Async.execute("CREATE TABLE IF NOT EXISTS calendar (identifier VARCHAR(60), days TEXT)", {}, function() 
        MySQL.Async.fetchAll("SELECT * FROM calendar", {}, function(calendar_data)
            for _, v in pairs(calendar_data) do 
                Calendar.rewardsClaimed[v.identifier] = json.decode(v.days)
            end
        end)
    end)
end)