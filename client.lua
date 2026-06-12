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

    -- Replaced QBCore notify with exports.qbx_core:Notify
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
    
    -- Replaced QB progressbar with ox_lib progressbar for better performance and Qbox standards
    if lib.progressBar({
        duration = 2500,
        label = Config.Text['grab_toy'],
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            carMovement = true,
            mouse = false,
            combat = true,
        },
        anim = {
            dict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft",
            clip = "insert_coins",
            flag = 16,
        },
    }) then
        ClearPedTasks(ped)
        -- Triggering Qbox compatible callback mechanism 
        exports.qbx_core:TriggerCallback('qbx-clawmachine:canPlay', function(canPlay)
            if not canPlay then
                exports.qbx_core:Notify(Config.Text['no_funds'], 'error')
                return
            end
            local miniGameSuccess = PlayClawMiniGame()
            TriggerServerEvent('qbx-clawmachine:resolveGame', machineId, miniGameSuccess)
        end, machineId)
    else
        ClearPedTasks(ped)
    end
end

CreateThread(function()
    local model = `ch_prop_arcade_claw_01a`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    -- Replacing qb-target with modern ox_target models (native to Qbox environment)
    exports.ox_target:removeTargetModel(model, Config.Text['use_claw'])
    
    for k, v in pairs(Config.machines) do
        if DoesObjectOfTypeExistAtCoords(v.location.x, v.location.y, v.location.z, 1.0, model, 0) then
            local object = GetClosestObjectOfType(v.location.x, v.location.y, v.location.z, 1.0, model)
            SetEntityAsMissionEntity(object, true, true)
            Wait(100)
            DeleteObject(object)
        end
        
        RequestModel(model)
        if not HasModelLoaded(model) then
            Wait(10)
        end
        
        local claw = CreateObject(model, v.location.x, v.location.y, v.location.z - 1.0, true, true, false)
        SetEntityHeading(claw, (v.location.w - 180))
        FreezeEntityPosition(claw, true)
        
        local machineId = k
        exports.ox_target:addTargetModel(model, {
            {
                icon = 'fas fa-coins',
                label = Config.Text['use_claw']..Config.price,
                distance = 1.0,
                onSelect = function(data)
                    if IsPedAPlayer(data.entity) then return false end
                    StartClawRound(machineId)
                end,
            }
        })
    end
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