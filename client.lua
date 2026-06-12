-- directionPrompts setup remains standard for control manipulation
local directionPrompts = {
    { control = 172, label = '↑' },
    { control = 173, label = '↓' },
    { control = 174, label = '←' },
    { control = 175, label = '→' },
}

-- Replaced legacy help display with modern ox_lib textUI
local function DisplayHelp(text)
    lib.showTextUI(text, { position = "right-center" })
end

local function HideHelp()
    lib.hideTextUI()
end

local function PlayClawMiniGame()
    local sequence = {}
    local steps = math.random(3, 5)
    for i = 1, steps do
        sequence[i] = directionPrompts[math.random(1, #directionPrompts)]
    end
    local currentStep = 1
    local timer = GetGameTimer()
    local stepNotified = false

    exports.qbx_core:Notify(Config.Text['skill_instructions'], 'primary', 2000)
    
    while currentStep <= #sequence do
        if GetGameTimer() - timer > 15000 then
            exports.qbx_core:Notify(Config.Text['skill_fail'], 'error', 2000)
            HideHelp()
            return false
        end
        
        local prompt = sequence[currentStep]
        if not stepNotified then
            exports.qbx_core:Notify(string.format('%s (%s/%s)', prompt.label, currentStep, #sequence), 'primary', 1500)
            stepNotified = true
        end
        
        DisplayHelp(('Press %s to align the claw (%s/%s)'):format(prompt.label, currentStep, #sequence))
        
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 21, true)
        
        if IsControlJustPressed(0, prompt.control) then
            currentStep = currentStep + 1
            stepNotified = false
            timer = GetGameTimer()
        elseif IsControlJustPressed(0, 22) then
            exports.qbx_core:Notify(Config.Text['skill_fail'], 'error', 2000)
            HideHelp()
            return false
        end
        Wait(0)
    end
    
    HideHelp()
    exports.qbx_core:Notify(Config.Text['skill_success'], 'success', 1500)
    return true
end

local function StartClawRound(machineId)
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local model = `ch_prop_arcade_claw_01a`
    local object = DoesObjectOfTypeExistAtCoords(pCoords.x, pCoords.y, pCoords.z, 2.0, model)
    if object then
        TaskTurnPedToFaceEntity(ped, object, 1500)
    end
    
    if lib.progressBar({
        duration = 2500,
        label = Config.Text['grab_toy'],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, carMovement = true, mouse = false, combat = true },
        anim = { dict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft", clip = "insert_coins", flag = 16 },
    }) then
        ClearPedTasks(ped)
        
        -- Pulls your newly synchronized HUD cash balance locally
        local playerData = exports.qbx_core:GetPlayerData()
        local currentCash = playerData and playerData.money and playerData.money.cash or 0
        
        if currentCash < Config.price then
            exports.qbx_core:Notify(Config.Text['no_funds'], 'error')
            return
        end
        
        -- Open a secure server session before launching the minigame
        TriggerServerEvent('qbx-clawmachine:server:startSession', machineId)
        
        local miniGameSuccess = PlayClawMiniGame()
        TriggerServerEvent('qbx-clawmachine:resolveGame', machineId, miniGameSuccess)
    else
        ClearPedTasks(ped)
    end
end

CreateThread(function()
    local model = `ch_prop_arcade_claw_01a`
    
    -- Cleaned Up: Static target mapping model format prevents any texture or MLO conflicts
    exports.ox_target:addModel(model, {
        {
            name = 'claw_machine_interact',
            icon = 'fas fa-coins',
            label = Config.Text['use_claw'] .. Config.price,
            distance = 1.5,
            -- Pierces addon map collision masks natively to guarantee the eye reads the built-in model
            canInteract = function(entity, distance, coords, name, bone)
                local entityCoords = GetEntityCoords(entity)
                for index, machine in pairs(Config.machines) do
                    local targetPos = vec3(machine.location.x, machine.location.y, machine.location.z)
                    if #(entityCoords - targetPos) < 4.0 then
                        return true
                    end
                end
                return false
            end,
            onSelect = function(data)
                if IsPedAPlayer(data.entity) then return false end
                local entityCoords = GetEntityCoords(data.entity)
                for index, machine in pairs(Config.machines) do
                    local targetPos = vec3(machine.location.x, machine.location.y, machine.location.z)
                    if #(entityCoords - targetPos) < 4.0 then
                        StartClawRound(index)
                        break
                    end
                end
            end,
        }
    })
end)

RegisterNetEvent("qbx-clawmachine:client:animation", function(type)
    local ped = PlayerPedId()
    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
        local animDict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft"
        local anim = (type == "win") and "win" or "lose"
        
        while not HasAnimDictLoaded(animDict) do
            RequestAnimDict(animDict)
            Wait(5)
        end
        
        TaskPlayAnim(ped, animDict, anim, 3.0, 3.0, -1, 0, 0, 0, 0, 0)
        Wait(2000)
        ClearPedTasks(ped)
    end
end)
