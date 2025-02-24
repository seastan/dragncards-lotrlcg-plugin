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

local localPassiveEffect(name, side = "A", listenToThisChange=[], thisCondition=[true], listenToTargetChange, targetCondition, token, limit=-1) = {
    /*
    Cards with effects of form "<card>" gets +1 <token> for each other card matching <thisCondition>"
    thisCondition: a condition that is independent of the target card. Includes 'this-card-in-play'.
    targetCondition: a condition evaluated for each card in play to determine whether they are included. Includes 'target-card-in-play'.
    limit: default 0 (no limit). Maximum number of tokens that can be added by this effect.
    */
    "_comment": name,
    "rules": {
        targetChangeRule: {
            "_comment": "Add/remove tokens on this card when other cards pass/fail targetCondition.",
            "type": "whileInPlay",
            "side": side,
            "listenTo": ["/cardById/*/inPlay", "/cardById/*/currentSide"] + listenToTargetChange,
            "condition": ["AND",
                "$TARGET.inPlay",
            ] + targetCondition,
            "onDo": [
                "COND",
                    ["AND"] + thisCondition,
                        countCards(["AND", "$TARGET.inPlay"] + targetCondition) + [
                        ["COND",
                            ["LESS_EQUAL", "$TARGET_COUNT", limit],
                            [
                                modifyToken("$THIS_ID", token, 1)
                            ]
                        ]
                    ]
            ],
            "offDo": [
                "COND",
                    ["AND"] + thisCondition,
                        countCards(["AND", "$TARGET.inPlay"] + targetCondition) + [
                        ["COND",
                            ["LESS_THAN", "$TARGET_COUNT", limit],
                            [
                                modifyToken("$THIS_ID", token, -1)
                            ]
                        ]
                    ]
            ]
        },
        passiveRule: { 
            "_comment": "Add/remove tokens on cards meeting targetCondition when this card passes/fails thisCondition.",
            "type": "whileInPlay",
            "side": side,
            "listenTo": listenToThisChange,
            "condition": ["AND"] + thisCondition,
            "onDo":
                countCards(["AND", "$TARGET.inPlay"] + targetCondition, limit) + [
                ["LOG", "└── ", "Added {{$TARGET_COUNT}} " + token + " to ", "$THIS.currentFace.name", "."],
                ["INCREASE_VAL", "/cardById/$THIS_ID/tokens/" + token, "$TARGET_COUNT"]
            ],
            /*"offDo":  // Only need to re-add when a card using thisCondition is added
                countCards(["AND", "$THIS.inPlay"] + ["PREV", ["AND", "$TARGET.inPlay"] + targetCondition], limit) + [
                ["LOG", "└── ", "Removed {{$TARGET_COUNT}} " + token + " from ", "$THIS.currentFace.name", "."],
                ["DECREASE_VAL", "/cardById/$THIS_ID/tokens/" + token, "$TARGET_COUNT"]
            ]*/
        }
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
                token = "attack",
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
                token = "attack",
            ),
            "323ebfa3-57e5-4394-9f55-284b2f7ee0be": localPassiveEffect(
                name = "Faramir (Hero, Lore)",
                listenToTargetChange = ["/cardById/*/groupId"],
                targetCondition = [
                    ["IS_ENEMY", "$TARGET"],
                    ["EQUAL", "$TARGET.groupId", "sharedStagingArea"]
                ],
                token = "attack",
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
                token = "attack",  // TODO support attack and defense
            ),
        },
    }
}