local logEnabled = true

RegisterServerEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text)
	TriggerClientEvent('3dme:triggerDisplay', -1, text, source)
	if logEnabled then
		setLog(text, source)
	end
end)

function setLog(text, source)
	local time = os.date("%d/%m/%Y %X")
	local name = GetPlayerName(source)
	local identifier = GetPlayerIdentifiers(source)
	local data = time .. ' : ' .. name .. ' - ' .. identifier[1] .. ' : ' .. text
end

RegisterServerEvent('LogToWebhook')
AddEventHandler('LogToWebhook', function(message)
    local steamID = tostring(GetPlayerIdentifier(source, 0))
    local nomeDoJogador = GetPlayerName(source)

    TriggerEvent('3dme:logToWebhook', nomeDoJogador, steamID, message)
end)

RegisterServerEvent('3dme:logToWebhook')
AddEventHandler('3dme:logToWebhook', function(nome, steamID, message)
    local webhookURL = "WEBHOOKURL"

    local embed = {
        {
            ["color"] = 16776960,
            ["title"] = "COMANDOS CHAT",
            ["description"] = message,
            ["fields"] = {
                {["name"] = "Nome", ["value"] = nome, ["inline"] = true},
                {["name"] = "Steam ID", ["value"] = steamID, ["inline"] = true}
            }
        }
    }
    
    local payload = json.encode({embeds = embed})
    
    PerformHttpRequest(webhookURL, function(err, text, headers) 
        -- 
    end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end)


----------------------------------------------------------
----------------------------------------------------------

RegisterServerEvent('dfcfg:acao')
AddEventHandler('dfcfg:acao', function(text, cords)
	TriggerClientEvent('dfcfg:acaoclient', -1, source, text, cords)
end)


----------------------------------------------------------
----------------------------------------------------------

-- 
local currentStatus = nil

-- 
RegisterNetEvent('setStatus')
AddEventHandler('setStatus', function(status)
    currentStatus = status
    TriggerClientEvent('updateStatus', -1, currentStatus) -- 
end)

-- 
RegisterNetEvent('clearStatus')
AddEventHandler('clearStatus', function()
    currentStatus = nil
    TriggerClientEvent('updateStatus', -1, currentStatus) -- 
end)

----------------------------------------------------------
----------------------------------------------------------