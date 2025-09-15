class_name ProjectileSpawner extends Node

var rock_scene: PackedScene = preload("res://entities/objects/projectiles/rock/rock.tscn")
var ice_bolt_scene: PackedScene = preload("res://entities/objects/projectiles/ice_bolt/ice_bolt.tscn")
var fireball_scene: PackedScene = preload("res://entities/objects/projectiles/fireball/fireball.tscn")


@onready var level: Level = get_parent();


func spawn(spawn_data: Dictionary) -> Projectile:
	var projectile_type: Projectile.Type = spawn_data["projectile_type"]
	var projectile: Projectile;
	match projectile_type:
		Projectile.Type.ROCK:
			projectile = rock_scene.instantiate();
		Projectile.Type.ICE_BOLT:
			projectile = ice_bolt_scene.instantiate();
		Projectile.Type.FIREBALL:
			projectile = fireball_scene.instantiate();
		_:
			push_error("Undefined Projectile Type: ", projectile_type);
	if projectile:
		projectile.spawn_data = spawn_data
		self.add_child(projectile)
		projectile._initialize_from_spawn_data()

	return projectile
