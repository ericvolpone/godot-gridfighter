class_name Hero extends Node3D

# Animation Data
signal punch_frame;

var definition: HeroDefinition

# HUD
const HUD_PATH := "res://entities/ui/hud/ActionHUDContainer.tscn"


@onready var player: Player = get_parent().get_parent()
@onready var animator: AnimationPlayer = $AnimationPlayer;

# UI Variables
var action_hud_container: ActionHUDContainer

var combat_action_1: PunchAction = PunchAction.new();
var combat_action_2: BlockAction = BlockAction.new();
var combat_action_3: CombatAction;

func init_combat_actions() -> void:
		# Configure punch
	_init_combat_actions()
	combat_action_1.set_multiplayer_authority(get_multiplayer_authority())
	connect("punch_frame", combat_action_1.handle_animation_signal)
	# Configure block
	combat_action_2.set_multiplayer_authority(get_multiplayer_authority())
	combat_action_3.set_multiplayer_authority(get_multiplayer_authority())
		# Have children initialize any special combat actions
	add_child(combat_action_1)
	add_child(combat_action_2)
	add_child(combat_action_3)
	
	if is_multiplayer_authority():
		# TODO It sucks that we couldnt figure out preload here
		var hud_scene: PackedScene = load(HUD_PATH)
		
		action_hud_container = hud_scene.instantiate()
		add_child(action_hud_container);
		action_hud_container.add_action(combat_action_1)
		action_hud_container.add_action(combat_action_2)
		action_hud_container.add_action(combat_action_3)

# Animation Signals
func emit_punch_signal() -> void:
	emit_signal("punch_frame")

# Interface Methods
func _init_combat_actions() -> void:
	push_error("Must implement _init_combat_actions in child")
	return

# Helpers
func get_hero_id() -> int:
	return definition.hero_id
