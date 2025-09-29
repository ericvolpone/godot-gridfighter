class_name Projectile extends ShapeCast3D

@export var impact_scene: PackedScene;

enum Type {
	ROCK,
	ICE_BOLT,
	FIREBALL
}

var spawn_data: Dictionary

var direction: Vector3 = Vector3.ZERO
var speed: float = 0;
var force: float = 0
var owner_peer_id: int = -1
var projectile_ttl: float = 5 #Default, overridable via spawn data
var alive_time: float = 0;
var has_collided: bool = false;
var is_first_tick: bool = true


func _ready() -> void:
	_initialize_from_spawn_data()
	NetworkTime.on_tick.connect(_tick);
	NetworkTime.after_tick_loop.connect(_after_loop);
	VLogger.log_mp("Created Projectile")

func _tick(delta: float, _tick_id: int) -> void:
	if is_queued_for_deletion(): return
	alive_time += delta

	var distance: float = speed * delta
	var motion: Vector3 = direction * distance
	target_position = global_position + motion
	
	force_shapecast_update()
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state 
	var query := PhysicsShapeQueryParameters3D.new()
	query.motion = motion
	query.shape = shape
	query.transform = global_transform
	
	var hit_interval := space_state.cast_motion(query)
	if hit_interval[0] != 1.0 or hit_interval[1] != 1.0 and not is_first_tick:
		# Move to collision
		position += motion * hit_interval[1]
		collide()
	else:
		position += motion

	is_first_tick = false

	if alive_time >= projectile_ttl:
		clear_self()

func _after_loop() -> void:
	if has_collided:
		queue_free();

func _initialize_from_spawn_data() -> void:
	global_position = spawn_data["spawn_location"]
	direction = spawn_data["direction"]
	speed = spawn_data.get("speed", 0)
	owner_peer_id = spawn_data["owner_peer_id"]
	if spawn_data.has("projectile_ttl"):
		projectile_ttl = spawn_data["projectile_ttl"]
	look_at(global_position - direction)

func collide() -> void:
	var impact: ProjectileImpact = impact_scene.instantiate();
	get_tree().root.add_child(impact)
	impact.global_position = global_position
	impact.look_at(direction)
	clear_self()

func clear_self() -> void:
	NetworkTime.on_tick.disconnect(_tick)
	queue_free();
