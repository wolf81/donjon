// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// dungeon/gen_data.js
//
// written by drow <drow@bin.sh>
// http://creativecommons.org/licenses/by-nc/3.0/
'use strict';
let gen_data = {
    "Dungeon Name": ["The ${ Dungeon Type } of ${ Dire Horror } ${ Dungeon Horror }", "The ${ Lost Dungeon } ${ Dungeon Type } of ${ Dungeon Horror }", "The ${ Dungeon Type } of ${ lt The Darklord }", "The ${ Lost Dungeon } ${ Dungeon Type } of ${ lt The Darklord }"],
    "Lost Dungeon": "Black Dark Dread Forsaken Lost Secret".split(" "),
    "Dungeon Type": "Barrow Catacombs Caverns Chambers Crypts Cyst Delve Dungeon Gauntlet Halls Hive Labyrinth Lair Pit Prison Sanctum Sepulcher Shrine Temple Tomb Tunnels Undercrypt Vaults Warrens".split(" "),
    "Dire Horror": "${ Bloody Epithet };${ Dark Epithet };${ Dire Epithet };${ Eldritch Epithet };${ Fiendish Epithet };${ Mighty Epithet }".split(";"),
    "Bloody Epithet": ["Bloody", "Crimson", "Ghastly", "Gruesome"],
    "Dark Epithet": "Aphotic Black Dark Dismal Gloomy Tenebrous Shadowy Sunless".split(" "),
    "Dire Epithet": "Baleful Cruel Dire Grim Horrendous Merciless Poisonous Sinister Treacherous Unspeakable Woeful".split(" "),
    "Eldritch Epithet": "Arcane Demonic Eldritch Elemental Fiendish Infernal Unearthly".split(" "),
    "Fiendish Epithet": "Abyssal Accursed Baatorian Black Corrupt Damned Demonic Fallen Fell Fiendish Hellish Malefic Malevolent Malign Profane Vile Wicked".split(" "),
    "Mighty Epithet": ["Adamant", "Awesome", "Indomitable", "Mighty", "Terrible"],
    "Dungeon Horror": "Ages Annihilation Chaos Death Devastation Doom Evil Horror Madness Malice Necromancy Nightmares Ruin Secrets Sorrows Souls Terror Woe Worms".split(" "),
    "The Darklord": ["${ Named Darklord }", "${ Darklord Name }", "${ Darklord Name } the ${ Darklord Epithet }",
        "The ${ Monster Epithet } ${ Noble Title }"
    ],
    "Named Darklord": "Emirkol the Chaotic;Gothmog of Udun;Kas the Bloody;Kas the Betrayer;Lord Greywulf;Marceline the Vampire Queen;Shiva the Destroyer;The Goblin King;Ulfang the Black;Zeiram the Lich".split(";"),
    "Darklord Name": ["${ gen_name Draconic }", "${ gen_name Gothic }", "${ gen_name Fiendish }"],
    "Darklord Epithet": "${ Bloody Epithet };${ Dire Epithet };${ Eldritch Epithet };${ Fiendish Epithet };${ Insane Epithet };${ Mighty Epithet };${ Darkmage }".split(";"),
    "Insane Epithet": ["Deranged", "Insane", "Lunatic", "Mad", "Possessed"],
    Darkmage: "Archmage Enchantress Necromancer Pontifex Sorceror Warlock Witch".split(" "),
    "Monster Epithet": "Demon Gargoyle Lich Shadow Vampire Wraith Wyrm".split(" "),
    "Noble Title": "Baron Count Duke Knight Lord Warlord Baroness Countess Duchess Knight Emperor King Prince Tyrant Empress Princess Queen".split(" ")
};