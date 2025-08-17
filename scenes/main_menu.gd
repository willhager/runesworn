extends Control

func _ready():
	$Version.text = Global.version
	
func _on_start_button_pressed() :
	Global.curScenePath = Global.classSelectionPath
	get_tree().change_scene_to_packed(Global.classSelectionScene)


func _on_options_button_pressed() -> void:
	$SettingsLayer/SettingsMenu.pause()
