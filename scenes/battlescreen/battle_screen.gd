extends Control

@onready var pDamageNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Damage")
@onready var pHealNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Heal")
@onready var pShieldNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Shield")
@onready var pFreezeNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Freeze")
@onready var pExplosiveNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Explosive")
@onready var pSelectedNode : Node = get_node("BookControl/PlayerDiceTray/Selected")

@onready var playerDiceTrayNode : Node = get_node("BookControl/PlayerDiceTray")
@onready var bookNode : Node = get_node("BookControl/BookContainer/Book")
@onready var bookControlNode : Node = get_node("BookControl")

@onready var enemy_instance : Node = null

@onready var eNameNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EName")
@onready var eHealthNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EHealth")
@onready var eRewardNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EReward")
@onready var eAbilitiesNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EAbilities")

@onready var circleControl : Node = get_node("BookControl/CircleControl")
@onready var circleNode : Node = get_node("BookControl/CircleControl/Circle")
@onready var ScreenLabelNode : Node = get_node("Label")

@onready var circleStartNode : Node = get_node("CircleStart")
@onready var nextButtonNode : Node = get_node("BookControl/NextButton")

@onready var textLabelNode : Node = get_node("TextBoxPanel/MarginContainer/TextLabel")
@onready var continueButtonNode : Node = get_node("TextBoxPanel/ContinueButton")

@onready var rollButtonNode : Node = get_node("ButtonTray/VBoxContainer/RollButton")
@onready var endTurnButtonNode : Node = get_node("ButtonTray/VBoxContainer/EndTurn")

var pDiePath : String = "BookControl/PlayerDiceTray/PDiceContainer/Die"
var pDiePath2 : String = "/CenterContainer/Faces"

var encounterIconPath : String = "ProgressTray/VBoxContainer/Encounter"

var healthLabelText = "H: "
var damageLabelText = "D:"
var shieldLabelText = "S:"
var healLabelText = "H:"
var freezeLabelText = "F:"
var explosiveLabelText = "E:"
var poisonLabelText = "P:"

var damageEffectName = Global.damageEffectName
var shieldEffectName = Global.shieldEffectName
var healEffectName = Global.healEffectName
var piercingEffectName = Global.piercingEffectName
var freezeEffectName = Global.freezeEffectName
var explosiveEffectName = Global.explosiveEffectName

var enemy : Dictionary
var health : int
var rolled : bool = false
var numSelected : int = 0
var selectedArry : Array[bool]
var selectedAttackDice : int = 0
var maxDieNum : int = 3

var curDamage : int
var curHeal : int
var curShield : int
var curPiercing : int
var curFreeze : int
var curExplosive : int
var pDiceRolls : Array[Dictionary]

var selectedText = "0/" + str(maxDieNum)


func _ready() -> void:
	update_encounters()
	hideAllNodes()
	health = Global.health
	rollButtonNode.disabled = true
	endTurnButtonNode.disabled = true
	endTurnButtonNode.disabled = true
		
	bookNode.play("open")
	await bookNode.animation_finished
	
	pDiceRolls.resize(5)
	selectedArry.resize(5)
	
	#initialize player dice and set textures
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		var dieTexture : SpriteFrames = SpriteFrames.new()
		dieTexture.add_animation("faces")
		dieTexture.set_animation_speed("faces", 10)
		for j in range(0, 6) :
			dieTexture.add_frame("faces", load(DiceData.get_die_by_name(Global.die[i]).get("faces")[j].get("sprite")))
		node.set_sprite_frames(dieTexture)
		node.set_frame(0)
		node.play("faces")
		node.pause()
		selectedArry[i] = false
	
	playerDiceTrayNode.show()
	
	#start "summoning circle"
	showNodes_circleStart()

		
func reready() :
	hideAllNodes()
	bookControlNode.remove_child(enemy_instance)
	enemy_instance.queue_free()
	rollButtonNode.disabled = true
	endTurnButtonNode.disabled = true
	playerDiceTrayNode.show()
	
	circleControl.reready()
	$InfoPanel.reready()
	ScreenLabelNode.text = "Choose Your Path..."
	showNodes_circleStart()
	
func update_encounters() -> void :
	var greenRect = load("res://resources//green-rect.png")
	var redRectSelected = load("res://resources/red-rect-selected.png")
	for i in range(1, Global.encounterNum) :
		var finished = get_node(encounterIconPath + str(i))
		finished.set_texture(greenRect)
		
	var active = get_node(encounterIconPath + str(Global.encounterNum))
	active.set_texture(redRectSelected)
	
func _on_roll_button_pressed() -> void:
	if(!rolled) : 
		rolled = true
		rollButtonNode.disabled = true
	else :
		return
	
	enemy_instance.roll_eDice()
	#start and stop roll animation
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		node.set_frame(randi_range(0, 5))
		node.play()
	await get_tree().create_timer(0.75).timeout
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		node.pause()
	
	#store dice rolls in pDiceRolls arry, set frames
	for i in range (0, 5) :
		pDiceRolls[i] = DiceData.roll_die(Global.die[i])
		var pNode = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		pNode.set_frame(pDiceRolls[i].get("index"))
		
		
func dieButtonEffects(dieNum : int) -> void:
	var roll = pDiceRolls[dieNum]
	var node = get_node(pDiePath + str(dieNum) + pDiePath2 + str(dieNum))
	if(selectedArry[dieNum] == false && numSelected < maxDieNum) : 
		node.offset += Vector2(20, 0)
		match roll.get("effect") : 
			damageEffectName : 
				curDamage += pDiceRolls[dieNum].get("value")
				selectedAttackDice += 1
				if curPiercing > 0 :
					pDamageNode.text = damageLabelText + str(curDamage) + "+" + str(curPiercing)
				else :
					pDamageNode.text = damageLabelText + str(curDamage)
			healEffectName :
				curHeal += pDiceRolls[dieNum].get("value")
				pHealNode.text = healLabelText + str(curHeal)
			shieldEffectName :
				curShield += pDiceRolls[dieNum].get("value")
				pShieldNode.text = shieldLabelText + str(curShield)
			piercingEffectName :
				curPiercing += pDiceRolls[dieNum].get("value")
				if curPiercing > 0 :
					pDamageNode.text = damageLabelText + str(curDamage) + "+" + str(curPiercing)
				else :
					pDamageNode.text = damageLabelText + str(curDamage)
			freezeEffectName :
				curFreeze += pDiceRolls[dieNum].get("value")
				pFreezeNode.text = freezeLabelText + str(curFreeze)
			explosiveEffectName :
				curExplosive += pDiceRolls[dieNum].get("value")
				pExplosiveNode.text = explosiveLabelText + str(curExplosive)
		numSelected += 1
		pSelectedNode.text = str(numSelected) + "/" + str(maxDieNum)
		selectedArry[dieNum] = true
	elif(selectedArry[dieNum] == true) :
		node.offset -= Vector2(20, 0)
		match roll.get("effect") : 
			damageEffectName : 
				curDamage -= pDiceRolls[dieNum].get("value")
				selectedAttackDice -= 1
				if curPiercing > 0 :
					pDamageNode.text = damageLabelText + str(curDamage) + "+" + str(curPiercing)
				else :
					pDamageNode.text = damageLabelText + str(curDamage)
			healEffectName :
				curHeal -= pDiceRolls[dieNum].get("value")
				pHealNode.text = healLabelText + str(curHeal)
			shieldEffectName :
				curShield -= pDiceRolls[dieNum].get("value")
				pShieldNode.text = shieldLabelText + str(curShield)
			piercingEffectName :
				curPiercing -= pDiceRolls[dieNum].get("value")
				if curPiercing > 0 :
					pDamageNode.text = damageLabelText + str(curDamage) + "+" + str(curPiercing)
				else :
					pDamageNode.text = damageLabelText + str(curDamage)
			freezeEffectName :
				curFreeze -= pDiceRolls[dieNum].get("value")
				pFreezeNode.text = freezeLabelText + str(curFreeze)
			explosiveEffectName :
				curExplosive -= pDiceRolls[dieNum].get("value")
				pExplosiveNode.text = explosiveLabelText + str(curExplosive)
		numSelected -= 1
		pSelectedNode.text = str(numSelected) + "/" + str(maxDieNum)
		selectedArry[dieNum] = false
	if Global.playerType == "Champion" :
		if selectedAttackDice == 3 :
			maxDieNum = 4
			pSelectedNode.text = str(numSelected) + "/" + str(maxDieNum)
		elif selectedAttackDice < 3 :
			maxDieNum = 3
			pSelectedNode.text = str(numSelected) + "/" + str(maxDieNum)
	
	if numSelected == maxDieNum :
		endTurnButtonNode.disabled = false
	else :
		endTurnButtonNode.disabled = true
	
func _on_end_turn_pressed() -> void:
	if(numSelected != maxDieNum):
		return
	endTurnButtonNode.disabled = true
	
	numSelected = 0
	selectedAttackDice = 0
	maxDieNum = 3
	var eDamage = curDamage - enemy_instance.curEShield
	var eExplosive = curExplosive - enemy_instance.curEShield
	
	if(eDamage > 0 || curPiercing > 0) :
		enemy_instance.update_health_with_damage(curDamage, curPiercing)
	if eExplosive > 0 :
		enemy_instance.update_health_with_aoe(curExplosive)
		
	var damage = enemy_instance.curEDamage - curShield
	if(damage > 0) :
		health -= damage
	if enemy_instance.curEPiercing > 0 :
		health -= enemy_instance.curEPiercing
	if health < 0 :
		health = 0
	Global.health = health
	$InfoPanel.update_health(health)
	
	if(health <= 0) :
		clear()
		$defeat.callDefeat()
		return
	elif(enemy_instance.get_total_health() <= 0) :
		clear()
		Global.health = health
		Global.encounterNum += 1
		if (Global.encounterNum == 7) :
			Global.encounterNum = 1
			Global.difficulty += 1
			#insert modifier upgrade screen maybe
		update_encounters()
		$victory.callVictory()
		return
	
	enemy_instance.update_health_with_heal()
	if health + curHeal > Global.maxHealth :
		health = Global.maxHealth
	else :
		health += curHeal
	
	enemy_instance.update_health_with_poison()
	
	if(enemy_instance.get_total_health() <= 0) :
		clear()
		Global.health = health
		Global.encounterNum += 1
		if (Global.encounterNum == 7) :
			Global.encounterNum = 1
			Global.difficulty += 1
			#insert modifier upgrade screen maybe
		update_encounters()
		$victory.callVictory()
		return
	
	rolled = false
	rollButtonNode.disabled = false
	
	if(Global.playerType == "Goliath") :
		goliathClear()
	else :
		clear()
	Global.health = health
	$InfoPanel.update_health(health)
	
func _on_die_0_pressed() -> void:
	if(rolled) :
		dieButtonEffects(0)

func _on_die_1_pressed() -> void:
	if(rolled) :
		dieButtonEffects(1)

func _on_die_2_pressed() -> void:
	if(rolled) :
		dieButtonEffects(2)

func _on_die_3_pressed() -> void:
	if(rolled) :
		dieButtonEffects(3)

func _on_die_4_pressed() -> void:
	if(rolled) :
		dieButtonEffects(4)

func goliathClear() -> void :
	var golShield = curShield - enemy_instance.curEDamage
	clear()
	if golShield < 0 :
		curShield = 0
	else :
		curShield = golShield
	pShieldNode.text = shieldLabelText + str(curShield)
	
func clear() -> void :
	curDamage = 0
	curHeal = 0
	curShield = 0
	curPiercing = 0
	curExplosive = 0
	curFreeze = 0
	
	for i in range (0, 5) :
		if selectedArry[i] == true :
			var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
			node.offset -= Vector2(20, 0)
		selectedArry[i] = false
	pSelectedNode.text = selectedText
	pDamageNode.text = damageLabelText
	pHealNode.text = healLabelText
	pShieldNode.text = shieldLabelText
	pExplosiveNode.text = explosiveLabelText
	pFreezeNode.text = freezeLabelText
	
	enemy_instance.clear()

	rolled = false
	numSelected = 0
	selectedAttackDice = 0
	
func hideAllNodes() :
	circleNode.hide()
	playerDiceTrayNode.hide()
	
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
	eNameNode.text = Global.enemy.get("name")
	eHealthNode.text = "Max Health:" + str(enemy_instance.get_max_health())
	eRewardNode.text = "Reward:" + str(int(Global.enemy.get("reward")))
	if(Global.enemy.get("hasAbility")) : 
		eAbilitiesNode.show()
		eAbilitiesNode.text = "Abilities: \n" + Global.enemy.get("ability")
		eAbilitiesNode.set_tooltip(Global.enemy.get("ability"), Global.enemy.get("abilityDescription"))
	else :
		eAbilitiesNode.hide()
	
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
