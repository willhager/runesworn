extends Panel

var encounterIconPath : String = "VBoxContainer/Encounter"

func _ready() -> void :
	pass
	
func update_encounters() -> void :
	var greenRect = load("res://resources/green-rect.png")
	var redRectSelected = load("res://resources/red-rect-selected.png")
	var redRect = load("res://resources/red-rect.png")
	
	for i in range(1, 7) :
		var node = get_node(encounterIconPath + str(i))
		if i < Global.encounterNum :
			node.set_texture(greenRect)
		else :
			node.set_texture(redRect)
	
	var active = get_node(encounterIconPath + str(Global.encounterNum))
	active.set_texture(redRectSelected)
