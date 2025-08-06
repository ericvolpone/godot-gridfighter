class_name PowerUpSpawner extends MultiplayerSpawner

@onready var power_up_speed_scene: PackedScene = preload("res://entities/objects/powerups/power_up_speed.tscn") 

# Holds respawn points and if they are available for respawn
@export var spawn_point_by_availability: Dictionary[Node3D, bool]
@export var spawn_time: float = 10;
@export var are_power_ups_enabled: bool = false;
@onready var max_active_power_ups: int = spawn_point_by_availability.keys().size();

var active_power_ups: Dictionary[PowerUp, bool] = {};

func _ready() -> void:
	call_deferred("_configure_power_up_spawner")

func start_cycle() -> void:
	if not are_power_ups_enabled:
		return

	if is_multiplayer_authority():
		create_timer_for_powerup()

func create_timer_for_powerup() -> void:
	get_tree().create_timer(spawn_time).timeout.connect(func() -> void:
		spawn({});
		create_timer_for_powerup()
		)

func _configure_power_up_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> PowerUp:
		var peer_id: int = get_multiplayer_authority()
		var power_up: PowerUp = power_up_speed_scene.instantiate();
		power_up.set_multiplayer_authority(peer_id)
		call_deferred("_spawn_power_up", power_up)
		return power_up

func _spawn_power_up(power_up: PowerUp) -> void:
	var spawn_points: Array[Node3D] = spawn_point_by_availability.keys();
	spawn_points.shuffle()
	
	for spawn_point: Node3D in spawn_points:
		if spawn_point_by_availability[spawn_point]:
			# Point is available, we can occupy it
			spawn_point_by_availability[spawn_point] = false
			power_up.global_position = spawn_point.global_position
			power_up.power_up_spawn_point = spawn_point
			power_up.signal_power_up_applied.connect(func(_spawn_point: Node3D) -> void:
				print("Spawn point now available");
				spawn_point_by_availability[_spawn_point] = true;
				)
			return
