extends Control

@onready var titleTextNode : Node = get_node("BookControl/ClassContainer/ClassTitle")
@onready var goliathButtonNode : Node = get_node("BookControl/ClassContainer/GoliathButton")
@onready var assassinButtonNode : Node = get_node("BookControl/ClassContainer/AssassinButton")
@onready var championButtonNode : Node = get_node("BookControl/ClassContainer/ChampionButton")
@onready var classDescriptionNode : Node = get_node("BookControl/RightPageContainer/CDPanel/ClassDescription")
@onready var bookNode : Node = get_node("BookControl/BookContainer/Book")
@onready var diceListNode : Node = get_node("BookControl/RightPageContainer/DLPanel/DiceList")
@onready var nextButtonNode : Node = get_node("BookControl/NextButton")
@onready var classContainerNode : Node = get_node("BookControl/ClassContainer")
@onready var rightPageContainerNode : Node = get_node("BookControl/RightPageContainer")
@onready var healthLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/HealthLabel")
@onready var levelLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/LevelLabel")
@onready var modifiersLabelNode : Node = get_node("BookControl/RightPageContainer/MPanel/Modifiers")
@onready var backButtonNode : Node = get_node("BookControl/BackButton")

var playerType : String
var classSelected : bool = false

func _ready() -> void :
	healthLabelNode.text = "Health:" + str(Global.health)
	levelLabelNode.text = "Level:" + "0"
	nextButtonNode.disabled = true
	
func start_class_selection():
	titleTextNode.show()
	goliathButtonNode.show()
	assassinButtonNode.show()
	championButtonNode.show()

func _on_goliath_button_pressed():
	playerType = "Goliath"
	Global.playerType = playerType
	Global.load_player_data()
	if classSelected :
		diceListNode.clear()
		populateDiceList()
	else :
		populateDiceList()
	classDescriptionNode.text = "The Wall: Stacks extra shield for use in later turns."
	modifiersLabelNode.text = "Coming soon!"
	modifiersLabelNode.text = "-Extra shields do damage after heal phase\n-Gain additional 3 shield per turn\n"
	healthLabelNode.text = "Health:" + str(Global.health)
	classSelected = true
	nextButtonNode.disabled = false

func _on_assassin_button_pressed():
	playerType = "Assassin"
	Global.playerType = playerType
	Global.load_player_data()
	if classSelected :
		diceListNode.clear()
		populateDiceList()
	else :
		populateDiceList()
	classDescriptionNode.text = "The Dagger: Landed damage inflicts a poison counter. Enemy takes damage equal to poison counter after heal."
	modifiersLabelNode.text = "Coming soon!"
	healthLabelNode.text = "Health:" + str(Global.health)
	classSelected = true
	nextButtonNode.disabled = false

func _on_champion_button_pressed():
	playerType = "Champion"
	Global.playerType = playerType
	Global.load_player_data()
	if classSelected :
		diceListNode.clear()
		populateDiceList()
	else :
		populateDiceList()
	classDescriptionNode.text = "The Chain: 3 or more selected attack rolls allows for selection of another die."
	modifiersLabelNode.text = "Coming soon!"
	modifiersLabelNode.text = "-Gain x2 multiplier to highest attack roll\n-Chained rolls apply to any face type"
	healthLabelNode.text = "Health:" + str(Global.health)
	classSelected = true
	nextButtonNode.disabled = false
	
func _on_next_button_pressed() -> void:
	hideAllNodes()
	bookNode.play("default")
	await bookNode.animation_finished
	Global.curScenePath = Global.diceSelectionPath
	get_tree().change_scene_to_file(Global.diceSelectionPath)
	
func populateDiceList() -> void:
	var dice_list = DiceData.dice_data.get("dice", [])
	var die_index = 0
	var die_name : String
	for i in range(Global.totalDiceIndex + 1):
		if die_index < dice_list.size() :
			if Global.player_has_die(dice_list[die_index].get("name")):
				die_name = dice_list[die_index].get("name", "Unknown Die")
				diceListNode.add_item(die_name, null, false)
		die_index += 1

func hideAllNodes():
	classContainerNode.hide()
	rightPageContainerNode.hide()
	nextButtonNode.hide()
	backButtonNode.hide()

func _on_back_button_pressed() -> void:
	Global.playerType = ""
	Global.health = 0
	hideAllNodes()
	Global.curScenePath = Global.mainMenuPath
	get_tree().change_scene_to_file(Global.mainMenuPath)
