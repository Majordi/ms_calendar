ESX = exports['es_extended']:getSharedObject()

Calendar.IsOpened = false

CreateThread(function() 
    local timer = 1000
    while true do 
        timer = 1000

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, v in pairs(Calendar.Coords) do 
            local distance = #(playerCoords - v)

            if distance < 10 then
                timer = 0
                local scale = 0.7 + math.sin(GetGameTimer() / 500) * 0.2

                DrawMarker(25, v.x, v.y, v.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, 0.5, 0, 150, 255, 150, false, true, 2, nil, nil, nil, false)
            end

            if distance < 1.5 then 
                timer = 0

                if not Calendar.IsOpened then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour ouvrir le calendrier de l'avent.")
                end

                if IsControlJustPressed(0, 38) then 
                    if not Calendar.IsOpened then
                        Calendar.IsOpened = true

                        TriggerServerEvent("calendar:open", k)
                    end
                end
            end
        end

        Wait(timer)
    end
end)

RegisterNetEvent("calendar:open", function(rewardToOpen) 
    SetNuiFocus(true, true)
    
    if rewardToOpen then
        Calendar.Gifts[rewardToOpen].canOpen = true
    end

    SendNUIMessage({
        type = "calendar:open",
        gifts = Calendar.Gifts
    })
end)

RegisterNUICallback("calendar:close", function() 
    Calendar.IsOpened = false

    SetNuiFocus(false, false)
end)

RegisterNUICallback("calendar:claim", function() 
    TriggerServerEvent("calendar:claim")
end)