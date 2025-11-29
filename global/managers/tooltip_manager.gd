extends Node

var dicePopup_scene := preload("res://scenes/tooltip/dice_popup.tscn")
var dicePopup_tooltip

var tooltip_scene := preload("res://scenes/tooltip/tooltip.tscn")
var tooltip

func _ready():
	dicePopup_tooltip = dicePopup_scene.instantiate()
	tooltip = tooltip_scene.instantiate()
	call_deferred("_add_tooltip")

func _add_tooltip():
	get_tree().root.add_child(dicePopup_tooltip)
	get_tree().root.add_child(tooltip)
	dicePopup_tooltip.hide()
	tooltip.hide()

func show_dicePopup(die: String, global_pos: Vector2):
	dicePopup_tooltip.populate(die)
	dicePopup_tooltip.show_tooltip(global_pos)

func hide_dicePopup():
	dicePopup_tooltip.request_hide()

func show_tooltip(title: String, text: String, global_pos: Vector2) :
	tooltip.show_tooltip(title, text, global_pos)
	
func hide_tooltip():
	tooltip.request_hide()
