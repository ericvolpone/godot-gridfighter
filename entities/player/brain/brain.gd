class_name Brain extends Node

var move_direction: Vector3
var jump_strength: float = 0
var using_combat_action_1: bool = false
var using_combat_action_2: bool = false
var using_combat_action_3: bool = false
var using_combat_action_4: bool = false
var opening_in_game_menu: bool = false

enum BrainType {
	ZERO,
	KOTH_AI,
	PLAYER
}

func is_ai() -> bool:
	return self is not PlayerBrain

static func new_brain_from_type_with_deps(type: BrainType, koth_manager: KothManager) -> Brain:
	match type:
		BrainType.ZERO:
			return ZeroBrain.new();
		BrainType.KOTH_AI:
			return KothAIBrain.with_manager(koth_manager);
		BrainType.PLAYER:
			return PlayerBrain.new();
		_:
			return ZeroBrain.new();

func gather_movement_direction() -> void:
	push_error("Implement gather_movement_direction in child brain");

func gather_jump_strength() -> void:
	push_error("Implement gather_jump_strength in child brain");

func gather_use_combat_action_1() -> void:
	push_error("Implement gather_use_combat_action_1 in child brain");

func gather_use_combat_action_2() -> void:
	push_error("Implement gather_use_combat_action_2 in child brain");

func gather_use_combat_action_3() -> void:
	push_error("Implement gather_use_combat_action_3 in child brain");
	
func gather_use_combat_action_4() -> void:
	push_error("Implement gather_use_combat_action_4 in child brain");

func gather_opening_in_game_menu() -> void:
	push_error("Implement gather_opening_in_game_menu in child brain")
