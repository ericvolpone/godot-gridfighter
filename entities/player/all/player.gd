class_name Player extends CharacterBody3D
#region Variables
	#region Var:Animation
const ANIM_IDLE: StringName = "master_animations/Idle"
const ANIM_RUN: StringName = "master_animations/Run"
const ANIM_JUMP: StringName = "master_animations/Jump"
const ANIM_FALL: StringName = "master_animations/Fall"
const ANIM_PUNCH: StringName = "master_animations/Punch"
const ANIM_BLOCK: StringName = "master_animations/Block"
const ANIM_SHOUT: StringName = "master_animations/Shout"
const ANIM_CAST: StringName = "master_animations/Cast"

var animator: AnimationPlayer;
	#endregion
	#region Var:HeroDefinitions
const BOLTY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/bolty/bolty.tres") as HeroDefinition
const BOLTY_HERO_ID: int = BOLTY_HERO_DEF.hero_id;
const ROCKY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/rocky/rocky.tres") as HeroDefinition
const ROCKY_HERO_ID: int = ROCKY_HERO_DEF.hero_id;
const SLUSHY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/slushy/slushy.tres") as HeroDefinition
const SLUSHY_HERO_ID: int = SLUSHY_HERO_DEF.hero_id;
const TORCHY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/torchy/torchy.tres") as HeroDefinition
const TORCHY_HERO_ID: int = TORCHY_HERO_DEF.hero_id;
const WOODY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/woody/woody.tres") as HeroDefinition
const WOODY_HERO_ID: int = WOODY_HERO_DEF.hero_id;
const HERO_DB: Dictionary[int, HeroDefinition] = {
	BOLTY_HERO_ID : BOLTY_HERO_DEF,
	ROCKY_HERO_ID : ROCKY_HERO_DEF,
	SLUSHY_HERO_ID : SLUSHY_HERO_DEF,
	TORCHY_HERO_ID : TORCHY_HERO_DEF,
	WOODY_HERO_ID : WOODY_HERO_DEF
}
	#endregion
	#region Var:PlayerBaseAttributes
var player_id: String;
var player_name: String;
@onready var brain: Brain = $Brain;
	#endregion
	#region Var:TreeNodes
@onready var player_spawner: PlayerSpawner = get_parent() # TODO Not really needed
@onready var level: Level = player_spawner.get_parent(); # TODO Probably just signal this up
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
@onready var state_machine: RewindableStateMachine = $RewindableStateMachine
@onready var ring_indicator: CSGCylinder3D = $RingIndicator
#endregion
	#region Var:Hero
@onready var hero_socket: Node3D = $HeroSocket
var hero: Hero;
# Maybe move "change hero" into the set function, exposing it is confusing
# need this for multiplayer though
var chosen_hero_id: int = 0;
## current_hero_id is used to change the hero.  It is synchronized in the RBS so call this instead of _change_hero
@export var current_hero_id: int = -1: set = _change_hero;
	#endregion
	#region Var:Menu
# TODO Make this default in scene and disable if brain not multiplayer authority (have a task)
var is_in_menu: bool = false;
var _menu_tick: int = -1;
@onready var in_game_menu: InGameMenu = load("res://entities/menu/in_game_menu.tscn").instantiate();
	#endregion
	#region Var:PlayerStats
		#region Var:PlayerStats:Modifiers
var jump_pad_velocity: Vector3 = Vector3.ZERO
var colliding_aoes: Dictionary[AOE, bool] = {} # TODO Move this into rollback tick
var active_aoes: Dictionary[AOE, bool] = {}
var status_effects: Dictionary[StatusEffect, bool] = {}

		#endregion
		#region Var:PlayerStats:StatusEffects
var shock_value: float = 0;
var burn_value: float = 0;
var freeze_value: float = 0;

var is_cold: bool = false;
var cold_time_remaining: float = 0;
const COLD_SLOW_MODIFIER: float = .5;

var is_frozen: bool = false;
var freeze_time_remaining: float = 0;
const FREEZE_SLOW_MODIFIER: float = 1;

var is_rooted: bool = false;
var root_time_remaining: float = 0;
const ROOT_SLOW_MODIFIER: float = .9;
		#endregion
		#region Var:PlayerStats:Movement
var jump_velocity: float = 4.5;

var speed_boost_modifier: float = 0;
var max_player_speed: float = 10;
		#endregion
		#region Var:PlayerStats:Strength
var current_strength_modifier: float = 0;
var max_player_strength: float = 10;
		#endregion
	#endregion
	#region Var:State
@export var is_knocked: bool = false;
@export var is_standing_back_up: bool = false;
@export var is_blocking: bool = false;
@export var is_respawning: bool = false;
@onready var global_combat_cooldown_next_use: float = NetworkTime.time
var is_immune_to_knockback: bool = false;
	#endregion
	#region Var:Netfox
var respawn_tick: int = -1;
	#endregion
	#region Var:StateMachine
	
	#endregion
#endregion

#region Functions
	#region Func:Initialization
func _enter_tree() -> void:
	hero_socket = $HeroSocket

func _ready() -> void:
	# Set current_hero_id to chosen hero in case player is not spawned yet
	if current_hero_id == -1:
		current_hero_id = (chosen_hero_id)

	animator = hero.animator
	state_machine.state = &"RespawnState"
	state_machine.on_display_state_changed.connect(_on_display_state_changed)
	
	if not brain.is_ai() and brain.is_multiplayer_authority():
		# TODO Probably put this elsewhere?
		add_child(in_game_menu)
		in_game_menu.hide()
		ring_indicator.material_override = ring_indicator.material.duplicate()
		$RingIndicator.material_override.albedo_color = Color.DEEP_SKY_BLUE
	
	rollback_synchronizer.process_settings()

func add_brain(_brain: Brain, peer_id: int) -> void:
	if(_brain is PlayerBrain):
		_brain.set_multiplayer_authority(peer_id)
	brain = _brain;
	brain.name = "Brain"
	add_child(brain)

## Private function associated with the setter of "current_hero_id", use
## current_hero_id instead of this function to change hero
func _change_hero(hero_id: int) -> void:
	if current_hero_id == hero_id:
		return
	current_hero_id = hero_id

	var hero_definition: HeroDefinition = HERO_DB[hero_id];
	if hero:
		hero.queue_free()
	
	hero = hero_definition.instantiate()
	hero_socket.add_child(hero)
	hero = hero
	hero.call_deferred("init_combat_actions")
	animator = hero.animator

	#endregion
	#region Func:Menu
func process_menu_input(tick: int) -> void:
	# Some pause between menu inputs to make usable
	if tick < _menu_tick + 8:
		return

	if brain.opening_in_game_menu:
		_menu_tick = tick;
		if(is_in_menu):
			is_in_menu = false
			in_game_menu.hide()
		else:
			is_in_menu = true
			in_game_menu.show()
	#endregion
	#region Func:Native

func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	_force_update_is_on_floor()
	process_menu_input(tick);
	process_combat_actions_state();
	process_knock();
	process_external_modifiers(delta, tick)
	process_status_effects(delta);

	if global_position.y <= -8 and tick > respawn_tick and is_fresh:
		is_respawning = true
		respawn_tick = tick
	
	if tick == respawn_tick:
		level.handle_player_death(self)

	#endregion

	#region Movement
func movement_speed() -> float:
	var modifier: float = 0
	if is_frozen: modifier = FREEZE_SLOW_MODIFIER
	elif is_rooted: modifier = ROOT_SLOW_MODIFIER
	elif is_cold: modifier = COLD_SLOW_MODIFIER
	return (hero.get_starting_move_speed() + speed_boost_modifier) * (1 - modifier)

func strength() -> float:
	return hero.get_starting_strength() + current_strength_modifier

func process_knock() -> void:
	if(is_knocked and state_machine.state != &"KnockedState"):
		state_machine.transition(&"KnockedState")

func apply_gravity(delta: float) -> void:
	velocity.y -= 9.8 * delta

func process_external_modifiers(delta: float, _tick: int) -> void:
	if jump_pad_velocity:
		velocity.y = jump_pad_velocity.y

	# Process colliding AOEs
	for aoe: AOE in colliding_aoes.keys():
		aoe.apply_effect(self, delta);

func process_status_effects(delta: float) -> void:
	# SHOCKED
	if shock_value > 3:
		shock_value = 0
		apply_shock(.75)
	if burn_value > 2:
		print(multiplayer.get_unique_id(), " - ", NetworkTime.tick, " - Detected Burn")
		burn_value = 0
		apply_burn(1.9)
	
	# COLD
	if is_cold:
		cold_time_remaining -= delta
		if cold_time_remaining <= 0:
			remove_cold()
	
	# FROZEN
	if is_frozen:
		freeze_time_remaining -= delta
		if freeze_time_remaining <= 0:
			remove_freeze()
	elif freeze_value > 4:
		freeze_value = 0;
		apply_freeze(2)

	# FROZEN
	if is_rooted:
		root_time_remaining -= delta
		if root_time_remaining <= 0:
			remove_root()

func move_and_slide_physics_factor() -> void:
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

func _force_update_is_on_floor() -> void:
	_snapshot_and_apply_velocity(Vector3.ZERO)

func _snapshot_and_apply_velocity(velocity_to_apply: Vector3) -> void:
	var old_velocity: Vector3 = velocity
	velocity = velocity_to_apply
	move_and_slide_physics_factor()
	velocity = old_velocity

	#endregion
	#region Func:Actions
func process_combat_actions_state() -> void:
	if brain.using_combat_action_1 and hero.combat_action_1.is_usable():
		hero.combat_action_1.execute()
		state_machine.transition(&"PunchState")
	elif brain.using_combat_action_2 and hero.combat_action_2.is_usable():
		hero.combat_action_2.execute()
		state_machine.transition(&"BlockState")
	elif brain.using_combat_action_3 and hero.combat_action_3.is_usable():
		hero.combat_action_3.execute()
		if hero.combat_action_3.is_action_state:
			state_machine.transition(hero.combat_action_3.action_state_string)
	elif brain.using_combat_action_4 and hero.combat_action_4.is_usable():
		hero.combat_action_4.execute()
		if hero.combat_action_4.is_action_state:
			state_machine.transition(hero.combat_action_4.action_state_string)
	#endregion
	#region Func:Helpers
func has_control() -> bool:
	var control_states: Array[StringName] = [&"MoveState", &"IdleState", &"JumpState", &"FallState"]
	return !is_knocked and !is_in_menu and state_machine.state in control_states;

func get_facing_direction() -> Vector3:
	return global_transform.basis.z.normalized()

	#endregion
	#region Func:PowerUp
func apply_speed_boost(value: int) -> void:
	if not is_multiplayer_authority():
		return;
	speed_boost_modifier += value;
	
	if speed_boost_modifier >= max_player_speed - hero.get_starting_move_speed():
		speed_boost_modifier = max_player_speed - hero.get_starting_move_speed()

func apply_strength_boost(value: int) -> void:
	if not is_multiplayer_authority():
		return;
	current_strength_modifier += value;
	
	if current_strength_modifier >= max_player_strength - hero.get_starting_strength():
		current_strength_modifier = max_player_strength - hero.get_starting_strength()

#endregion
	#region Func:Animation

func _on_display_state_changed(_old_state: RewindableState, new_state: RewindableState) -> void:
	var animation_name: String = new_state.animation_name
	if animation_name != "":
		animator.play(animation_name, 0.2)

	#endregion
	#region Func:ExternalAppliers
func knock_back(direction: Vector3, force: float) -> void:
	if(!is_immune_to_knockback and not is_knocked):
		var knocked_state: ActionState = $RewindableStateMachine/KnockedState
		knocked_state.xz_velocity_override = direction * force
		# TODO Could adjust this to have a static "Gravity" y velocity override, :shrug:
		is_knocked = true

# TODO Honestly, we should just spawn a new effect no matter what maybe?
func apply_cold(duration: float) -> void:
	level.status_effect_spawner.spawn({
		"owner_player_id" : player_id,
		"effect_ttl" : duration,
		"effect_type" : StatusEffect.Type.COLD
	})
	is_cold = true;
	cold_time_remaining = duration

func apply_freeze(duration: float) -> void:
	level.status_effect_spawner.spawn({
		"owner_player_id" : player_id,
		"effect_ttl" : duration,
		"effect_type" : StatusEffect.Type.FROZEN
	})
	freeze_value = 0
	is_frozen = true;
	freeze_time_remaining = duration

func apply_root(duration: float) -> void:
	level.status_effect_spawner.spawn({
		"owner_player_id" : player_id,
		"effect_ttl" : duration,
		"effect_type" : StatusEffect.Type.ROOTED
	})
	is_rooted = true;
	root_time_remaining = duration

func apply_burn(duration: float) -> void:
	level.status_effect_spawner.spawn({
			"owner_player_id" : player_id,
			"effect_ttl" : duration,
			"effect_type" : StatusEffect.Type.BURNT
		})
	burn_value = 0
	state_machine.transition(&"BurntState")

func apply_shock(duration: float) -> void:
	level.status_effect_spawner.spawn({
			"owner_player_id" : player_id,
			"effect_ttl" : duration,
			"effect_type" : StatusEffect.Type.SHOCKED
		})
	shock_value = 0
	state_machine.transition(&"ShockedState")

func remove_cold() -> void:
	cold_time_remaining = 0
	is_cold = false;

func remove_freeze() -> void:
	freeze_time_remaining = 0
	is_frozen = false;

func remove_root() -> void:
	root_time_remaining = 0
	is_rooted = false;

	#endregion
	#region Func:RPC

	#endregion
	#region Func:Unused?

@rpc("call_local", "any_peer", "reliable")
func _update_action_cooldown(action_number: int, next_available_use: float) -> void:
	if brain.is_multiplayer_authority():
		match action_number:
			1:
				hero.combat_action_1.cd_available_time = next_available_use
			2:
				hero.combat_action_2.cd_available_time = next_available_use
			3:
				hero.combat_action_3.cd_available_time = next_available_use
			4:
				hero.combat_action_4.cd_available_time = next_available_use
			_:
				push_error("Unrecognized action number for updating cooldown")

	#endregion
#endregion
