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

@onready var eDie0 : Node = get_node("EnemyDiceTray/EDiceContainer/Control0/EDie0")
@onready var eDie1 : Node = get_node("EnemyDiceTray/EDiceContainer/Control1/EDie1")
@onready var eDie2 : Node = get_node("EnemyDiceTray/EDiceContainer/Control2/EDie2")

var eDieSpritePath : String = "EnemyDiceTray/EDiceContainer/Control"
var eDieSpritePath2 : String  = "/EDie"


var numDice = 3

var freezeCounter : Array[int]

var addToPoison : bool = false

var selected : Array[Dictionary] = []

func _ready() -> void :
	GameState.enemyHealth = randi_range(16, 22)
	GameState.maxHealth = GameState.enemyHealth
	eHealthNode.text = "Health:" + str(GameState.enemyHealth)
	GameState.EDice.resize(numDice)
	GameState.eDiceRolls.resize(numDice)
	freezeCounter.resize(numDice)
	
	GameState.EDice[0] = DiceData.get_die_by_name("Guardian's Die")
	GameState.EDice[1] = DiceData.get_die_by_name("Healer's Die")
	GameState.EDice[2] = DiceData.get_die_by_name("Cozy Campfire")

	
	#set faces from dice dictionary
	for i in range(0, numDice) :
		var nodePath = eDieSpritePath + str(i) + eDieSpritePath2 + str(i)
		var node = get_node(nodePath)
		var dieTexture : SpriteFrames = SpriteFrames.new()
		dieTexture.add_animation("faces")
		dieTexture.set_animation_speed("faces", 15)
		for j in range(0, 6) :
			dieTexture.add_frame("faces", load(GameState.EDice[i].get("faces")[j].get("sprite")))
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
		GameState.eDiceRolls[i] = DiceData.roll_die(GameState.EDice[i].get("name"))
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.set_frame(GameState.eDiceRolls[i].get("index"))
	
	var indices : Array
	var pool = [0, 1, 2]
	for value in pool.duplicate() :
		if GameState.EDice[value].get("freeze") == true :
			pool.erase(value)
			
	pool.shuffle()
	if len(pool) < 3 :
		indices = pool
	else :
		indices = pool.slice(0, 2)
	
	await get_tree().create_timer(0.3).timeout

	for i in range (0, indices.size()) :
		var roll = GameState.eDiceRolls[indices[i]]
		selected.append(roll)
		var eNode = get_node(eDieSpritePath + str(indices[i]) + eDieSpritePath2 + str(indices[i]))
		await get_tree().create_timer(0.2).timeout
		eNode.offset += Vector2(-20, 0)
		match roll.get("effect") :
			Global.damageEffectName :
				GameState.enemy_damage += roll.get("value")
			Global.healEffectName :
				GameState.enemy_heal += roll.get("value")
			Global.shieldEffectName :
				GameState.enemy_shield += roll.get("value")
			Global.piercingEffectName :
				GameState.enemy_piercing += roll.get("value")
	
	if GameState.enemy_piercing > 0:
		eDamageNode.text = "D:" + str(GameState.enemy_damage) + "+" + str(GameState.enemy_piercing)
	else :
		eDamageNode.text = "D:" + str(GameState.enemy_damage)
	eHealNode.text = "H:" + str(GameState.enemy_heal)
	eShieldNode.text = "S:" + str(GameState.enemy_shield)

func update_health_with_damage(rolls : Array[Dictionary]) -> void :
	var curDamage = 0
	var curPiercing = 0
	for roll in rolls :
		match roll.get("effect") :
			Global.damageEffectName :
				curDamage += roll.get("value")
			Global.piercingEffectName :
				curPiercing += roll.get("value")
	var eDamage = curDamage - GameState.enemy_shield
	GameState.enemy_damage += curDamage
	if(eDamage > 0) :
		GameState.enemyHealth -= eDamage
	if (curPiercing > 0) :
		GameState.enemyHealth -= curPiercing
	if((eDamage > 0 || curPiercing > 0) && Global.playerType == "Assassin") :
		addToPoison = true
	if GameState.enemyHealth < 0 : GameState.enemyHealth = 0
	eHealthNode.text = "Health:" + str(GameState.enemyHealth)
	
func update_health_with_aoe(rolls : Array[Dictionary]) :
	var aoeDamage = 0
	for roll in rolls :
		match roll.get("effect") :
			Global.explosiveEffectName :
				aoeDamage += roll.get("value")
	GameState.enemy_damage += aoeDamage
	var eExplosive = aoeDamage - GameState.enemy_shield
	if eExplosive > 0 :
		GameState.enemyHealth -= eExplosive
	if GameState.enemyHealth < 0 : GameState.enemyHealth = 0
	eHealthNode.text = "Health:" + str(GameState.enemyHealth)

func update_health_with_heal() -> void :
	GameState.enemyHealth += GameState.enemy_heal
	if GameState.enemyHealth < 0 : GameState.enemyHealth = 0
	if GameState.enemyHealth > GameState.maxHealth : GameState.enemyHealth = GameState.maxHealth
	eHealthNode.text = "Health:" + str(GameState.enemyHealth)
	
func update_health_with_poison() -> void :
	GameState.enemyHealth -= GameState.enemy_poison_counter
	if GameState.enemyHealth < 0 : GameState.enemyHealth = 0
	if GameState.enemyHealth > GameState.maxHealth : GameState.enemyHealth = GameState.maxHealth
	eHealthNode.text = "Health:" + str(GameState.enemyHealth)
	if addToPoison :
		GameState.enemy_poison_counter += 1
		ePoisonNode.text = "P: " + str(GameState.enemy_poison_counter)
	
func get_max_health() -> String : 
	return str(GameState.maxHealth)
	
func get_total_health() -> int : 
	return GameState.enemyHealth
	
func get_rolls() -> Array[Dictionary]:
	return selected
	
func clear() -> void :
	GameState.enemy_damage = 0
	GameState.enemy_shield = 0
	GameState.enemy_heal = 0
	GameState.enemy_piercing = 0
	
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
