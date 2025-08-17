extends Control

@onready var pDamageNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Damage")
@onready var pHealNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Heal")
@onready var pShieldNode : Node = get_node("BookControl/PlayerDiceTray/PInfoContainer/Shield")
@onready var pSelectedNode : Node = get_node("BookControl/PlayerDiceTray/Selected")

@onready var playerDiceTrayNode : Node = get_node("BookControl/PlayerDiceTray")
@onready var enemyDiceTrayNode : Node = get_node("BookControl/EnemyDiceTray")
@onready var bookNode : Node = get_node("BookControl/BookContainer/Book")

@onready var eNameNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EName")
@onready var eDamageNode : Node = get_node("BookControl/EnemyDiceTray/EInfoContainer/EDamage")
@onready var eHealNode : Node = get_node("BookControl/EnemyDiceTray/EInfoContainer/EHeal")
@onready var eShieldNode : Node = get_node("BookControl/EnemyDiceTray/EInfoContainer/EShield")
@onready var eHealthNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EHealth")
@onready var ePoisonNode : Node = get_node("BookControl/EnemyDiceTray/EInfoContainer/EPoison")
@onready var eRewardNode : Node = get_node("EInfoPanel/MarginContainer/VBoxContainer/EReward")

@onready var pHealthNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/HealthLabel")
@onready var levelLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/LevelLabel")
@onready var classLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/ClassLabel")
@onready var modifiersLabelNode : Node = get_node("InfoPanel/MarginContainer/SideInfoContainer/Modifiers")

@onready var button1 : Node = get_node("BookControl/CircleControl/Circle/Button1")
@onready var button2 : Node = get_node("BookControl/CircleControl/Circle/Button2")
@onready var button3 : Node = get_node("BookControl/CircleControl/Circle/Button3")
@onready var notesDescription : Node = get_node("BookControl/CircleControl/Circle/DescriptionContainer/NotesPanel/Notes")
@onready var rewardDescription : Node = get_node("BookControl/CircleControl/Circle/DescriptionContainer/RewardPanel/Reward")
@onready var circleNode : Node = get_node("BookControl/CircleControl/Circle")
@onready var circleStartNode : Node = get_node("CircleStart")
@onready var nextButtonNode : Node = get_node("BookControl/NextButton")

@onready var rollButtonNode : Node = get_node("ButtonTray/VBoxContainer/RollButton")
@onready var endTurnButtonNode : Node = get_node("ButtonTray/VBoxContainer/EndTurn")

var enemies : Array
var button1pressed : bool = false
var button2pressed : bool = false
var button3pressed : bool = false

var pDiePath : String = "BookControl/PlayerDiceTray/PDiceContainer/Die"
var pDiePath2 : String = "/CenterContainer/Faces"
var eDiePath : String = "BookControl/EnemyDiceTray/EDiceContainer/Control"
var eDiePath2 : String = "/EDie"
var encounterIconPath : String = "ProgressTray/VBoxContainer/Encounter"

var healthLabelText = "Health: "
var damageLabelText = "D:"
var shieldLabelText = "S:"
var healLabelText = "H:"
var poisonLabelText = "P:"

var damageEffectName = Global.damageEffectName
var shieldEffectName = Global.shieldEffectName
var healEffectName = Global.healEffectName
var piercingEffectName = Global.piercingEffectName

var enemy : Dictionary
var health : int
var enemyHealth : int
var rolled : bool = false
var numSelected : int = 0
var selectedArry : Array[bool]
var selectedAttackDice : int = 0
var maxDieNum : int = 3

var curDamage : int
var curHeal : int
var curShield : int
var curPiercing : int
var curEDamage : int
var curEHeal : int
var curEShield : int
var curEPiercing : int
var curEPoisonCounter : int
var EDice : Array[String]
var eDiceRolls : Array[Dictionary]
var pDiceRolls : Array[Dictionary]

var selectedText = "0/" + str(maxDieNum)


func _ready() -> void:
	update_encounters()
	hideAllNodes()
	classLabelNode.text = Global.playerType
	modifiersLabelNode.text = Global.get_modifier_0() + Global.get_modifier_1() + Global.get_modifier_2()
	health = Global.health
	pHealthNode.text = healthLabelText + str(health)
	levelLabelNode.text = "Level:" + str(Global.difficulty)
	enemies = EncounterData.get_3_encounters(Global.difficulty)
	rollButtonNode.disabled = true
	endTurnButtonNode.disabled = true
	
	bookNode.play("open")
	await bookNode.animation_finished
	
	EDice.resize(5)
	eDiceRolls.resize(5)
	pDiceRolls.resize(5)
	selectedArry.resize(5)
	
	#initialize player dice and set textures
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		var dieTexture : SpriteFrames = SpriteFrames.new()
		dieTexture.add_animation("faces")
		dieTexture.set_animation_speed("faces", 10)
		for j in range(0, 5) :
			dieTexture.add_frame("faces", load(DiceData.get_die_by_name(Global.die[i]).get("faces")[j].get("sprite")))
		node.set_sprite_frames(dieTexture)
		node.set_frame(0)
		node.play("faces")
		node.pause()
		selectedArry[i] = false
	
	playerDiceTrayNode.show()
	
	showNodes_circleStart()

##establishes enemy dice, textures, etc
func build_enemy() : 
	enemy = Global.enemy
	eNameNode.text = enemy.get("name")
	eRewardNode.text = "Reward:" + str(enemy.get("reward"))
	enemyHealth = randi_range(enemy.get("healthMin"), enemy.get("healthMax"))
	eHealthNode.text = healthLabelText + str(enemyHealth)
	var enemyDice = enemy.get("dice")
	
	#establish enemy dice textures and dictionary storage
	for i in range(0, enemy.get("diceNum")) :
		EDice[i] = enemyDice[i]
		var nodePath = eDiePath + str(i) + eDiePath2 + str(i)
		var node = get_node(nodePath)
		var dieTexture : SpriteFrames = SpriteFrames.new()
		dieTexture.add_animation("faces")
		dieTexture.set_animation_speed("faces", 10)
		for j in range(0, 5) :
			dieTexture.add_frame("faces", load(DiceData.get_die_by_name(EDice[i]).get("faces")[j].get("sprite")))
		node.set_sprite_frames(dieTexture)
		node.set_frame(0)
		node.play("faces")
		node.pause()
	
	if(Global.playerType == "Assassin") :
		ePoisonNode.text = poisonLabelText
		
func reready() :
	hideAllNodes()
	classLabelNode.text = Global.playerType
	pHealthNode.text = healthLabelText + str(health)
	levelLabelNode.text = "Level:" + str(Global.difficulty)
	enemies = EncounterData.get_3_encounters(Global.difficulty)
	rollButtonNode.disabled = true
	endTurnButtonNode.disabled = true
	playerDiceTrayNode.show()
	notesDescription.text = ""
	rewardDescription.text = ""
	button1pressed = false
	button1.button_pressed = false
	button2pressed = false
	button2.button_pressed = false
	button3pressed = false
	button3.button_pressed = false
	
	curEPoisonCounter = 0
	
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
	else :
		return
	
	#start and stop roll animation
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		node.set_frame(randi_range(0, 5))
		node.play()
		if (i < enemy.get("diceNum")) :
			var eNode = get_node(eDiePath + str(i) + eDiePath2 + str(i))
			eNode.set_frame(randi_range(0, 5))
			eNode.play("faces")
	await get_tree().create_timer(0.75).timeout
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		node.pause()
		if (i < enemy.get("diceNum")) :
			var eNode = get_node(eDiePath + str(i) + eDiePath2 + str(i))
			eNode.pause()
	
	#store dice rolls in pDiceRolls arry, set frames
	for i in range (0, 5) :
		pDiceRolls[i] = DiceData.roll_die(Global.die[i])
		var pNode = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		pNode.set_frame(pDiceRolls[i].get("index"))
	
	#store enemy dice rolls in arry, set texture
	for i in range(0, enemy.get("diceNum")) :
		eDiceRolls[i] = DiceData.roll_die(EDice[i])
		var eNode = get_node(eDiePath + str(i) + eDiePath2 + str(i))
		eNode.set_frame(eDiceRolls[i].get("index"))
	
	var indices : Array
	if enemy.get("diceNum") == 5 :
		var pool = [0, 1, 2, 3, 4]
		pool.shuffle() 
		indices = pool.slice(0, 3)
	elif enemy.get("diceNum") == 4 :
		var pool = [0, 1, 2, 3]
		pool.shuffle() 
		indices = pool.slice(0, 3)
	else :
		indices = [0, 1, 2]
	
	for i in range (0, indices.size()) :
		var roll = eDiceRolls[indices[i]]
		var eNode = get_node(eDiePath + str(indices[i]) + eDiePath2 + str(indices[i]))
		eNode.offset += Vector2(-20, 0)
		match roll.get("effect") :
			damageEffectName :
				curEDamage += roll.get("value")
			healEffectName :
				curEHeal += roll.get("value")
			shieldEffectName :
				curEShield += roll.get("value")
			piercingEffectName :
				curEPiercing += roll.get("value")
	
	if curEPiercing > 0:
		eDamageNode.text = damageLabelText + str(curEDamage) + "+" + str(curEPiercing)
	else :
		eDamageNode.text = damageLabelText + str(curEDamage)
	eHealNode.text = healLabelText + str(curEHeal)
	eShieldNode.text = shieldLabelText + str(curEShield)

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
	
func _on_end_turn_pressed() -> void:
	if(numSelected != maxDieNum):
		return
	
	numSelected = 0
	selectedAttackDice = 0
	maxDieNum = 3
	var eDamage = curDamage - curEShield
	if(eDamage > 0) :
		if(Global.playerType == "Assassin") :
			curEPoisonCounter += 1
			ePoisonNode.text = poisonLabelText + str(curEPoisonCounter)
		enemyHealth -= eDamage
	if (curPiercing > 0) :
		enemyHealth -= curPiercing
		
	var damage = curEDamage - curShield
	if(damage > 0) :
		health -= damage
	if curEPiercing > 0 :
		health -= curEPiercing
	
	if(health <= 0) :
		clear()
		$defeat.callDefeat()
		return
	elif(enemyHealth <= 0) :
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
	
	enemyHealth += curEHeal
	health += curHeal
	
	enemyHealth -= curEPoisonCounter
	if(enemyHealth <= 0) :
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
	
	if(Global.playerType == "Goliath") :
		goliathClear()
	else :
		clear()
	
	pHealthNode.text = healthLabelText + str(health)
	eHealthNode.text = healthLabelText + str(enemyHealth)

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

func _on_left_side_pressed() -> void:
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


func _on_right_side_pressed() -> void:
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

func goliathClear() -> void :
	curShield = curShield - curEDamage
	if curShield < 0 :
		curShield = 0
	curDamage = 0
	curPiercing = 0
	curEDamage = 0
	curHeal = 0
	curEHeal = 0
	curEShield = 0
	curEPiercing = 0
	
	rolled = false
	numSelected = 0
	selectedAttackDice = 0
	
	for i in range (0, 5) :
		if selectedArry[i] == true :
			var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
			node.offset -= Vector2(20, 0)
		selectedArry[i] = false
	for i in range(0, enemy.get("diceNum") + 1) :
		var eNode = get_node(eDiePath + str(i) + eDiePath2 + str(i))
		eNode.offset = Vector2(0, 0)
	pSelectedNode.text = selectedText
	pDamageNode.text = damageLabelText
	pHealNode.text = healLabelText
	pShieldNode.text = shieldLabelText + str(curShield)
	eDamageNode.text = damageLabelText
	eHealNode.text = healLabelText
	eShieldNode.text = shieldLabelText
	
func clear() -> void :
	curDamage = 0
	curEDamage = 0
	curHeal = 0
	curEHeal = 0
	curShield = 0
	curEShield = 0
	for i in range (0, 5) :
		if selectedArry[i] == true :
			var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
			node.offset -= Vector2(20, 0)
		selectedArry[i] = false
	for i in range(0, enemy.get("diceNum") + 1) :
		var eNode = get_node(eDiePath + str(i) + eDiePath2 + str(i))
		eNode.offset = Vector2(0, 0)
	pSelectedNode.text = selectedText
	pDamageNode.text = damageLabelText
	pHealNode.text = healLabelText
	pShieldNode.text = shieldLabelText
	eDamageNode.text = damageLabelText
	eHealNode.text = healLabelText
	eShieldNode.text = shieldLabelText

	rolled = false
	numSelected = 0
	selectedAttackDice = 0
	
func hideAllNodes() :
	circleNode.hide()
	playerDiceTrayNode.hide()
	enemyDiceTrayNode.hide()
	
func showNodes_circleStart() :
	nextButtonNode.show()
	circleNode.modulate.a = 0
	circleNode.show()
	circleStartNode.play("circle_start")
	
func _on_next_button_pressed() -> void:
	Global.enemy = EncounterData.get_encounter_by_index(Global.difficulty, enemies[Global.mapLoc].get("id"))
	circleNode.hide()
	enemyDiceTrayNode.show()
	rollButtonNode.disabled = false;
	endTurnButtonNode.disabled = false;
	nextButtonNode.hide()
	build_enemy()
