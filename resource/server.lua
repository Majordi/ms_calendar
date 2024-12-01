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

    if string.len(currentNumberServerDay) >= 2 then
        if tonumber(string.sub(currentNumberServerDay, 1, 1)) == 0 then
            local day = string.sub(currentNumberServerDay, 2, 2)
            currentNumberServerDay = day
        end
    end

    currentNumberServerDay = tonumber(currentNumberServerDay)
    
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

    if string.len(currentNumberServerDay) >= 2 then
        if tonumber(string.sub(currentNumberServerDay, 1, 1)) == 0 then
            local day = string.sub(currentNumberServerDay, 2, 2)
            currentNumberServerDay = day
        end
    end

    currentNumberServerDay = tonumber(currentNumberServerDay)

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
                for k, _ in pairs(json.decode(v.days)) do 
                    if not Calendar.rewardsClaimed[v.identifier] then 
                        Calendar.rewardsClaimed[v.identifier] = {}
                    end

                    Calendar.rewardsClaimed[v.identifier][k] = true
                end
            end
        end)
    end)
end)