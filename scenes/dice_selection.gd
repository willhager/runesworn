extends Control

@onready var bookNode : Node = get_node("BookControl/BookContainer/Book")
@onready var diceLabelNode : Node = get_node("BookControl/DiceContainer/DiceLabel")
@onready var nextButtonNode : Node = get_node("BookControl/NextButton")
@onready var diceListNode : Node = get_node("BookControl/RightPageContainer/DLPanel/DiceList")
@onready var dieButton1Node : Node = get_node("BookControl/DiceContainer/DieButton1")
@onready var dieButton2Node : Node = get_node("BookControl/DiceContainer/DieButton2")
@onready var dieButton3Node : Node = get_node("BookControl/DiceContainer/DieButton3")
@onready var dieButton4Node : Node = get_node("BookControl/DiceContainer/DieButton4")
@onready var dieButton5Node : Node = get_node("BookControl/DiceContainer/DieButton5")
@onready var diceContainerNode : Node = get_node("BookControl/DiceContainer")
@onready var rightPageContainerNode : Node = get_node("BookControl/RightPageContainer")
@onready var classLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/ClassLabel")
@onready var healthLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/HealthLabel")
@onready var levelLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/LevelLabel")
@onready var backButtonNode : Node = get_node("BookControl/BackButton")

var dieButtonPath = "BookControl/DiceContainer/DieButton"
var dieFacePath = "BookControl/RightPageContainer/DiceInfoPanel/InfoHBox/FaceContainer/Face"
var dieInfoPath = "BookControl/RightPageContainer/DiceInfoPanel/InfoHBox/InfoContainer/Info"

var damageEffectName = Global.damageEffectName
var shieldEffectName = Global.shieldEffectName
var healEffectName = Global.healEffectName
var piercingEffectName = Global.piercingEffectName

var rows = 4

var box1 = false
var box2 = false
var box3 = false
var box4 = false
var box5 = false

func _ready():
	classLabelNode.text = Global.playerType
	healthLabelNode.text = "Health:" + str(Global.health)
	levelLabelNode.text = "Level: " + "0"
	diceListNode.clear()
	var dice_list = DiceData.dice_data.get("dice", [])
	var die_index = 0
	#var total_slots = rows * $DiceBox/DiceList.columns
	var die_name : String
	for i in range(Global.totalDiceIndex + 1):
		if (die_index < dice_list.size() && Global.player_has_die(dice_list[die_index].get("name"))):
			die_name = dice_list[die_index].get("name", "Unknown Die")
			die_index += 1
			diceListNode.add_item(die_name, null, true)
		elif (die_index < dice_list.size() && !(Global.player_has_die(dice_list[die_index].get("name")))):
			die_index += 1
	diceListNode.item_selected.connect(_on_dice_list_item_clicked)
	
	for i in range (1, 6) :
		var node = get_node(dieButtonPath + str(i))
		node.disabled = true
	nextButtonNode.disabled = true
		
func _on_dice_list_item_clicked(index: int) -> void:
	var selected_text = diceListNode.get_item_text(index)
	var selected_die_faces = DiceData.get_die_by_name(selected_text).get("faces")
	for i in range (0, 6) :
		var faceNode = get_node(dieFacePath + str(i))
		faceNode.texture = load(selected_die_faces[i].get("sprite"))
		var infoNode = get_node(dieInfoPath + str(i))
		var value = str(selected_die_faces[i].get("value"))
		match selected_die_faces[i].get("effect") :
			damageEffectName :
				infoNode.text = "Deals " + str(int(value)) + " damage."
			shieldEffectName :
				infoNode.text = "Protects you from " + str(int(value)) + " damage."
			healEffectName :
				infoNode.text = "Restores " + str(int(value)) + " health."
			piercingEffectName :
				infoNode.text = "Deals " + str(int(value)) + " damage, skips shield."
			
	add_selected_die(selected_text)
	
func add_selected_die(text):
	if !box1:
		dieButton1Node.text = text
		dieButton1Node.disabled = false
		box1 = true
	elif !box2:
		dieButton2Node.text = text
		dieButton2Node.disabled = false
		box2 = true
	elif !box3:
		dieButton3Node.text = text
		dieButton3Node.disabled = false
		box3 = true
	elif !box4:
		dieButton4Node.text = text
		dieButton4Node.disabled = false
		box4 = true
	elif !box5:
		dieButton5Node.text = text
		dieButton5Node.disabled = false
		box5 = true
	else:
		pass
	if (box1 && box2 && box3 && box4 && box5) :
		nextButtonNode.disabled = false


func _on_die_button_1_pressed() :
	if box1 : 
		dieButton1Node.text = "Empty"
		dieButton1Node.disabled = true
		box1 = false
		nextButtonNode.disabled = true

func _on_die_button_2_pressed() :
	if box2 : 
		dieButton2Node.text = "Empty"
		dieButton2Node.disabled = true
		box2 = false
		nextButtonNode.disabled = true

func _on_die_button_3_pressed() :
	if box3 : 
		dieButton3Node.text = "Empty"
		dieButton3Node.disabled = true
		box3 = false
		nextButtonNode.disabled = true

func _on_die_button_4_pressed() :
	if box4 :
		dieButton4Node.text = "Empty"
		dieButton4Node.disabled = true
		box4 = false
		nextButtonNode.disabled = true

func _on_die_button_5_pressed() :
	if box5 :
		dieButton5Node.text = "Empty"
		dieButton5Node.disabled = true
		box5 = false
		nextButtonNode.disabled = true

func _on_next_button_pressed():
	for i in range (0, 5) :
		var nodePath = dieButtonPath + str(i+1)
		var node = get_node(nodePath)
		Global.die[i] = node.text
	hideAllNodes()
	bookNode.play("close")
	await bookNode.animation_finished
	FadeTransition.transition()
	await FadeTransition.on_transition_finished
	get_tree().change_scene_to_packed(Global.battleScreenScene)
	
func hideAllNodes():
	diceContainerNode.hide()
	rightPageContainerNode.hide()
	nextButtonNode.hide()
	backButtonNode.hide()

func _on_back_button_pressed() -> void :
	hideAllNodes()
	Global.curScenePath = Global.classSelectionPath
	bookNode.play_backwards("default")
	await bookNode.animation_finished
	get_tree().change_scene_to_packed(Global.classSelectionScene)
