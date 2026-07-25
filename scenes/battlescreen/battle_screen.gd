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
	
func _on_roll_button_pressed() -> void:
	if(!rolled) : 
		rolled = true
		rollButtonNode.disabled = true
	else :
		return
	
	enemy_instance.roll_eDice()
	player_instance.roll_dice()

func on_player_selected_max_dice() :
	endTurnButtonNode.disabled = false
func on_player_selected_less_than_max_dice() :
	endTurnButtonNode.disabled = true
	
func _on_end_turn_pressed() -> void:
	endTurnButtonNode.disabled = true
	
	if enemy_instance.has_method("die_num_effect") :
		player_instance.set_max_dice_num(enemy_instance.die_num_effect(player_instance.maxDieNum))
	else : player_instance.set_max_dice_num(Global.maxSelectableDice)
	
	if enemy_instance.has_method("skip_turn_effect") :
		var skip = enemy_instance.skip_turn_effect()
		if skip :
			rolled = false
			rollButtonNode.disabled = false
			player_instance.clear()
			enemy_instance.clear()
			return
	
	var rolls = modify_player_rolls()
	
	player_instance.update_current_values(rolls)
	
	enemy_instance.update_health_with_damage(rolls)
	enemy_instance.update_health_with_aoe(rolls)
		
	player_instance.update_health_with_damage(enemy_instance.get_rolls())
	
	Global.health = player_instance.health
	$InfoPanel.update_health(player_instance.health)
	
	if(player_instance.health <= 0) :
		clear()
		$defeat.callDefeat()
		return
	elif(enemy_instance.get_total_health() <= 0) :
		if enemy_instance.has_method("death_effect") :
			player_instance.health -= enemy_instance.death_effect()
			Global.health = player_instance.health
			$InfoPanel.update_health(player_instance.health)
			if(player_instance.health <= 0) :
				clear()
				$defeat.callDefeat()
				return
		if enemy_instance.get_total_health() <= 0 :
			clear()
			Global.health = player_instance.health
			Global.encounterNum += 1
			if (Global.encounterNum == 7) :
				Global.encounterNum = 1
				Global.difficulty += 1
				#insert modifier upgrade screen maybe
			ProgressTrayNode.update_encounters()
			$victory.callVictory()
			return
	
	enemy_instance.update_health_with_heal()
	
	player_instance.update_health_with_heal()
	
	enemy_instance.update_health_with_poison()
	
	if(enemy_instance.get_total_health() <= 0) :
		if enemy_instance.has_method("death_effect") :
			enemy_instance.death_effect()
		if enemy_instance.get_total_health() <= 0 :
			clear()
			Global.health = player_instance.health
			Global.encounterNum += 1
			if (Global.encounterNum == 7) :
				Global.encounterNum = 1
				Global.difficulty += 1
				#insert modifier upgrade screen maybe
			ProgressTrayNode.update_encounters()
			$victory.callVictory()
			return
	
	rolled = false
	rollButtonNode.disabled = false
	
	clear()
	Global.health = player_instance.health
	$InfoPanel.update_health(player_instance.health)
	
func modify_player_rolls() -> Array[Dictionary] :
	var ret = player_instance.get_player_rolls()
	if enemy_instance.has_method("modify_player_rolls") :
		ret = enemy_instance.modify_player_rolls(ret)
	return ret

func clear() -> void :
	
	enemy_instance.clear()
	player_instance.clear()
	
	rolled = false
	
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
