extends Control

@onready var healthLabelNode : Node = get_node("Panel/MarginContainer/SideInfoContainer/HealthLabel")
@onready var levelLabelNode : Node = get_node("Panel/MarginContainer/SideInfoContainer/LevelLabel")
@onready var classLabelNode : Node = get_node("Panel/MarginContainer/SideInfoContainer/ClassLabel")

@onready var modifierNode1 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier1Box/Modifier1Container/Modifier1")
@onready var modifierNode2 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier2Box/Modifier2Container/Modifier2")
@onready var modifierNode3 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier3Box/Modifier3Container/Modifier3")

@onready var modifierLabelNode1 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier1Box/Modifier1Label")
@onready var modifierLabelNode2 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier2Box/Modifier2Label")
@onready var modifierLabelNode3 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier3Box/Modifier3Label")


@onready var modifierBoxNode1 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier1Box")
@onready var modifierBoxNode2 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier2Box")
@onready var modifierBoxNode3 : Node = get_node("Panel/MarginContainer/SideInfoContainer/ModifierIconContainer/Modifier3Box")

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
	if Global.get_modifier_0_icon_path() :
		modifierNode1.set_texture(load(Global.get_modifier_0_icon_path()))
	modifierLabelNode1.set_text(Global.get_modifier_0())
	modifierBoxNode1.set_tooltip(Global.get_modifier_0(), Global.get_modifier_0_tooltip())
	
	if Global.get_modifier_1_icon_path() :
		modifierNode2.set_texture(load(Global.get_modifier_1_icon_path()))
	modifierLabelNode2.set_text(Global.get_modifier_1())
	modifierBoxNode2.set_tooltip(Global.get_modifier_1(), Global.get_modifier_1_tooltip())
	
	if Global.get_modifier_2_icon_path() :
		modifierNode3.set_texture(load(Global.get_modifier_2_icon_path()))
	modifierLabelNode3.set_text(Global.get_modifier_2())
	modifierBoxNode3.set_tooltip(Global.get_modifier_2(), Global.get_modifier_2_tooltip())
		
func full_update() -> void :
	update_class()
	update_health()
	update_level()
	update_modifiers()
