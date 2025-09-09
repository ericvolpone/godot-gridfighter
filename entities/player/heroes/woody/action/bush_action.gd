class_name BushAction extends CombatAction

const BUSH_TTL: float = 10;

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	if not is_multiplayer_authority(): return;

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/RootWallActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	if not is_multiplayer_authority(): return;
	
	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn_aoe.rpc({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.BUSH,
		"aoe_ttl" : BUSH_TTL,
		"spawn_position" : global_position + (spawn_direction),
		"spawn_direction" : spawn_direction
	});

func is_usable_child() -> bool:
	return true;
