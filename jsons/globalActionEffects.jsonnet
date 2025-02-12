local globalActionEffect(name, log, thisCondition=[], targetCondition, targetEffect, beforeEffect=[], afterEffect=[["ACTION_LIST", "discardCard"]]) = {
    /*
    Actions like "Ready all character cards in play." and "Until the end of the phase, each Noble hero gets +1 [willpower]."
    */
    "_comment": name,
    ability: {
        "A": ["COND",
            ["AND"] + thisCondition,
            [
                ["LOG", "└── ", log],
                ["FOR_EACH_KEY_VAL", "$TARGET_ID", "$TARGET", "$CARD_BY_ID", [
                    ["COND",
                        ["AND",
                            ["EQUAL", "$TARGET.inPlay", true],
                        ] + targetCondition,
                        [targetEffect]
                    ]
                ]]
            ] + afterEffect,
            true,
            ["LOG", "└── ", "The ability's conditions are not met."]
        ],
    },
};

local addToken(tokenName, timing="phase", amount=1) = [["ADD_TEMP_TOKEN", timing, "$TARGET_ID", tokenName, amount]];
local removeToken(tokenName, timing="phase", amount=1) = [["ADD_TEMP_TOKEN", timing, "$TARGET_ID", tokenName, -amount]];
local readyCard() = [
    ["SET", "/cardById/$TARGET_ID/rotation", 0],
    ["SET", "/cardById/$TARGET_ID/exhausted", false]
];

{
    "_comment" : "JSON file automatically generated using jsonnet",
    "automation": {
        "cards": {
            "51223bd0-ffd1-11df-a976-0801200c9025": globalActionEffect(
                name = "Grim Resolve",
                log = "Readied all characters.",
                targetCondition = [["IS_CHARACTER", "$TARGET"]],
                targetEffect = readyCard(),
            ),
            "d0024a2b-e3ea-44aa-a813-999b8ab754a4": {"_comment": "Grim Resolve", "inheritFrom": "51223bd0-ffd1-11df-a976-0801200c9025"},
            "51223bd0-ffd1-11df-a976-0801206c9003": globalActionEffect(
                name = "Astonishing Speed",
                log = "Gave all Rohan characters +2 willpower until the end of the phase.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Rohan."], ["IS_CHARACTER", "$TARGET"]],
                targetEffect = addToken("willpower", amount=2),
            ),
            "0b1ff7b7-06ae-416a-a9a0-1199fc985fc4": {"_comment": "Astonishing Speed", "inheritFrom": "51223bd0-ffd1-11df-a976-0801206c9003"},
            "51223bd0-ffd1-11df-a976-0801209c9015": globalActionEffect(
                name = "Lure of Moria",
                log = "Readied all Dwarf characters.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Dwarf."], ["IS_CHARACTER", "$TARGET"]],
                targetEffect = readyCard(),
            ),
            "6ed73c76-bcdc-47bd-9d1d-96dc1eddab2d": {"_comment": "Lure of Moria", "inheritFrom": "51223bd0-ffd1-11df-a976-0801209c9015"},
            "91f28bdf-4b78-4750-9853-65e783e4cb15": globalActionEffect(
                name = "Strength of Arms",
                log = "Readied each Ally.",
                targetCondition = [["IS_ALLY", "$TARGET"]],
                targetEffect = readyCard(),
            ),
            "edb23ff8-1851-41ec-8e8e-dfac6ef9e710": globalActionEffect(
                name = "Wind from the Sea",
                log = "Readied each Hero committed to the quest and removed Wind from the Sea from the game.",
                targetCondition = [["IS_HERO", "$TARGET"], ["EQUAL", "$TARGET.committed", true],],
                targetEffect = readyCard(),
                afterEffect = [["DELETE_CARD", "$THIS_ID"]],
            ),
            "bedda85f-f07f-469a-b6f7-d59910210a86": globalActionEffect(
                name = "A Desperate Path",
                log = "Discarded cards from the encounter deck until a treachery is discarded. Each questing character is readied and gets +1 willpower until the end of the phase.",
                targetCondition = [["IS_CHARACTER", "$TARGET"], ["EQUAL", "$TARGET.committed", true],],
                targetEffect = readyCard() + addToken("willpower"),
                beforeEffect = [["DISCARD_UNTIL", "sharedEncounterDeck", "Treachery"]],
            ),
            "51223bd0-ffd1-11df-a976-0801204c9012": globalActionEffect(
                name = "Rear Guard",
                log = "Gave each Hero committed to the quest +1 willpower until the end of the phase.",
                targetCondition = [["IS_HERO", "$TARGET"], ["EQUAL", "$TARGET.committed", true],],
                targetEffect = addToken("willpower"),
            ),
            "4823aae3-46ef-4a75-89f9-cbd3aa1b9050": globalActionEffect(
                name = "Light the Beacons",
                log = "Gave each character +2 defense until the end of the round.",
                targetCondition = [["IS_CHARACTER", "$TARGET"]],
                targetEffect = addToken("defense", amount=2, timing="round"),
            ),
            "8588e98f-1aaf-4e90-95b9-48b76c0fc4be": globalActionEffect(
                name = "Hold Your Ground!",
                log = "Readied each sentinel character.",
                thisCondition = [["IS_PLAYER_IN_VALOUR", "$THIS.controller"]],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.keywords", "Sentinel."], ["IS_CHARACTER", "$TARGET"]],
                targetEffect = readyCard(),
            ),
            "8b15901c-c6b2-421e-8c6d-3200558e3609": globalActionEffect(
                name = "Leaf-wrapped Lembas (Boon)",
                log = "Added Leaf-wrapped Lembas to the victory display and readied all heroes.",
                thisCondition = ["$THIS.inPlay", ["GREATER_THAN", "$THIS.cardIndex", 0]],
                targetCondition = [["IS_HERO", "$TARGET"]],
                targetEffect = readyCard(),
                afterEffect = [["ACTION_LIST", "addToVictoryDisplay"]],
            ),
            "51223bd0-ffd1-11df-a976-0801202c9009": globalActionEffect(
                name = "Eomund",
                log = "Readied each Rohan character",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Rohan."], ["IS_CHARACTER", "$TARGET"]],
                targetEffect = readyCard(),
                afterEffect = [],
            ),
            "f94a6cd8-d909-453a-a206-e477244b1b0f": {"_comment": "Eomund", "inheritFrom": "51223bd0-ffd1-11df-a976-0801202c9009"},
            "ff265d76-021b-4f23-9e62-a57e16b3e77d": globalActionEffect(
                name = "Lords of the Eldar",
                log = "Moved Lords of the Eldar to the bottom of the deck and gave all Noldor characters +1 willpower, +1 attack, and +1 defense until the end of the round.",
                thisCondition = [["IN_STRING", "$THIS.groupId", "Discard"]],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Noldor."], ["IS_CHARACTER", "$TARGET"]],
                targetEffect = addToken("willpower", timing="round") + addToken("attack", timing="round") + addToken("defense", timing="round"),
                afterEffect = [["MOVE_CARD", "$THIS_ID", "{{$THIS.controller}}Deck", -1]],
            ),
            "8a236d16-1b31-474c-992b-3a2cd91a3b71": globalActionEffect(
                name = "The Free Peoples",
                log = "Readied each character and gave each character controlled by {{$THIS.controller}} +1 willpower until the end of the phase.",
                targetCondition = [["IS_CHARACTER", "$TARGET"]],
                targetEffect = readyCard() + [
                    ["COND",
                        ["EQUAL", "$TARGET.controller", "$THIS.controller"],
                        addToken("willpower"),
                    ]
                ],
            ),
            "cb08f48e-7acf-44ff-ac6f-36d4f017a962": globalActionEffect(
                name = "Captains of the West",
                log = "Gave each Noble hero +1 willpower until the end of the phase.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Noble."], ["IS_HERO", "$TARGET"]],
                targetEffect = addToken("willpower"),
            ),
            "21c68054-6070-49cd-be5f-7d432842a879": globalActionEffect(
                name = "Scouting Party",
                log = "Gave each Scout character +2 willpower until the end of the phase.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Scout."], ["IS_CHARACTER", "$TARGET"], ["EQUAL", "$TARGET.controller", "$THIS.controller"]],
                targetEffect = addToken("willpower", amount=2),
            ),
            "51223bd0-ffd1-11df-a976-0801200c9022": globalActionEffect(
                name = "For Gondor!",
                log = "Gave each character +1 attack and each Gondor character +1 defense until the end of the phase.",
                targetCondition = [["IS_CHARACTER", "$TARGET"]],
                targetEffect = addToken("attack") + [
                    ["COND",
                        ["IN_STRING", "$TARGET.currentFace.traits", "Gondor."],
                        addToken("defense"),
                    ]
                ],
            ),
            "51223bd0-ffd1-11df-a976-0801207c9083": globalActionEffect(
                name = "Untroubled by Darkness",
                log = "Gave each Dwarf character +1/+2 willpower until the end of the phase.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Dwarf."], ["IS_CHARACTER", "$TARGET"]],
                targetEffect = [
                    ["COND",
                        ["OR", ["ACTIVE_LOCATION_HAS_TRAIT", "Underground."], ["ACTIVE_LOCATION_HAS_TRAIT", "Dark."]],
                        [
                            addToken("willpower", amount=2),
                        ],
                        true,
                        [
                            addToken("willpower", amount=1),
                        ],
                    ]
                ],
            )
        },
    }
}