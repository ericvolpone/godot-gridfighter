class_name KothAIBrain extends Brain

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var koth_manager: KothManager;

static func with_manager(_koth_manager: KothManager) -> KothAIBrain:
	var brain: KothAIBrain = KothAIBrain.new();
	brain.koth_manager = _koth_manager
	return brain

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
	
	gather_movement_direction()

func _gather() -> void:
	if not is_multiplayer_authority(): return

	gather_movement_direction()
	gather_jump()
	gather_use_combat_action_1()
	gather_use_combat_action_2()
	gather_use_combat_action_3()
	gather_use_combat_action_4()
	gather_opening_in_game_menu()

func gather_movement_direction() -> void:
	var current_ring: KothRing = koth_manager.current_ring;
	if(current_ring == null):
		return;

	var to_direction: Vector3 = current_ring.global_position - get_parent().global_position
	to_direction.y = 0;
	
	if to_direction.length_squared() < 0.25:  # 0.5^2 to avoid sqrt
		return
	
	to_direction = to_direction.normalized();
	move_direction = to_direction;

func gather_jump() -> void:
	if 0 == rng.randi_range(0, 20):
		jump_strength = 1.0
	else:
		jump_strength = 0.0;

func gather_use_combat_action_1() -> void:
	if 0 == rng.randi_range(0, 100):
		using_combat_action_1 = true
	else:
		using_combat_action_1 = false;

func gather_use_combat_action_2() -> void:
	pass;
func gather_use_combat_action_3() -> void:
	pass;
func gather_use_combat_action_4() -> void:
	pass;
func gather_opening_in_game_menu() -> void:
	pass
