class_name AOESpawner extends MultiplayerSpawner

#region Var:Abilities
var storm_scene: PackedScene = preload("res://entities/objects/bolty/lightning_storm.tscn")
var gust_scene: PackedScene = preload("res://entities/objects/bolty/gust.tscn")
var blizzard_scene: PackedScene = preload("res://entities/objects/slushy/blizzard.tscn")
var harden_scene: PackedScene = preload("res://entities/player/heroes/rocky/actions/harden.tscn")
var thorn_trap_scene: PackedScene = preload("res://entities/player/heroes/woody/action/thorn_trap/thorn_trap.tscn")
var bush_scene: PackedScene = preload("res://entities/objects/map/environment/bush.tscn")
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
		var aoe: AOE;
		match aoe_type:
			AOE.Type.STORM:
				aoe = storm_scene.instantiate()
			AOE.Type.GUST:
				aoe = gust_scene.instantiate()
				aoe.gust_direction = spawn_data["spawn_direction"]
			AOE.Type.BLIZZARD:
				aoe = blizzard_scene.instantiate()
			AOE.Type.HARDEN:
				aoe = harden_scene.instantiate()
			AOE.Type.THORN_TRAP:
				aoe = thorn_trap_scene.instantiate()
			AOE.Type.BUSH:
				aoe = bush_scene.instantiate()
				aoe.is_growing = true
			_:
				pass
		
		if aoe:
			aoe.spawn_data = spawn_data
		return aoe;

@rpc("any_peer", "call_local", "reliable")
func spawn_aoe(spawn_data: Dictionary) -> AOE:
	if not multiplayer.is_server():
		return null

	return spawn(spawn_data)
