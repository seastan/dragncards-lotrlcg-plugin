/*
To compile:
> jsonnet jsons/cardAutomations/basicAttachments.jsonnet > jsons/cardAutomations/basicAttachments-GENERATED.json
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

// checkFaceUp: primarily for Dreamchaser campaign boons which can be upgraded (flipped 'face-down') but still need to trigger
// listenTo: list of paths to additionally listen
// condition: list of conditions to append to "AND" condition
local attachmentRule(name, willpower=0, threat=0, attack=0, defense=0, hitPoints=0, questPoints=0, engagementCost=0, checkFaceUp=true, checkAttachedToCharacter=false, listenTo=[], condition=[]) = { 
    "_comment": "Add/remove tokens to the attached card.",
    "type": "passive", 
    "listenTo": ["/cardById/$THIS_ID/inPlay", "/cardById/$THIS_ID/currentSide", "/cardById/$THIS_ID/cardIndex", "/cardById/$THIS_ID/rotation"] + listenTo,
    "condition": [
        "AND", 
            "$THIS.inPlay",
            ["GREATER_THAN", "$THIS.cardIndex", 0],  // Card must be attached
            ["NOT_EQUAL", "$THIS.rotation", -30],  // Attached card must not be a shadow
    ] + (if checkFaceUp then [["EQUAL", "$THIS.currentSide", "A"]] else [])
    + (if checkAttachedToCharacter then [["IS_CHARACTER", "$GAME.cardById.{{$THIS.parentCardId}}"]] else [])
    + condition,
    "onDo":
        modifyToken("$THIS.parentCardId", "willpower", willpower) +
        modifyToken("$THIS.parentCardId", "threat", threat) +
        modifyToken("$THIS.parentCardId", "attack", attack) +
        modifyToken("$THIS.parentCardId", "defense", defense) +
        modifyToken("$THIS.parentCardId", "hitPoints", hitPoints) +
        modifyToken("$THIS.parentCardId", "questPoints", questPoints) +
        modifyToken("$THIS.parentCardId", "engagementCost", engagementCost)
    ,
    "offDo": [["VAR", "$PREV_PARENT_ID", ["PREV", "$THIS.parentCardId"]]] + 
        modifyToken("$PREV_PARENT_ID", "willpower", -willpower) +
        modifyToken("$PREV_PARENT_ID", "threat", -threat) +
        modifyToken("$PREV_PARENT_ID", "attack", -attack) +
        modifyToken("$PREV_PARENT_ID", "defense", -defense) +
        modifyToken("$PREV_PARENT_ID", "hitPoints", -hitPoints) +
        modifyToken("$PREV_PARENT_ID", "questPoints", -questPoints) +
        modifyToken("$PREV_PARENT_ID", "engagementCost", -engagementCost)
    ,
};

local staticAttachment(name, willpower=0, threat=0, attack=0, defense=0, hitPoints=0, questPoints=0, engagementCost=0, checkFaceUp=true, checkAttachedToCharacter=false) = {
    "_comment": name,
    "rules": {
        "attachmentStaticPassiveTokens": attachmentRule(name, willpower, threat, attack, defense, hitPoints, questPoints, engagementCost, checkFaceUp, checkAttachedToCharacter)
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
            questPoints= std.get(bonusRule, "questPoints", default=0),
            engagementCost = std.get(bonusRule, "engagementCost", default=0),
            checkFaceUp  = std.get(bonusRule, "checkFaceUp", default=true),
            listenTo   = std.get(bonusRule, "listenTo",  default=[]),
            condition  = std.get(bonusRule, "condition", default=[])
        )
        for bonusRule in bonusList
    }
};

// All attachments were found through the following regex search:
// Attached .* \b(?:gets|gains)\b .* \[?\b(?:willpower|threat|attack|defense|hit|quest|engagement)\b
// Skipped: PvP scenarios, Custom sets
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
            "fa1aa093-59e5-4919-8c06-86864848a89e": self["09134509-191b-4903-b4b5-5e650f8143c1"],
            "51223bd0-ffd1-11df-a976-0801212c9013": conditionalAttachment("Durin's Axe (Objective Attachment)", [
                {name: "attachmentBasicPassiveTokens", attack: 3, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Dwarf."]]]},
                {name: "attachmentConditionalPassiveTokens", attack: 3, willpower: 1, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Dwarf."]]}
            ]),
            "51223bd0-ffd1-11df-a976-0801212c9014": conditionalAttachment("Durin's Helm (Objective Attachment)", [
                {name: "attachmentBasicPassiveTokens", defense: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Dwarf."]]]},
                {name: "attachmentConditionalPassiveTokens", defense: 1, hitPoints: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Dwarf."]]}
            ]),
            "0ee1f1e6-1952-4bad-8ecd-631e80f4ccc0": conditionalAttachment("Firefoot", [
                {name: "attachmentBasicPassiveTokens", attack: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "omer"]]]},  // Matches both Éomer and Eomer
                {name: "attachmentConditionalPassiveTokens", attack: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.name", "omer"]]}
            ]),
            "9bf3f0fd-6eff-4560-8d65-c5ba79cf155f": self["0ee1f1e6-1952-4bad-8ecd-631e80f4ccc0"],
            "477ca0c8-7922-4c17-bba2-6d7c4718c49d": conditionalAttachment("Hauberk of Mail", [
                {name: "attachmentBasicPassiveTokens", defense: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.keywords", "Sentinel."]]]},
                {name: "attachmentConditionalPassiveTokens", defense: 1, hitPoints: 1, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.keywords", "Sentinel."]]}
            ]),
            "f40cc90c-02df-464b-a401-6640aa93e2f8": conditionalAttachment("Cloak of Lorien", [  // TODO fix listenTo trigger not firing
                {name: "attachmentBasicPassiveTokens", defense: 1, listenTo: ["/groupById/sharedActiveLocation/stackIds"], condition: [["NOT", ["ACTIVE_LOCATION_HAS_TRAIT", "Forest."]]]},
                {name: "attachmentConditionalPassiveTokens", defense: 2, listenTo: ["/groupById/sharedActiveLocation/stackIds"], condition: [["ACTIVE_LOCATION_HAS_TRAIT", "Forest."]]}
            ]),
            "47deb269-e02b-426d-b64a-34a4adff44de": conditionalAttachment("Valiant Sword", [
                {name: "attachmentBasicPassiveTokens", attack: 1, listenTo: ["/playerData/*/threat"], condition: [["LESS_THAN", "$GAME.playerData.{{$THIS.controller}}.threat", 40]]},
                {name: "attachmentConditionalPassiveTokens", attack: 2, listenTo: ["/playerData/*/threat"], condition: [["GREATER_EQUAL", "$GAME.playerData.{{$THIS.controller}}.threat", 40]]}
            ]),
            "bfc41b26-7986-4bca-9e77-052abac32603": self["47deb269-e02b-426d-b64a-34a4adff44de"],
            "c06f0513-459b-48ae-9e40-9a1a56e845ef": conditionalAttachment("Shining Shield", [
                {name: "attachmentBasicPassiveTokens", defense: 1, listenTo: ["/playerData/*/threat"], condition: [["LESS_THAN", "$GAME.playerData.{{$THIS.controller}}.threat", 40]]},
                {name: "attachmentConditionalPassiveTokens", defense: 2, listenTo: ["/playerData/*/threat"], condition: [["GREATER_EQUAL", "$GAME.playerData.{{$THIS.controller}}.threat", 40]]}
            ]),
            "789fbae0-a33e-4ea0-a34f-adfe3b62dba7": conditionalAttachment("Strider", [
                {name: "attachmentConditionalPassiveTokens", willpower: 2, listenTo: ["/cardById/*/inPlay", "/cardById/*/controller"], condition: [["LESS_EQUAL", ["LENGTH", ["FILTER_CARDS", "$C", ["AND", "$C.inPlay", ["EQUAL", "$C.controller", "$THIS.controller"], ["IS_CHARACTER", "$C"]]]], 5]]}
            ]),

            "51223bd0-ffd1-11df-a976-0801200c9027": staticAttachment("Celebrían's Stone", willpower=2),
            "ac8089a9-6dee-4c11-8c6c-4ef528400b39": staticAttachment("Celebrían's Stone", willpower=2),
            "51223bd0-ffd1-11df-a976-0801200c9040": staticAttachment("Citadel Plate", hitPoints=4),
            "51223bd0-ffd1-11df-a976-0801200c9055": staticAttachment("The Favor of the Lady", willpower=1),
            "51223bd0-ffd1-11df-a976-0801200c9056": staticAttachment("Power in the Earth", threat=-1),
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
            "4823aae3-46ef-4a75-89f9-cbd3aa1b9071": staticAttachment("Ranger Spikes", threat=-2),
            "f5f63ad3-e6cc-4827-8674-f81ff7a6e7d7": staticAttachment("Ranger Spikes", threat=-2),
            "66d8e628-8ca8-4605-9017-aece027f054f": staticAttachment("Spear of the Mark", attack=1),
            "478a8847-d97e-4ce4-86eb-7e0e3d0627e0": staticAttachment("Spear of the Mark", attack=1),
            "6b86cf8e-1708-434d-90a5-93163f3d61ea": staticAttachment("Elven Mail", hitPoints=2),
            "12d436ac-15e6-47c5-8288-357c918071a7": staticAttachment("Bow of the Galadhrim", attack=1),
            "7cde0efa-22e2-41c3-a167-e36da4de092d": staticAttachment("Bow of the Galadhrim", attack=1),
            "bf925a7c-b427-4fb6-ba6b-dbc86304a69f": staticAttachment("Heirloom of Iârchon", willpower=1),
            "2e5e6e97-003b-4500-8372-495f5ee86051": staticAttachment("Heirloom of Iârchon", willpower=1),
            "7f458303-66c1-45db-bf3f-20669fea6ff4": staticAttachment("Haunting Fog", questPoints=6),
            "8a6566b1-2425-442b-8e44-f8a3aa4590fe": staticAttachment("Sword of Númenor", attack=1),
            "7a8a2dbe-5a97-42da-a3c9-283724783145": staticAttachment("Secret Vigil", threat=-1),
            "2f9c24db-2ee4-4368-99fa-db49a0add8f5": staticAttachment("Raiment of War", attack=1, defense=1, hitPoints=2),
            "44b36766-fbb5-464d-bf9c-6a9cb9f48fad": staticAttachment("Entangling Nets", attack=-2, defense=-2),
            "9128a94e-546a-4b89-8bec-6c2739af0c6e": staticAttachment("Vigilant Guard", hitPoints=2),
            "778cf45f-cc72-424d-a7b3-09373328dd1b": staticAttachment("Windfola", willpower=1),
            "80a03178-4039-4b2c-a2c4-2d546aa9b0b2": staticAttachment("Ranger Spear", attack=1),
            "9ccbe47b-b30f-468a-a867-60314e3b5d61": staticAttachment("Dwarven Shield", defense=1),
            "565ab52d-0390-4f39-8e6d-7809444b53af": staticAttachment("Mirkwood Long-knife ", willpower=1, attack=1),
            "01a43351-0e36-4175-9a94-693ff91404ad": staticAttachment("Overgrown", threat=1),
            "27d6c3df-c7dc-4ea0-941f-dcad65b3f1eb": staticAttachment("Mordor Warg", threat=2, attack=2, defense=2, hitPoints=2),
            "25b9113d-1096-4b8d-a2d3-1eb134fbca62": staticAttachment("Racing Warg", threat=1, attack=1, defense=1, hitPoints=1),
            "dd1a7167-8988-4ec7-a9ae-8e3becbc58d0": staticAttachment("Haradrim Spear", attack=1),
            "0b179f39-f202-4fe7-b930-0f3db582bc3e": staticAttachment("The Red Arrow", willpower=1),
            "86de124c-08d9-4482-8a37-be15455e0419": staticAttachment("The Red Arrow", willpower=1),
            "1a06164a-8f54-49b7-a067-52680893f69d": staticAttachment("Frenzied Creature", threat=1, attack=1, defense=1),
            "50e62ade-1958-439d-9314-383d8621ecf5": staticAttachment("The Serpent's Garb", threat=2),
            "8a0391d0-33c2-4881-82b6-1d9d824c3536": staticAttachment("Squire's Helm", hitPoints=2),
            "e11e74bb-80c4-4766-ad89-7bdd22ecad5b": staticAttachment("Ancestral Armor", defense=2, hitPoints=2),
            "30f499a0-c419-49b2-a5b7-93072fbaf875": staticAttachment("Glamdring", attack=2, checkAttachedToCharacter=true),
            "48eb743b-454a-43b7-96bf-27d468ad858a": staticAttachment("Wild Stallion", willpower=1, attack=1, defense=1, hitPoints=1),
            "80bb3d6a-c730-4994-badc-52fed8d92730": staticAttachment("Orcrist", attack=2, checkAttachedToCharacter=true),
            "4c23f4d0-fbf4-4c07-bb1d-0f5507647e0f": staticAttachment("Sting", willpower=1, attack=1, defense=1, checkAttachedToCharacter=true),
            "b1cc99c3-09a7-4418-85c4-e368f44adf1d": staticAttachment("Necklace of Girion", willpower=2, checkAttachedToCharacter=true),
            "d45259f1-a551-466c-8352-cc466e1670c2": staticAttachment("Stone of Elostirion", willpower=2, checkAttachedToCharacter=true),
            "4c77565a-475e-4f57-9360-8f0a2916607f": staticAttachment("Armor of Erebor", defense=1),
            "639a4814-6a8e-4d7d-b589-fbbf22c78df2": staticAttachment("Put off Pursuit", questPoints=2),
            "b897b63d-86ac-417c-88d2-1a594f3674f1": staticAttachment("Sword of Rhûn", attack=2),
            "53c01bdc-2761-4f8f-90bc-1eedd14ca376": staticAttachment("Easterling Horse", threat=2),
            "57e22e64-6ff5-4133-8c70-2ee3460d02f9": staticAttachment("Evidence of the Cult", threat=1, attack=1, defense=1),
            "1ac7e2b5-aa19-4608-b101-e22390c8a906": staticAttachment("Fanaticism", threat=1, attack=1, defense=1),
            "be4ccbc9-1d4c-461f-a44d-582c52d353e6": staticAttachment("Durin's Axe", attack=2, checkAttachedToCharacter=true),
            "28bc6296-217d-460a-96b1-47714daf3817": staticAttachment("Silver Circlet", willpower=2),
            "b41ed6a0-17bc-4cbc-a654-d4d9538eed62": staticAttachment("Inner Strength", defense=1),
            "fbf90e5c-4d15-499c-98c2-f8e63855fb69": staticAttachment("Strength and Courage", attack=1),
            "de829d6a-4b69-4423-88ce-d9e803e0e418": staticAttachment("Power of Command", willpower=1),
            "309c763a-60c9-4e33-bb0b-2b5e3a015227": staticAttachment("Wainrider Chariot", attack=1),
            "9a39a6b1-d480-4ced-8590-d3748b076208": staticAttachment("Well Preserved", hitPoints=1),
            "ad26f445-5cba-461c-8226-26a75cdf1891": staticAttachment("Spare Pipe", hitPoints=1),
            "7bae4f1a-42b7-46ab-bfbb-0078ed0842a4": staticAttachment("Sword of Belegost", attack=4),
            "0f201650-6d15-4909-9d06-0a87ab94f327": staticAttachment("Hired Muscle", threat=1, attack=1, defense=1),
            "58aa1ac7-961f-4a44-ad11-7613d87d4eab": staticAttachment("The Cabal's Champion", threat=1, attack=1, defense=1, hitPoints=2),
            "e84369a8-89c8-4866-bd21-7c25ece2ca3f": staticAttachment("Shadow-Fall", questPoints=3),
            "27f961dd-c360-418e-9aac-6756d3a46dde": staticAttachment("Poison-darts", attack=2),
            "dc2da597-7d44-4654-a3f4-860e3f7117d6": staticAttachment("Fiery Whip", defense=1),
            "c7c7761f-a4dd-4f09-ac10-f0483d0c931d": staticAttachment("Flaming Sword", attack=1),
            "8bc37a15-f097-4471-8259-ac6f2cac3bc3": staticAttachment("Cunning Wolves", questPoints=3),
            "8d99a2be-18d6-4bfb-85ab-7be54a18e6b7": staticAttachment("Black Mare", hitPoints=3),
            "51223bd0-ffd1-11df-a976-1801204c9075": staticAttachment("Sting (Treasure)", willpower=1, attack=1, defense=1),
            "51223bd0-ffd1-11df-a976-1801204c9064": staticAttachment("Orcrist (Treasure)", attack=2),
            "51223bd0-ffd1-11df-a976-1801204c9037": staticAttachment("Glamdring (Treasure)", attack=2),
            "12d51424-0edd-4977-9df1-5f6a7a5a96e1": staticAttachment("Mithril Shirt (Treasure)", defense=1, hitPoints=1),
            "857d6dc8-ba1e-4839-8e96-a8a0136a2302": staticAttachment("Thror's Battle Axe (Treasure)", attack=2),
            "323842f5-457f-4dd4-95b8-eb19c24664cb": staticAttachment("Dark Bats", willpower=-1, attack=-1, defense=-1),
            "418e6de7-af19-4ea7-bfbe-2a02838c6de4": staticAttachment("Dagger of Westernesse", attack=1),
            "9bb32f2c-29fb-43ba-b7ba-2227b28f7b58": staticAttachment("Elf-stone", questPoints=1),
            "60c7ba84-8d59-48c6-ab81-0639ab55a8bf": staticAttachment("Elf-stone", questPoints=1),
            "ef014a91-c2d9-44ca-acd0-cc1a339c051f": staticAttachment("Tireless Ranger", defense=1),
            "1d1ab8a3-ad76-4992-ae5c-6a89fd0ed463": staticAttachment("Skilled Healer", hitPoints=2),
            "ff574390-bd68-4277-9065-dd9dbf552d00": staticAttachment("Valiant Warrior", attack=1),
            "af49e5ea-c6a2-4be4-bbf3-ac53c100e887": staticAttachment("Noble Hero", willpower=1),
            "4b36df3f-d75b-4b3a-9324-9ab31c10d7b9": staticAttachment("Pale Blade", attack=1),
            "09aeff64-6e0d-4dfa-af21-2e7805441376": staticAttachment("Black Steed", engagementCost=-10),
            "7791cd04-7ffe-41f3-9633-cf57ad3a34ca": staticAttachment("Sting (Boon)", willpower=1, attack=1, defense=1),
            "23acfc2e-3262-4f22-8496-a753fa9089bd": staticAttachment("Mithril Shirt (Boon)", defense=1, hitPoints=1),
            "c7f5eac0-dbda-419f-994c-c182775682b3": staticAttachment("Glamdring (Boon)", attack=2),
            "24eabbac-62b1-4d2c-93a0-f97c04a2aefa": staticAttachment("Andúril (Boon)", willpower=1, attack=1, defense=1),
            "b86ba0f8-11f9-4694-b421-17b683bd4325": staticAttachment("Ent Draught", hitPoints=2),
            "1665d088-793c-4350-82f3-e35fd307463d": staticAttachment("Beyond All Hope (Boon)", willpower=1, attack=1, defense=1),
            "6e85113d-a2a6-44a7-895c-ca5115f7b7d2": staticAttachment("Fell Beast", threat=1, attack=1, defense=1, engagementCost=-10),
            "5003227b-ebc3-454a-88b4-2d6e20cc48f7": staticAttachment("Hell-hawk", threat=2, attack=2, defense=2),
            "f31e3b0f-bb24-4c6d-856f-4805db1bbf4b": staticAttachment("Armor Plating (Boon)", defense=1, checkFaceUp=false),
            "e6f3f717-5348-463c-8cdf-dff28ee89d92": staticAttachment("Ballista (Boon)", attack=1, checkFaceUp=false),
            "be24f0fa-17fe-4bad-9334-52396925f5da": staticAttachment("Enlarged Quarters (Boon)", hitPoints=1, checkFaceUp=false),
            "930cdcbc-a3f4-4eb8-92d0-42e2af7a8184": staticAttachment("Extra Sails (Boon)", willpower=1, checkFaceUp=false),
            "09993d97-ebf8-4c2c-b051-2691b175a2aa": staticAttachment("Black Key (Boon)", willpower=1, checkFaceUp=false),
            "dfa5000e-07a5-4694-82b5-f9a5347d0961": staticAttachment("Parrying Cutlass (Boon)", defense=1, checkFaceUp=false),  // TODO make conditional based on faceup side and resources on hero
            "cf6bc361-8dbb-40f6-b6e6-3762ce390b0a": staticAttachment("Throwing Axe (Boon)", attack=1, checkFaceUp=false),  // TODO ditto
            "5a194ef3-94dc-46aa-af0e-7653a9955539": staticAttachment("Black Key (Burden)", threat=1, attack=1, defense=1, checkFaceUp=false),
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
            "7cb17939-363a-437d-840f-feac38489b8f": staticAttachment("Hardy (Boon)", hitPoints=2),
            "81d0fb8f-1d63-49c9-95e5-ce8432a65020": staticAttachment("Resolute (Boon)", willpower=1),
            "66e7a60b-ab6d-48ed-a28c-0595521ebec3": staticAttachment("Ruthless (Boon)", attack=1),
            "5d1d5894-7ff0-4e23-8cd6-9dd132b0616c": staticAttachment("Stalwart (Boon)", defense=1),
            // TODO Thaurdir's Legacy/Majesty/Spite: bonus needs to be conditional on if attached to Hero rather than Thaurdir
            "dff70cc7-d8a4-4fd5-b856-56d2203d007d": staticAttachment("Mail of Earuor (Boon)", hitPoints=2),
            "b98de754-08e1-4a78-970e-384350d2961c": staticAttachment("Daechanar's Brand (Boon)", attack=1),
            "969e2d92-da4f-4257-8833-0cc4c19ea10d": staticAttachment("Heirloom of Iarchon (Boon)", willpower=1),
            "46b11215-59ee-46ac-8154-693ce9fff971": staticAttachment("Orders from Angmar (Boon)", defense=1),
            "a539e3f4-4387-4569-a14e-fea235ad447c": staticAttachment("Raiment of the Second Age (Boon)", attack=2, hitPoints=2),

            // ALeP
            "65f15c99-d34e-4496-9ad3-4036114dc333": staticAttachment("Flinthoof", attack=1),
            "608a1135-3b40-4189-b498-b9eff3a3f7ce": staticAttachment("Brightmane", willpower=1, threat=1),
            "097f57fe-63f3-4494-ab39-a907fe6f089c": staticAttachment("Bree Pony", hitPoints=1),
            "f0ceca81-907d-4c7f-a8e3-0842bf11b80d": staticAttachment("Relic of Nargothrond", defense=1),
            "ba8a2808-f29b-404d-84dd-18d2483d9c97": staticAttachment("Subdued", attack=-4),
            "4a2566d3-9af7-455a-bb5a-d9dafe62c636": staticAttachment("Anduril", willpower=1, attack=1, defense=1),
            "8c504bd4-31c7-4269-a034-3007cf3cba9e": staticAttachment("Let Us Sing Together", willpower=1),
            "cc5a34e3-d7b0-4f7f-82bf-d4f4c8778dd5": staticAttachment("Claw Marks", threat=2),
            "f894c32c-5dfa-45f9-a5a3-122f3c171b89": staticAttachment("Star-like Gem (Boon)", willpower=1),
            "9b5119ec-5bc1-4421-8da7-1407b8279f67": staticAttachment("Longing for Home", willpower=-2),
            "530d5c75-bf6d-46c3-bd75-f39fb63a4d37": staticAttachment("Wolf Tracks", questPoints=10),

            "ec138f38-054b-4d34-80f6-bd058c5483e7": conditionalAttachment("Bright Mail (Boon)", [
                {name: "attachmentBasicPassiveTokens", defense: 1, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Hobbit."]]]},
                {name: "attachmentConditionalPassiveTokens", defense: 2, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Hobbit."]]}
            ]),
            "aaea207b-e0af-4865-89c9-16985543ef9a": conditionalAttachment("Heightened Stature (Boon)", [
                {name: "attachmentBasicPassiveTokens", hitPoints: 2, condition: [["NOT", ["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Hobbit."]]]},
                {name: "attachmentConditionalPassiveTokens", hitPoints: 3, condition: [["IN_STRING", "$GAME.cardById.{{$THIS.parentCardId}}.currentFace.traits", "Hobbit."]]}
            ]),
        }
    }
}