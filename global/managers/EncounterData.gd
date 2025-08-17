extends Node

var encounter_data : Dictionary = {}
var tier1 : Array
var tier2 : Array
var tier3 : Array

func _ready() -> void :
	load_encounter_data()
	
func load_encounter_data() -> void :
	var file_path = "res://global/data/Encounters.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		if typeof(json_result) == TYPE_DICTIONARY:
			encounter_data = json_result
		else:
			push_error("Failed to parse encounter JSON.")
	else:
		push_error("Failed to open encounter JSON file.")
		
	tier1 = encounter_data.get("1")
	tier2 = encounter_data.get("2")
	#tier3 = encounter_data.get("3")
	
func get_encounter(tier : int) -> Dictionary:
	var encounterList
	match tier :
		1 : 
			encounterList = tier1
		2 : 
			encounterList = tier2
		3 :
			encounterList = tier3
	var total_weight : int = 0
	for encounter in encounterList:
		total_weight += encounter.get("weight", 1)

	var roll = randi() % total_weight
	var cumulative = 0

	for encounter in encounterList:
		cumulative += encounter.get("weight", 1)
		if roll < cumulative:
			return encounter

	return encounterList[-1]  # Fallback
	
func get_4_encounters(tier: int) -> Array:
	var encounter_list
	match tier:
		1:
			encounter_list = tier1
		2:
			encounter_list = tier2
		3:
			encounter_list = tier3

	if encounter_list.size() <= 4:
		return encounter_list.duplicate()

	var selected_encounters: Array = []
	var available_encounters = encounter_list.duplicate()

	for _i in range(4):
		var total_weight : int = 0
		for encounter in available_encounters:
			total_weight += encounter.get("weight", 1)

		var roll = randi() % total_weight
		var cumulative = 0
		var chosen_index = 0

		for j in range(available_encounters.size()):
			cumulative += available_encounters[j].get("weight", 1)
			if roll < cumulative:
				chosen_index = j
				break

		selected_encounters.append(available_encounters[chosen_index])
		available_encounters.remove_at(chosen_index)

	return selected_encounters
	
func get_3_encounters(tier: int) -> Array:
	var encounter_list
	match tier:
		1:
			encounter_list = tier1
		2:
			encounter_list = tier2
		3:
			encounter_list = tier3

	if encounter_list.size() <= 3:
		return encounter_list.duplicate()

	var selected_encounters: Array = []
	var available_encounters = encounter_list.duplicate()

	for _i in range(3):
		var total_weight : int = 0
		for encounter in available_encounters:
			total_weight += encounter.get("weight", 1)

		var roll = randi() % total_weight
		var cumulative = 0
		var chosen_index = 0

		for j in range(available_encounters.size()):
			cumulative += available_encounters[j].get("weight", 1)
			if roll < cumulative:
				chosen_index = j
				break

		selected_encounters.append(available_encounters[chosen_index])
		available_encounters.remove_at(chosen_index)

	return selected_encounters

func remove_encounter(tier : int, id : int) -> Dictionary:
	match tier:
		1:
			for i in range (0, tier1.size()) :
				if tier1[i].get("id") == id :
					return tier1.pop_at(i)
		2:
			for i in range (0, tier2.size()) :
				if tier2[i].get("id") == id :
					return tier2.pop_at(i)
		3:
			for i in range (0, tier3.size()) :
				if tier3[i].get("id") == id :
					return tier3.pop_at(i)
	return tier1[0] #fallback
	
func get_encounter_by_index(tier : int, id : int) -> Dictionary:
	match tier:
		1:
			for i in range (0, tier1.size()) :
				if tier1[i].get("id") == id :
					return tier1[i]
		2:
			for i in range (0, tier2.size()) :
				if tier2[i].get("id") == id :
					return tier2[i]
		3:
			for i in range (0, tier3.size()) :
				if tier3[i].get("id") == id :
					return tier3[i]
	return tier1[0] #fallback
