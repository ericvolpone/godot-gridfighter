class_name Hero extends Node3D

#region Signals
signal punch_frame;
signal cast_frame;
signal kneel_frame
signal uppercut_frame
#endregion

#region Variables
	#region Var:Definition
var definition: HeroDefinition
	#endregion
#endregion

# HUD
const HUD_PATH := "res://entities/ui/hud/ActionHUDContainer.tscn"


@onready var player: Player = get_parent().get_parent()
@onready var animator: AnimationPlayer = $AnimationPlayer;

# UI Variables
var action_hud_container: ActionHUDContainer

var combat_action_1: PunchAction = PunchAction.new();
var combat_action_2: BlockAction = BlockAction.new();
var combat_action_3: CombatAction;
var combat_action_4: CombatAction;

func _ready() -> void:
	name = definition.display_name

func init_combat_actions() -> void:
	combat_action_1.name = "PunchAction"
	combat_action_2.name = "BlockAction"
		# Configure punch
	_init_combat_actions()
	connect("punch_frame", combat_action_1.handle_animation_signal)
	# Configure block
		# Have children initialize any special combat actions
	add_child(combat_action_1)
	add_child(combat_action_2)
	add_child(combat_action_3)
	if combat_action_4: 
		add_child(combat_action_4)

	# Allow combat actions to mutate the player
	combat_action_1.mutate(player)
	combat_action_2.mutate(player)
	combat_action_3.mutate(player)
	combat_action_4.mutate(player)

	if player.brain.is_multiplayer_authority():
		# TODO It sucks that we couldnt figure out preload here
		var hud_scene: PackedScene = load(HUD_PATH)
		action_hud_container = hud_scene.instantiate()
		add_child(action_hud_container);
		action_hud_container.add_action(combat_action_1)
		action_hud_container.add_action(combat_action_2)
		action_hud_container.add_action(combat_action_3)
		if combat_action_4:
			action_hud_container.add_action(combat_action_4)

# Animation Signals
func _emit_punch_signal() -> void:
	emit_signal(punch_frame.get_name())
func _emit_cast_signal() -> void:
	emit_signal(cast_frame.get_name())
func _emit_kneel_signal() -> void:
	emit_signal(kneel_frame.get_name())
func _emit_uppercut_signal() -> void:
	emit_signal(uppercut_frame.get_name())

# Interface Methods
func _init_combat_actions() -> void:
	push_error("Must implement _init_combat_actions in child")
	return

# Helpers
func get_hero_id() -> int:
	return definition.hero_id

func get_starting_move_speed() -> float:
	return definition.starting_move_speed

func get_starting_strength() -> float:
	return definition.starting_strength
