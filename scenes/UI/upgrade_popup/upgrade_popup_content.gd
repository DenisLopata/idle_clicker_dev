extends VBoxContainer
class_name UpgradePopupContent

signal upgrade_purchased(id: String)

var upgrade_button_scene = preload("res://scenes/components/upgrade_button/upgrade_button.tscn")

func setup(upgrades: Array) -> void:
	for upg in upgrades:
		var btn = upgrade_button_scene.instantiate()
		btn.upgrade = upg
		btn.upgrade_purchased.connect(_on_upgrade_purchased)
		add_child(btn)

func _on_upgrade_purchased(id: String) -> void:
	upgrade_purchased.emit(id)
