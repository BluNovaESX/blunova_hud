-- ===== KONFIGURATION =====
local Config = {
    UpdateInterval = 200,      -- Update-Intervall in ms
    MaxSpeed = 250,            -- Maximale Geschwindigkeit für Tacho
    UseMPH = false,            -- MPH statt KM/H
    HideInPauseMenu = true,    -- HUD im Pause-Menü verstecken
    
    -- Tasten
    ToggleHudKey = 'F7',       -- Taste zum Ein-/Ausblenden des HUDs
    SeatbeltKey = 'B',         -- Taste für Gurt
}

-- ===== VARIABLEN =====
local ESX = nil
local PlayerData = {}
local isHudVisible = true
local isSeatbeltOn = false
local lastVehicle = nil


-- ===== HILFSFUNKTIONEN =====
local function GetESX()
    if ESX then return ESX end
    if GetResourceState and GetResourceState('es_extended') == 'started' then
        if exports and exports['es_extended'] and exports['es_extended'].getSharedObject then
            ESX = exports['es_extended']:getSharedObject()
            return ESX
        end
    end
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    return ESX
end

local function Notify(msg, ntype, duration)
    duration = duration or 3000
    ntype = ntype or 'info'

    if GetResourceState and GetResourceState('esx_notify') == 'started' then
        exports['esx_notify']:Notify(msg, ntype, duration)
        return
    end

    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
        return
    end

    -- Fallback (ohne ESX Notification)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local function SendHudConfig()
    SendNUIMessage({
        action = 'setConfig',
        maxSpeed = Config.MaxSpeed,
        useMPH = Config.UseMPH
    })
end

-- ===== ESX INITIALISIERUNG =====
Citizen.CreateThread(function()
    while ESX == nil do
        GetESX()
        Citizen.Wait(100)
    end
    
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
    
    PlayerData = ESX.GetPlayerData()

    SendHudConfig()

    -- Spieler ID senden
    SendNUIMessage({
        action = 'updatePlayerId',
        id = GetPlayerServerId(PlayerId())
    })
end)

-- ===== ESX EVENTS =====
RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    if account.name == 'money' then
        SendNUIMessage({
            action = 'updateMoney',
            cash = account.money
        })
    elseif account.name == 'bank' then
        SendNUIMessage({
            action = 'updateMoney',
            bank = account.money
        })
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    SendHudConfig()
    UpdateMoney()
    
    SendNUIMessage({
        action = 'updatePlayerId',
        id = GetPlayerServerId(PlayerId())
    })
end)

-- ===== GELD UPDATE =====
function UpdateMoney()
    local xPlayer = ESX.GetPlayerData()
    if not xPlayer then return end

    local cash = 0
    local bank = 0

    -- ESX Accounts (Legacy & ältere Versionen)
    if xPlayer.accounts then
        for _, account in pairs(xPlayer.accounts) do
            local name = account.name or account.account
            local money = account.money or account.balance or 0
            if name == 'money' then
                cash = money
            elseif name == 'bank' then
                bank = money
            end
        end
    else
        -- Fallback (wenn accounts nicht vorhanden sind)
        if xPlayer.money then cash = xPlayer.money end
        if xPlayer.bank then bank = xPlayer.bank end
    end

    SendNUIMessage({
        action = 'updateMoney',
        cash = cash,
        bank = bank
    })
end

        end
        
        SendNUIMessage({
            action = 'updateMoney',
            cash = cash,
            bank = bank
        })
    end)
end

-- ===== HAUPT-UPDATE LOOP =====
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.UpdateInterval)
        
        local playerPed = PlayerPedId()
        
        -- Pause-Menü Check
        if Config.HideInPauseMenu and IsPauseMenuActive() then
            SendNUIMessage({ action = 'hideHud', hide = true })
        else
            if isHudVisible then
                SendNUIMessage({ action = 'hideHud', hide = false })
            end
        end
        
        -- Status Update
        local health = GetEntityHealth(playerPed) - 100
        if health < 0 then health = 0 end
        local armor = GetPedArmour(playerPed)
        
        SendNUIMessage({
            action = 'updateStatus',
            health = health,
            armor = armor
        })
        
        -- Fahrzeug Check
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle ~= 0 then
            SendNUIMessage({ action = 'showVehicleHud', show = true })
            
            -- Geschwindigkeit berechnen
            local speed = GetEntitySpeed(vehicle)
            if Config.UseMPH then
                speed = speed * 2.236936
            else
                speed = speed * 3.6
            end
            
            -- Treibstoff (Standard FiveM Fuel System)
            local fuel = GetVehicleFuelLevel(vehicle)
            
            -- Motor Status
            local engineOn = GetIsVehicleEngineRunning(vehicle)
            
            SendNUIMessage({
                action = 'updateVehicle',
                speed = speed,
                fuel = fuel,
                engine = engineOn
            })
            
            -- Gurt Status
            SendNUIMessage({
                action = 'updateSeatbelt',
                buckled = isSeatbeltOn
            })
            
            lastVehicle = vehicle
        else
            SendNUIMessage({ action = 'showVehicleHud', show = false })
            
            -- Gurt zurücksetzen wenn aus Fahrzeug
            if lastVehicle ~= nil then
                isSeatbeltOn = false
                lastVehicle = nil
            end
        end
    end
end)

-- ===== HUNGER & DURST (esx_status kompatibel) =====
RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(data)
    local hunger = 100
    local thirst = 100
    
    for _, v in pairs(data) do
        if v.name == 'hunger' then
            hunger = v.percent
        elseif v.name == 'thirst' then
            thirst = v.percent
        end
    end
    
    SendNUIMessage({
        action = 'updateStatus',
        hunger = hunger,
        thirst = thirst
    })
end)

-- ===== VOICE/MIKROFON (pma-voice kompatibel) =====
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        
        local talking = NetworkIsPlayerTalking(PlayerId())
        
        SendNUIMessage({
            action = 'updateMic',
            talking = talking
        })
    end
end)

-- ===== GURT SYSTEM =====
RegisterCommand('gurt', function()
    ToggleSeatbelt()
end, false)

RegisterKeyMapping('gurt', 'Gurt anlegen/ablegen', 'keyboard', Config.SeatbeltKey)

function ToggleSeatbelt()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= 0 then
        isSeatbeltOn = not isSeatbeltOn
        
        if isSeatbeltOn then
            -- Spieler kann nicht rausfliegen
            SetPedConfigFlag(playerPed, 32, false)
            Notify('Du hast dich angeschnallt.', 'success', 3000)
            PlaySoundFrontend(-1, 'TOGGLE_ON', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        else
            SetPedConfigFlag(playerPed, 32, true)
            Notify('Du hast dich abgeschnallt.', 'error', 3000)
            PlaySoundFrontend(-1, 'TOGGLE_OFF', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        end
        
        SendNUIMessage({
            action = 'updateSeatbelt',
            buckled = isSeatbeltOn
        })
    end
end

-- ===== UNFALL - RAUSWERFEN WENN NICHT ANGESCHNALLT =====
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle ~= 0 and not isSeatbeltOn then
            local speed = GetEntitySpeed(vehicle) * 3.6
            
            if HasEntityCollidedWithAnything(vehicle) and speed > 60 then
                Citizen.Wait(50)
                SetEntityCoords(playerPed, GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 0.0, 1.0))
                SetPedToRagdoll(playerPed, 5000, 5000, 0, true, true, false)
                ApplyDamageToPed(playerPed, math.random(10, 30), true)
            end
        end
    end
end)

-- ===== HUD EIN-/AUSBLENDEN =====
RegisterCommand('togglehud', function()
    isHudVisible = not isHudVisible
    SendNUIMessage({ action = 'hideHud', hide = not isHudVisible })
    
    if isHudVisible then
        Notify('HUD aktiviert', 'info', 3000)
    else
        Notify('HUD deaktiviert', 'info', 3000)
    end
end, false)

RegisterKeyMapping('togglehud', 'HUD ein/ausblenden', 'keyboard', Config.ToggleHudKey)

-- ===== STANDARD HUD DEAKTIVIEREN =====
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Standard Minimap Health/Armor ausblenden
        HideHudComponentThisFrame(3)  -- Cash
        HideHudComponentThisFrame(4)  -- Bank/Cash change
        HideHudComponentThisFrame(6)  -- Vehicle Name
        HideHudComponentThisFrame(7)  -- Area Name
        HideHudComponentThisFrame(8)  -- Vehicle Class
        HideHudComponentThisFrame(9)  -- Street Name
        
        -- Radar/Minimap anpassen (optional)
        -- DisplayRadar(false) -- Komplett ausblenden
    end
end)

-- ===== GELD UPDATE BEI SPAWN =====
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    UpdateMoney()
end)

-- ===== EXPORT FUNKTIONEN =====
exports('IsHudVisible', function()
    return isHudVisible
end)

exports('SetHudVisible', function(visible)
    isHudVisible = visible
    SendNUIMessage({ action = 'hideHud', hide = not visible })
end)

exports('IsSeatbeltOn', function()
    return isSeatbeltOn
end)

exports('SetSeatbelt', function(buckled)
    isSeatbeltOn = buckled
    local playerPed = PlayerPedId()
    SetPedConfigFlag(playerPed, 32, not buckled)
    SendNUIMessage({
        action = 'updateSeatbelt',
        buckled = buckled
    })
end)

print('^2[BluNova HUD]^7 Resource erfolgreich geladen!')
