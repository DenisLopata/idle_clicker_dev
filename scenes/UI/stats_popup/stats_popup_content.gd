extends VBoxContainer
class_name StatsPopupContent

var _update_timer: float = 0.0
var _labels: Dictionary = {}

func _ready() -> void:
	_create_sections()
	_update_display()

func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= 1.0:
		_update_timer = 0.0
		_update_display()

func _create_sections() -> void:
	# Session Stats
	_add_section_header("Session")
	_add_stat_row("session_time", "Session Time")
	_add_stat_row("session_clicks", "Session Clicks")

	_add_separator()

	# Lifetime Stats
	_add_section_header("Lifetime")
	_add_stat_row("total_clicks", "Total Clicks")
	_add_stat_row("total_playtime", "Total Playtime")

	_add_separator()

	# Action Counters
	_add_section_header("Actions Performed")
	_add_stat_row("action_loc", "Code Written")
	_add_stat_row("action_bug", "Bugs Fixed")
	_add_stat_row("action_commit", "Commits Made")
	_add_stat_row("action_ship", "Features Shipped")

	_add_separator()

	# Peak Records
	_add_section_header("Peak Records")
	for type in ResourceTypes.ResourceType.values():
		var type_name := ResourceTypes.get_type_name(type)
		_add_stat_row("peak_%d" % type, "Peak %s" % type_name, ResourceTypes.get_color(type))

	_add_separator()

	# Total Earned
	_add_section_header("Total Earned")
	for type in ResourceTypes.ResourceType.values():
		var type_name := ResourceTypes.get_type_name(type)
		_add_stat_row("earned_%d" % type, type_name, ResourceTypes.get_color(type))

func _add_section_header(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.7))
	add_child(label)

func _add_separator() -> void:
	var sep := HSeparator.new()
	add_child(sep)

func _add_stat_row(id: String, label_text: String, color: Color = Color.WHITE) -> void:
	var row := HBoxContainer.new()

	var name_label := Label.new()
	name_label.text = label_text + ":"
	name_label.custom_minimum_size.x = 120
	name_label.modulate = color
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.text = "0"
	value_label.modulate = color
	row.add_child(value_label)

	add_child(row)
	_labels[id] = value_label

func _update_display() -> void:
	# Session stats
	_labels["session_time"].text = _format_time(GameStats.get_session_time())
	_labels["session_clicks"].text = NumberFormat.format(GameStats.session_clicks)

	# Lifetime stats
	_labels["total_clicks"].text = NumberFormat.format(GameStats.total_clicks)
	_labels["total_playtime"].text = _format_time(GameStats.get_playtime())

	# Action counters
	_labels["action_loc"].text = NumberFormat.format(GameStats.get_action_count("loc_button"))
	_labels["action_bug"].text = NumberFormat.format(GameStats.get_action_count("bug_button"))
	_labels["action_commit"].text = NumberFormat.format(GameStats.get_action_count("commit_button"))
	_labels["action_ship"].text = NumberFormat.format(GameStats.get_action_count("ship_button"))

	# Peak records
	for type in ResourceTypes.ResourceType.values():
		_labels["peak_%d" % type].text = NumberFormat.format(GameStats.get_peak(type))

	# Total earned
	for type in ResourceTypes.ResourceType.values():
		_labels["earned_%d" % type].text = NumberFormat.format(GameStats.get_total_earned(type))

func _format_time(seconds: float) -> String:
	var total_seconds := int(seconds)
	var days := floori(total_seconds / 86400.0)
	var hours := floori((total_seconds % 86400) / 3600.0)
	var minutes := floori((total_seconds % 3600) / 60.0)
	var secs := total_seconds % 60

	if days > 0:
		return "%dd %dh" % [days, hours]
	elif hours > 0:
		return "%dh %dm" % [hours, minutes]
	else:
		return "%dm %ds" % [minutes, secs]
