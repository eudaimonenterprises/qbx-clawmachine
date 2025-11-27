local QBCore = exports['qb-core']:GetCoreObject()

local activeSessions = {}

local function GetSessionTime()
    return os.time() * 1000
end

QBCore.Functions.CreateCallback('qb-clawmachine:canPlay', function(source, cb, machineIndex)
    local Player = QBCore.Functions.GetPlayer(source)
    local machine = Config.machines[machineIndex]

    if not Player or not machine then
        cb(false)
        return
    end

    local paid = Player.Functions.RemoveMoney(machine.payaccount, Config.price, 'claw_machine')

    if not paid then
        TriggerClientEvent("QBCore:Notify", source, Config.Text['no_funds'], 'error')
        cb(false)
        return
    end

    activeSessions[source] = { machineId = machineIndex, expires = GetSessionTime() + 60000 }
    cb(true)
end)

RegisterNetEvent('qb-clawmachine:resolveGame', function(machineIndex, skillSuccess)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local machine = Config.machines[machineIndex]
    local session = activeSessions[src]

    if not Player or not machine or not session or session.machineId ~= machineIndex then
        TriggerClientEvent("QBCore:Notify", src, Config.Text['ate_money'], 'error')
        return
    end

    if session.expires < GetSessionTime() then
        activeSessions[src] = nil
        TriggerClientEvent("QBCore:Notify", src, Config.Text['ate_money'], 'error')
        return
    end

    activeSessions[src] = nil

    local randomToy = math.random(1, #machine.prizes)
    local prizeChance = math.random(1, 100)
    local adjustedChance = machine.prizechance

    if skillSuccess then
        adjustedChance = math.min(100, adjustedChance + (Config.skillBonus or 0))
    else
        adjustedChance = math.floor(adjustedChance * 0.5)
    end

    if adjustedChance >= prizeChance then
        local prizeItem = machine.prizes[randomToy]
        Player.Functions.AddItem(prizeItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[prizeItem], 'add')
        TriggerClientEvent("qb-clawmachine:client:animation", src, "win")
    else
        TriggerClientEvent("QBCore:Notify", src, Config.Text['ate_money'], 'error')
        TriggerClientEvent("qb-clawmachine:client:animation", src, "lose")
    end
end)
