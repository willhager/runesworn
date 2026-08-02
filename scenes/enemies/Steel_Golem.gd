extends enemy_template

#Steel Golem 
#dice: Barb, swordsman, guardian, cozy
#health: 14-20
#diceNum: 4

@onready var eDamageNode : Node = get_node("EnemyDiceTray/EInfoContainer/EDamage")
@onready var eHealNode : Node = get_node("EnemyDiceTray/EInfoContainer/EHeal")
@onready var eShieldNode : Node = get_node("EnemyDiceTray/EInfoContainer/EShield")
@onready var ePoisonNode : Node = get_node("EnemyDiceTray/EInfoContainer/EPoison")

@onready var eHealthNode : Node = get_node("EnemyDiceTray/EInfoContainer/EHealth")

@onready var eDieControl0 : Node = get_node("EnemyDiceTray/EDiceContainer/Control0")
@onready var eDieControl1 : Node = get_node("EnemyDiceTray/EDiceContainer/Control1")
@onready var eDieControl2 : Node = get_node("EnemyDiceTray/EDiceContainer/Control2")
@onready var eDieControl3 : Node = get_node("EnemyDiceTray/EDiceContainer/Control3")

@onready var eDie0 : Node = get_node("EnemyDiceTray/EDiceContainer/Control0/EDie0")
@onready var eDie1 : Node = get_node("EnemyDiceTray/EDiceContainer/Control1/EDie1")
@onready var eDie2 : Node = get_node("EnemyDiceTray/EDiceContainer/Control2/EDie2")
@onready var eDie3 : Node = get_node("EnemyDiceTray/EDiceContainer/Control3/EDie3")

var eDieSpritePath : String = "EnemyDiceTray/EDiceContainer/Control"
var eDieSpritePath2 : String  = "/EDie"


var numDice = 4

var freezeCounter : Array[int]

var addToPoison : bool = false

var remaining : int = 3

var selected : Array[Dictionary] = []

func _ready() -> void :
	var enemyDict = EncounterData.get_encounter_by_name(2, "Steel Golem")
	enemyHealth = randi_range(enemyDict.get("healthMin"), enemyDict.get("healthMax"))
	maxHealth = enemyHealth
	eHealthNode.text = "Health:" + str(enemyHealth)
	EDice.resize(enemyDict.get("numDice"))
	eDiceRolls.resize(enemyDict.get("numDice"))
	
	numDice = enemyDict.get("numDice")
	
	for i in range(0, enemyDict.get("numDice")) :
		EDice[i] = DiceData.get_die_by_name(enemyDict.dice[i])

	
	#set faces from dice dictionary
	for i in range(0, numDice) :
		var nodePath = eDieSpritePath + str(i) + eDieSpritePath2 + str(i)
		var node = get_node(nodePath)
		var dieTexture : SpriteFrames = SpriteFrames.new()
		dieTexture.add_animation("faces")
		dieTexture.set_animation_speed("faces", 15)
		for j in range(0, 6) :
			dieTexture.add_frame("faces", load(EDice[i].get("faces")[j].get("sprite")))
		node.set_sprite_frames(dieTexture)
		node.set_frame(0)
		node.play("faces")
		node.pause()
		
	if(Global.playerType == "Assassin") :
		ePoisonNode.text = "P:"
	

func roll_eDice() -> void :
	for i in range(0, numDice) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.set_frame(randi_range(0, 5))
		eNode.play("faces")
	await get_tree().create_timer(0.75).timeout
	for i in range(0, numDice) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.pause()
		
	for i in range(0, numDice) :
		eDiceRolls[i] = DiceData.roll_die(EDice[i].get("name"))
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.set_frame(eDiceRolls[i].get("index"))
	
	var indices : Array
	var pool = [0, 1, 2, 3]
	for value in pool.duplicate() :
		if EDice[value].get("freeze") == true :
			pool.erase(value)
			
	pool.shuffle()
	if len(pool) < 4 :
		indices = pool
	else :
		indices = pool.slice(0, 3)
	
	await get_tree().create_timer(0.3).timeout

	for i in range (0, indices.size()) :
		var roll = eDiceRolls[indices[i]]
		selected.append(roll)
		var eNode = get_node(eDieSpritePath + str(indices[i]) + eDieSpritePath2 + str(indices[i]))
		await get_tree().create_timer(0.2).timeout
		eNode.offset += Vector2(-20, 0)
		match roll.get("effect") :
			Global.damageEffectName :
				enemy_damage += roll.get("value")
			Global.healEffectName :
				enemy_heal += roll.get("value")
			Global.shieldEffectName :
				enemy_shield += roll.get("value")
			Global.piercingEffectName :
				enemy_piercing += roll.get("value")
	
	if enemy_piercing > 0:
		eDamageNode.text = "D:" + str(enemy_damage) + "+" + str(enemy_piercing)
	else :
		eDamageNode.text = "D:" + str(enemy_damage)
	eHealNode.text = "H:" + str(enemy_heal)
	eShieldNode.text = "S:" + str(enemy_shield)

func update_health_with_damage(rolls : Array[Dictionary]) -> void :
	var curDamage = 0
	var curPiercing = 0
	for roll in rolls :
		match roll.get("effect") :
			Global.damageEffectName :
				curDamage += roll.get("value")
			Global.piercingEffectName :
				curPiercing += roll.get("value")
	var eDamage = curDamage - enemy_shield
	if (curPiercing > 0) :
		if curPiercing > 3 : 
			enemyHealth -= 3
			remaining = 0
		else :
			enemyHealth -= curPiercing
			remaining -= curPiercing
	if(eDamage > 0) :
		if eDamage > remaining :
			enemyHealth -= remaining
		else :
			enemyHealth -= eDamage
			remaining -= eDamage
	if((eDamage > 0 || curPiercing > 0) && Global.playerType == "Assassin") :
		addToPoison = true
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)
	
func update_health_with_aoe(rolls : Array[Dictionary]) :
	var aoeDamage = 0
	for roll in rolls :
		match roll.get("effect") :
			Global.explosiveEffectName :
				aoeDamage += roll.get("value")
	var eExplosive = aoeDamage - enemy_shield
	if eExplosive > 0 :
		if remaining < eExplosive :
			enemyHealth -= remaining
			remaining = 0
		else :
			enemyHealth -= eExplosive
			remaining -= eExplosive
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)

func update_health_with_heal() -> void :
	enemyHealth += enemy_heal
	if enemyHealth < 0 : enemyHealth = 0
	if enemyHealth > maxHealth : enemyHealth = maxHealth
	eHealthNode.text = "Health:" + str(enemyHealth)
	
func update_health_with_poison() -> void :
	enemyHealth -= enemy_poison_counter
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)
	if addToPoison :
		enemy_poison_counter += 1
		ePoisonNode.text = "P: " + str(enemy_poison_counter)
	
func get_max_health() -> String : 
	return str(maxHealth)
	
func get_total_health() -> int : 
	return enemyHealth
	
func get_rolls() -> Array[Dictionary]:
	return selected
	
func clear() -> void :
	enemy_damage = 0
	enemy_shield = 0
	enemy_heal = 0
	enemy_piercing = 0
	
	remaining = 3
	
	addToPoison = false
	
	eDamageNode.text = "D:"
	eHealNode.text = "H:"
	eShieldNode.text = "S:"
	
	selected = []
	
	for i in range(0, numDice) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.offset = Vector2(0, 0)
	
	
func hideAllNodes() -> void :
	$enemyDiceTray.visible = false
