extends Control

#GOBLIN GANG
#dice1: beginner, barb
#dice2: beginner, barb
#dice3: barb, barb
#health: 4-8
#diceNum: 6

@onready var eDamageNode : Node = get_node("EnemyDiceTray/EInfoContainer/EDamage")
@onready var eHealNode : Node = get_node("EnemyDiceTray/EInfoContainer/EHeal")
@onready var eShieldNode : Node = get_node("EnemyDiceTray/EInfoContainer/EShield")
@onready var ePoisonNode : Node = get_node("EnemyDiceTray/EInfoContainer/EPoison")

@onready var goblin1HealthNode : Node = get_node("EnemyDiceTray/VBoxContainer1/Goblin1Health")
@onready var goblin2HealthNode : Node = get_node("EnemyDiceTray/VBoxContainer2/Goblin2Health")
@onready var goblin3HealthNode : Node = get_node("EnemyDiceTray/VBoxContainer3/Goblin3Health")

@onready var goblin1NameNode : Node = get_node("EnemyDiceTray/VBoxContainer1/Goblin1Label")
@onready var goblin2NameNode : Node = get_node("EnemyDiceTray/VBoxContainer2/Goblin2Label")
@onready var goblin3NameNode : Node = get_node("EnemyDiceTray/VBoxContainer3/Goblin3Label")

@onready var eDie0 : Node = get_node("EnemyDiceTray/Goblin1Container/Control0/EDie0")
@onready var eDie1 : Node = get_node("EnemyDiceTray/Goblin1Container/Control1/EDie1")
@onready var eDie2 : Node = get_node("EnemyDiceTray/Goblin2Container/Control0/EDie2")
@onready var eDie3 : Node = get_node("EnemyDiceTray/Goblin2Container/Control1/EDie3")
@onready var eDie4 : Node = get_node("EnemyDiceTray/Goblin3Container/Control0/EDie4")
@onready var eDie5 : Node = get_node("EnemyDiceTray/Goblin3Container/Control1/EDie5")

var goblin1Health : int
var goblin2Health : int
var goblin3Health : int

var maxHealth : int

var curEDamage : int
var curEHeal : int
var curEShield : int
var curEPiercing : int
var curEPoisonCounter : int

var addToPoison : bool = false

var EDice : Array[String]

var eDiceRolls1 : Array[Dictionary]
var eDiceRolls2 : Array[Dictionary]
var eDiceRolls3 : Array[Dictionary]


var goblin1Alive: bool = true
var goblin2Alive: bool = true
var goblin3Alive : bool = true


func _ready() -> void :
	goblin1Health = randi_range(4, 8)
	goblin2Health = randi_range(4, 8)
	goblin3Health = randi_range(4, 8)
	
	maxHealth = goblin1Health + goblin2Health + goblin3Health
	
	goblin1HealthNode.text = "H:" + str(goblin1Health)
	goblin2HealthNode.text = "H:" + str(goblin2Health)
	goblin3HealthNode.text = "H:" + str(goblin3Health)

	EDice.resize(6)
	
	eDiceRolls1.resize(2)
	eDiceRolls2.resize(2)
	eDiceRolls3.resize(2)

	
	EDice[0] = "Beginner's Die"
	EDice[1] = "Barbarian's Die"
	EDice[2] = "Beginner's Die"
	EDice[3] = "Barbarian's Die"
	EDice[4] = "Barbarian's Die"
	EDice[5] = "Barbarian's Die"
	
	#set faces from dice dictionary
	set_eDice_faces(eDie0, EDice[0])
	set_eDice_faces(eDie1, EDice[1])
	set_eDice_faces(eDie2, EDice[2])
	set_eDice_faces(eDie3, EDice[3])
	set_eDice_faces(eDie4, EDice[4])
	set_eDice_faces(eDie5, EDice[5])
	
		
	if(Global.playerType == "Assassin") :
		ePoisonNode.text = "P:"
	
func set_eDice_faces(node : Node, die_name : String) :
	var dieTexture : SpriteFrames = SpriteFrames.new()
	dieTexture.add_animation("faces")
	dieTexture.set_animation_speed("faces", 15)
	for j in range(0, 6) :
		dieTexture.add_frame("faces", load(DiceData.get_die_by_name(die_name).get("faces")[j].get("sprite")))
	node.set_sprite_frames(dieTexture)
	node.set_frame(0)
	node.play("faces")
	node.pause()

func roll_eDice() -> void :
	if goblin1Alive :
		eDie0.set_frame(randi_range(0, 5))
		eDie0.play("faces")
		eDie1.set_frame(randi_range(0, 5))
		eDie1.play("faces")
	if goblin2Alive :
		eDie2.set_frame(randi_range(0, 5))
		eDie2.play("faces")
		eDie3.set_frame(randi_range(0, 5))
		eDie3.play("faces")
	if goblin3Alive :
		eDie4.set_frame(randi_range(0, 5))
		eDie4.play("faces")
		eDie5.set_frame(randi_range(0, 5))
		eDie5.play("faces")
	
	await get_tree().create_timer(0.75).timeout
	
	eDie0.pause()
	eDie1.pause()
	eDie2.pause()
	eDie3.pause()
	eDie4.pause()
	eDie5.pause()
	
	if goblin1Alive :
		eDiceRolls1[0] = DiceData.roll_die(EDice[0])
		eDiceRolls1[1] = DiceData.roll_die(EDice[1])
		eDie0.set_frame(eDiceRolls1[0].get("index"))
		eDie1.set_frame(eDiceRolls1[1].get("index"))
	
	if goblin2Alive :
		eDiceRolls2[0] = DiceData.roll_die(EDice[2])
		eDiceRolls2[1] = DiceData.roll_die(EDice[3])
		eDie2.set_frame(eDiceRolls2[0].get("index"))
		eDie3.set_frame(eDiceRolls2[1].get("index"))
		
	if goblin3Alive :
		eDiceRolls3[0] = DiceData.roll_die(EDice[4])
		eDiceRolls3[1] = DiceData.roll_die(EDice[5])
		eDie4.set_frame(eDiceRolls3[0].get("index"))
		eDie5.set_frame(eDiceRolls3[1].get("index"))
	
	await get_tree().create_timer(0.3).timeout
	
	var goblin1Selected = randi_range(0, 1)
	var goblin2Selected = randi_range(0, 1)
	var goblin3Selected = randi_range(0, 1)

	if goblin1Alive :
		var roll = eDiceRolls1[goblin1Selected]
		var eNode : Node
		match goblin1Selected :
			0 : eNode = eDie0
			1 : eNode = eDie1
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
				
	if goblin2Alive :
		var roll = eDiceRolls2[goblin2Selected]
		var eNode : Node
		match goblin2Selected :
			0 : eNode = eDie2
			1 : eNode = eDie3
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
				
	if goblin3Alive :
		var roll = eDiceRolls3[goblin3Selected]
		var eNode : Node
		match goblin3Selected :
			0 : eNode = eDie4
			1 : eNode = eDie5
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

func update_health_with_damage(curDamage : int, curPiercing : int = 0) -> void :
	var eDamage = curDamage - curEShield
	if(eDamage > 0 || curPiercing > 0) :
		if(Global.playerType == "Assassin") :
			addToPoison = true
	if goblin1Alive :
		goblin1Health -= eDamage
		if (curPiercing > 0) :
			goblin1Health -= curPiercing
		if goblin1Health <= 0 :
			goblin1HealthNode.text = "H:0"
			goblin1NameNode.text = "Goblin (DEAD)"
			goblin1Alive = false
		else :
			goblin1HealthNode.text = "H:" + str(goblin1Health)
	elif goblin2Alive :
		goblin2Health -= eDamage
		if (curPiercing > 0) :
			goblin2Health -= curPiercing
		if goblin2Health <= 0 :
			goblin2HealthNode.text = "H:0"
			goblin2NameNode.text = "Goblin (DEAD)"
			goblin2Alive = false
		else :
			goblin2HealthNode.text = "H:" + str(goblin2Health)
	elif goblin3Alive :
		goblin3Health -= eDamage
		if (curPiercing > 0) :
			goblin3Health -= curPiercing
		if goblin3Health <= 0 :
			goblin3HealthNode.text = "H:0"
			goblin3NameNode.text = "Goblin (DEAD)"
			goblin3Alive = false
		else :
			goblin3HealthNode.text = "H:" + str(goblin3Health)	

func update_health_with_heal() -> void :
	if goblin1Alive:
		goblin1Health += curEHeal
		goblin1HealthNode.text = "H:" + str(goblin1Health)
	elif goblin1Alive:
		goblin2Health += curEHeal
		goblin2HealthNode.text = "H:" + str(goblin2Health)
	if goblin3Alive:
		goblin3Health += curEHeal
		goblin3HealthNode.text = "H:" + str(goblin3Health)
	
func update_health_with_poison() -> void :
	if goblin1Alive:
		goblin1Health -= curEPoisonCounter
		goblin1HealthNode.text = "H:" + str(goblin1Health)
	elif goblin1Alive:
		goblin2Health -= curEPoisonCounter
		goblin2HealthNode.text = "H:" + str(goblin2Health)
	if goblin3Alive:
		goblin3Health -= curEPoisonCounter
		goblin3HealthNode.text = "H:" + str(goblin3Health)
	if addToPoison :
		curEPoisonCounter += 1
		ePoisonNode.text = "P: " + str(curEPoisonCounter)
		
func update_health_with_aoe(aoeDamage : int) -> void :
	var eExplosive = aoeDamage - curEShield
	if(goblin1Alive) : 
		goblin1Health -= eExplosive
		goblin1HealthNode.text = "H:" + str(goblin1Health)
	if(goblin2Alive) : 
		goblin2Health -= eExplosive
		goblin2HealthNode.text = "H:" + str(goblin2Health)
	if(goblin3Alive) : 
		goblin3Health -= eExplosive
		goblin3HealthNode.text = "H:" + str(goblin3Health)
	
func get_max_health() -> String : 
	return str(maxHealth)
	
func get_total_health() -> int : 
	return goblin1Health + goblin2Health + goblin3Health
	
func clear() -> void :
	curEDamage = 0
	curEShield = 0
	curEHeal = 0
	curEPiercing = 0
	
	addToPoison = false
	
	eDamageNode.text = "D:"
	eHealNode.text = "H:"
	eShieldNode.text = "S:"
	
	eDie0.offset = Vector2(0, 0)
	eDie1.offset = Vector2(0, 0)
	eDie2.offset = Vector2(0, 0)
	eDie3.offset = Vector2(0, 0)
	eDie4.offset = Vector2(0, 0)
	eDie5.offset = Vector2(0, 0)
	
	
func hideAllNodes() -> void :
	$enemyDiceTray.visible = false
	
