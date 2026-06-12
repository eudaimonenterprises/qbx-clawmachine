# qbx-clawmachine
Claw Machine with Prizes (Qbox) - Uses ox_target.

You can add as many machines with unique prizes in each machine. Below is a list of pre-configured items with images in the funkyplop images folder that you can use right off the start.

# ox_inventory/data/items.lua assets
```
-- Funkyplop Toys
-- Claw Machine
['funkyplop_harryputter'] = {
    label = 'Harry Putter Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A square-headed nerd clutching a long, straight club wedged firmly between two glossy dimpled balls. He knows how to handle a shaft.",
    client = {
        image = 'funkyplop_harryputter.png'
    }
},
['funkyplop_dorko'] = {
    label = 'Dorko Fanboy Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A pale-faced brat with a punchable face. He relies on daddy's money to buy both personality and laywers.",
    client = {
        image = 'funkyplop_dorko.png'
    }
},
['funkyplop_hermoney'] = {
    label = 'Hermoney Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A wide-eyed overachiever clutching a fat stack of cash. She quickly realized that milking rich trust-fund marks pays a lot better than studying.",
    client = {
        image = 'funkyplop_hermoney.png'
    }
},
['funkyplop_rat'] = {
    label = 'Rat Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A jittery ginger fish who knows it doesn't count on the inside. He trades dignity to hold pockets.",
    client = {
        image = 'funkyplop_rat.png'
    }
},
['funkyplop_dumblydope'] = {
    label = 'Dumblydope Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A brain-fried elder frozen in a state of permanent, catatonic stupidity. The thick green mist is a volatile cocktail of skunk, patchouli, and crop dust.",
    client = {
        image = 'funkyplop_dumblydope.png'
    }
},
['funkyplop_hotwing'] = {
    label = 'Hotwing Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A bug-eyed clucker that looks utterly incapable of navigating a basic flight path. The only thing this bird delivers is the flu with a side of buffalo sauce.",
    client = {
        image = 'funkyplop_hotwing.png'
    }
},
['funkyplop_haggard'] = {
    label = 'Haggard Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A mud-splattered mountain man covered with a tangled beard that smells like cheap whiskey. He spends his days hoarding metal for the scrap yard.",
    client = {
        image = 'funkyplop_haggard.png'
    }
},
['funkyplop_groaninggertel'] = {
    label = 'Groaning Gertel Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A neon-drenched ghostly clubgoer desperate for attention. She permanently haunts nightclub bathrooms, turning howls in the throes of depraved activities into a high-art form.",
    client = {
        image = 'funkyplop_groaninggertel.png'
    }
},
['funkyplop_voldoemoord'] = {
    label = 'Voldoemoord Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A pale poseur assassin dripping with fake murder ink clutching his cold, scaly sidekick. This depressed emo kid finally found his niche.",
    client = {
        image = 'funkyplop_voldoemoord.png'
    }
},
['funkyplop_snake'] = {
    label = 'Trouser Snake Funkyplop',
    weight = 100,
    stack = true,
    close = false,
    description = "A greasy-haired pimp rocking a deep V-neck shirt and an obnoxious gold chain. His black cane completes the pair of pipes that ran through the entire city.",
    client = {
        image = 'funkyplop_trousersnake.png'
    }
}
```

# server.cfg addition
```
ensure qbx-clawmachine
```
