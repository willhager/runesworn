extends Button

var dieName : String
var dieNameSet : bool
var pos

func _ready() :
	set_die_name(Global.die[0])
	var rect = get_parent().get_global_rect()
	var tooltip_size = tooltip_manager.dicePopup_tooltip.size
	pos = Vector2(
		rect.position.x - tooltip_size.x - 8,              
		rect.position.y + ((rect.size.y - tooltip_size.y) * 0.5) - 2 * (.2 * rect.size.y)
	)

func set_die_name(die_name) :
	dieName = die_name
	dieNameSet = true

func _on_mouse_entered() :
	if dieNameSet == false :
		push_error("var dieName not set in pDie0, unable to show tooltip")
	print("mouse entered")
	tooltip_manager.show_dicePopup(dieName, pos)
	
func _on_mouse_exited() :
	tooltip_manager.hide_dicePopup()
	
