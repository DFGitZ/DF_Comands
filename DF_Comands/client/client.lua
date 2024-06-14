local time = 7000
local VORPcore = exports.vorp_core:GetCore()
local displayingEstado = false
local displayTextEstado = ""

function LogToWebhook(message)
    TriggerServerEvent('LogToWebhook', message)
end

----------------------------------------
----------------------------------------

RegisterCommand('me', function(source, args)                                                        
    local text = 'me | '
    if #args < 1 then
        VORPcore.NotifyRightTip("Escreve algo!", 4000)
        return
    end
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end
    TriggerServerEvent('3dme:shareDisplay', text)
    LogToWebhook(text) -- 
end)

----------------------------------------

RegisterCommand('tentar', function(source, args)
    local tentativa = (math.random(1, 2) == 1) -- 
    local texto = table.concat(args, " ")
    if texto == "" then
        VORPcore.NotifyRightTip("Escreve algo!", 4000)
        return
    end
    local resultado = tentativa and "Consegui" or "Não consegui"
    local text = texto .. " | " .. resultado
    local success = tentativa -- 
    TriggerServerEvent('3dme:shareDisplay', text, success) -- 
    LogToWebhook(text) -- 
end)

----------------------------------------

RegisterCommand('ooc', function(source, args)
    local texto = table.concat(args, " ")
    if texto == "" then
        VORPcore.NotifyRightTip("Escreve algo!", 4000)
        return
    end
    local text = "OOC | " .. texto  -- 
    TriggerServerEvent('3dme:shareDisplay', text)
    LogToWebhook(text) -- 
end)

----------------------------------------

RegisterNetEvent('3dme:triggerDisplay')
AddEventHandler('3dme:triggerDisplay', function(text, source)
    local color
    if string.find(text, "Consegui") then
        color = {0, 255, 0, 100} -- Verde 
    elseif string.find(text, "Não consegui") then
        color = {255, 0, 0, 100} -- Vermelho 
    else
        -- 
        color = {255, 255, 255, 100} -- Branco 
    end
    Display(GetPlayerFromServerId(source), text, color)
end)

function Display(mePlayer, text, color)
    Citizen.CreateThread(function()
        local displaying = true
        local time = 5000 -- Tempo de exibição 
        if chatMessage then
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist2(coordsMe, coords)
            if dist < 2500 then
                TriggerEvent('chat:addMessage', {
                    color = color,
                    multiline = true,
                    args = { text }
                })
            end
        end

        Citizen.CreateThread(function()
            Wait(time)
            displaying = false
        end)

        Citizen.CreateThread(function()
            while displaying do
                Wait(0)
                local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
                local coords = GetEntityCoords(PlayerPedId(), false)
                local dist = Vdist2(coordsMe, coords)
                if dist < 2500 then
                    DrawText3D(coordsMe['x'], coordsMe['y'], coordsMe['z']+1.0, text, color)
                end
            end
        end)
    end)
end

---------------------------------------
---------------------------------------

local nbrDisplaying = 1
local time2 = 28740000
local nbrDisplaying2 = 1

RegisterCommand('acao', function(source, args)
    local text = table.concat(args, " ")
    if text == "" then
        VORPcore.NotifyRightTip("Escreve algo!", 4000)
        return
    end

    TriggerServerEvent('dfcfg:acao', text, GetEntityCoords(PlayerPedId()))

    LogToWebhook(text)
    VORPcore.NotifyTip("Podes usar /racao para remover!",4000) 
end)

RegisterNetEvent('dfcfg:acaoclient')
AddEventHandler('dfcfg:acaoclient', function(source, text, cords)
    DisplayAc(GetPlayerFromServerId(source), text, cords)
end)

function DisplayAc(mePlayer, text, cc)
    local tempo = 0
    local displaying2 = true

    Citizen.CreateThread(function()
        Wait(time2)
        displaying2 = false
    end)

    Citizen.CreateThread(function()
        nbrDisplaying2 = nbrDisplaying2 + 1

        while displaying2 do
            Wait(0)
            tempo = tempo + 1
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cc.x, cc.y, cc.z, true)

            if dist < 15 then
                local texto = '~g~'..text..'~s~'
                DrawText3D(cc.x, cc.y, cc.z, texto, {128, 128, 128, 255}) 
            end
        end

        nbrDisplaying2 = nbrDisplaying2 - 1
    end)

    RegisterCommand('racao', function(source, args)
        displaying2 = false
    end)
end

----------------------------------------
local currentStatus = nil
local statusPosition = {x = 0.0, y = 0.0, z = 0.0}


function DisplayCurrentStatus()
    if currentStatus and followPlayer then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        DrawText3D(coords.x, coords.y, coords.z + 0.1, currentStatus, {24, 95, 176, 255})
    end
end


RegisterCommand('estado', function(source, args, rawCommand)
    local text = table.concat(args, " ")
    if text and #text > 0 then
        currentStatus = "Estado | " .. text
        followPlayer = true
        VORPcore.NotifyTip("Podes usar /restado para remover!", 4000)
        LogToWebhook(currentStatus) -- 
        TriggerServerEvent('setStatus', currentStatus) -- 
    else
        -- 
        VORPcore.NotifyRightTip("Escreve algo!", 4000)
    end
end, false)

-- 
RegisterCommand('restado', function(source, args, rawCommand)
    currentStatus = nil
    followPlayer = false
    TriggerServerEvent('clearStatus') -- 
end, false)

--
RegisterNetEvent('updateStatus')
AddEventHandler('updateStatus', function(status)
    currentStatus = status
end)

-- 
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DisplayCurrentStatus()
    end
end)

----------------------------------------------------------
----------------------------------------------------------
--  
function DrawText3D(x, y, z, text, color)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())  
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    if onScreen then
        SetTextScale(0.30, 0.30) 
        SetTextFontForCurrentCommand(1)
        SetTextColor(color[1], color[2], color[3], color[4]) 
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 225
        DrawSprite("scoretimer_textures", "scoretimer_bg_1b", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 20, 20, 20, 200, 0) 
    end
end
