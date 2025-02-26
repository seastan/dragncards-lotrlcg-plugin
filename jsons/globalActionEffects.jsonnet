local globalActionEffect(name, log, thisCondition=[], targetCondition, targetEffect, beforeEffect=[], afterEffect=[["DISCARD_CARD", "$THIS"]]) = {
    /*
    Actions like "Ready all character cards in play." and "Until the end of the phase, each Noble hero gets +1 [willpower]."
    */
    "_comment": name,
    ability: {
        "A": ["COND",
            ["AND"] + thisCondition,
            beforeEffect + [
                ["LOG", "└── ", log],
                ["FOR_EACH_KEY_VAL", "$TARGET_ID", "$TARGET", "$CARD_BY_ID", [
                    ["COND",
                        ["AND",
                            ["EQUAL", "$TARGET.inPlay", true],
                            ["NOT", "$TARGET.currentFace.tags.immuneToPlayerCardEffects"]
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
            "4fb48ed9-1651-4ae7-83d1-9d76a1dc27e7": globalActionEffect(
                name = "Charge of the Rohirrim",
                log = "Gave all Rohan characters with a Mount attachment +3 attack until the end of the phase.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Rohan."], ["IS_CHARACTER", "$TARGET"], ["HAS_ATTACHMENT_WITH_TRAIT", "$TARGET", "Mount."]],
                targetEffect = addToken("attack", amount=3),
            ),
            "ba4ca60e-b375-4cf7-b725-529cbc6efbb0": {"_comment": "Charge of the Rohirrim", "inheritFrom": "4fb48ed9-1651-4ae7-83d1-9d76a1dc27e7"},
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
                log = "Gave each hero committed to the quest +1 willpower until the end of the phase.",
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
            "a73ea798-1d91-4bda-86d9-1085739d9cb4": globalActionEffect(
                name = "Burst into Song",
                log = "Readied each hero with a Song attachment.",
                targetCondition = [["IS_HERO", "$TARGET"], ["HAS_ATTACHMENT_WITH_TRAIT", "$TARGET", "Song."]],
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
                log = "Gave each Dwarf character +{{$AMOUNT}} willpower until the end of the phase.",
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Dwarf."], ["IS_CHARACTER", "$TARGET"]],
                beforeEffect = [
                    ["VAR", "$AMOUNT", 1],
                    ["COND",
                        ["OR", ["ACTIVE_LOCATION_HAS_TRAIT", "Underground."], ["ACTIVE_LOCATION_HAS_TRAIT", "Dark."]],
                        ["UPDATE_VAR", "$AMOUNT", 2],
                    ]
                ],
                targetEffect = addToken("willpower", amount="$AMOUNT"),
            ),
            "7c7912dc-4d55-4c40-98a0-befbbff24c90": globalActionEffect(
                name = "Shadows Give Way",
                log = "Discarded each shadow card.",
                targetCondition = [["EQUAL", "$TARGET.rotation", -30]],
                targetEffect = [["DISCARD_CARD", "$TARGET_ID"]],
            ),
            "7d906063-149f-4b7d-b271-e1532afea7c0": globalActionEffect(
                name = "Horn's Cry",
                log = "Gave each enemy -1 attack until the end of the phase.",
                targetCondition = [["IS_ENEMY", "$TARGET"]],
                targetEffect = addToken("attack", timing="phase", amount=-1),
            ),
            "768ae041-2d15-44a3-a928-62838536a160": globalActionEffect(
                name = "Take No Notice",
                log = "Gave each enemy +5 engagement cost until the end of the round.",
                targetCondition = [["IS_ENEMY", "$TARGET"]],
                targetEffect = addToken("engagementCost", timing="round", amount=5),
            ),
            "f07ea741-4991-46c9-9c6a-439dc186cec6": globalActionEffect(
                name = "Arrows from the Trees",
                log = "Dealt one damage to each enemy in the staging area.",
                targetCondition = [["IS_ENEMY", "$TARGET"], ["EQUAL", "$TARGET.groupId", "sharedStagingArea"]],
                targetEffect = [["INCREASE_VAL", "/cardById/$TARGET.id/tokens/damage", 1]],
            ),
            "51223bd0-ffd1-11df-a976-0801202c9006": globalActionEffect(
                name = "Beorning Beekeeper",
                log = "Discarded Beorning Beekeeper to deal one damage to each enemy in the staging area.",
                targetCondition = [["IS_ENEMY", "$TARGET"], ["EQUAL", "$TARGET.groupId", "sharedStagingArea"]],
                targetEffect = [["INCREASE_VAL", "/cardById/$TARGET.id/tokens/damage", 1]],
            ),
            "51223bd0-ffd1-11df-a976-0801200c9018": globalActionEffect(
                name = "Longbeard Orc Slayer",
                log = "Dealt one damage to each Orc enemy.",
                targetCondition = [["IS_ENEMY", "$TARGET"], ["IN_STRING", "$TARGET.currentFace.traits", "Orc."]],
                targetEffect = [["INCREASE_VAL", "/cardById/$TARGET.id/tokens/damage", 1]],
                afterEffect = []
            ),
            "3dc9ec01-71b6-48fd-8fe4-0c8fa2161fe3": globalActionEffect(
                name = "Need Drives Them",
                log = "Readied each character if its owner has 40 or more threat.",
                targetCondition = [["IS_CHARACTER", "$TARGET"], ["IS_PLAYER_IN_VALOUR", "$TARGET.controller"]],
                targetEffect = readyCard(),
            ),
            "5865f440-4912-41e7-861e-9526d07e371f": {"_comment": "Need Drives Them", "inheritFrom": "3dc9ec01-71b6-48fd-8fe4-0c8fa2161fe3"},
            "f9351811-479d-4bad-a6b3-ac745739b63f": globalActionEffect(
                name = "In The Shadows",
                log = "Gave each enemy engaged with {{$THIS.controller}} that has engagement cost higher than threat -1 attack and -1 defense until the end of the phase",
                targetCondition = [
                    ["IS_ENEMY", "$TARGET"],
                    ["EQUAL", "$TARGET.groupId", "{{$THIS.controller}}Engaged"],
                    ["GREATER_THAN", ["GET_ENGAGEMENT_COST", "$TARGET"], "$GAME.playerData.{{$THIS.controller}}.threat"],
                ],
                targetEffect = removeToken("attack") + removeToken("defense"),
            ),
            "697e1c80-a218-4dc7-b0c3-06921e879b81": globalActionEffect(
                name = "Robin Smallburrow",
                log = "Gave each enemy +{{$AMOUNT}} engagement cost until the end of the round.",
                targetCondition = [["IS_ENEMY", "$TARGET"]],
                beforeEffect = [
                    ["VAR", "$ACTIVE_LOCATIONS", ["GET_ACTIVE_LOCATIONS"]],
                    ["VAR", "$AMOUNT", 0],
                    ["FOR_EACH_VAL", "$LOCATION", "$ACTIVE_LOCATIONS",
                        ["UPDATE_VAR", "$AMOUNT", ["MAX", ["LIST", "$AMOUNT", ["GET_QUEST_POINTS", "$LOCATION"]]]]
                    ],
                ],
                targetEffect = addToken("engagementCost", timing="round", amount="$AMOUNT"),
                afterEffect = []
            ),
            "9418c634-54c6-47de-9aae-798038a4a35b": globalActionEffect(
                name = "Smoke Rings",
                log = "Gave each hero with a Pipe attachment +1 willpower until the end of the phase.",
                targetCondition = [["IS_HERO", "$TARGET"], ["HAS_ATTACHMENT_WITH_TRAIT", "$TARGET", "Pipe."]],
                targetEffect = addToken("willpower"),
                beforeEffect = [
                    ["VAR", "$CONTROLLED_PIPES", ["FILTER_CARDS", "$CARD", 
                        ["AND",
                            ["EQUAL", "$CARD.inPlay", true],
                            ["EQUAL", "$CARD.controller", "$THIS.controller"],
                            ["IN_STRING", "$CARD.currentFace.traits", "Pipe."],
                        ]
                    ]],
                    ["VAR", "$THREAT_REDUCTION", ["LENGTH", "$CONTROLLED_PIPES"]],
                    ["COND",
                        ["GREATER_THAN", "$THREAT_REDUCTION", 0],
                        [
                            ["LOG", "└── ", ["GET_ALIAS", "$THIS.controller"], " reduced their threat by {{$THREAT_REDUCTION}}."],
                            ["DECREASE_VAL", "/playerData/{{$THIS.controller}}/threat", "$THREAT_REDUCTION"],
                        ]
                    ]
                ],
            ),
            "c7c503b9-a804-4e37-8554-927d0095e7b1": globalActionEffect(
                name = "Old Toby",
                log = "Healed 1 damage from each hero with a Pipe attachment.",
                targetCondition = [["IS_HERO", "$TARGET"], ["HAS_ATTACHMENT_WITH_TRAIT", "$TARGET", "Pipe."]],
                targetEffect = [["HEAL", "$TARGET_ID", 1]],
                beforeEffect = [
                    ["VAR", "$CONTROLLED_PIPES", ["FILTER_CARDS", "$CARD", 
                        ["AND",
                            ["EQUAL", "$CARD.inPlay", true],
                            ["EQUAL", "$CARD.controller", "$THIS.controller"],
                            ["IN_STRING", "$CARD.currentFace.traits", "Pipe."],
                        ]
                    ]],
                    ["VAR", "$CARDS_TO_DRAW", ["LENGTH", "$CONTROLLED_PIPES"]],
                    ["COND",
                        ["GREATER_THAN", "$CARDS_TO_DRAW", 0],
                        [
                            ["LOG", "└── ", ["GET_ALIAS", "$THIS.controller"], " draws {{$CARDS_TO_DRAW}} cards."],
                            ["DRAW_CARD", "$THIS.controller", "$CARDS_TO_DRAW"],
                        ]
                    ]
                ],
            ),
        },
    }
}