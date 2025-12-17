extends Node
class_name ProductionSystem

@export var rules: Array[ProductionRule] = []

var _accumulators: Dictionary = {}
var _last_seen_amount: Dictionary = {}

var _modifiers: Dictionary = {}

var _game_state: GameState

func initialize(game_state: GameState) -> void:
	_game_state = game_state
	_game_state.resource_changed.connect(_on_resource_changed)
	_game_state.resource_changed.connect(func(type, _value):
		if type == ResourceTypes.ResourceType.BUGS:
			update_bug_penalties()
	)
		
	for rule in rules:
		_accumulators[rule.id] = 0.0
		_last_seen_amount[rule.id] = _game_state.get_resource(rule.source)
	
func _on_resource_changed(
	type: ResourceTypes.ResourceType,
	_new_value: float
) -> void:
	for rule in rules:
		if not rule.enabled:
			continue
		if rule.source != type:
			continue

		_process_rule(rule)
		
func _process_rule(rule: ProductionRule) -> void:
	
	var available := _game_state.get_resource(rule.source)
	var last: float = _last_seen_amount.get(rule.id, 0.0)
	
	var delta := available - last
	_last_seen_amount[rule.id] = available

	match rule.trigger:
		ProductionRule.TriggerType.ON_GAIN:
			if delta <= 0.0:
				return
			_process_amount(rule, delta)

		ProductionRule.TriggerType.ON_CONSUME:
			if delta >= 0.0:
				return
			_process_amount(rule, -delta)
			
	
func _process_amount(rule: ProductionRule, amount: float) -> void:
	var multiplier := _get_rule_multiplier(rule)
	if multiplier <= 0.0:
		return

	var produced := amount * multiplier
	if produced <= 0.0:
		return

	var acc: float = _accumulators[rule.id]
	acc += produced

	var times := int(acc / rule.source_amount)
	if times <= 0:
		_accumulators[rule.id] = acc
		return

	_accumulators[rule.id] = acc - times * rule.source_amount
	_game_state.add_resource(
		rule.target,
		times * rule.target_amount
	)

func add_modifier(modifier: RuleModifier) -> void:
	if not _modifiers.has(modifier.rule_id):
		_modifiers[modifier.rule_id] = []
	_modifiers[modifier.rule_id].append(modifier)

func _get_rule_multiplier(rule: ProductionRule) -> float:
	var result := 1.0
	if not _modifiers.has(rule.id):
		return result

	for modifier in _modifiers[rule.id]:
		result *= modifier.multiplier

	return max(result, 0.0)

func update_bug_penalties() -> void:
	var bugs := _game_state.get_resource(ResourceTypes.ResourceType.BUGS)

	# Remove previous BugPenaltyModifiers first
	for rule in rules:
		if _modifiers.has(rule.id):
			_modifiers[rule.id] = _modifiers[rule.id].filter(func(m):
				return m is not BugPenaltyModifier
			)

		# Apply new Bug penalty if there are bugs
		if bugs > 0:
			var stacks := int(bugs / 10) # or use BugPenaltyModifier.bugs_per_stack
			var penalty := 1.0 - stacks * 0.05
			penalty = max(penalty, 0.1) # never go below 10% efficiency

			var mod := BugPenaltyModifier.new()
			mod.rule_id = rule.id
			mod.multiplier = penalty

			add_modifier(mod)
