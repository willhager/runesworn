extends PopupPanel

var dieFacePath = "Panel/MarginContainer/VBoxContainer/InfoHBox/FaceContainer/Face"
var dieInfoPath = "Panel/MarginContainer/VBoxContainer/InfoHBox/InfoContainer/Info"
@onready var dieName :Node = get_node("Panel/MarginContainer/VBoxContainer/Label")

var hide_timer: Timer

func _ready():
	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = 0.05  # small delay, enough to catch fast switches
	add_child(hide_timer)
	hide_timer.timeout.connect(_on_hide_timeout)

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

func show_tooltip(global_pos: Vector2):
	hide_timer.stop()
	popup()
	size = Vector2.ZERO
	call_deferred("_finish_popup", global_pos)

func _finish_popup(global_pos: Vector2):
	position = global_pos
	
func request_hide() :
	hide_timer.start()
	
func _on_hide_timeout():
	hide()



	
