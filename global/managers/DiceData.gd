extends Node

var dice_data: Dictionary = {}

func _ready():
	load_dice_data()

func load_dice_data():
	var file_path = "res://global/data/DiceMap.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		if typeof(json_result) == TYPE_DICTIONARY:
			dice_data = json_result
		else:
			push_error("Failed to parse dice JSON.")
	else:
		push_error("Failed to open dice JSON file.")

func get_die_by_name(dname: String) -> Dictionary:
	for die in dice_data.get("dice", []):
		if die.get("name") == dname:
			return die
	return {}
	
func get_die_by_index(dindex: int) -> Dictionary:
	for die in dice_data.get("dice", []):
		if die.get("id") == dindex:
			return die
	return {}

##Returns a random face from the "faces" dictionary of the die from input
func roll_die(die_name: String) -> Dictionary:
	var die = get_die_by_name(die_name)
	if die:
		return weighted_random_choice(die["faces"])
	return {}

func weighted_random_choice(faces: Array) -> Dictionary:
	var total_weight : int = 0
	for face in faces:
		total_weight += face.get("weight", 1)

	var roll = randi() % total_weight
	var cumulative = 0

	for face in faces:
		cumulative += face.get("weight", 1)
		if roll < cumulative:
			return face

	return faces[-1]  # Fallback
