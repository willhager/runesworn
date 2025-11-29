extends PopupPanel

var dieFacePath = "Panel/MarginContainer/VBoxContainer/InfoHBox/FaceContainer/Face"
var dieInfoPath = "Panel/MarginContainer/VBoxContainer/InfoHBox/InfoContainer/Info"
@onready var dieName :Node = get_node("Panel/MarginContainer/VBoxContainer/Label")

func populate(die : String) :
	dieName.text = die
	var selected_die_faces = DiceData.get_die_by_name(die).get("faces")
	for i in range (0, 6) :
		var faceNode = get_node(dieFacePath + str(i))
		faceNode.texture = load(selected_die_faces[i].get("sprite"))
		var infoNode = get_node(dieInfoPath + str(i))
		var value = str(selected_die_faces[i].get("value"))
		match selected_die_faces[i].get("effect") :
			Global.damageEffectName :
				infoNode.text = "Deals " + str(int(value)) + " damage."
			Global.shieldEffectName :
				infoNode.text = "Protects you from " + str(int(value)) + " damage."
			Global.healEffectName :
				infoNode.text = "Restores " + str(int(value)) + " health."
			Global.piercingEffectName :
				infoNode.text = "Deals " + str(int(value)) + " damage, skips shield."
			Global.explosiveEffectName :
					infoNode.text = "Deals " + str(int(value)) + " damage, spread to all enemies."
	print("populated")
				
		
func show_tooltip(global_pos: Vector2) :
	popup()  # Required for PopupPanel
	size = Vector2.ZERO  # Forces layout update
	await get_tree().process_frame
	print(global_pos)
	position = global_pos
	print("tooltip pos:", position, " size:", size)
	print("finished executing show tooltip")
	
	
