class_name PlayerBrain extends Brain

# Called when the node enters the scene tree for the first time.
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
	if not is_multiplayer_authority(): return;
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction: Vector3 = (get_parent().transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_direction = direction;

func gather_jump() -> void:
	if not is_multiplayer_authority(): return;
	
	jump_strength = Input.get_action_strength("jump")

func gather_use_combat_action_1() -> void:
	if not is_multiplayer_authority(): return;
	
	using_combat_action_1 = Input.get_action_strength("combat_1") > 0.0

func gather_use_combat_action_2() -> void:
	if not is_multiplayer_authority(): return;
	
	using_combat_action_2 = Input.get_action_strength("combat_2") > 0.0

func gather_use_combat_action_3() -> void:
	if not is_multiplayer_authority(): return;
	
	using_combat_action_3 = Input.get_action_strength("combat_3") > 0.0

func gather_use_combat_action_4() -> void:
	if not is_multiplayer_authority(): return;
	
	using_combat_action_4 = Input.get_action_strength("combat_4") > 0.0

func gather_opening_in_game_menu() -> void:
	if not is_multiplayer_authority(): return

	opening_in_game_menu = Input.get_action_strength("menu_open") > 0.0
