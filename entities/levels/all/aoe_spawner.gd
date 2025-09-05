class_name AOESpawner extends MultiplayerSpawner

#region Var:Abilities
var storm_scene: PackedScene = preload("res://entities/objects/bolty/LightningStorm.tscn")
var gust_scene: PackedScene = preload("res://entities/objects/bolty/gust.tscn")
var blizzard_scene: PackedScene = preload("res://entities/objects/slushy/blizzard.tscn")
var harden_scene: PackedScene = preload("res://entities/player/heroes/rocky/actions/harden.tscn")
#endregion

#region Var:Effects
var shocked_effect: PackedScene = preload("res://entities/effects/statuses/shocked_effect.tscn")
#endregion


@onready var level: Level = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_aoe_spawner")

func _configure_aoe_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> AOE:
		var aoe_type: AOE.Type = spawn_data["aoe_type"]
		match aoe_type:
			AOE.Type.STORM:
				var storm: LightningStorm = storm_scene.instantiate()
				storm.call_deferred("_initialize_from_spawn_data", spawn_data)
				return storm;
			AOE.Type.GUST:
				var gust: Gust = gust_scene.instantiate()
				gust.gust_direction = spawn_data["spawn_direction"]
				gust.call_deferred("_initialize_from_spawn_data", spawn_data)
				return gust
			AOE.Type.BLIZZARD:
				var blizzard: Blizzard = blizzard_scene.instantiate()
				blizzard.call_deferred("_initialize_from_spawn_data", spawn_data)
				return blizzard
			AOE.Type.HARDEN:
				var harden: Harden = harden_scene.instantiate()
				harden.call_deferred("_initialize_from_spawn_data", spawn_data)
				return harden
			_:
				return null

@rpc("any_peer", "call_local", "reliable")
func spawn_aoe(spawn_data: Dictionary) -> AOE:
	if not multiplayer.is_server():
		return null

	return spawn(spawn_data)
