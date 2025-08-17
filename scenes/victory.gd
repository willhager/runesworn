extends Control

@onready var rewardNode = get_node("Panel/VBoxContainer/Reward")
@onready var mapButtonNode = get_node("Panel/VBoxContainer/MapButton")
@onready var menuButtonNode = get_node("Panel/VBoxContainer/MenuButton")

@onready var root = get_parent()

var reward
var foundLoot

func _ready() -> void:
	self.visible = false
	self.set_process_input(false)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rewardNode.hide()
	foundLoot = randi_range(0, 4)
	if foundLoot == 2 :
		reward = LootData.get_loot_drop()
		rewardNode.show()
		rewardNode.text = "You've found some loot: " + reward.get("itemName")

func callVictory() -> void :
	self.visible = true
	self.set_process_input(true)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	
func _on_map_button_pressed() -> void:
	self.visible = false
	self.set_process_input(false)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if foundLoot == 2 :
		Global.player_data.get("dice").set(reward.get("itemName"), 1)
		Global.save_player_data()
	root.reready()

func _on_menu_button_pressed() -> void:
	Global.health = 0
	Global.difficulty = 1
	Global.encounterNum = 1
	Global.curScenePath = Global.mainMenuPath
	if foundLoot == 2 :
		Global.player_data.get("dice").set(reward.get("itemName"), 1)
		Global.save_player_data()
	get_tree().change_scene_to_file(Global.mainMenuPath)
