extends VBoxContainer
class_name StatsPanel

@onready var clicks_value: Label = $ClicksRow/Value
@onready var playtime_value: Label = $PlaytimeRow/Value
@onready var earned_container: VBoxContainer = $EarnedContainer

var _earned_labels: Dictionary = {}  # ResourceType -> Label
var _update_timer: float = 0.0

func _ready() -> void:
	_create_earned_rows()
	_update_display()

func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= 1.0:
		_update_timer = 0.0
		_update_display()

func _create_earned_rows() -> void:
	for type in ResourceTypes.ResourceType.values():
		var row := HBoxContainer.new()
		row.name = "Earned_%s" % ResourceTypes.get_type_name(type)

		var name_label := Label.new()
		name_label.text = "%s:" % ResourceTypes.get_type_name(type)
		name_label.custom_minimum_size.x = 80
		name_label.modulate = ResourceTypes.get_color(type)
		row.add_child(name_label)

		var value_label := Label.new()
		value_label.text = "0"
		value_label.modulate = ResourceTypes.get_color(type)
		row.add_child(value_label)

		earned_container.add_child(row)
		_earned_labels[type] = value_label

func _update_display() -> void:
	clicks_value.text = NumberFormat.format(GameStats.total_clicks)
	playtime_value.text = _format_time(GameStats.get_playtime())

	for type in _earned_labels.keys():
		_earned_labels[type].text = NumberFormat.format(GameStats.get_total_earned(type))

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
