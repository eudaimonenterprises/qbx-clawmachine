local QBCore = exports['qb-core']:GetCoreObject()

local directionPrompts = {
    { control = 172, label = '↑' },
    { control = 173, label = '↓' },
    { control = 174, label = '←' },
    { control = 175, label = '→' },
}

local function DisplayHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, -1)
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

    QBCore.Functions.Notify(Config.Text['skill_instructions'], 'primary', 2000)

    while currentStep <= #sequence do
        if GetGameTimer() - timer > 15000 then
            QBCore.Functions.Notify(Config.Text['skill_fail'], 'error', 2000)
            return false
        end

        local prompt = sequence[currentStep]

        if not stepNotified then
            QBCore.Functions.Notify(string.format('%s (%s/%s)', prompt.label, currentStep, #sequence), 'primary', 1500)
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
            QBCore.Functions.Notify(Config.Text['skill_fail'], 'error', 2000)
            return false
        end

        Wait(0)
    end

    QBCore.Functions.Notify(Config.Text['skill_success'], 'success', 1500)
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

    QBCore.Functions.Progressbar('claw_machine', Config.Text['grab_toy'], 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft",
        anim = "insert_coins",
        flag = 16,
    }, {}, {}, function()
        ClearPedTasks(ped)
        QBCore.Functions.TriggerCallback('qb-clawmachine:canPlay', function(canPlay)
            if not canPlay then
                QBCore.Functions.Notify(Config.Text['no_funds'], 'error')
                return
            end

            local miniGameSuccess = PlayClawMiniGame()
            TriggerServerEvent('qb-clawmachine:resolveGame', machineId, miniGameSuccess)
        end, machineId)
    end, function()
        ClearPedTasks(ped)
    end)
end

CreateThread(function()
    local model = `ch_prop_arcade_claw_01a`
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end


    exports['qb-target']:RemoveTargetModel(model, Config.Text['use_claw'])

    for k,v in pairs(Config.machines) do
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

        exports['qb-target']:AddTargetModel(model, {
            options = {
                {
                    icon = 'fas fa-coins',
                    label = Config.Text['use_claw']..Config.price,
                    targeticon = 'fas fa-coins',
                    action = function(entity)
                        if IsPedAPlayer(entity) then return false end
                        StartClawRound(machineId)
                    end,
                }
            },
            distance = 1.0
        })
    end
end)

RegisterNetEvent("qb-clawmachine:client:animation", function(type)
    local ped = PlayerPedId()
    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
        if type == "win" then
            animDict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft"
            anim = "win"

            while not HasAnimDictLoaded(animDict) do
                RequestAnimDict(animDict)
                Wait(5)
            end

            TaskPlayAnim(ped, animDict, anim, 3.0, 3.0, -1, 0, 0, 0, 0, 0)
        elseif type == "lose" then
            animDict = "anim_casino_a@amb@casino@games@arcadecabinet@maleleft"
            anim = "lose"

            while not HasAnimDictLoaded(animDict) do
                RequestAnimDict(animDict)
                Wait(5)
            end

            TaskPlayAnim(ped, animDict, anim, 3.0, 3.0, -1, 0, 0, 0, 0, 0)
        end

        Wait(2000)

        ClearPedTasks(ped)
    end
end)