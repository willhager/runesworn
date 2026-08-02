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

func _ready() -> void :
	GameState.health = Global.health
	GameState.pDiceRolls.resize(5)
	GameState.selectedArry.resize(5)
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
		GameState.selectedArry[i] = false
		button.disabled = true

func reready() -> void :
	GameState.maxDieNum = Global.maxSelectableDice
	pSelectedNode.text = "0/" + str(GameState.maxDieNum)
	
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
		GameState.pDiceRolls[i] = DiceData.roll_die(Global.die[i])
		var pNode = get_node(pDiePath + str(i) + pDiePath2 + str(i))
		pNode.set_frame(GameState.pDiceRolls[i].get("index"))
		
	for i in range(0, Global.die.size()) :
		var die = get_node(pDiePath + str(i))
		die.disabled = false
		
func dieButtonEffects(dieNum : int) -> void:
	var roll = GameState.pDiceRolls[dieNum]
	var node = get_node(pDiePath + str(dieNum) + pDiePath2 + str(dieNum))
	
	if(GameState.selectedArry[dieNum] == false && GameState.numSelected < GameState.maxDieNum) : 
		node.offset += Vector2(20, 0)
		
		match roll.get("effect") : 
			damageEffectName : 
				GameState.player_damage += GameState.pDiceRolls[dieNum].get("value")
				GameState.selectedAttackDice += 1
				if GameState.player_Piercing > 0 :
					pDamageNode.text = damageLabelText + str(GameState.player_damage) + "+" + str(GameState.player_Piercing)
				else :
					pDamageNode.text = damageLabelText + str(GameState.player_damage)
			
			healEffectName :
				GameState.player_heal += GameState.pDiceRolls[dieNum].get("value")
				pHealNode.text = healLabelText + str(GameState.player_heal)
			
			shieldEffectName :
				GameState.player_shield += GameState.pDiceRolls[dieNum].get("value")
				pShieldNode.text = shieldLabelText + str(GameState.player_shield)
			
			piercingEffectName :
				GameState.player_Piercing += GameState.pDiceRolls[dieNum].get("value")
				if GameState.player_Piercing > 0 :
					pDamageNode.text = damageLabelText + str(GameState.player_damage) + "+" + str(GameState.player_Piercing)
				else :
					pDamageNode.text = damageLabelText + str(GameState.player_damage)
			
			freezeEffectName :
				GameState.player_Freeze += GameState.pDiceRolls[dieNum].get("value")
				pFreezeNode.text = freezeLabelText + str(GameState.player_Freeze)
			
			explosiveEffectName :
				GameState.player_Explosive += GameState.pDiceRolls[dieNum].get("value")
				pExplosiveNode.text = explosiveLabelText + str(GameState.player_Explosive)
		
		GameState.numSelected += 1
		pSelectedNode.text = str(GameState.numSelected) + "/" + str(GameState.maxDieNum)
		GameState.selectedArry[dieNum] = true
		
	elif(GameState.selectedArry[dieNum] == true) :
		node.offset -= Vector2(20, 0)
		
		match roll.get("effect") : 
			damageEffectName : 
				GameState.player_damage -= GameState.pDiceRolls[dieNum].get("value")
				GameState.selectedAttackDice -= 1
				if GameState.player_Piercing > 0 :
					pDamageNode.text = damageLabelText + str(GameState.player_damage) + "+" + str(GameState.player_Piercing)
				else :
					pDamageNode.text = damageLabelText + str(GameState.player_damage)
			
			healEffectName :
				GameState.player_heal -= GameState.pDiceRolls[dieNum].get("value")
				pHealNode.text = healLabelText + str(GameState.player_heal)
			
			shieldEffectName :
				GameState.player_shield -= GameState.pDiceRolls[dieNum].get("value")
				pShieldNode.text = shieldLabelText + str(GameState.player_shield)
			
			piercingEffectName :
				GameState.player_Piercing -= GameState.pDiceRolls[dieNum].get("value")
				if GameState.player_Piercing > 0 :
					pDamageNode.text = damageLabelText + str(GameState.player_damage) + "+" + str(GameState.player_Piercing)
				else :
					pDamageNode.text = damageLabelText + str(GameState.player_damage)
			
			freezeEffectName :
				GameState.player_Freeze -= GameState.pDiceRolls[dieNum].get("value")
				pFreezeNode.text = freezeLabelText + str(GameState.player_Freeze)
			
			explosiveEffectName :
				GameState.player_Explosive -= GameState.pDiceRolls[dieNum].get("value")
				pExplosiveNode.text = explosiveLabelText + str(GameState.player_Explosive)
		
		GameState.numSelected -= 1
		pSelectedNode.text = str(GameState.numSelected) + "/" + str(GameState.maxDieNum)
		GameState.selectedArry[dieNum] = false
		
	if GameState.selectedAttackDice == 3 :
		if GameState.maxDieNum <= Global.maxSelectableDice :
			GameState.maxDieNum = GameState.maxDieNum + 1
		pSelectedNode.text = str(GameState.numSelected) + "/" + str(GameState.maxDieNum)
	elif GameState.selectedAttackDice < 3 :
		if GameState.maxDieNum > Global.maxSelectableDice :
			GameState.maxDieNum = Global.maxSelectableDice
		pSelectedNode.text = str(GameState.numSelected) + "/" + str(GameState.maxDieNum)
	
	if GameState.numSelected == GameState.maxDieNum :
		selected_max_dice.emit()
	else :
		selected_less_than_max_dice.emit()

func end_turn() :
	GameState.numSelected = 0
	GameState.selectedAttackDice = 0


func update_health_with_damage(enemy_rolls : Array[Dictionary]) :
	var incomingDamage = 0
	var incomingPiercing = 0
	for roll in enemy_rolls :
		match roll.get("effect") :
			Global.damageEffectName :
				incomingDamage += roll.get("value")
			Global.piercingEffectName :
				incomingPiercing += roll.get("value")
	
	var damage_post_shield = incomingDamage - GameState.player_shield
	
	if damage_post_shield > 0 :
		GameState.health -= damage_post_shield
	if incomingPiercing > 0 :
		GameState.health -= incomingPiercing
	if GameState.health < 0 : GameState.health = 0

func update_health_with_heal() :
	if GameState.health + GameState.player_heal > Global.maxHealth :
		GameState.health = Global.maxHealth
	else :
		GameState.health += GameState.player_heal

func set_max_dice_num(newNum) -> void :
	GameState.maxDieNum = newNum
	
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
	GameState.player_damage = 0
	GameState.player_heal = 0
	GameState.player_Piercing = 0
	GameState.player_Explosive = 0
	GameState.player_Freeze = 0
	GameState.player_shield = 0

	for i in range (0, 5) :
		if GameState.selectedArry[i] == true :
			var node = get_node(pDiePath + str(i) + pDiePath2 + str(i))
			var button = get_node(pDiePath + str(i))
			node.offset -= Vector2(20, 0)
			button.disabled = true
		GameState.selectedArry[i] = false
	pSelectedNode.text = "0/" + str(GameState.maxDieNum)
	pDamageNode.text = damageLabelText
	pHealNode.text = healLabelText
	pExplosiveNode.text = explosiveLabelText
	pFreezeNode.text = freezeLabelText
	
	GameState.numSelected = 0
	GameState.selectedAttackDice = 0
	
func get_player_rolls() :
	var ret : Array[Dictionary]
	for i in range(0, GameState.pDiceRolls.size()) :
		if GameState.selectedArry[i] :
			ret.append(GameState.pDiceRolls[i].duplicate())
	return ret

func hideAllNodes() -> void :
	playerDiceTrayNode.hide()
	
func showAllNodes() -> void :
	playerDiceTrayNode.show()
	
func update_current_values(rolls) -> void :
	GameState.player_damage = 0
	GameState.player_shield = 0
	GameState.player_heal = 0
	GameState.player_Explosive = 0
	GameState.player_Piercing = 0
	for roll in rolls :
		match roll.get("effect") : 
			damageEffectName : 
				GameState.player_damage += roll.get("value")
				if GameState.player_Piercing > 0 :
					pDamageNode.text = damageLabelText + str(GameState.player_damage) + "+" + str(GameState.player_Piercing)
				else :
					pDamageNode.text = damageLabelText + str(GameState.player_damage)
			
			healEffectName :
				GameState.player_heal += roll.get("value")
				pHealNode.text = healLabelText + str(GameState.player_heal)
			
			shieldEffectName :
				GameState.player_shield += roll.get("value")
				pShieldNode.text = shieldLabelText + str(GameState.player_shield)
			
			piercingEffectName :
				GameState.player_Piercing += roll.get("value")
				if GameState.player_Piercing > 0 :
					pDamageNode.text = damageLabelText + str(GameState.player_damage) + "+" + str(GameState.player_Piercing)
				else :
					pDamageNode.text = damageLabelText + str(GameState.player_damage)
			
			explosiveEffectName :
				GameState.player_Explosive += roll.get("value")
				pExplosiveNode.text = explosiveLabelText + str(GameState.player_Explosive)
	pShieldNode.text = shieldLabelText + str(GameState.player_shield)
