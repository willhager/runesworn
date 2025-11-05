extends enemy_template

#CHAOS SLIME 
#dice: chaos, chaos, chaos
#health: 6-10
#diceNum: 3

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

var enemyHealth : int
var maxHealth : String
var curEDamage : int
var curEHeal : int
var curEShield : int
var curEPiercing : int
var curEPoisonCounter : int
var eDamage : int
var curPPiercing : int

var addToPoison : bool = false

var EDice : Array[String]
var eDiceRolls : Array[Dictionary]



func _ready() -> void :
	enemyHealth = randi_range(8, 12)
	maxHealth = str(enemyHealth)
	eHealthNode.text = "Health:" + str(enemyHealth) + "/" + maxHealth
	EDice.resize(3)
	eDiceRolls.resize(3)
	
	EDice[0] = "Cube of Chance"
	EDice[1] = "Cube of Chance"
	EDice[2] = "Cube of Chance"
	
	#set faces from dice dictionary
	for i in range(0, 3) :
		var nodePath = eDieSpritePath + str(i) + eDieSpritePath2 + str(i)
		var node = get_node(nodePath)
		var dieTexture : SpriteFrames = SpriteFrames.new()
		dieTexture.add_animation("faces")
		dieTexture.set_animation_speed("faces", 15)
		for j in range(0, 6) :
			dieTexture.add_frame("faces", load(DiceData.get_die_by_name(EDice[i]).get("faces")[j].get("sprite")))
		node.set_sprite_frames(dieTexture)
		node.set_frame(0)
		node.play("faces")
		node.pause()
		
	if(Global.playerType == "Assassin") :
		ePoisonNode.text = "P:"
	

func roll_eDice() -> void :
	for i in range(0, 3) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.set_frame(randi_range(0, 5))
		eNode.play("faces")
	await get_tree().create_timer(0.75).timeout
	for i in range(0, 3) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.pause()
		
	for i in range(0, 3) :
		eDiceRolls[i] = DiceData.roll_die(EDice[i])
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.set_frame(eDiceRolls[i].get("index"))
	
	var indices : Array
	var pool = [0, 1, 2]
	pool.shuffle() 
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
	
	var buff = randi_range(0, 2)
	match buff :
		0 : curEDamage += randi_range(0, 2)
		1 : curEHeal += randi_range(0, 2)
		2 : curEShield += randi_range(0, 2)
	
	if curEPiercing > 0:
		eDamageNode.text = "D:" + str(curEDamage) + "+" + str(curEPiercing)
	else :
		eDamageNode.text = "D:" + str(curEDamage)
	eHealNode.text = "H:" + str(curEHeal)
	eShieldNode.text = "S:" + str(curEShield)

func update_health_with_damage(pDamage : int, pPiercing : int) -> void :
	eDamage = pDamage - curEShield
	if(eDamage > 0) :
		enemyHealth -= eDamage
	if (pPiercing > 0) :
		enemyHealth -= pPiercing
	if((eDamage > 0 || pPiercing > 0) && Global.playerType == "Assassin") :
		addToPoison = true
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)
	
func update_health_with_aoe(aoeDamage : int) :
	var eExplosive = aoeDamage - curEShield
	enemyHealth -= eExplosive
	if enemyHealth < 0 : enemyHealth = 0
	eHealthNode.text = "Health:" + str(enemyHealth)


func update_health_with_heal() -> void :
	enemyHealth += curEHeal
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
	eDamage = 0
	curPPiercing = 0
	addToPoison = false
	eDamageNode.text = "D:"
	eHealNode.text = "H:"
	eShieldNode.text = "S:"
	
	for i in range(0, 3) :
		var eNode = get_node(eDieSpritePath + str(i) + eDieSpritePath2 + str(i))
		eNode.offset = Vector2(0, 0)
	
	
func hideAllNodes() -> void :
	$enemyDiceTray.visible = false
	
