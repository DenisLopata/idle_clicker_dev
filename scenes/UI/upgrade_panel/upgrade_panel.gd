class_name UpgradePanel
extends VBoxContainer

signal upgrade_purchased(id: String)

@onready var upgrade_list = $UpgradeList

const UPGRADE_BUTTON_SCENE = preload("uid://bv4ate2xmc7cp") #res://scenes/components/upgrade_button/upgrade_button.gd

func add_upgrade(upgrade: UpgradeEntry) -> void:
	var btn: UpgradeButton = UPGRADE_BUTTON_SCENE.instantiate()
	btn.upgrade = upgrade
	btn.upgrade_purchased.connect(_on_upgrade_purchased)
	upgrade_list.add_child(btn)


func _on_upgrade_purchased(id: String) -> void:
	upgrade_purchased.emit(id)
