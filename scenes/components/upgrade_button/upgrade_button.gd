extends Button
class_name UpgradeButton

signal upgrade_purchased(id: String)

@export var upgrade: UpgradeEntry

# Strongly typed cost
@export var cost_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.MONEY

@onready var title_label = $TitleLabel
@onready var cost_label = $CostLabel
@onready var desc_label = $DescriptionLabel

func _ready() -> void:
	pressed.connect(_on_pressed)
	GameState.resource_changed.connect(_on_resource_changed)
	_update_visual_state()


func _on_pressed() -> void:
	if upgrade.purchased:
		return

	var available := GameState.get_resource(cost_type)
	if available >= upgrade.cost:
		GameState.add_resource(cost_type, -upgrade.cost)
		upgrade.purchased = true
		upgrade_purchased.emit(upgrade.id)
		_update_visual_state()


func _on_resource_changed(type: int, _new_value: float) -> void:
	# Only react if the resource affects affordability
	if type == cost_type:
		_update_visual_state()


func _update_visual_state() -> void:
	title_label.text = upgrade.title
	desc_label.text = upgrade.description

	if upgrade.purchased:
		cost_label.text = "Purchased"
		disabled = true
		modulate = Color(0.8, 1.0, 0.8)
		return

	# Update cost label
	cost_label.text = "Cost: %d" % upgrade.cost

	# Visual feedback for affordability
	var available := GameState.get_resource(cost_type)
	if available >= upgrade.cost:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(0.6, 0.6, 0.6)
