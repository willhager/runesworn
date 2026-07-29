extends Control

signal selected_max_dice
signal selected_less_than_max_dice

@onready var pDamageNode : Node = get_node("PlayerDiceTray/PInfoContainer/Damage")
@onready var pHealNode : Node = get_node("PlayerDiceTray/PInfoContainer/Heal")
@onready var pShieldNode : Node = get_node("PlayerDiceTray/PInfoContainer/Shield")
@onready var pFreezeNode : Node = get_node("PlayerDiceTray/PInfoContainer/Freeze")
@onready var pExplosiveNode : Node = get_node("PlayerDiceTray/PInfoContainer/Explosive")
@onready var pSelectedNode : Node = get_node("PlayerDiceTray/Selected")

@onready var playerDiceTrayNode : Node = get_node("PlayerDiceTray")

var pDiePath : String = "PlayerDiceTray/PDiceContainer/Die"
var pDiePath2 : String = "/CenterContainer/Faces"

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
var numSelected : int = 0
var selectedArry : Array[bool]
var selectedAttackDice : int = 0
var maxDieNum : int = Global.maxSelectableDice

var curDamage : int
var curHeal : int
var curShield : int
var curPiercing : int
var curFreeze : int
var curExplosive : int

var prevShield : int = 0

var enemy_damage_cache : int = 0

var pDiceRolls : Array[Dictionary]

func _ready() -> void :
	health = Global.health
	pDiceRolls.resize(5)
	selectedArry.resize(5)
	for i in range(0, 5) :
		var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		var button = get_node(pDiePath + str(i))
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
		button.disabled = true

func reready() -> void :
	maxDieNum = Global.maxSelectableDice
	pSelectedNode.text = "0/" + str(maxDieNum)
	
	playerDiceTrayNode.show()

func roll_dice() -> void :
	for i in range(0, Global.die.size()) :
		var die = get_node(pDiePath + str(i))
		die.disabled = true
	
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
		
	for i in range(0, Global.die.size()) :
		var die = get_node(pDiePath + str(i))
		die.disabled = false
		
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
		
	if selectedAttackDice == 3 :
		if maxDieNum <= Global.maxSelectableDice :
			maxDieNum = maxDieNum + 1
		pSelectedNode.text = str(numSelected) + "/" + str(maxDieNum)
	elif selectedAttackDice < 3 :
		if maxDieNum > Global.maxSelectableDice :
			maxDieNum = Global.maxSelectableDice
		pSelectedNode.text = str(numSelected) + "/" + str(maxDieNum)
	
	if numSelected == maxDieNum :
		selected_max_dice.emit()
	else :
		selected_less_than_max_dice.emit()

func end_turn() :
	numSelected = 0
	selectedAttackDice = 0


func update_health_with_damage(enemy_rolls : Array[Dictionary]) :
	var incomingDamage = 0
	var incomingPiercing = 0
	for roll in enemy_rolls :
		match roll.get("effect") :
			Global.damageEffectName :
				incomingDamage += roll.get("value")
			Global.piercingEffectName :
				incomingPiercing += roll.get("value")
	
	enemy_damage_cache = incomingDamage
	var damage_post_shield = incomingDamage - curShield
	
	if damage_post_shield > 0 :
		health -= damage_post_shield
	if incomingPiercing > 0 :
		health -= incomingPiercing
	if health < 0 : health = 0

func update_health_with_heal() :
	if health + curHeal > Global.maxHealth :
		health = Global.maxHealth
	else :
		health += curHeal

func set_max_dice_num(newNum) -> void :
	maxDieNum = newNum
	
func _on_die_0_pressed() -> void:
	dieButtonEffects(0)

func _on_die_1_pressed() -> void:
	dieButtonEffects(1)

func _on_die_2_pressed() -> void:
	dieButtonEffects(2)

func _on_die_3_pressed() -> void:
	dieButtonEffects(3)

func _on_die_4_pressed() -> void:
	dieButtonEffects(4)

func clear() -> void :
	curDamage = 0
	curHeal = 0
	curPiercing = 0
	curExplosive = 0
	curFreeze = 0
	curShield = 0

	for i in range (0, 5) :
		if selectedArry[i] == true :
			var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
			var button = get_node(pDiePath + str(i))
			node.offset -= Vector2(20, 0)
			button.disabled = true
		selectedArry[i] = false
	pSelectedNode.text = "0/" + str(maxDieNum)
	pDamageNode.text = damageLabelText
	pHealNode.text = healLabelText
	pExplosiveNode.text = explosiveLabelText
	pFreezeNode.text = freezeLabelText
	
	numSelected = 0
	selectedAttackDice = 0
	
func get_player_rolls() :
	var ret : Array[Dictionary]
	for i in range(0, pDiceRolls.size()) :
		if selectedArry[i] :
			ret.append(pDiceRolls[i].duplicate())
	return ret

func hideAllNodes() -> void :
	playerDiceTrayNode.hide()
	
func showAllNodes() -> void :
	playerDiceTrayNode.show()
	
func update_current_values(rolls) -> void :
	curDamage = 0
	curShield = 0
	curHeal = 0
	curExplosive = 0
	curPiercing = 0
	for roll in rolls :
		match roll.get("effect") : 
			damageEffectName : 
				curDamage += roll.get("value")
				if curPiercing > 0 :
					pDamageNode.text = damageLabelText + str(curDamage) + "+" + str(curPiercing)
				else :
					pDamageNode.text = damageLabelText + str(curDamage)
			
			healEffectName :
				curHeal += roll.get("value")
				pHealNode.text = healLabelText + str(curHeal)
			
			shieldEffectName :
				curShield += roll.get("value")
				pShieldNode.text = shieldLabelText + str(curShield)
			
			piercingEffectName :
				curPiercing += roll.get("value")
				if curPiercing > 0 :
					pDamageNode.text = damageLabelText + str(curDamage) + "+" + str(curPiercing)
				else :
					pDamageNode.text = damageLabelText + str(curDamage)
			
			explosiveEffectName :
				curExplosive += roll.get("value")
				pExplosiveNode.text = explosiveLabelText + str(curExplosive)
	curShield += prevShield
	pShieldNode.text = shieldLabelText + str(curShield)
