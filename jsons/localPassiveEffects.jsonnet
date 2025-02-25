/*
To compile:
> for file in jsons/*.jsonnet; do jsonnet "$file" -o "${file%.jsonnet}-GENERATED.json"; done
*/

local modifyToken(card_id, tokenName, amount) =
    if amount > 0 then [
        ["LOG", "└── ", "Added " + amount + " " + tokenName + " to ", "$GAME.cardById.{{" + card_id + "}}.currentFace.name", "."],
        ["INCREASE_VAL", "/cardById/" + card_id + "/tokens/" + tokenName, amount]
    ]
    else if amount < 0 then [
        ["LOG", "└── ", "Removed " + (-amount) + " " + tokenName + " from ", "$GAME.cardById.{{" + card_id + "}}.currentFace.name", "."],
        ["DECREASE_VAL", "/cardById/" + card_id + "/tokens/" + tokenName, -amount]
    ]
    else
        []
;

local countCards(condition, limit=-1) = 
    [
        ["VAR", "$TARGET_COUNT", 0],
        ["FOR_EACH_KEY_VAL", "$TARGET_ID", "$TARGET", "$GAME.cardById", [
        ["COND",
            condition,
            ["INCREASE_VAR", "$TARGET_COUNT", 1]
        ]]]
    ] + 
    if limit != -1 then [["UPDATE_VAR", "$TARGET_COUNT", ["MIN", ["LIST", "$TARGET_COUNT", limit]]]] else []
;

local localPassiveEffect(name, side = "A", listenToThisChange=[], thisCondition=[true], listenToTargetChange, targetCondition, targetInPlay=true, tokens, tokenAmounts=1, limit=-1) = {
    /*
    Cards with effects of form "<card>" gets +1 <token> for each other card matching <thisCondition>"
    thisCondition: a condition that is independent of the target card. Includes 'this-card-in-play'.
    targetCondition: a condition evaluated for each card in play to determine whether they are included. Includes 'target-card-in-play'.
    limit: default 0 (no limit). Maximum number of tokens that can be added by this effect.
    */
    local fullTargetCondition = ["AND"] + (if targetInPlay then ["$TARGET.inPlay"] else []) + targetCondition,
    "_comment": name,
    "rules": {
        ["targetChangeRule" + token]: {
            "_comment": "Add/remove tokens on this card when other cards pass/fail targetCondition.",
            "type": "whileInPlay",
            "side": side,
            "listenTo": ["/cardById/*/inPlay", "/cardById/*/currentSide"] + listenToTargetChange,
            "condition": fullTargetCondition,
            "onDo": [
                "COND",
                    ["AND", ["NOT_EQUAL", "$THIS_ID", "$TARGET_ID"]] + thisCondition,
                    if limit != -1 then
                        countCards(fullTargetCondition) + [
                        ["COND",
                            ["LESS_EQUAL", "$TARGET_COUNT", limit],
                            [
                                modifyToken("$THIS_ID", token, tokenAmounts)
                            ]
                        ]
                    ] else [
                        modifyToken("$THIS_ID", token, tokenAmounts)
                    ]
            ],
            "offDo": [
                "COND",
                    ["AND", ["NOT_EQUAL", "$THIS_ID", "$TARGET_ID"]] + thisCondition,
                    if limit != -1 then
                        countCards(fullTargetCondition) + [
                        ["COND",
                            ["LESS_THAN", "$TARGET_COUNT", limit],
                            [
                                modifyToken("$THIS_ID", token, -tokenAmounts)
                            ]
                        ]
                    ] else [
                        modifyToken("$THIS_ID", token, -tokenAmounts)
                    ]
            ]
        } for token in tokens
    } + {
        ["passiveRule" + token]: { 
            "_comment": "Add/remove tokens on cards meeting targetCondition when this card passes/fails thisCondition.",
            "type": "whileInPlay",
            "side": side,
            "listenTo": listenToThisChange,
            "condition": ["AND"] + thisCondition,
            "onDo":
                countCards(fullTargetCondition, limit) + 
                (if tokenAmounts > 1 then [["UPDATE_VAR", "$TARGET_COUNT", ["MULTIPLY", "$TARGET_COUNT", tokenAmounts]]] else []) + [
                ["LOG", "└── ", "Added {{$TARGET_COUNT}} " + token + " to ", "$THIS.currentFace.name", "."],
                ["INCREASE_VAL", "/cardById/$THIS_ID/tokens/" + token, "$TARGET_COUNT"]
            ],
            "offDo":
                ["COND",
                    "$THIS.inPlay",
                        countCards(["AND"] + ["PREV", fullTargetCondition], limit) +
                        (if tokenAmounts > 1 then [["UPDATE_VAR", "$TARGET_COUNT", ["MULTIPLY", "$TARGET_COUNT", tokenAmounts]]] else []) + [
                        ["LOG", "└── ", "Removed {{$TARGET_COUNT}} " + token + " from ", "$THIS.currentFace.name", "."],
                        ["DECREASE_VAL", "/cardById/$THIS_ID/tokens/" + token, "$TARGET_COUNT"]
                    ]
                ]
        } for token in tokens
    }
};

local addToken(tokenName, amount=1) = [["INCREASE_VAL", "/cardById/$TARGET_ID/tokens/" + tokenName, amount]];
local removeToken(tokenName, amount=1) = [["DECREASE_VAL", "/cardById/$TARGET_ID/tokens/" + tokenName, amount]];

{
    "_comment" : "JSON file automatically generated using jsonnet",
    "automation": {
        "cards": {
            "51223bd0-ffd1-11df-a976-0801211c9007": localPassiveEffect(
                name = "Erebor Battle Master",
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [
                    ["IN_STRING", "$TARGET.currentFace.traits", "Dwarf."],
                    ["IS_ALLY", "$TARGET"],
                    ["EQUAL", "$TARGET.cardIndex", 0],
                    ["NOT_EQUAL", "$THIS_ID", "$TARGET_ID"],
                    ["EQUAL", "$THIS.controller", "$TARGET.controller"],
                ],
                tokens = ["attack"],
                limit = 4,
            ),
            "052b1f85-8b9c-4bb0-a735-bdbd5ac1b2c4": localPassiveEffect(
                name = "Merry (Tactics)",
                listenToTargetChange = ["/cardById/*/controller"],
                targetCondition = [
                    ["IN_STRING", "$TARGET.currentFace.traits", "Hobbit."],
                    ["IS_HERO", "$TARGET"],
                    ["EQUAL", "$TARGET.cardIndex", 0],
                    ["EQUAL", "$THIS.controller", "$TARGET.controller"],
                ],
                tokens = ["attack"],
            ),
            "323ebfa3-57e5-4394-9f55-284b2f7ee0be": localPassiveEffect(
                name = "Faramir (Hero, Lore)",
                listenToTargetChange = ["/cardById/*/groupId"],
                targetCondition = [
                    ["IS_ENEMY", "$TARGET"],
                    ["EQUAL", "$TARGET.groupId", "sharedStagingArea"]
                ],
                tokens = ["attack"],
            ),
            "8fcb55c3-2996-4c13-b120-2b0c31f62d21": {"_comment": "Faramir (Hero, Lore)", "inheritFrom": "323ebfa3-57e5-4394-9f55-284b2f7ee0be"},
            "51223bd0-ffd1-11df-a976-0801206c9009": localPassiveEffect(
                name = "Eagles of the Misty Mountains",
                listenToTargetChange = ["/cardById/*/currentSide", "/cardById/*/cardIndex"],
                targetCondition = [
                    ["EQUAL", "$TARGET.currentSide", "B"],
                    ["GREATER_THAN", "$TARGET.cardIndex", 0],
                    ["EQUAL", "$THIS_ID", "$TARGET.parentCardId"],
                ],
                tokens = ["attack", "defense"],
            ),
            "9ea49df7-4c1f-432a-ba95-c0576fc62e89": localPassiveEffect(
                name = "Guardian of Esgaroth",  // Doesn't check that attachments are different or that they are player cards
                listenToTargetChange = ["/cardById/*/cardIndex"],
                targetCondition = [
                    ["GREATER_THAN", "$TARGET.cardIndex", 0],
                    ["EQUAL", "$THIS_ID", "$TARGET.parentCardId"],
                ],
                tokens = ["willpower", "attack", "defense", "hitPoints"],
                limit = 3,
            ),
            "a933917f-4c7e-416e-8b08-ee2e60f6ab5f": localPassiveEffect(
                name = "Warden of Annuminas",
                listenToTargetChange = ["/cardById/*/groupId"],
                targetCondition = [
                    ["IS_ENEMY", "$TARGET"],
                    ["EQUAL", "$TARGET.groupId", "{{$THIS.controller}}Engaged"],
                ],
                tokens = ["willpower"],
            ),
            "40efacf7-f3c1-434b-b31f-42b3721c90c0": localPassiveEffect(
                name = "Fornost Bowman",
                listenToTargetChange = ["/cardById/*/groupId"],
                targetCondition = [
                    ["IS_ENEMY", "$TARGET"],
                    ["EQUAL", "$TARGET.groupId", "{{$THIS.controller}}Engaged"],
                ],
                tokens = ["attack"],
            ),
            "0f2501c7-16ad-4fee-bea6-17b767fb0d14": localPassiveEffect(
                name = "Guardian of Arnor",
                listenToTargetChange = ["/cardById/*/groupId"],
                targetCondition = [
                    ["IS_ENEMY", "$TARGET"],
                    ["EQUAL", "$TARGET.groupId", "{{$THIS.controller}}Engaged"],
                ],
                tokens = ["defense"],
            ),
            "12946b30-a231-4074-a524-960365081360": localPassiveEffect(
                name = "Thurindir",
                listenToTargetChange = ["/cardById/*/groupId"],
                targetCondition = [
                    ["EQUAL", "$TARGET.currentFace.type", "Side Quest"],
                    ["EQUAL", "$TARGET.groupId", "sharedVictory"]
                ],
                targetInPlay = false,
                tokens = ["willpower"],
            ),
            "cc7beee8-1f42-4926-8c45-8a50f3a87c57": localPassiveEffect(
                name = "Elrohir (Hero)",
                listenToTargetChange = [],
                targetCondition = [
                    ["EQUAL", "$TARGET.currentFace.name", "Elladan"],
                    ["EQUAL", "$TARGET.cardIndex", 0],
                ],
                tokens = ["defense"],
                tokenAmounts = 2,
                limit = 1,
            ),
            "51223bd0-ffd1-11df-a976-0801209c9010": localPassiveEffect(
                name = "Elladan (Hero)",
                listenToTargetChange = [],
                targetCondition = [
                    ["EQUAL", "$TARGET.currentFace.name", "Elrohir"],
                    ["EQUAL", "$TARGET.cardIndex", 0],
                ],
                tokens = ["attack"],
                tokenAmounts = 2,
                limit = 1,
            ),
            "769dbf59-9e02-4750-9605-b1ad6c8783e2": localPassiveEffect(
                name = "Elrohir (Ally)",
                listenToTargetChange = [],
                targetCondition = [
                    ["EQUAL", "$TARGET.currentFace.name", "Elladan"],
                    ["EQUAL", "$TARGET.cardIndex", 0],
                ],
                tokens = ["defense"],
                tokenAmounts = 2,
                limit = 1,
            ),
            "51512531-0697-4005-9fb6-884da5b02f75": localPassiveEffect(
                name = "Elladan (Ally)",
                listenToTargetChange = [],
                targetCondition = [
                    ["EQUAL", "$TARGET.currentFace.name", "Elrohir"],
                    ["EQUAL", "$TARGET.cardIndex", 0],
                ],
                tokens = ["attack"],
                tokenAmounts = 2,
                limit = 1,
            ),

        },
    }
}