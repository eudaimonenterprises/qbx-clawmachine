Config = {}

Config.machines = { -- Add as many claw machines as you want. They are all run off ox_target
    [1] = {
        -- Used strictly to verify which physical machine the player is standing in front of
        location = vector4(2733.0, -377.96, -48.98, 271.79), 
        prizechance = 35, -- Base % chance to win a prize per play
        payaccount = "cash", -- Account used to pay for the game
        prizes = {
            'funkyplop_harryputter',
            'funkyplop_dorko',
            'funkyplop_hermoney',
            'funkyplop_rat',
            'funkyplop_dumblydope',
            'funkyplop_hotwing',
            'funkyplop_haggard',
            'funkyplop_groaninggertel',
            'funkyplop_voldoemoord',
            'funkyplop_snake'
        }
    },
--    [2] = {
--        location = vector4(115.19, -1570.59, 29.6, 230.98), -- Must be a vector4 to set the heading of the machine. Machine will face the way you are facing
--        prizechance = 50, -- % chance player will get a prize
--        payaccount = "cash", -- Set to "cash" or "bank" depending on what you want the player to pay as
--        prizes = { -- Add as many prizes as you want
--            'funkyplop_dorko',
--            'funkyplop_rat',
--        }
--    }
}

Config.price = 20
Config.skillBonus = 20 -- Percentage bonus applied to the prize chance when the skill check is completed

Config.Text = { -- Convert text to your own language
    ['claw_machine'] = 'Claw Machine',
    ['use_claw'] = 'Use Claw Machine $',
    ['grab_toy'] = 'Working Joystick...',
    ['ate_money'] = 'No prize this time.',
    ['no_funds'] = 'You do not have enough money to play.',
    ['skill_instructions'] = 'Match the arrow prompts to guide the claw to a prize!',
    ['skill_fail'] = 'You fumbled the joystick.',
    ['skill_success'] = 'Perfect alignment!'
}
