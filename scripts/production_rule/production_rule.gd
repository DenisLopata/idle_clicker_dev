class_name ProductionRule
extends Resource

enum TriggerType {
	ON_GAIN,
	ON_CONSUME
}


@export var id: String

@export var source: ResourceTypes.ResourceType
@export var target: ResourceTypes.ResourceType

@export var source_amount: float = 1.0
@export var target_amount: float = 1.0

@export var enabled: bool = true

@export var trigger: TriggerType = TriggerType.ON_GAIN
