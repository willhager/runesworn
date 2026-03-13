extends Node

var curScenePath = "res://scenes/main_menu.tscn"

var mainMenuPath = "res://scenes/mainmenu/main_menu.tscn"
var classSelectionPath = "res://scenes/classselection/class_selection.tscn"
var diceSelectionPath = "res://scenes/diceselection/dice_selection.tscn"
var battleScreenPath = "res://scenes/battlescreen/battle_screen.tscn"

var classSelectionScene = load(classSelectionPath)
var diceSelectionScene = load(diceSelectionPath)
var battleScreenScene = load(battleScreenPath)


var version = "v1.0.0a"
##Contains data about player dice unlocks
var player_data: Dictionary = {}

##Currently selected player
var playerType : String
var hasModifier0 : bool = true
var hasModifier1 : bool = false
var hasModifier2 : bool = false

##Current dice selected by player
var die : Array[String] = ["", "", "", "", ""]
var health : int
var maxHealth : int
var difficulty = 1
var encounterNum = 1
var lootMult = 1
var maxLootNum = 8
var totalDiceIndex : int = 10

var JSON_PATH : String
var playerDataLoaded = false

#Dictionary containing information about current enemy. Reset/updated when encounter selected in map screen.
var enemy : Dictionary

var mapLoc : int = 2

var damageEffectName = "damage"
var shieldEffectName = "shield"
var healEffectName = "heal"
var piercingEffectName = "piercing"
var freezeEffectName = "freeze"
var explosiveEffectName = "explosive"

func _ready() :
	pass
	
func get_modifier_0() -> String :
	if(hasModifier0) :
		match playerType :
			"Goliath" :
				return "The Wall\n"
			"Champion" :
				return "The Chain\n"
			"Assassin" : 
				return "The Dagger\n"
	return ""
	
func get_modifier_0_tooltip() -> String :
	if(hasModifier0) :
		match playerType :
			"Goliath" :
				return "Stacks extra shield for use in later turns.\n"
			"Champion" :
				return "3 or more selected attack rolls allows for selection of another die.\n"
			"Assassin" : 
				return "Landed damage inflicts a poison counter. Enemy takes damage equal to poison counter after heal.\n"
	return ""

func get_modifier_1() -> String :
	if(hasModifier1) :
		match playerType :
			"Goliath" :
				return "Coming soon!\n"
			"Champion" :
				return "Coming soon!\n"
			"Assassin" :
				return "Coming soon!\n"
	return ""
	
func get_modifier_1_tooltip() -> String :
	if(hasModifier1) :
		match playerType :
			"Goliath" :
				return "Extra shields do damage after heal phase.\n"
			"Champion" :
				return "Gain x2 multiplier to highest attack roll.\n"
			"Assassin" :
				return "Coming soon!\n"
	return ""

func get_modifier_2() -> String :
	if(hasModifier2) :
		match playerType :
			"Goliath" :
				return "Coming soon!\n"
			"Champion" :
				return "Coming soon!\n"
			"Assassin" :
				return "Coming soon!\n"
	return ""
	
func get_modifier_2_tooltip() -> String :
	if(hasModifier2) :
		match playerType :
			"Goliath" :
				return "Gain additional 3 shield per turn.\n"
			"Champion" :
				return "The Chain applies to any face type.\n"
			"Assassin" :
				return "Coming soon!\n"
	return ""

func player_has_die(dieName : String) -> bool :
	if(player_data.get("dice").get(dieName) == 1.0) :
		return true
	return false

func load_player_data():
	JSON_PATH = "res://saves/" + playerType + ".json"
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		if typeof(json_result) == TYPE_DICTIONARY:
			player_data = json_result
		else:
			push_error("Failed to parse player JSON.")
	else:
		push_error("Failed to open player JSON")
	health = player_data.get("Health")
	maxHealth = health

func save_player_data():
	var json_text = JSON.stringify(player_data, "\t")
	var file = FileAccess.open(JSON_PATH, FileAccess.WRITE)
	file.store_string(json_text)
	file.close()
