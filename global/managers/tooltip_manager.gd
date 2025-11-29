extends Node

var dicePopup_scene := preload("res://scenes/dice_popup.tscn")
var dicePopup_tooltip

func _ready():
	dicePopup_tooltip = dicePopup_scene.instantiate()
	call_deferred("_add_tooltip")

func _add_tooltip():
	get_tree().root.add_child(dicePopup_tooltip)
	dicePopup_tooltip.hide()  # NOW safe

func show_dicePopup(die: String, global_pos: Vector2):
	dicePopup_tooltip.populate(die)
	dicePopup_tooltip.show_tooltip(global_pos)

func hide_dicePopup():
	dicePopup_tooltip.hide()
