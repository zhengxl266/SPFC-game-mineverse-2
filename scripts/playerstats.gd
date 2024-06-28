extends Node

var current_xp = 0
var level = 1
const XP_DATABASE = "res://player level and stats tables/player_stats.json"
const MAX_LEVEL = 6
const GROWTH_RATE: float = 2.50
var XP_Table_Data = {}
signal player_leveled_up(new_level)

func _ready():
	XP_Table_Data = get_xp_data()
	load_player_data()
	connect_to_level_up_signal()
	
	
func connect_to_level_up_signal():
	PlayerStats.player_leveled_up.connect(_on_player_leveled_up)
	
func _on_player_leveled_up(new_level):
	pass

func gain_xp(amount):
	current_xp += amount
	print("Gained XP: ", amount)
	print("Current XP: ", current_xp)
	check_level_up()

func check_level_up():
	var max_xp = get_max_xp_at(level)
	if current_xp >= max_xp and level < MAX_LEVEL:
		level += 1
		current_xp -= max_xp
		emit_signal("player_leveled_up", level)
	elif level == MAX_LEVEL:
		current_xp = 0

func get_xp_data() -> Dictionary:
	var file = FileAccess.open(XP_DATABASE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	return data

func get_max_xp_at(level):
	return XP_Table_Data[str(level)]["need"]

func load_player_data():
	var file = FileAccess.open(XP_DATABASE, FileAccess.READ)
	if file:
		var data = parse_json(file.get_as_text())
		for key in data.keys():
			if data[key].has("total"):
				if data[key]["total"] == current_xp:
					level = int(key)
					break
	else:
		print("Error: Unable to open XP data file")

func save_player_data():
	var file = FileAccess.open(XP_DATABASE, FileAccess.WRITE)
	if file:
		var data = XP_Table_Data.duplicate(true)
		data[str(level)]["total"] = current_xp
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		print("Error: Unable to save XP data")

func _exit_tree():
	save_player_data()

func parse_json(json_text):
	return JSON.parse_string(json_text)
