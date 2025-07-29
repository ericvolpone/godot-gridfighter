class_name KothAIBrain extends Brain

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var koth_level: AbstractKothLevel;

func _init(_koth_level: AbstractKothLevel) -> void:
	koth_level = _koth_level;

func get_movement_direction() -> Vector3:
	var current_ring: KothRing = koth_level.current_ring;
	if(current_ring == null):
		return Vector3.ZERO;

	var to_direction: Vector3 = current_ring.global_position - get_parent().global_position
	to_direction.y = 0;
	
	if to_direction.length_squared() < 0.25:  # 0.5^2 to avoid sqrt
		return Vector3.ZERO
	
	to_direction = to_direction.normalized();
	
	return to_direction;

func should_jump() -> bool:
	return 0 == rng.randi_range(0, 20);

func should_use_combat_action_1() -> bool:
	return 0 == rng.randi_range(0, 100);

func should_use_combat_action_2() -> bool:
	return false;

func should_use_combat_action_3() -> bool:
	return false;
