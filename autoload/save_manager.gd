extends Node
class_name SaveManagerClass

signal game_saved
signal game_loaded
signal offline_progress_calculated(elapsed_seconds: float)

const SAVE_PATH := "user://savegame.save"
const TIMESTAMP_KEY := "_timestamp"

@export var auto_save_interval: float = 30.0

var _saveables: Array[Node] = []
var _auto_save_timer: float = 0.0

func _ready() -> void:
	# Save when window loses focus (alt-tab, etc.)
	get_tree().root.focus_exited.connect(_on_focus_lost)

func _notification(what: int) -> void:
	# Save before game closes (works with auto_accept_quit = true)
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func _process(delta: float) -> void:
	_auto_save_timer += delta
	if _auto_save_timer >= auto_save_interval:
		_auto_save_timer = 0.0
		save_game()

func register(node: Node) -> void:
	if node not in _saveables:
		_saveables.append(node)

func unregister(node: Node) -> void:
	_saveables.erase(node)

func save_game() -> void:
	var save_data := {}

	# Save timestamp for offline progress
	save_data[TIMESTAMP_KEY] = Time.get_unix_time_from_system()

	for node in _saveables:
		if node.has_method("get_save_data"):
			var node_data = node.get_save_data()
			save_data[node.name] = node_data

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		game_saved.emit()
		print("[SaveManager] Game saved")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file found")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		printerr("[SaveManager] Failed to open save file")
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		printerr("[SaveManager] Failed to parse save file")
		return false

	var save_data: Dictionary = json.data

	# Load node data first
	for node in _saveables:
		if node.has_method("load_save_data") and save_data.has(node.name):
			node.load_save_data(save_data[node.name])

	# Calculate offline progress
	if save_data.has(TIMESTAMP_KEY):
		var saved_time: float = save_data[TIMESTAMP_KEY]
		var current_time := Time.get_unix_time_from_system()
		var elapsed_seconds := current_time - saved_time

		if elapsed_seconds > 0:
			print("[SaveManager] Offline for %.1f seconds" % elapsed_seconds)
			offline_progress_calculated.emit(elapsed_seconds)

			# Call apply_offline_progress on nodes that support it
			for node in _saveables:
				if node.has_method("apply_offline_progress"):
					node.apply_offline_progress(elapsed_seconds)

	game_loaded.emit()
	print("[SaveManager] Game loaded")
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveManager] Save deleted")

func _on_focus_lost() -> void:
	save_game()
