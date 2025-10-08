@abstract
class_name CombatAction extends RewindableAction

const DEFAULT_CD: float = 5.0;
const GLOBAL_CD: float = 0.5;

var is_interuptable: bool = true;
var is_action_state: bool = false;
var action_state_string: StringName;
var action_animation: StringName;
var cd_available_tick: int = -1

@onready var hero: Hero = get_parent();

func is_on_cooldown(tick: int) -> bool:
	return tick < cd_available_tick;

func get_remaining_cooldown_time_in_secs(tick: int) -> int:
	var time_remaining: float = NetworkTime.ticks_to_seconds(cd_available_tick - tick);
	return ceil(time_remaining)

func is_usable(tick: int) -> bool:
	return 	hero.player.has_control() and \
		not is_on_cooldown(tick) and \
		tick >= hero.player.global_combat_cooldown_next_use_tick and \
		is_usable_child();

func execute(tick: int) -> void:
	cd_available_tick = tick + NetworkTime.seconds_to_ticks(get_cd_time());
	hero.player.global_combat_cooldown_next_use_tick = tick + NetworkTime.seconds_to_ticks(GLOBAL_CD);
	set_active(true)

# Interface Methods
func get_action_image_path() -> String:
	push_error("get_action_image_path not defined for action")
	return "res://models/sprites/hud/actions/punch.png";

func get_cd_time() -> float:
	return DEFAULT_CD

@abstract func can_move() -> bool;
@abstract func xz_multiplier() -> float;
@abstract func y_velocity_override() -> float;
@abstract func y_velocity_override_deceleration() ->bool;
@abstract func execute_child(tick: int) -> void;
@abstract func rewind() -> void;

func is_usable_child() -> bool:
	return true;

func handle_animation_signal() -> void:
	pass
