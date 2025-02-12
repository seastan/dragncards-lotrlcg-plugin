local globalPassiveEffect(name, side = "A", listenToThisChange, thisCondition, listenToTargetChange = [], targetCondition, effectOn, effectOff, conditionOnLog, conditionOffLog, targetOnLog, targetOffLog="", thisInPlay=true) = {
    /*
    Cards with effects of form "While <thisCondition>, apply <effectOn> to each card in play that meets <targetCondition>."
    thisCondition: a condition that is independent of the target card. Includes 'this-card-in-play' by default unless thisInPlay is false.
    targetCondition: a condition evaluated for each card in play to determine whether they should be affected. Includes 'target-card-in-play', 'target-is-not-attached', and 'target-card-is-on-side-A' by default.
        Warning: if targetCondition is not independent of the primary card, then effectOff will not be applied if the primary card changing causes the condition to become false.
        e.g. if targetCondition includes ["EQUAL", "$THIS.controller", "$TARGET.controller"], then if $THIS.controller changes, no recalculations will occur. 
    */
    "_comment": name,
    "rules": {
        targetChangeRule: {
            "_comment": "Add/remove tokens on cards that pass/fail targetCondition depending on if this card meets thisCondition.",
            "type": if thisInPlay then "whileInPlay" else "passive",
            "side": side,
            "listenTo": ["/cardById/*/inPlay", "/cardById/*/cardIndex", "/cardById/*/currentSide"] + listenToTargetChange,
            "condition": ["AND",
                "$TARGET.inPlay",
                ["EQUAL", "$TARGET.cardIndex", 0],
                ["NOT", "$TARGET.currentFace.tags.immuneToPlayerCardEffects"],
                ["NOT_EQUAL", "$THIS_ID", "$TARGET_ID"],  // Ignore self because will be covered in passiveRule
            ] + targetCondition,
            "onDo": [
                "COND",
                    ["AND", "$TARGET.inPlay", ["EQUAL", "$TARGET.cardIndex", 0], ["NOT", "$TARGET.currentFace.tags.immuneToPlayerCardEffects"]] + thisCondition,
                    [
                        ["LOG", "└── ", targetOnLog, "$TARGET.currentFace.name", "."],
                    ] + effectOn,
            ],
            "offDo": [
                "COND",
                    ["AND", "$TARGET.inPlay"] + thisCondition,
                    [
                        ["LOG", "└── ", targetOffLog, "$TARGET.currentFace.name", "."],
                    ] + effectOff,
            ]
        },
        passiveRule: { 
            "_comment": "Add/remove tokens on cards meeting targetCondition when this card passes/fails thisCondition.",
            "type": if thisInPlay then "whileInPlay" else "passive",
            "side": side,
            "listenTo": listenToThisChange,
            "condition": ["AND"] + thisCondition,
            "onDo": [
                ["LOG", "└── ", conditionOnLog],
                ["FOR_EACH_KEY_VAL", "$TARGET_ID", "$TARGET", "$GAME.cardById", [
                ["COND",
                    ["AND", "$TARGET.inPlay", ["EQUAL", "$TARGET.cardIndex", 0], ["NOT", "$TARGET.currentFace.tags.immuneToPlayerCardEffects"]] + targetCondition,
                    effectOn,
                ]]]
            ],
            "offDo": [
                ["LOG", "└── ", conditionOffLog],
                ["FOR_EACH_KEY_VAL", "$TARGET_ID", "$TARGET", "$GAME.cardById", [
                ["COND",
                    ["AND", "$TARGET.inPlay", ["PREV", ["EQUAL", "$TARGET.cardIndex", 0]], ["NOT", "$TARGET.currentFace.tags.immuneToPlayerCardEffects"]] + ["PREV", ["AND"] + targetCondition],
                    effectOff,
                ]]]
            ]
        }
    }
};

local addToken(tokenName, amount=1) = [["INCREASE_VAL", "/cardById/$TARGET_ID/tokens/" + tokenName, amount]];
local removeToken(tokenName, amount=1) = [["DECREASE_VAL", "/cardById/$TARGET_ID/tokens/" + tokenName, amount]];

{
    "_comment" : "JSON file automatically generated using jsonnet",
    "automation": {
        "cards": {
            "51223bd0-ffd1-11df-a976-0801206c9005": globalPassiveEffect(
                name = "Dain Ironfoot (Leadership)",
                listenToThisChange = ["/cardById/$THIS_ID/exhausted"],
                thisCondition = [["EQUAL", "$THIS.exhausted", false]],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Dwarf."], ["IS_CHARACTER", "$TARGET"]],
                effectOn = addToken("willpower") + addToken("attack"),
                effectOff = removeToken("willpower") + removeToken("attack"),
                conditionOnLog = "Added 1 willpower and 1 attack to each Dwarf character.",
                conditionOffLog = "Removed 1 willpower and 1 attack from each Dwarf character.",
                targetOnLog = "Dáin Ironfoot added 1 willpower and 1 attack to ",
            ),
            "347fa1ce-ec8d-43d9-a407-bc26d041b45e": {"_comment": "Leadership Dain Ironfoot", "inheritFrom": "51223bd0-ffd1-11df-a976-0801206c9005"},
            "51223bd0-ffd1-11df-a976-0801213c9008": globalPassiveEffect(
                name = "Hardy Leadership",
                listenToThisChange = ["/cardById/$THIS_ID/cardIndex"],
                thisCondition = [["GREATER_THAN", "$THIS.cardIndex", 0]],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Dwarf."], ["IS_CHARACTER", "$TARGET"]],
                effectOn = addToken("hitPoints"),
                effectOff = removeToken("hitPoints"),
                conditionOnLog = "Added 1 hit point to each Dwarf character.",
                conditionOffLog = "Removed 1 hit point from each Dwarf character.",
                targetOnLog = "Hardy Leadership added 1 hit point to ",
                targetOffLog = "Hardy Leadership removed 1 hit point from ",
            ),
            "f49d9b7f-bdb6-4f2c-8b25-42b07c60a2f3": globalPassiveEffect(
                name = "Kahliel's Headdress",
                listenToThisChange = ["/cardById/$THIS_ID/cardIndex"],
                thisCondition = [["GREATER_THAN", "$THIS.cardIndex", 0]],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Harad."], ["IS_CHARACTER", "$TARGET"]],
                effectOn = addToken("willpower"),
                effectOff = removeToken("willpower"),
                conditionOnLog = "Added 1 hit point to each Harad character.",
                conditionOffLog = "Removed 1 hit point from each Harad character.",
                targetOnLog = "Kahliel's Headdress added 1 hit point to ",
                targetOffLog = "Kahliel's Headdress removed 1 hit point from ",
            ),
            "4823aae3-46ef-4a75-89f9-cbd3aa1b9008": globalPassiveEffect(
                name = "Boromir (Hero, Leadership)",
                listenToThisChange = ["/cardById/$THIS_ID/tokens/resource"],
                thisCondition = [["GREATER_THAN", "$THIS.tokens.resource", 0]],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Gondor."], ["EQUAL", "$TARGET.currentFace.type", "Ally"]],
                effectOn = addToken("attack"),
                effectOff = removeToken("attack"),
                conditionOnLog = "Added 1 attack to each Gondor ally.",
                conditionOffLog = "Removed 1 attack from each Gondor ally.",
                targetOnLog = "Boromir added 1 attack to ",
            ),
            "55a2193b-c458-4aa0-82ec-544a373a1dca": {"_comment": "Boromir (Hero, Leadership)", "inheritFrom": "4823aae3-46ef-4a75-89f9-cbd3aa1b9008"},
            "2f0a3f18-c84f-4458-b6f7-2e6be9acee6b": globalPassiveEffect(
                name = "Visionary Leadership",
                listenToThisChange = ["/cardById/{{$THIS.parentCardId}}/tokens/resource", "/cardById/$THIS_ID/cardIndex"],
                thisCondition = [["GREATER_THAN", "$THIS.cardIndex", 0], ["GREATER_THAN", "$GAME.cardById.{{$THIS.parentCardId}}.tokens.resource", 0]],
                targetCondition = [["IN_STRING", "$TARGET.currentFace.traits", "Gondor."], ["IS_CHARACTER", "$TARGET"]],
                effectOn = addToken("willpower"),
                effectOff = removeToken("willpower"),
                conditionOnLog = "Added 1 willpower to each Gondor character.",
                conditionOffLog = "Removed 1 willpower from each Gondor character.",
                targetOnLog = "Visionary Leadership added 1 willpower to ",
            ),
            "c74f3029-f234-482e-b621-173686013e3e": {"_comment": "Visionary Leadership", "inheritFrom": "2f0a3f18-c84f-4458-b6f7-2e6be9acee6b"},
            "d5f09d24-be50-4958-b0d0-41b1ad09b7af": globalPassiveEffect(
                name = "Fellowship of the Ring",
                listenToThisChange = ["/cardById/$THIS_ID/cardIndex"],
                thisCondition = [["GREATER_THAN", "$THIS.cardIndex", 0]],
                targetCondition = [["EQUAL", "$TARGET.currentFace.type", "Hero"]],
                effectOn = addToken("willpower"),
                effectOff = removeToken("willpower"),
                conditionOnLog = "Added 1 willpower to each hero.",
                conditionOffLog = "Removed 1 willpower from each hero.",
                targetOnLog = "Fellowship of the Ring added 1 willpower to ",
            ),
            "51223bd0-ffd1-11df-a976-0801210c9018": globalPassiveEffect(
                name = "Sword that was Broken",
                listenToThisChange = ["/cardById/$THIS_ID/cardIndex"],
                thisCondition = [["GREATER_THAN", "$THIS.cardIndex", 0], ["EQUAL", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "Aragorn"]],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["EQUAL", "$THIS.controller", "$TARGET.controller"], ["IS_CHARACTER", "$TARGET"]],
                effectOn = addToken("willpower"),
                effectOff = removeToken("willpower"),
                conditionOnLog = "Added 1 willpower to each character controlled by {{$THIS.controller}}.",
                conditionOffLog = "Removed 1 willpower from each character controlled by {{$THIS.controller}}.",
                targetOnLog = "Sword that was Broken added 1 willpower to ",
                targetOffLog = "Sword that was Broken removed 1 willpower from ",
            ),
            "b8f5c0b1-a11e-41f5-b0bd-8dab7d537feb": globalPassiveEffect(
                name = "Keep Watch",
                listenToThisChange = ["/cardById/$THIS_ID/groupId"],
                thisCondition = [["EQUAL", "$THIS.groupId", "sharedVictory"]],
                listenToTargetChange = ["/cardById/*/groupId", "/cardById/*/rotation"],
                targetCondition = [["IN_STRING", "$TARGET.groupId", "Engaged"], ["NOT", "$TARGET.currentFace.unique"], ["IS_ENEMY", "$TARGET"], ["NOT_EQUAL", "$TARGET.rotation", -30]],
                effectOn = removeToken("attack"),
                effectOff = addToken("attack"),
                conditionOnLog = "Removed 1 attack from each non-unique enemy engaged with a player.",
                conditionOffLog = "Added 1 attack to each non-unique enemy engaged with a player.",
                targetOnLog = "Keep Watch removed 1 attack from ",
                targetOffLog = "Keep Watch added 1 attack to ",
                thisInPlay = false,
            ),
            "09ebd71c-8286-4838-b661-36a8633c9f0c": globalPassiveEffect(
                name = "Aragorn (Hero, Tactics)",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/groupId", "/cardById/*/rotation"],
                targetCondition = [["EQUAL", "$TARGET.groupId", "{{$THIS.controller}}Engaged"], ["IS_ENEMY", "$TARGET"], ["NOT_EQUAL", "$TARGET.rotation", -30]],
                effectOn = removeToken("defense"),
                effectOff = addToken("defense"),
                conditionOnLog = "Removed 1 defense from each enemy engaged with {{$THIS.controller}}.",
                conditionOffLog = "Added 1 defense to each enemy engaged with {{$THIS.controller}}.",
                targetOnLog = "Aragorn removed 1 defense from ",
                targetOffLog = "Aragorn added 1 defense to ",
            ),
            "97d09901-724d-4932-ac51-59df1ef1dbec": globalPassiveEffect(
                name = "Rally the West",
                listenToThisChange = ["/cardById/$THIS_ID/groupId"],
                thisCondition = [["EQUAL", "$THIS.groupId", "sharedVictory"]],
                targetCondition = [["EQUAL", "$TARGET.currentFace.type", "Hero"]],
                effectOn = addToken("willpower"),
                effectOff = removeToken("willpower"),
                conditionOnLog = "Added 1 willpower to each hero.",
                conditionOffLog = "Removed 1 willpower from each hero.",
                targetOnLog = "Rally the West added 1 willpower to ",
                thisInPlay = false,
            ),
            "1c149f93-9e3b-42fa-878c-80b29563a283": globalPassiveEffect(
                name = "Ethir Swordsman",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["EQUAL", "$THIS.controller", "$TARGET.controller"], ["IS_CHARACTER", "$TARGET"], ["IN_STRING", "$TARGET.currentFace.traits", "Outlands."]],
                effectOn = addToken("willpower"),
                effectOff = removeToken("willpower"),
                conditionOnLog = "Added 1 willpower to each Outlands character controlled by {{$THIS.controller}}.",
                conditionOffLog = "Removed 1 willpower from each Outlands character controlled by {{$THIS.controller}}.",
                targetOnLog = "Ethir Swordsman added 1 willpower to ",
                targetOffLog = "Ethir Swordsman removed 1 willpower from ",
            ),
            "c00844d6-1c3c-4e8c-a46c-8de15b8408df": globalPassiveEffect(
                name = "Knights of the Swan",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["EQUAL", "$THIS.controller", "$TARGET.controller"], ["IS_CHARACTER", "$TARGET"], ["IN_STRING", "$TARGET.currentFace.traits", "Outlands."]],
                effectOn = addToken("attack"),
                effectOff = removeToken("attack"),
                conditionOnLog = "Added 1 attack to each Outlands character controlled by {{$THIS.controller}}.",
                conditionOffLog = "Removed 1 attack from each Outlands character controlled by {{$THIS.controller}}.",
                targetOnLog = "Knights of the Swan added 1 attack to ",
                targetOffLog = "Knights of the Swan removed 1 attack from ",
            ),
            "2e84d805-365c-47ea-9c4f-e3f75daeb9a6": globalPassiveEffect(
                name = "Warrior of Lossarnach",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["EQUAL", "$THIS.controller", "$TARGET.controller"], ["IS_CHARACTER", "$TARGET"], ["IN_STRING", "$TARGET.currentFace.traits", "Outlands."]],
                effectOn = addToken("defense"),
                effectOff = removeToken("defense"),
                conditionOnLog = "Added 1 defense to each Outlands character controlled by {{$THIS.controller}}.",
                conditionOffLog = "Removed 1 defense from each Outlands character controlled by {{$THIS.controller}}.",
                targetOnLog = "Warrior of Lossarnach added 1 defense to ",
                targetOffLog = "Warrior of Lossarnach removed 1 defense from ",
            ),
            "4cb4741d-c9d8-4d62-ab4f-50fa80c59fbb": globalPassiveEffect(
                name = "Anfalas Herdsman",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [["EQUAL", "$THIS.controller", "$TARGET.controller"], ["IS_CHARACTER", "$TARGET"], ["IN_STRING", "$TARGET.currentFace.traits", "Outlands."]],
                effectOn = addToken("hitPoints"),
                effectOff = removeToken("hitPoints"),
                conditionOnLog = "Added 1 hit point to each Outlands character controlled by {{$THIS.controller}}.",
                conditionOffLog = "Removed 1 hit point from each Outlands character controlled by {{$THIS.controller}}.",
                targetOnLog = "Anfalas Herdsman added 1 hit point to ",
                targetOffLog = "Anfalas Herdsman removed 1 hit point from ",
            ),
            "1f7fc118-94a7-48a0-bd0c-9c15a36ddc23": globalPassiveEffect(
                name = "Bill the Pony",
                listenToThisChange = [],
                thisCondition = [],
                targetCondition = [["IS_CHARACTER", "$TARGET"], ["IN_STRING", "$TARGET.currentFace.traits", "Hobbit."]],
                effectOn = addToken("hitPoints"),
                effectOff = removeToken("hitPoints"),
                conditionOnLog = "Added 1 hit point to each Hobbit character.",
                conditionOffLog = "Removed 1 hit point from each Hobbit character.",
                targetOnLog = "Bill the Pony added 1 hit point to ",
                targetOffLog = "Bill the Pony removed 1 hit point from ",
            ),
            "80c51ea1-495e-40a0-8257-ff3e81aeb298": globalPassiveEffect(
                name = "Grip/Fang/Wolf (ALeP)",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/rotation"],
                targetCondition = [["EQUAL", "$TARGET.currentFace.type", "Enemy"], ["NOT_EQUAL", "$TARGET.rotation", -30]],
                effectOn = addToken("engagementCost"),
                effectOff = removeToken("engagementCost"),
                conditionOnLog = "Added 1 engagement cost to each enemy.",
                conditionOffLog = "Removed 1 engagement cost from each enemy.",
                targetOnLog = "{{$THIS.currentFace.name}} added 1 engagement cost to ",
                targetOffLog = "{{$THIS.currentFace.name}} removed 1 engagement cost from ",
            ),
            "bd50a02b-0827-44e2-9407-d1e3703d59e0": self["80c51ea1-495e-40a0-8257-ff3e81aeb298"],
            "55f4784e-2262-4961-a600-03de90e2ed11": self["80c51ea1-495e-40a0-8257-ff3e81aeb298"],
            "ce96b767-c569-48b8-a998-d8009b0143c7": globalPassiveEffect(
                name = "Pippin (Hero, Lore)",
                listenToThisChange = [],
                thisCondition = [],
                listenToTargetChange = ["/cardById/*/rotation"],
                targetCondition = [["EQUAL", "$TARGET.currentFace.type", "Enemy"], ["NOT_EQUAL", "$TARGET.rotation", -30]],
                effectOn = [["INCREASE_VAL", "/cardById/$TARGET_ID/tokens/engagementCost", ["LENGTH",
                                ["FILTER_CARDS", "$CARD", [
                                    "AND",
                                        "$CARD.inPlay",
                                        ["EQUAL", "$CARD.controller", "$THIS.controller"],
                                        ["IN_STRING", "$CARD.currentFace.traits", "Hobbit."],
                                        ["EQUAL", "$CARD.currentFace.type", "Hero"]
                                    ]
                                ]
                            ]]],
                effectOff = [["DECREASE_VAL", "/cardById/$TARGET_ID/tokens/engagementCost", ["LENGTH",
                                ["FILTER_CARDS", "$CARD", [
                                    "AND",
                                        "$CARD.inPlay",
                                        ["EQUAL", "$CARD.controller", "$THIS.controller"],
                                        ["IN_STRING", "$CARD.currentFace.traits", "Hobbit."],
                                        ["EQUAL", "$CARD.currentFace.type", "Hero"]
                                    ]
                                ]
                            ]]],
                conditionOnLog = "Added engagement cost to each enemy.",
                conditionOffLog = "Removed engagement cost from each enemy.",
                targetOnLog = "{{$THIS.currentFace.name}} added engagement cost to ",
                targetOffLog = "{{$THIS.currentFace.name}} removed engagement cost from ",
            ),
            // TODO Elfhelm, Brand son of Bain, Banner of Elendil, Red Book of Westmarch
            // Many encounter cards could be added here
        },
    }
}