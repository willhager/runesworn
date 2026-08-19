extends Control

@onready var bookNode : Node = get_node("BookControl/BookContainer/Book")
@onready var bookControlNode : Node = get_node("BookControl")

@onready var enemy_instance : Node = null
@onready var player_instance : Node = null

@onready var eInfoPanelNode : Node = get_node("EInfoPanel")

@onready var circleControl : Node = get_node("BookControl/CircleControl")
@onready var circleNode : Node = get_node("BookControl/CircleControl/Circle")
@onready var ScreenLabelNode : Node = get_node("Label")

@onready var circleStartNode : Node = get_node("CircleStart")

@onready var nextButtonNode : Node = get_node("BookControl/NextButton")

@onready var textLabelNode : Node = get_node("TextBoxPanel/MarginContainer/TextLabel")
@onready var continueButtonNode : Node = get_node("TextBoxPanel/ContinueButton")

@onready var ProgressTrayNode : Node = get_node("ProgressTray")

@onready var rollButtonNode : Node = get_node("ButtonTray/VBoxContainer/RollButton")
@onready var endTurnButtonNode : Node = get_node("ButtonTray/VBoxContainer/EndTurn")

var damageEffectName = Global.damageEffectName
var shieldEffectName = Global.shieldEffectName
var healEffectName = Global.healEffectName
var piercingEffectName = Global.piercingEffectName
var freezeEffectName = Global.freezeEffectName
var explosiveEffectName = Global.explosiveEffectName

var enemy : Dictionary

var rolled : bool = false

var rolls

func _ready() -> void:
	ProgressTrayNode.update_encounters()
	
	match Global.playerType :
		"Goliath" :
			var scene_res = load("res://scenes/players/Goliath.tscn")
			if scene_res is PackedScene :
				var instance = scene_res.instantiate()
				bookControlNode.add_child(instance)
				player_instance = instance
			else :
				push_error("Invalid scene path: " + Global.enemy.get("path"))
		"Champion" :
			var scene_res = load("res://scenes/players/Champion.tscn")
			if scene_res is PackedScene :
				var instance = scene_res.instantiate()
				bookControlNode.add_child(instance)
				player_instance = instance
			else :
				push_error("Invalid scene path: " + Global.enemy.get("path"))
		"Assassin" :
			var scene_res = load("res://scenes/players/Assassin.tscn")
			if scene_res is PackedScene :
				var instance = scene_res.instantiate()
				bookControlNode.add_child(instance)
				player_instance = instance
			else :
				push_error("Invalid scene path: " + Global.enemy.get("path"))
			
	hideAllNodes()
	
	player_instance.selected_max_dice.connect(on_player_selected_max_dice)
	player_instance.selected_less_than_max_dice.connect(on_player_selected_less_than_max_dice)
	
	rollButtonNode.disabled = true
	endTurnButtonNode.disabled = true
	
	bookNode.play("open")
	await bookNode.animation_finished
	
	player_instance.showAllNodes()
	
	#start "summoning circle"
	showNodes_circleStart()
	
func _process(_delta) -> void :
	if Input.is_action_just_pressed("spacebar") :
		if not rollButtonNode.disabled :
			_on_roll_button_pressed()
		elif not endTurnButtonNode.disabled :
			_on_end_turn_pressed()
		
func reready() :
	hideAllNodes()
	
	player_instance.reready()
	
	eInfoPanelNode.reready()
	bookControlNode.remove_child(enemy_instance)
	enemy_instance.queue_free()
	rollButtonNode.disabled = true
	
	endTurnButtonNode.disabled = true
	
	circleControl.reready()
	$InfoPanel.reready()
	ScreenLabelNode.text = "Choose Your Path..."
	showNodes_circleStart()
	
	
func pre_roll() -> void:
	if player_instance.has_method("pre_roll") :
		player_instance.pre_roll()
	if enemy_instance.has_method("pre_roll") :
		enemy_instance.pre_roll()
	#RelicManager.pre_roll()

func _on_roll_button_pressed() -> void:
	if(!rolled) : 
		rolled = true
		rollButtonNode.disabled = true
	else :
		return
	
	enemy_instance.roll_eDice()
	player_instance.roll_dice()
	
func pre_select() -> void: 
	if player_instance.has_method("pre_select") :
		player_instance.pre_select()
	if enemy_instance.has_method("pre_select") :
		enemy_instance.pre_select()
	#RelicManager.pre_select()


func on_player_selected_max_dice() :
	endTurnButtonNode.disabled = false

func on_player_selected_less_than_max_dice() :
	endTurnButtonNode.disabled = true
	
func on_enemy_skip_turn() :
	if Global.playerType == "Goliath" :
		GameState.player_shield = player_instance.prevShield
	rolled = false
	rollButtonNode.disabled = false
	player_instance.clear(false)
	enemy_instance.clear()
	return
	
func pre_end() :
	GameState.copy_pDiceRolls_deep()
	if player_instance.has_method("pre_end") :
		player_instance.pre_end()
	if enemy_instance.has_method("pre_end") :
		enemy_instance.pre_end()
	#RelicManager.pre_end()

func _on_end_turn_pressed() -> void:
	player_instance.set_max_dice_num(Global.maxSelectableDice)
	pre_end()
	endTurnButtonNode.disabled = true
	
	player_instance.update_current_values()
	
	enemy_instance.update_health_with_damage()
	enemy_instance.update_health_with_aoe()
	
	player_instance.update_health_with_damage()
	
	Global.health = GameState.health
	$InfoPanel.update_health(GameState.health)
	
	if check_end_of_turn() : return
	
	enemy_instance.update_health_with_heal()
	
	player_instance.update_health_with_heal()
	
	enemy_instance.update_health_with_poison()
	
	if check_end_of_turn(): return
	
	rolled = false
	rollButtonNode.disabled = false
	
	if player_instance.has_method("pre_cleanup") :
		player_instance.pre_cleanup()
	if enemy_instance.has_method("pre_cleanup") :
		enemy_instance.pre_cleanup()
	#RelicManager.pre_cleanup()
	
	clear(false)
	Global.health = GameState.health
	$InfoPanel.update_health(GameState.health)

func check_end_of_turn() -> bool :
	if(GameState.health <= 0) :
		clear(true)
		$defeat.callDefeat()
		return true
	elif(enemy_instance.get_total_health() <= 0) :
		if enemy_instance.has_method("death_effect") :
			enemy_instance.death_effect()
			Global.health = GameState.health
			$InfoPanel.update_health(GameState.health)
			if(GameState.health <= 0) :
				clear(true)
				$defeat.callDefeat()
				return true
		if enemy_instance.get_total_health() <= 0 :
			clear(true)
			Global.health = GameState.health
			Global.encounterNum += 1
			if (Global.encounterNum == 7) :
				Global.encounterNum = 1
				Global.difficulty += 1
				#insert modifier upgrade screen maybe
			ProgressTrayNode.update_encounters()
			$victory.callVictory()
			return true
	return false

func clear(endOfRound: bool) -> void :
	
	enemy_instance.clear()
	player_instance.clear(endOfRound)
	
	rolled = false
	
	GameState.clear_pDiceRolls_deep_copy()
	
func hideAllNodes() :
	circleNode.hide()
	player_instance.hideAllNodes()
	
func showNodes_circleStart() :
	nextButtonNode.show()
	circleNode.modulate.a = 0
	circleNode.show()
	circleStartNode.play("circle_start")
	
func _on_next_button_pressed() -> void:
	ScreenLabelNode.text = "Battle!"
	
	Global.enemy = EncounterData.get_encounter_by_index(Global.difficulty, circleControl.getEnemies()[Global.mapLoc].get("id"))
	var scene_res = load(Global.enemy.get("path"))
	if scene_res is PackedScene :
		var instance = scene_res.instantiate()
		bookControlNode.add_child(instance)
		enemy_instance = instance
	else :
		push_error("Invalid scene path: " + Global.enemy.get("path"))
	
	eInfoPanelNode.set_core_values(Global.enemy.get("name"), "Max Health:" + str(enemy_instance.get_max_health()), "Reward:" + str(int(Global.enemy.get("reward"))))
	if(Global.enemy.get("hasAbility")) : 
		eInfoPanelNode.set_abilities_text("Abilities:\n" + Global.enemy.get("ability"))
		eInfoPanelNode.set_abilities_tooltip(Global.enemy.get("ability"), Global.enemy.get("abilityDescription"))
	else :
		eInfoPanelNode.set_abilities_text("Abilities:\nNone")

	if enemy_instance.has_signal("skip_turn") :
		enemy_instance.connect("skip_turn", on_enemy_skip_turn)
	if(Global.enemy.get("hasText")) :
		circleNode.hide()
		nextButtonNode.hide()
		textLabelNode.text = Global.enemy.get("text")
		circleStartNode.play("text_box")
	else:
		circleNode.hide()
		rollButtonNode.disabled = false;
		endTurnButtonNode.disabled = false;
		nextButtonNode.hide()
	

func _on_continue_button_pressed() -> void:
	circleStartNode.play_backwards("text_box")
	rollButtonNode.disabled = false;
	nextButtonNode.hide()
