class_name ProjectileSpawner extends MultiplayerSpawner

var rock_scene: PackedScene = preload("res://entities/objects/projectiles/rock/rock.tscn")
var ice_bolt_scene: PackedScene = preload("res://entities/objects/projectiles/ice_bolt/ice_bolt.tscn")


@onready var level: Level = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_projectile_spawner")

func _configure_projectile_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> Rock:
		var projectile_type: Projectile.Type = spawn_data["projectile_type"]
		var projectile: Projectile;
		match projectile_type:
			Projectile.Type.ROCK:
				projectile = rock_scene.instantiate();
			Projectile.Type.ICE_BOLT:
				projectile = ice_bolt_scene.instantiate();
			_:
				push_error("Undefined Projectile Type: ", projectile_type);
		if projectile:
			projectile.call_deferred("initialize_from_spawn_data", spawn_data)
		return projectile

@rpc("any_peer", "call_local", "reliable")
func spawn_projectile(spawn_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	spawn(spawn_data)
