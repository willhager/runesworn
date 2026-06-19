extends enemy_template

# skeleton swordsman
# dice: barb, barb, barb
# health: 3-5
# dicenum: 3

@onready var eDamageNode : Node = get_node("EnemyDiceTray/EInfoContainer/EDamage")
@onready var eHealNode : Node = get_node("EnemyDiceTray/EInfoContainer/EHeal")
@onready var eShieldNode : Node = get_node("EnemyDiceTray/EInfoContainer/EShield")
@onready var ePoisonNode : Node = get_node("EnemyDiceTray/EInfoContainer/EPoison")

@onready var eHealthNode : Node = get_node("EnemyDiceTray/EInfoContainer/EHealth")

@onready var eDieControl0 : Node = get_node("EnemyDiceTray/EDiceContainer/Control0")
@onready var eDieControl1 : Node = get_node("EnemyDiceTray/EDiceContainer/Control1")

@onready var eDie0 : Node = get_node("EnemyDiceTray/EDiceContainer/Control0/EDie0")
@onready var eDie1 : Node = get_node("EnemyDiceTray/EDiceContainer/Control1/EDie1")

var eDieSpritePath : String = "EnemyDiceTray/EDiceContainer/Control"
var eDieSpritePath2 : String  = "/EDie"

var enemyHealth : int
var maxHealth : String
var curEDamage : int
var curEHeal : int
var curEShield : int
var curEPiercing : int
var curEPoisonCounter : int
var EDice : Array[Dictionary]
var eDiceRolls : Array[Dictionary]

var numDice : int = 4

var freezeCounter : Array[int]

var addToPoison : bool = false


func _ready() -> void :
	enemyHealth = randi_range(15, 20)
	maxHealth = str(enemyHealth)
	eHealthNode.text = "Health:" + str(enemyHealth)
	EDice.resize(numDice)
	eDiceRolls.resize(numDice)
	freezeCounter.resize(numDice)
	
	EDice[0] = DiceData.get_die_by_name("Carnival McMarkus")
	EDice[1] = DiceData.get_die_by_name("Barbarian's Die")
	EDice[2] = DiceData.get_die_by_name("Mosquito's Die")
	EDice[3] = DiceData.get_die_by_name("Cozy Campfire")

	
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
		if !EDice[i].get("freeze") :
			var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
			eNode.set_frame(randi_range(0, 5))
			eNode.play("faces")
	await get_tree().create_timer(0.75).timeout
	for i in range(0, numDice) :
		if !EDice[i].get("freeze") :
			var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
			eNode.pause()
		
	for i in range(0, numDice) :
		if !EDice[i].get("freeze") :
			eDiceRolls[i] = DiceData.roll_die(EDice[i].get("name"))
			var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
			eNode.set_frame(eDiceRolls[i].get("index"))
	
	var indices : Array
	var pool = [0, 1, 2, 3]
	for value in pool.duplicate() :
		if EDice[value].get("freeze") == true :
			pool.erase(value)
			
	pool.shuffle()
	if len(pool) < 2 :
		indices = pool
	else :
		indices = pool.slice(0, 2)
	
	await get_tree().create_timer(0.3).timeout

	for i in range (0, indices.size()) :
		var roll = eDiceRolls[indices[i]]
		var eNode = get_node(eDieSpritePath + str(indices[i]) + eDieSpritePath2 + str(indices[i]))
		await get_tree().create_timer(0.2).timeout
		eNode.offset += Vector2(-20, 0)
		match roll.get("effect") :
			Global.damageEffectName :
				curEDamage += roll.get("value")
			Global.healEffectName :
				curEHeal += roll.get("value")
			Global.shieldEffectName :
				curEShield += roll.get("value")
			Global.piercingEffectName :
				curEPiercing += roll.get("value")
	
	if curEPiercing > 0:
		eDamageNode.text = "D:" + str(curEDamage) + "+" + str(curEPiercing)
	else :
		eDamageNode.text = "D:" + str(curEDamage)
	eHealNode.text = "H:" + str(curEHeal)
	eShieldNode.text = "S:" + str(curEShield)
	
func modify_player_rolls(rolls : Array[Dictionary]) -> Array[Dictionary] :
	var random_change = randi_range(1, 5)
	var random_idx = randi_range(0, len(rolls))
	var old_value = rolls[random_idx].get("value")
	var new_value = old_value - random_change
	if new_value < 0 : new_value = 0
	rolls[random_idx].set("value", new_value)
	return rolls

func update_health_with_damage(rolls : Array[Dictionary]) -> void :
	var curDamage = 0
	var curPiercing = 0
	for roll in rolls :
		match roll.get("effect") :
			Global.damageEffectName :
				curDamage += roll.get("value")
			Global.piercingEffectName :
				curPiercing += roll.get("value")
	
	var eDamage = curDamage - curEShield
	if(eDamage > 0) :
		enemyHealth -= eDamage
	if (curPiercing > 0) :
		enemyHealth -= curPiercing
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
	var eExplosive = aoeDamage - curEShield
	enemyHealth -= eExplosive
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)

func update_health_with_heal() -> void :
	enemyHealth += curEHeal
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)
	
func update_health_with_poison() -> void :
	enemyHealth -= curEPoisonCounter
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)
	if addToPoison :
		curEPoisonCounter += 1
		ePoisonNode.text = "P: " + str(curEPoisonCounter)
	
func get_max_health() -> String : 
	return maxHealth
	
func get_total_health() -> int : 
	return enemyHealth
	
func clear() -> void :
	curEDamage = 0
	curEShield = 0
	curEHeal = 0
	curEPiercing = 0
	
	addToPoison = false
	
	eDamageNode.text = "D:"
	eHealNode.text = "H:"
	eShieldNode.text = "S:"	
	
	for i in range(0, numDice) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.offset = Vector2(0, 0)
	
func hideAllNodes() -> void :
	$enemyDiceTray.visible = false
