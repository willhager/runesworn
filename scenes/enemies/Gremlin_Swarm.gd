extends enemy_template

#gremlin GANG
#dice1: barb, barb
#dice2: barb, barb
#dice3: barb, barb
#health: 5-10
#diceNum: 6

@onready var eDamageNode : Node = get_node("EnemyDiceTray/EInfoContainer/EDamage")
@onready var eHealNode : Node = get_node("EnemyDiceTray/EInfoContainer/EHeal")
@onready var eShieldNode : Node = get_node("EnemyDiceTray/EInfoContainer/EShield")
@onready var ePoisonNode : Node = get_node("EnemyDiceTray/EInfoContainer/EPoison")

@onready var gremlin1HealthNode : Node = get_node("EnemyDiceTray/VBoxContainer1/Gremlin1Health")
@onready var gremlin2HealthNode : Node = get_node("EnemyDiceTray/VBoxContainer2/Gremlin2Health")
@onready var gremlin3HealthNode : Node = get_node("EnemyDiceTray/VBoxContainer3/Gremlin3Health")

@onready var gremlin1NameNode : Node = get_node("EnemyDiceTray/VBoxContainer1/Gremlin1Label")
@onready var gremlin2NameNode : Node = get_node("EnemyDiceTray/VBoxContainer2/Gremlin2Label")
@onready var gremlin3NameNode : Node = get_node("EnemyDiceTray/VBoxContainer3/Gremlin3Label")

@onready var eDie0 : Node = get_node("EnemyDiceTray/Gremlin1Container/Control0/EDie0")
@onready var eDie1 : Node = get_node("EnemyDiceTray/Gremlin1Container/Control1/EDie1")
@onready var eDie2 : Node = get_node("EnemyDiceTray/Gremlin2Container/Control0/EDie2")
@onready var eDie3 : Node = get_node("EnemyDiceTray/Gremlin2Container/Control1/EDie3")
@onready var eDie4 : Node = get_node("EnemyDiceTray/Gremlin3Container/Control0/EDie4")
@onready var eDie5 : Node = get_node("EnemyDiceTray/Gremlin3Container/Control1/EDie5")

var gremlin1Health : int
var gremlin2Health : int
var gremlin3Health : int

var maxg1 : int
var maxg2 : int
var maxg3 : int

var maxHealth : int

var enemy_damage : int
var enemy_heal : int
var enemy_shield : int
var enemy_piercing : int
var enemy_poison_counter : int

var addToPoison : bool = false

var EDice : Array[Dictionary]

var eDiceRolls1 : Array[Dictionary]
var eDiceRolls2 : Array[Dictionary]
var eDiceRolls3 : Array[Dictionary]


var gremlin1Alive: bool = true
var gremlin2Alive: bool = true
var gremlin3Alive : bool = true

var selected : Array[Dictionary] = []


func _ready() -> void :
	gremlin1Health = randi_range(5, 10)
	gremlin2Health = randi_range(5, 10)
	gremlin3Health = randi_range(5, 10)
	
	GameState.maxHealth = gremlin1Health + gremlin2Health + gremlin3Health
	
	maxg1 = gremlin1Health
	maxg2 = gremlin2Health
	maxg3 = gremlin3Health
	
	
	gremlin1HealthNode.text = "H:" + str(gremlin1Health)
	gremlin2HealthNode.text = "H:" + str(gremlin2Health)
	gremlin3HealthNode.text = "H:" + str(gremlin3Health)

	GameState.EDice.resize(6)
	
	eDiceRolls1.resize(2)
	eDiceRolls2.resize(2)
	eDiceRolls3.resize(2)

	
	GameState.EDice[0] = DiceData.get_die_by_name("Barbarian's Die")
	GameState.EDice[1] = DiceData.get_die_by_name("Barbarian's Riposte")
	GameState.EDice[2] = DiceData.get_die_by_name("Barbarian's Die")
	GameState.EDice[3] = DiceData.get_die_by_name("Barbarian's Riposte")
	GameState.EDice[4] = DiceData.get_die_by_name("Barbarian's Die")
	GameState.EDice[5] = DiceData.get_die_by_name("Barbarian's Riposte")
	
	#set faces from dice dictionary
	set_eDice_faces(eDie0, GameState.EDice[0].get("name"))
	set_eDice_faces(eDie1, GameState.EDice[1].get("name"))
	set_eDice_faces(eDie2, GameState.EDice[2].get("name"))
	set_eDice_faces(eDie3, GameState.EDice[3].get("name"))
	set_eDice_faces(eDie4, GameState.EDice[4].get("name"))
	set_eDice_faces(eDie5, GameState.EDice[5].get("name"))
	
		
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
	if gremlin1Alive :
		eDie0.set_frame(randi_range(0, 5))
		eDie0.play("faces")
		eDie1.set_frame(randi_range(0, 5))
		eDie1.play("faces")
	if gremlin2Alive :
		eDie2.set_frame(randi_range(0, 5))
		eDie2.play("faces")
		eDie3.set_frame(randi_range(0, 5))
		eDie3.play("faces")
	if gremlin3Alive :
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
	
	if gremlin1Alive :
		eDiceRolls1[0] = DiceData.roll_die(GameState.EDice[0].get("name"))
		eDiceRolls1[1] = DiceData.roll_die(GameState.EDice[1].get("name"))
		eDie0.set_frame(eDiceRolls1[0].get("index"))
		eDie1.set_frame(eDiceRolls1[1].get("index"))
	
	if gremlin2Alive :
		eDiceRolls2[0] = DiceData.roll_die(GameState.EDice[2].get("name"))
		eDiceRolls2[1] = DiceData.roll_die(GameState.EDice[3].get("name"))
		eDie2.set_frame(eDiceRolls2[0].get("index"))
		eDie3.set_frame(eDiceRolls2[1].get("index"))
		
	if gremlin3Alive :
		eDiceRolls3[0] = DiceData.roll_die(GameState.EDice[4].get("name"))
		eDiceRolls3[1] = DiceData.roll_die(GameState.EDice[5].get("name"))
		eDie4.set_frame(eDiceRolls3[0].get("index"))
		eDie5.set_frame(eDiceRolls3[1].get("index"))
	
	await get_tree().create_timer(0.3).timeout
	
	var gremlin1Selected = randi_range(0, 1)
	var gremlin2Selected = randi_range(0, 1)
	var gremlin3Selected = randi_range(0, 1)

	if gremlin1Alive :
		var roll = eDiceRolls1[gremlin1Selected]
		selected.append(roll)
		var eNode : Node
		match gremlin1Selected :
			0 : eNode = eDie0
			1 : eNode = eDie1
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
				
	if gremlin2Alive :
		var roll = eDiceRolls2[gremlin2Selected]
		selected.append(roll)
		var eNode : Node
		match gremlin2Selected :
			0 : eNode = eDie2
			1 : eNode = eDie3
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
				
	if gremlin3Alive :
		var roll = eDiceRolls3[gremlin3Selected]
		selected.append(roll)
		var eNode : Node
		match gremlin3Selected :
			0 : eNode = eDie4
			1 : eNode = eDie5
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
	if(eDamage > 0 || curPiercing > 0) :
		if(Global.playerType == "Assassin") :
			addToPoison = true
			
	if eDamage > 0 :
		if gremlin1Alive :
			gremlin1Health -= eDamage
			if (curPiercing > 0) :
				gremlin1Health -= curPiercing
			if gremlin1Health <= 0 :
				gremlin1HealthNode.text = "H:0"
				gremlin1NameNode.text = "gremlin (DEAD)"
				gremlin1Alive = false
			else :
				gremlin1HealthNode.text = "H:" + str(gremlin1Health)
		elif gremlin2Alive :
			gremlin2Health -= eDamage
			if (curPiercing > 0) :
				gremlin2Health -= curPiercing
			if gremlin2Health <= 0 :
				gremlin2HealthNode.text = "H:0"
				gremlin2NameNode.text = "gremlin (DEAD)"
				gremlin2Alive = false
			else :
				gremlin2HealthNode.text = "H:" + str(gremlin2Health)
		elif gremlin3Alive :
			gremlin3Health -= eDamage
			if (curPiercing > 0) :
				gremlin3Health -= curPiercing
			if gremlin3Health <= 0 :
				gremlin3HealthNode.text = "H:0"
				gremlin3NameNode.text = "gremlin (DEAD)"
				gremlin3Alive = false
			else :
				gremlin3HealthNode.text = "H:" + str(gremlin3Health)

func update_health_with_heal() -> void :
	if gremlin1Alive:
		gremlin1Health += GameState.enemy_heal
		if gremlin1Health < 0 : gremlin1Health = 0
		if gremlin1Health > maxg1 : gremlin1Health = maxg1
		gremlin1HealthNode.text = "H:" + str(gremlin1Health)
	elif gremlin1Alive:
		gremlin2Health += GameState.enemy_heal
		if gremlin2Health < 0 : gremlin2Health = 0
		if gremlin2Health > maxg2 : gremlin2Health = maxg2
		gremlin2HealthNode.text = "H:" + str(gremlin2Health)
	if gremlin3Alive:
		gremlin3Health += GameState.enemy_heal
		if gremlin3Health < 0 : gremlin3Health = 0
		if gremlin3Health > maxg3 : gremlin3Health = maxg3
		gremlin3HealthNode.text = "H:" + str(gremlin3Health)
	
func update_health_with_poison() -> void :
	if gremlin1Alive:
		gremlin1Health -= GameState.enemy_poison_counter
		gremlin1HealthNode.text = "H:" + str(gremlin1Health)
	elif gremlin1Alive:
		gremlin2Health -= GameState.enemy_poison_counter
		gremlin2HealthNode.text = "H:" + str(gremlin2Health)
	if gremlin3Alive:
		gremlin3Health -= GameState.enemy_poison_counter
		gremlin3HealthNode.text = "H:" + str(gremlin3Health)
	if addToPoison :
		GameState.enemy_poison_counter += 1
		ePoisonNode.text = "P: " + str(GameState.enemy_poison_counter)
		
func update_health_with_aoe(rolls : Array[Dictionary]) -> void :
	var aoeDamage = 0
	for roll in rolls :
		match roll.get("effect") :
			Global.explosiveEffectName :
				aoeDamage += roll.get("value")
	
	var eExplosive = aoeDamage - GameState.enemy_shield
	if eExplosive > 0 :
		if(gremlin1Alive) : 
			gremlin1Health -= eExplosive
			gremlin1HealthNode.text = "H:" + str(gremlin1Health)
		if(gremlin2Alive) : 
			gremlin2Health -= eExplosive
			gremlin2HealthNode.text = "H:" + str(gremlin2Health)
		if(gremlin3Alive) : 
			gremlin3Health -= eExplosive
			gremlin3HealthNode.text = "H:" + str(gremlin3Health)
	
func get_max_health() -> String : 
	return str(GameState.maxHealth)
	
func get_total_health() -> int : 
	return gremlin1Health + gremlin2Health + gremlin3Health
	
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
	
	eDie0.offset = Vector2(0, 0)
	eDie1.offset = Vector2(0, 0)
	eDie2.offset = Vector2(0, 0)
	eDie3.offset = Vector2(0, 0)
	eDie4.offset = Vector2(0, 0)
	eDie5.offset = Vector2(0, 0)
	
	selected = []
	
	
func hideAllNodes() -> void :
	$enemyDiceTray.visible = false
