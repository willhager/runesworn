extends Control

@onready var healthLabelNode : Node = get_node("Panel/MarginContainer/SideInfoContainer/HealthLabel")
@onready var levelLabelNode : Node = get_node("Panel/MarginContainer/SideInfoContainer/LevelLabel")
@onready var classLabelNode : Node = get_node("Panel/MarginContainer/SideInfoContainer/ClassLabel")
@onready var modifierNode1 : Node = get_node("Panel/MarginContainer/SideInfoContainer/Modifier1")
@onready var modifierNode2 : Node = get_node("Panel/MarginContainer/SideInfoContainer/Modifier2")
@onready var modifierNode3 : Node = get_node("Panel/MarginContainer/SideInfoContainer/Modifier3")

func _ready() -> void :
	if(Global.health) : healthLabelNode.text = "Health:" + str(Global.health) + "/" + str(Global.maxHealth)
	else : healthLabelNode.text = "Health"
	if(Global.playerType) : classLabelNode.text = Global.playerType
	else : classLabelNode.text = "Class"
	levelLabelNode.text = "Level:" + str(Global.difficulty)
	update_modifiers()

func reready() -> void :
	healthLabelNode.text = "Health:" + str(Global.health) + "/" + str(Global.maxHealth)
	levelLabelNode.text = "Level:" + str(Global.difficulty)
	
func update_class() -> void :
	classLabelNode.text = Global.playerType

func update_health(health : int = Global.health) -> void :
	healthLabelNode.text = "Health:" + str(health) + "/" + str(Global.maxHealth)
	
func update_level(level : int = Global.difficulty) -> void :
	levelLabelNode.text = "Level:" + str(level)

func update_modifiers() -> void :
	modifierNode1.text = Global.get_modifier_0()
	modifierNode1.set_tooltip(Global.get_modifier_0(), Global.get_modifier_0_tooltip())
	
	modifierNode2.text = Global.get_modifier_1()
	modifierNode2.set_tooltip(Global.get_modifier_1(), Global.get_modifier_1_tooltip())
	
	modifierNode3.text = Global.get_modifier_2()
	modifierNode3.set_tooltip(Global.get_modifier_2(), Global.get_modifier_2_tooltip())
		
func full_update() -> void :
	update_class()
	update_health()
	update_level()
	update_modifiers()
