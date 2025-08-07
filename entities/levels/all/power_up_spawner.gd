class_name PowerUpSpawner extends MultiplayerSpawner

# Power Up Scenes
@onready var power_up_speed_scene: PackedScene = preload("res://entities/objects/powerups/power_up_speed.tscn")
@onready var power_up_strength_scene: PackedScene = preload("res://entities/objects/powerups/power_up_strength.tscn")

@export var enabled_power_up_types: Array[PowerUp.Type] = []
@export var next_power_up_index: int = 0;
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Holds respawn points and if they are available for respawn
@export var spawn_point_by_availability: Dictionary[Node3D, bool]
@export var spawn_time: float = 10;
@export var are_power_ups_enabled: bool = false;
@onready var max_active_power_ups: int = spawn_point_by_availability.keys().size();

func _ready() -> void:
	call_deferred("_configure_power_up_spawner")

func start_cycle() -> void:
	if not are_power_ups_enabled:
		return

	if is_multiplayer_authority():
		if enabled_power_up_types.size() > 0:
			create_timer_for_powerup()

func create_timer_for_powerup() -> void:
	get_tree().create_timer(spawn_time).timeout.connect(func() -> void:
		var spawn_point: Node3D = _find_random_available_spawn_point();
		if spawn_point:
			next_power_up_index = rng.randi_range(0, enabled_power_up_types.size() - 1)
			spawn({"spawn_point" : spawn_point});
		create_timer_for_powerup()
		)

func _configure_power_up_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> PowerUp:
		# Needed to run client spawners before syncing of types happens...
		if enabled_power_up_types.size() == 0:
			return null
		var peer_id: int = get_multiplayer_authority()
		var power_up: PowerUp = get_scene_for_type(enabled_power_up_types[next_power_up_index]).instantiate();
		power_up.set_multiplayer_authority(peer_id)
		call_deferred("_spawn_power_up_at_point", power_up, spawn_data["spawn_point"])
		return power_up

func _spawn_power_up_at_point(power_up: PowerUp, spawn_point: Node3D) -> void:
	spawn_point_by_availability[spawn_point] = false
	power_up.global_position = spawn_point.global_position
	power_up.power_up_spawn_point = spawn_point
	power_up.signal_power_up_applied.connect(func(_spawn_point: Node3D) -> void:
		print("Spawn point now available");
		spawn_point_by_availability[_spawn_point] = true;
		)

func _find_random_available_spawn_point() -> Node3D:
	var spawn_points: Array[Node3D] = spawn_point_by_availability.keys();
	spawn_points.shuffle()
	
	for spawn_point: Node3D in spawn_points:
		if spawn_point_by_availability[spawn_point]:
			return spawn_point;
	
	return null

func get_scene_for_type(type: PowerUp.Type) -> PackedScene:
	match type:
		PowerUp.Type.SPEED:
			return power_up_speed_scene;
		PowerUp.Type.STRENGTH:
			return power_up_strength_scene
		_:
			push_error("Unmapped Power Up Type: " + str(type))
			return null
