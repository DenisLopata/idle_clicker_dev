class_name Milestone
extends Resource

@export var id: String
@export var reveal_node_path: String  # Path to node to reveal (relative to level root)
@export var required_resource: ResourceTypes.ResourceType
@export var required_amount: float = 0.0
