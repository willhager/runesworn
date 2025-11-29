extends Control

func _ready() -> void :
	self.visible = false
	self.set_process_input(false)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func callDefeat() -> void :
	self.visible = true
	self.set_process_input(true)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	
func _on_menu_button_pressed() -> void:
	Global.health = 0
	Global.difficulty = 1
	Global.encounterNum = 1
	Global.curScenePath = Global.mainMenuPath
	get_tree().change_scene_to_file(Global.mainMenuPath)
