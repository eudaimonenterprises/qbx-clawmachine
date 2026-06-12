local activeSessions = {}

local function GetSessionTime()
    return os.time() * 1000
end

-- CLEANED UP: The client now validates money locally first to prevent freezing loops.
-- When the game starts, it fires this network event to log the player session securely.
RegisterNetEvent('qbx-clawmachine:server:startSession', function(machineIndex)
    local src = source
    local machine = Config.machines[machineIndex]
    if not machine then return end

    activeSessions[src] = { machineId = machineIndex, expires = GetSessionTime() + 60000 }
end)

RegisterNetEvent('qbx-clawmachine:resolveGame', function(machineIndex, skillSuccess)
    local src = source
    local machine = Config.machines[machineIndex]
    local session = activeSessions[src]

    -- Secure validation check to prevent mod menus from spamming the prize event
    if not machine or not session or session.machineId ~= machineIndex then
        exports.qbx_core:Notify(src, Config.Text['ate_money'], 'error')
        return
    end

    if session.expires < GetSessionTime() then
        activeSessions[src] = nil
        exports.qbx_core:Notify(src, Config.Text['ate_money'], 'error')
        return
    end

    -- FIXED: Retrieve player data from qbx_core and remove money properly
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local paid = Player.Functions.RemoveMoney(machine.payaccount, Config.price, "claw-machine")
    if not paid then
        exports.qbx_core:Notify(src, Config.Text['no_funds'], 'error')
        return
    end

    -- Randomize the prize selection pool
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
            exports.qbx_core:Notify(src, "You don't have enough space in your inventory!", 'error')
            TriggerClientEvent("qbx-clawmachine:client:animation", src, "lose")
        end
    else
        exports.qbx_core:Notify(src, Config.Text['ate_money'], 'error')
        TriggerClientEvent("qbx-clawmachine:client:animation", src, "lose")
    end
end)
