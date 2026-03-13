extends Control

@onready var button1 : Node = get_node("Circle/Button1")
@onready var button2 : Node = get_node("Circle/Button2")
@onready var button3 : Node = get_node("Circle/Button3")
@onready var notesDescription : Node = get_node("Circle/DescriptionContainer/NotesPanel/Notes")
@onready var rewardDescription : Node = get_node("Circle/DescriptionContainer/RewardPanel/Reward")

var enemies : Array
var button1pressed : bool = false
var button2pressed : bool = false
var button3pressed : bool = false

func _ready() :
	enemies = EncounterData.get_3_encounters(Global.difficulty)

func reready() :
	enemies = EncounterData.get_3_encounters(Global.difficulty)
	notesDescription.text = ""
	rewardDescription.text = ""
	button1pressed = false
	button1.button_pressed = false
	button2pressed = false
	button2.button_pressed = false
	button3pressed = false
	button3.button_pressed = false
	
func getEnemies() -> Array :
	return enemies

func _on_bottom_pressed() -> void:
	if button1pressed :
		notesDescription.text = ""
		rewardDescription.text = ""
		button1pressed = false
	else :
		button1pressed = true
		button2pressed = false
		button2.button_pressed = false
		button3pressed = false
		button3.button_pressed = false
		Global.mapLoc = 2
		notesDescription.text = EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id")).get("notes")
		rewardDescription.text = "Reward:" + str(EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id")).get("reward"))

func _on_top_pressed() -> void:
	if button2pressed :
		notesDescription.text = ""
		rewardDescription.text = ""
		button2pressed = false
	else :
		button2pressed = true
		button1pressed = false
		button1.button_pressed = false
		button3pressed = false
		button3.button_pressed = false
		Global.mapLoc = 0
		notesDescription.text = EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id")).get("notes")
		rewardDescription.text = "Reward:" + str(EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id")).get("reward"))


func _on_right_pressed() -> void:
	if button3pressed :
		notesDescription.text = ""
		rewardDescription.text = ""
		button3pressed = false
	else :
		button3pressed = true
		button2pressed = false
		button2.button_pressed = false
		button1pressed = false
		button1.button_pressed = false
		Global.mapLoc = 1
		notesDescription.text = EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id")).get("notes")
		rewardDescription.text = "Reward:" + str(EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id")).get("reward"))
