class_name AOESpawner extends Node

#region Var:Abilities
var storm_scene: PackedScene = preload("res://entities/objects/bolty/lightning_storm.tscn")
var gust_scene: PackedScene = preload("res://entities/objects/bolty/gust.tscn")
var blizzard_scene: PackedScene = preload("res://entities/objects/slushy/blizzard.tscn")
var harden_scene: PackedScene = preload("res://entities/player/heroes/rocky/actions/harden.tscn")
var thorn_trap_scene: PackedScene = preload("res://entities/player/heroes/woody/action/thorn_trap/thorn_trap.tscn")
var bush_scene: PackedScene = preload("res://entities/objects/map/environment/bush.tscn")
var ring_of_fire_scene: PackedScene = preload("res://entities/objects/torchy/ring_of_fire.tscn")
#endregion

func spawn(spawn_data: Dictionary) -> AOE:
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
			AOE.Type.RING_OF_FIRE:
				aoe = ring_of_fire_scene.instantiate()
			_:
				pass
		
		if aoe:
			aoe.spawn_data = spawn_data
		add_child(aoe)
		return aoe;
