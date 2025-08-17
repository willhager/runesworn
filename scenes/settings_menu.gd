extends Control

func _ready() -> void :
	resume()
	
func pause() -> void:
	self.visible = true
	self.set_process_input(true)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	get_tree().paused = true
	
func resume() -> void :
	get_tree().paused = false
	self.set_process_input(false)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.visible = false
	
func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _process(_delta) -> void :
	if Input.is_action_just_pressed("escape") && !get_tree().paused :
		pause()
	elif Input.is_action_just_pressed("escape") && get_tree().paused :
		resume()


func _on_main_menu_pressed() -> void:
	Global.health = 0
	Global.difficulty = 1
	Global.encounterNum = 1
	get_tree().change_scene_to_file(Global.mainMenuPath)
