class_name BlizzardAction extends CombatAction

const BLIZZARD_TTL: float = 4
var cast_tick: int = -1

@onready var aoe_spawner: AOESpawner = hero.player.level.aoe_spawner;

func _ready() -> void:
	is_action_state = true
	action_state_string = "UppercutState"
	action_animation = Player.ANIM_UPPERCUT
	NetworkTime.on_tick.connect(_tick)

func get_action_image_path() -> String:
	return "res://models/sprites/hud/actions/generated/BlizzardActionIcon.png";

# Interface Methods
func get_cd_time() -> float:
	return 5.0;

func execute_child(tick: int) -> void:
	cast_tick = tick + NetworkTime.seconds_to_ticks(.5)

func _tick(delta: float, tick: int) -> void:
	if cast_tick != -1 and NetworkTime.tick == cast_tick:
		cast_tick = -1
		spawn_blizzard()

func spawn_blizzard() -> void:
	var spawn_direction: Vector3 = hero.player.get_facing_direction()
	aoe_spawner.spawn({
		"owner_peer_id" : hero.player.player_id,
		"aoe_type" : AOE.Type.BLIZZARD,
		"aoe_ttl" : BLIZZARD_TTL,
		"spawn_position" : hero.global_position + (spawn_direction * 3),
		"spawn_direction" : spawn_direction
	});

func is_usable_child() -> bool:
	return true;
