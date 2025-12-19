class_name ResourceTypes
extends RefCounted

enum ResourceType {
	LOC,
	BUGS,
	FEATURES,
	MONEY,
	ENERGY,
	TECH_DEBT,
}

const COLORS: Dictionary = {
	ResourceType.LOC: Color("#7cd4fd"),
	ResourceType.BUGS: Color("#ffd166"),
	ResourceType.FEATURES: Color("#6edb8f"),
	ResourceType.MONEY: Color("#f4c430"),
	ResourceType.ENERGY: Color("#a78bfa"),
	ResourceType.TECH_DEBT: Color("#ff6b6b"),
}

static func get_color(type: ResourceType) -> Color:
	return COLORS.get(type, Color.WHITE)
