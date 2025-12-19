class_name GameStatsClass
extends Node

# Lifetime stats
var total_clicks: int = 0
var total_playtime: float = 0.0
var total_earned: Dictionary = {}

# Session stats
var session_clicks: int = 0
var session_start: float = 0.0

# Action counters (action_id -> count)
var actions_performed: Dictionary = {}

# Peak records (ResourceType -> highest amount)
var peak_resources: Dictionary = {}

func _ready() -> void:
	session_start = Time.get_unix_time_from_system()
	_init_totals()
	SaveManager.register(self)

func _init_totals() -> void:
	for type in ResourceTypes.ResourceType.values():
		if not total_earned.has(type):
			total_earned[type] = 0.0
		if not peak_resources.has(type):
			peak_resources[type] = 0.0

func record_click() -> void:
	total_clicks += 1
	session_clicks += 1

func record_action(action_id: String) -> void:
	actions_performed[action_id] = actions_performed.get(action_id, 0) + 1

func record_earned(type: int, amount: float) -> void:
	if amount > 0:
		total_earned[type] = total_earned.get(type, 0.0) + amount

func update_peak(type: int, current_amount: float) -> void:
	if current_amount > peak_resources.get(type, 0.0):
		peak_resources[type] = current_amount

func get_playtime() -> float:
	return total_playtime + (Time.get_unix_time_from_system() - session_start)

func get_session_time() -> float:
	return Time.get_unix_time_from_system() - session_start

func get_total_earned(type: int) -> float:
	return total_earned.get(type, 0.0)

func get_peak(type: int) -> float:
	return peak_resources.get(type, 0.0)

func get_action_count(action_id: String) -> int:
	return actions_performed.get(action_id, 0)

# Save/Load interface
func get_save_data() -> Dictionary:
	# Update playtime before saving
	total_playtime = get_playtime()
	session_start = Time.get_unix_time_from_system()

	var earned_data := {}
	for type in total_earned.keys():
		earned_data[str(type)] = total_earned[type]

	var peak_data := {}
	for type in peak_resources.keys():
		peak_data[str(type)] = peak_resources[type]

	return {
		"total_clicks": total_clicks,
		"total_playtime": total_playtime,
		"total_earned": earned_data,
		"actions_performed": actions_performed,
		"peak_resources": peak_data
	}

func load_save_data(data: Dictionary) -> void:
	if data.has("total_clicks"):
		total_clicks = int(data["total_clicks"])

	if data.has("total_playtime"):
		total_playtime = float(data["total_playtime"])

	if data.has("total_earned"):
		for type_str in data["total_earned"].keys():
			var type := int(type_str)
			total_earned[type] = float(data["total_earned"][type_str])

	if data.has("actions_performed"):
		for action_id in data["actions_performed"].keys():
			actions_performed[action_id] = int(data["actions_performed"][action_id])

	if data.has("peak_resources"):
		for type_str in data["peak_resources"].keys():
			var type := int(type_str)
			peak_resources[type] = float(data["peak_resources"][type_str])

	# Reset session after loading
	session_start = Time.get_unix_time_from_system()
	session_clicks = 0

func reset() -> void:
	total_clicks = 0
	total_playtime = 0.0
	session_clicks = 0
	session_start = Time.get_unix_time_from_system()
	total_earned.clear()
	actions_performed.clear()
	peak_resources.clear()
	_init_totals()
