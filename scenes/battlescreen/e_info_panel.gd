extends Panel

@onready var ename : Node = get_node("MarginContainer/VBoxContainer/EName")
@onready var health : Node = get_node("MarginContainer/VBoxContainer/EHealth")
@onready var reward : Node = get_node("MarginContainer/VBoxContainer/EReward")
@onready var abilities : Node = get_node("MarginContainer/VBoxContainer/EAbilities")

func _ready() :
	ename.text = "ENEMY"
	health.text = "HEALTH:"
	reward.text = "REWARD:"
	abilities.text = "ABILITIES:"

func reready() -> void :
	ename.text = "ENEMY"
	health.text = "HEALTH:"
	reward.text = "REWARD:"
	abilities.text = "ABILITIES:"
	abilities.clear_tooltip()

func set_core_values(enemy_name : String, enemy_health : String, enemy_reward : String) :
	ename.text = enemy_name
	health.text = enemy_health
	reward.text = enemy_reward

func set_abilities_text(enemy_abilities: String) :
	abilities.text = enemy_abilities
	
func set_abilities_tooltip(title : String, body : String) :
	abilities.set_tooltip(title, body)
	
func clear_abilities_tooltip() :
	abilities.clear_tooltip()
