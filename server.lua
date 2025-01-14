ESX = exports["es_extended"]:getSharedObject()

local function createTableIfNotExists()
    local sql = [[
        CREATE TABLE IF NOT EXISTS `ollinox_freecar` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(255) NOT NULL,
            `date` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
    
    MySQL.Async.execute(sql, {}, function()
        print("Table `ollinox_freecar` checked/created successfully.")
    end)
end


createTableIfNotExists()

AddEventHandler("ollinox_freecar:server:claimVehicle", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer == nil then return end

    MySQL.Async.fetchAll('SELECT * FROM ollinox_freecar WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier }, function(result)
        if result[1] ~= nil then
            TriggerClientEvent('esx:showNotification', src, "You've already claimed a free car!")
        else
            TriggerClientEvent('ollinox_freecar:client:spawnClaimedVehicle', src)
        end
    end)
end)

AddEventHandler("ollinox_freecar:server:SetOwnedVehicle", function(plate, vehicleProps)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer == nil then return end

    MySQL.Async.execute("INSERT INTO ollinox_freecar (identifier) VALUES (@identifier)", {['@identifier'] = xPlayer.identifier}, function() end)

    MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)", {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@type'] = Config.VehicleType["type"],
        ['@vehicle'] = json.encode(vehicleProps),
        ['@stored'] = 0
    }, function()
        TriggerClientEvent('esx:showNotification', src, string.format("You've received a vehicle with plate number ~y~%s", string.upper(plate)))
    end)

    if Config.Discord then
        SendToDiscord(string.format("**Name**: %s\n**Identifier**: %s (%s)\n**Plate**: %s\n**Timestamp**: %s", xPlayer.getName(), GetPlayerName(src), xPlayer.identifier, plate, os.date('%Y-%m-%d %H:%M:%S')))
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(86400000) 
        local folder_name = GetCurrentResourceName()

        if folder_name ~= "Ollinox_freecar" then
            print("Warning: The folder name 'Ollinox_freecar' has been changed. Please revert it to continue.")
        end
    end
end)

function SendToDiscord(message)
    local embed = {
        {
            ["title"] = "Free Car Log",
            ["color"] = 16711680,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Author - Ollinox Scripts",
            },
            ["thumbnail"] = {
                ["url"] = "https://cdn.discordapp.com/attachments/1317515160457318400/1328624306812616765/AJxt1KO28xy7QwjNbHv-sHETwTL8-XuAQLpCNhNY3WtGKP-ejOIGvGsG36Nkv1Q5EyoY6OJrWxvUX3de0ojpU7vfFPnFLrH6a335I5wIajKE7TjHfd2AWKG91uCQT5ax002Un4PkEj2sZi3-P7ZUNSkF7aaQd0rfi21P4BZlQ6OgYr5zH8NqSfU9s1024.png?ex=6787614f&is=67860fcf&hm=497fa369770fddb67b2a78471276df2981ab9bfb7586d3bd62dfa2ed8621af82&" -- Replace with your thumbnail URL
            },
        }
    }
    PerformHttpRequest(Config.Discord, function(err, text, headers) end, 'POST', json.encode({username = "Ollinox Scripts", embeds = embed}), { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent("ollinox_freecar:server:claimVehicle")
RegisterNetEvent("ollinox_freecar:server:SetOwnedVehicle")

PerformHttpRequest("https://api.github.com/repos/oliver693/Ollinox_freecar/releases/latest", function(err, text, headers)
    if err == 200 then
        local latest_release = json.decode(text)
        local version = latest_release.tag_name
        print("Ollinox_freecar - Latest Version: " .. version)
    else
        print("Failed to fetch version information.")
    end
end, "GET", "", { ["User-Agent"] = "Mozilla/5.0" })
