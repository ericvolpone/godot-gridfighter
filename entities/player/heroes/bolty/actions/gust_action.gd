class_name GustAction extends CombatAction

const Gust_TTL: float = 8

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	if not is_multiplayer_authority(): return;

	is_action_state = true;
	action_state_string = "CastState"

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/gust.png";

# Interface Methods
func get_cd_time() -> float:
	return 8.0;

func execute_child() -> void:
	pass

func is_usable_child() -> bool:
	return true;

func _cast_frame_enact() -> void:
	if not is_multiplayer_authority(): return;

	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn_aoe.rpc({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.GUST,
		"aoe_ttl" : Gust_TTL,
		"spawn_position" : global_position + (spawn_direction),
		"spawn_direction" : spawn_direction
	});
