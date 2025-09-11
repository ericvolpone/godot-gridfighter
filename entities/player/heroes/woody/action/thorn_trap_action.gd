class_name ThornTrapAction extends CombatAction

const THORN_TRAP_TTL: float = 20
@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	is_action_state = true
	action_state_string = "KneelState"

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/ThornTrapActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child() -> void:
	if not is_multiplayer_authority(): return;

func _kneel_frame_enact() -> void:
	if not is_multiplayer_authority(): return;
	
	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn_aoe.rpc({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.THORN_TRAP,
		"aoe_ttl" : THORN_TRAP_TTL,
		"spawn_position" : global_position + (spawn_direction),
		"spawn_direction" : spawn_direction
	});

func is_usable_child() -> bool:
	return hero.player.is_on_floor();
