extends Node

var loot_data : Dictionary = {}

func _ready() -> void :
	load_loot_data()
	
func load_loot_data() -> void:
	var file_path = "res://global/data/LootTable.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		if typeof(json_result) == TYPE_DICTIONARY:
			loot_data = json_result
		else:
			push_error("Failed to parse dice JSON.")
	else:
		push_error("Failed to open dice JSON file.")

func get_loot_drop() -> Dictionary :
	var mult = Global.lootMult
	var cumulativeWeights : Array[float]
	cumulativeWeights.resize(Global.maxLootNum)
	cumulativeWeights[0] = loot_data.get(str(0)).get("weight")
	var total_weight : int = 0
	for i in range (0, Global.maxLootNum) :
		total_weight += loot_data.get(str(i)).get("weight")
		if(i == 0) :
			cumulativeWeights[i] = loot_data.get(str(i)).get("weight")
			#print("cumulativeweight at " +str(i) + ": " + str(cumulativeWeights[i]))
		else :
			cumulativeWeights[i] = cumulativeWeights[i - 1] + loot_data.get(str(i)).get("weight")
			#print("cumulativeweight at " +str(i) + ": " + str(cumulativeWeights[i]))
	
	#print("total weight" + str(total_weight))
	var lootRoll = (randi() % total_weight) * mult
	#print("loot roll" + str(lootRoll))
	
	for i in range (0, Global.maxLootNum) :
		if lootRoll > cumulativeWeights[i] :
			continue
		else :
			return loot_data.get(str(i))
		
	#print("fallback")
	return loot_data.get(str(0))
