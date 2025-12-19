class_name FloatingTextSpawner
extends RefCounted

const FLOATING_TEXT_SCENE = preload("res://scenes/components/floating_text/floating_text.tscn")

static func spawn(amount: float, type: ResourceTypes.ResourceType, spawn_position: Vector2) -> void:
	var floating := FLOATING_TEXT_SCENE.instantiate() as FloatingText

	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(floating)

	var prefix := "+" if amount > 0 else ""
	var type_name := ResourceTypes.get_type_name(type)
	var display_text := "%s%s %s" % [prefix, NumberFormat.format(absf(amount)), type_name]
	var color := ResourceTypes.get_color(type)

	floating.setup(display_text, color, spawn_position)
