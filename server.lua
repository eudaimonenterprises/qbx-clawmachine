local activeSessions = {}

local function GetSessionTime()
    return os.time() * 1000
end

-- Replaced QBCore callback with ox_lib's server callback registration
lib.callback.register('qbx-clawmachine:canPlay', function(source, machineIndex)
    -- Replaced QBCore GetPlayer with Qbox native PlayerData retrieval
    local Player = exports.qbx_core:GetPlayer(source)
    local machine = Config.machines[machineIndex]

    if not Player or not machine then
        return false
    end

    -- Replaced legacy function with qbx_core:RemoveMoney
    local paid = exports.qbx_core:RemoveMoney(source, machine.payaccount, Config.price, 'claw_machine')

    if not paid then
        -- Replaced QBCore:Notify client trigger with Qbox native server notify
        exports.qbx_core:Notify(source, Config.Text['no_funds'], 'error')
        return false
    end

    activeSessions[source] = { machineId = machineIndex, expires = GetSessionTime() + 60000 }
    return true
end)

RegisterNetEvent('qbx-clawmachine:resolveGame', function(machineIndex, skillSuccess)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local machine = Config.machines[machineIndex]
    local session = activeSessions[src]

    if not Player or not machine or not session or session.machineId ~= machineIndex then
        exports.qbx_core:Notify(src, Config.Text['ate_money'], 'error')
        return
    end

    if session.expires < GetSessionTime() then
        activeSessions[src] = nil
        exports.qbx_core:Notify(src, Config.Text['ate_money'], 'error')
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
        
        -- Native ox_inventory item handling check and implementation
        if exports.ox_inventory:CanCarryItem(src, prizeItem, 1) then
            exports.ox_inventory:AddItem(src, prizeItem, 1)
            TriggerClientEvent("qbx-clawmachine:client:animation", src, "win")
        else
            -- Notifies the player if they don't have enough pocket space for the prize
            exports.qbx_core:Notify(src, "You don't have enough space in your inventory!", 'error')
            TriggerClientEvent("qbx-clawmachine:client:animation", src, "lose")
        end
    else
        exports.qbx_core:Notify(src, Config.Text['ate_money'], 'error')
        TriggerClientEvent("qbx-clawmachine:client:animation", src, "lose")
    end
end)