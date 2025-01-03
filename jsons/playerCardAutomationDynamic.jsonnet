local modifyToken(card_id, tokenName, amount) =
    if amount > 0 then [
        ["LOG", "└── ", "Added " + amount + " " + tokenName + " to ", "$GAME.cardById.{{" + card_id + "}}.currentFace.name", "."],
        ["INCREASE_VAL", "/cardById/" + card_id + "/tokens/" + tokenName, amount]
    ]
    else if amount < 0 then [
        ["LOG", "└── ", "Removed " + amount + " " + tokenName + " from ", "$GAME.cardById.{{" + card_id + "}}.currentFace.name", "."],
        ["DECREASE_VAL", "/cardById/" + card_id + "/tokens/" + tokenName, -amount]
    ]
    else
        []
;

// listenTo: list of paths to additionally listen
// condition: list of conditions to append to "AND" condition
local attachmentRule(name, willpower=0, threat=0, attack=0, defense=0, hitPoints=0, listenTo=[], condition=[]) = { 
    "_comment": "Add/remove tokens to the attached card.",
    "type": "passive", 
    "listenTo": ["/cardById/$THIS_ID/inPlay", "/cardById/$THIS_ID/currentSide", "/cardById/$THIS_ID/cardIndex"] + listenTo,
    "condition": [
        "AND", 
            "$THIS.inPlay",
            ["EQUAL", "$THIS.currentSide", "A"],
            ["GREATER_THAN", "$THIS.cardIndex", 0],
    ] + condition,
    "onDo":
        modifyToken("$THIS.parentCardId", "willpower", willpower) +
        modifyToken("$THIS.parentCardId", "threat", threat) +
        modifyToken("$THIS.parentCardId", "attack", attack) +
        modifyToken("$THIS.parentCardId", "defense", defense) +
        modifyToken("$THIS.parentCardId", "hitPoints", hitPoints)
    ,
    "offDo": [["VAR", "$PREV_PARENT_ID", ["PREV", "$THIS.parentCardId"]]] + 
        modifyToken("$PREV_PARENT_ID", "willpower", -willpower) +
        modifyToken("$PREV_PARENT_ID", "threat", -threat) +
        modifyToken("$PREV_PARENT_ID", "attack", -attack) +
        modifyToken("$PREV_PARENT_ID", "defense", -defense) +
        modifyToken("$PREV_PARENT_ID", "hitPoints", -hitPoints)
    ,
};

local staticAttachment(name, willpower=0, threat=0, attack=0, defense=0, hitPoints=0) = {
    "_comment": name,
    "rules": {
        "attachmentStaticPassiveTokens": attachmentRule(name, willpower, threat, attack, defense, hitPoints)
    }
};

// bonusList is a list
local conditionalAttachment(name, bonusList) = {
    "_comment": name,
    "rules": {
        [bonusRule.name]: attachmentRule(
            name,
            willpower  = std.get(bonusRule, "willpower", default=0),
            threat     = std.get(bonusRule, "threat",    default=0),
            attack     = std.get(bonusRule, "attack",    default=0),
            defense    = std.get(bonusRule, "defense",   default=0),
            hitPoints  = std.get(bonusRule, "hitPoints", default=0),
            listenTo   = std.get(bonusRule, "listenTo",  default=[]),
            condition  = std.get(bonusRule, "condition", default=[])
        )
        for bonusRule in bonusList
    }
};

// All attachments were found through the following regex search:
// Attached .* \b(?:gets|gains)\b .* \[?\b(?:willpower|attack|defense|hit)\b
// Skipped: PvP scenarios, Nightmares, Custom sets, Dreamchaser campaign, Angmar Campaign,
{
    "_comment" : "JSON file automatically generated using jsonnet",
    "automation": {
        "cards": {
            // Dynamic stats based on trait will only be correct if trait is printed rather than granted by player card effect
            "51223bd0-ffd1-11df-a976-0801200c9041": conditionalAttachment("Dwarven Axe", [
                {name: "attachmentBasicPassiveTokens", attack: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Dwarf."]]]},
                {name: "attachmentConditionalPassiveTokens", attack: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Dwarf."]]}
            ]),
            "09134509-191b-4903-b4b5-5e650f8143c1": conditionalAttachment("Gondorian Shield", [
                {name: "attachmentBasicPassiveTokens", defense: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Gondor."]]]},
                {name: "attachmentConditionalPassiveTokens", defense: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Gondor."]]}
            ]),
            "fa1aa093-59e5-4919-8c06-86864848a89e": conditionalAttachment("Gondorian Shield", [
                {name: "attachmentBasicPassiveTokens", defense: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Gondor."]]]},
                {name: "attachmentConditionalPassiveTokens", defense: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Gondor."]]}
            ]),
            "0ee1f1e6-1952-4bad-8ecd-631e80f4ccc0": conditionalAttachment("Firefoot", [
                {name: "attachmentBasicPassiveTokens", attack: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "omer"]]]},  // Matches both Éomer and Eomer
                {name: "attachmentConditionalPassiveTokens", attack: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "omer"]]}
            ]),
            "9bf3f0fd-6eff-4560-8d65-c5ba79cf155f": conditionalAttachment("Firefoot", [
                {name: "attachmentBasicPassiveTokens", attack: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "omer"]]]},
                {name: "attachmentConditionalPassiveTokens", attack: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "omer"]]}
            ]),
            "f40cc90c-02df-464b-a401-6640aa93e2f8": staticAttachment("Cloak of Lorien", defense=1),  // TODO make dynamic based on active location having forest trait
            "47deb269-e02b-426d-b64a-34a4adff44de": staticAttachment("Valiant Sword", attack=1),
            "bfc41b26-7986-4bca-9e77-052abac32603": staticAttachment("Valiant Sword", attack=1),
            //"47deb269-e02b-426d-b64a-34a4adff44de": dynamicAttachment("Valiant Sword", [
            //    {name: "attachmentBasicPassiveTokens", attack: 1, listenTo: ["playerData/*/threat"], condition: [["LESS_THAN", "$GAME.playerData.player1.threat", 40]]},
            //    {name: "attachmentConditionalPassiveTokens", attack: 2, listenTo: ["playerData/*/threat"], condition: [["GREATER_EQUAL", "$GAME.playerData.player1.threat", 40]]}
            //]),
            //"bfc41b26-7986-4bca-9e77-052abac32603": dynamicAttachment("Valiant Sword", [
            //    {name: "attachmentBasicPassiveTokens", attack: 1, listenTo: ["playerData/*/threat"], condition: [["LESS_THAN", "$GAME.playerData.player1.threat", 40]]},
            //    {name: "attachmentConditionalPassiveTokens", attack: 2, listenTo: ["playerData/*/threat"], condition: [["GREATER_EQUAL", "$GAME.playerData.player1.threat", 40]]}
            //]),
            "418e6de7-af19-4ea7-bfbe-2a02838c6de4": staticAttachment("Dagger of Westernesse", attack=1),

            "51223bd0-ffd1-11df-a976-0801200c9027": staticAttachment("Celebrían's Stone", willpower=2),
            "ac8089a9-6dee-4c11-8c6c-4ef528400b39": staticAttachment("Celebrían's Stone", willpower=2),
            "51223bd0-ffd1-11df-a976-0801200c9040": staticAttachment("Citadel Plate", hitPoints=4),
            "51223bd0-ffd1-11df-a976-0801200c9055": staticAttachment("The Favour of the Lady", willpower=1),
            "51223bd0-ffd1-11df-a976-0801200c9071": staticAttachment("Dark Knowledge", willpower=-1),
            "51223bd0-ffd1-11df-a976-0801201c9002": staticAttachment("Dúnedain Mark", attack=1),
            "51223bd0-ffd1-11df-a976-0801202c9008": staticAttachment("Dúnedain Warning", defense=1),
            "51223bd0-ffd1-11df-a976-0801203c9008": staticAttachment("Dúnedain Quest", willpower=1),
            "51223bd0-ffd1-11df-a976-0801207c9026": staticAttachment("Dwarrowdelf Axe", attack=1),
            "90a3a467-a8a0-4394-9996-127b459deb58": staticAttachment("Dwarrowdelf Axe", attack=1),
            "51223bd0-ffd1-11df-a976-0801207c9012": staticAttachment("Boots from Erebor", hitPoints=1),
            "2e810a9b-5d79-4828-8268-33e82c5fc1fa": staticAttachment("Freezing Cold", willpower=-2),
            "51223bd0-ffd1-11df-a976-0801211c9021": staticAttachment("Ring Mail", defense=1, hitPoints=1),
            "51223bd0-ffd1-11df-a976-0801213c9005": staticAttachment("Fiery Sword", attack=3),
            "66d8e628-8ca8-4605-9017-aece027f054f": staticAttachment("Spear of the Mark", attack=1),
            "478a8847-d97e-4ce4-86eb-7e0e3d0627e0": staticAttachment("Spear of the Mark", attack=1),
            "6b86cf8e-1708-434d-90a5-93163f3d61ea": staticAttachment("Elven Mail", hitPoints=2),
            "12d436ac-15e6-47c5-8288-357c918071a7": staticAttachment("Bow of the Galadhrim", attack=1),
            "7cde0efa-22e2-41c3-a167-e36da4de092d": staticAttachment("Bow of the Galadhrim", attack=1),
            "bf925a7c-b427-4fb6-ba6b-dbc86304a69f": staticAttachment("Heirloom of Iârchon", willpower=1),
            "2e5e6e97-003b-4500-8372-495f5ee86051": staticAttachment("Heirloom of Iârchon", willpower=1),
            "8a6566b1-2425-442b-8e44-f8a3aa4590fe": staticAttachment("Sword of Númenor", attack=1),
            "2f9c24db-2ee4-4368-99fa-db49a0add8f5": staticAttachment("Raiment of War", attack=1, defense=1, hitPoints=2),
            "44b36766-fbb5-464d-bf9c-6a9cb9f48fad": staticAttachment("Entangling Nets", attack=-2, defense=-2),
            "9128a94e-546a-4b89-8bec-6c2739af0c6e": staticAttachment("Vigilant Guard", hitPoints=2),
            "778cf45f-cc72-424d-a7b3-09373328dd1b": staticAttachment("Windfola", willpower=1),
            "80a03178-4039-4b2c-a2c4-2d546aa9b0b2": staticAttachment("Ranger Spear", attack=1),
            "9ccbe47b-b30f-468a-a867-60314e3b5d61": staticAttachment("Dwarven Shield", defense=1),
            "565ab52d-0390-4f39-8e6d-7809444b53af": staticAttachment("Mirkwood Long-knife ", willpower=1, attack=1),
            "27d6c3df-c7dc-4ea0-941f-dcad65b3f1eb": staticAttachment("Mordor Warg", threat=2, attack=2, defense=2, hitPoints=2),
            "25b9113d-1096-4b8d-a2d3-1eb134fbca62": staticAttachment("Racing Warg", threat=1, attack=1, defense=1, hitPoints=1),
            "dd1a7167-8988-4ec7-a9ae-8e3becbc58d0": staticAttachment("Haradrim Spear", attack=1),
            "0b179f39-f202-4fe7-b930-0f3db582bc3e": staticAttachment("The Red Arrow", willpower=1),
            "86de124c-08d9-4482-8a37-be15455e0419": staticAttachment("The Red Arrow", willpower=1),
            "477ca0c8-7922-4c17-bba2-6d7c4718c49d": staticAttachment("Hauberk of Mail", defense=1),
            "1a06164a-8f54-49b7-a067-52680893f69d": staticAttachment("Frenzied Creature", threat=1, attack=1, defense=1),
            "8a0391d0-33c2-4881-82b6-1d9d824c3536": staticAttachment("Squire's Helm", hitPoints=2),
            "e11e74bb-80c4-4766-ad89-7bdd22ecad5b": staticAttachment("Ancestral Armor", defense=2, hitPoints=2),
            "30f499a0-c419-49b2-a5b7-93072fbaf875": staticAttachment("Glamdring", attack=2),
            "48eb743b-454a-43b7-96bf-27d468ad858a": staticAttachment("Wild Stallion", willpower=1, attack=1, defense=1, hitPoints=1),
            "80bb3d6a-c730-4994-badc-52fed8d92730": staticAttachment("Orcrist", attack=2),
            "4c23f4d0-fbf4-4c07-bb1d-0f5507647e0f": staticAttachment("Sting", willpower=1, attack=1, defense=1),
            "4c77565a-475e-4f57-9360-8f0a2916607f": staticAttachment("Armor of Erebor", defense=1),
            "b897b63d-86ac-417c-88d2-1a594f3674f1": staticAttachment("Sword of Rhûn", attack=2),
            "57e22e64-6ff5-4133-8c70-2ee3460d02f9": staticAttachment("Evidence of the Cult", threat=1, attack=1, defense=1),
            "1ac7e2b5-aa19-4608-b101-e22390c8a906": staticAttachment("Fanaticism", threat=1, attack=1, defense=1),
            "be4ccbc9-1d4c-461f-a44d-582c52d353e6": staticAttachment("Durin's Axe", attack=2),
            "28bc6296-217d-460a-96b1-47714daf3817": staticAttachment("Silver Circlet", willpower=2),
            "b41ed6a0-17bc-4cbc-a654-d4d9538eed62": staticAttachment("Inner Strength", defense=1),
            "fbf90e5c-4d15-499c-98c2-f8e63855fb69": staticAttachment("Strength and Courage", attack=1),
            "de829d6a-4b69-4423-88ce-d9e803e0e418": staticAttachment("Power of Command", willpower=1),
            "309c763a-60c9-4e33-bb0b-2b5e3a015227": staticAttachment("Wainrider Chariot", attack=1),
            "9a39a6b1-d480-4ced-8590-d3748b076208": staticAttachment("Well Preserved", hitPoints=1),
            "ad26f445-5cba-461c-8226-26a75cdf1891": staticAttachment("Spare Pipe", hitPoints=1),
            "7bae4f1a-42b7-46ab-bfbb-0078ed0842a4": staticAttachment("Sword of Belegost", attack=4),
            "0f201650-6d15-4909-9d06-0a87ab94f327": staticAttachment("Hired Muscle", threat=1, attack=1, defense=1),
            "51223bd0-ffd1-11df-a976-1801204c9075": staticAttachment("Sting (Treasure)", willpower=1, attack=1, defense=1),
            "51223bd0-ffd1-11df-a976-1801204c9064": staticAttachment("Orcrist (Treasure)", attack=2),
            "51223bd0-ffd1-11df-a976-1801204c9037": staticAttachment("Glamdring (Treasure)", attack=2),
            "12d51424-0edd-4977-9df1-5f6a7a5a96e1": staticAttachment("Mithril Shirt (Treasure)", defense=1, hitPoints=1),
            "857d6dc8-ba1e-4839-8e96-a8a0136a2302": staticAttachment("Thror's Battle Axe (Treasure)", attack=2),
            "323842f5-457f-4dd4-95b8-eb19c24664cb": staticAttachment("Dark Bats", willpower=-1, attack=-1, defense=-1),
            "ef014a91-c2d9-44ca-acd0-cc1a339c051f": staticAttachment("Tireless Ranger", defense=1),
            "1d1ab8a3-ad76-4992-ae5c-6a89fd0ed463": staticAttachment("Skilled Healer", hitPoints=2),
            "ff574390-bd68-4277-9065-dd9dbf552d00": staticAttachment("Valiant Warrior", attack=1),
            "af49e5ea-c6a2-4be4-bbf3-ac53c100e887": staticAttachment("Noble Hero", willpower=1),
            "4b36df3f-d75b-4b3a-9324-9ab31c10d7b9": staticAttachment("Pale Blade", attack=1),
            "7791cd04-7ffe-41f3-9633-cf57ad3a34ca": staticAttachment("Sting (Boon)", willpower=1, attack=1, defense=1),
            "23acfc2e-3262-4f22-8496-a753fa9089bd": staticAttachment("Mithril Shirt (Boon)", defense=1, hitPoints=1),
            "c7f5eac0-dbda-419f-994c-c182775682b3": staticAttachment("Glamdring (Boon)", attack=2),
            "24eabbac-62b1-4d2c-93a0-f97c04a2aefa": staticAttachment("Andúril (Boon)", willpower=1, attack=1, defense=1),
            "b86ba0f8-11f9-4694-b421-17b683bd4325": staticAttachment("Ent Draught", hitPoints=2),
            "1665d088-793c-4350-82f3-e35fd307463d": staticAttachment("Beyond All Hope (Boon)", willpower=1, attack=1, defense=1),
            "6e85113d-a2a6-44a7-895c-ca5115f7b7d2": staticAttachment("Fell Beast", threat=1, attack=1, defense=1), // TODO engagement cost -10
            "5003227b-ebc3-454a-88b4-2d6e20cc48f7": staticAttachment("Hell-hawk", threat=2, attack=2, defense=2),
            "1d109d1b-d1cb-48f0-8ff8-0413ac27048d": staticAttachment("Master of the Hunt (Boon)", hitPoints=1),
            "e347b2cf-e8c5-452a-bf59-7c411c8b430d": staticAttachment("Unbroken (Boon)", defense=1),
            "dbfe5919-9198-47a7-a268-52103803706d": staticAttachment("The Steadfast (Boon)", willpower=1),
            "01730a17-412d-4e71-b581-7c0b5bf61b73": staticAttachment("Dragon-slayer (Boon)", attack=1),
            "8a80874d-e169-4a46-9c4c-b991d7703b94": staticAttachment("Axe of the Edain (Boon)", attack=2),
            "4906a4b0-ace6-4c1e-9315-fcc8c5fddfd7": staticAttachment("Durin's Dagger (Boon)", attack=1),
            "01183fdb-a118-4a28-b938-0e2676f80716": staticAttachment("Glittering Lute (Boon)", willpower=2),
            "e921ca47-eeb2-4e5f-97ae-d4b22093acb9": staticAttachment("Gondolin Shield (Boon)", defense=1),
            "fa152f5a-de4d-42e2-a949-e9fc4fde16aa": staticAttachment("Helm of Heroes (Boon)", defense=2),
            "ee8d4a1a-6f19-4d00-a266-a4241e168cae": staticAttachment("Jewels of Wilder (Boon)", willpower=1),
            "213070d4-a652-40b9-ace9-7f81b2c93b86": staticAttachment("Masterwork Bow (Boon)", attack=1),
        }
    }
}