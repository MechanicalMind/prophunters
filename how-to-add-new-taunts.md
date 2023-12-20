# How to add new taunts
Create a file in (if the folders don't exist, create them)

    /lua/prophunters/taunts/

called `something.lua`
replacing `something` with a different name (e.g. the name of your addon, your name, etc)

Place your sound files in

    garrysmod/sound/prophunters/

in `something.lua` list your taunts in the form

    addTaunt("name", {
        "prophunters/sound1.wav", 
        "prophunters/sound2.wav"
    }, "team", "gender", {"category1", "category2"}, durationOverride)

each addTaunt adds one entry to the list which when clicked will randomly play one of the sound files

`name` is the name of your sound
`sound1.wav` is the path to your sound file (don't include `sound/`)
`team` is the team it should belong to (props or hunters)
`gender` is the gender of the voice (male, female or both)
`category` is the categories the taunt should belong to (all categories should be camelCase and not contain spaces)
`durationOverride` is the length the taunt goes for (you must specify this for mp3)

## Examples
    addTaunt("Farts", {
        "prophunters/fart1.mp3",
        "prophunters/fart2.mp3"
    }, "props", "both", {"farts"}, 5) // NOTE the 5 specifying the length, this is required for mp3s

    addTaunt("Get the hell out", {
        "vo/npc/male01/gethellout.wav"
    }, "props", "male", {"talk"})

    addTaunt("Zombie Growl", {
        "npc/zombie/zombie_alert1.wav",
        "npc/zombie/zombie_alert2.wav",
        "npc/zombie/zombie_alert3.wav"
    }, "props", "both", {"zombie", "growls"})

    
    addTaunt("Radio", {
        "music/radio1.mp3"
    }, "props", nil, {"music"}, 39)
