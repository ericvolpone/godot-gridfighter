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
const ANIM_UPPERCUT: StringName = "master_animations/UpperCut"
const ANIM_KNEEL: StringName = "master_animations/Kneel"
const ANIM_BURNT: StringName = "master_animations/Burnt"
const ANIM_TPOSE: StringName = "master_animations/T-Pose"

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
@onready var ring_indicator: CSGCylinder3D = $RingIndicator
#endregion
	#region Var:Hero
@onready var hero_socket: HeroSocket = $HeroSocket
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
		#region Var:PlayerStats:ActionTimers
var active_action_number: int = -1;
var active_action_start_tick: int = -1;
var active_action_end_tick: int = -1;
		#endregion
		#region Var:PlayerStats:Modifiers
var jump_pad_velocity: Vector3 = Vector3.ZERO
var colliding_aoes: Dictionary[AOE, bool] = {} # TODO Move this into rollback tick
var active_aoes: Dictionary[AOE, bool] = {}
var status_effects: Dictionary[StatusEffect, bool] = {}

		#endregion
		#region Var:PlayerStats:StatusEffects

var shock_value: float = 0;
var shock_time_remaining: float = 0;
const SHOCK_SLOW_MODIFIER: float = 1.0;
const SHOCK_DURATION: float = 1.0

var burn_value: float = 0;
var burnt_time_remaining: float = 0;
const BURN_Y_VELOCITY: float = 3;
const BURN_SLOW_MODIFIER: float = .5;
const BURN_DURATION: float = 1.9;

var cold_value: float = 0;
var cold_time_remaining: float = 0;
const COLD_SLOW_MODIFIER: float = .5;
const COLD_DURATION: float = 3

var freeze_value: float = 0;
var freeze_time_remaining: float = 0;
const FREEZE_SLOW_MODIFIER: float = 1;
const FREEZE_DURATION: float = 1.5

var root_value: float = 0;
var root_time_remaining: float = 0;
const ROOT_SLOW_MODIFIER: float = .9;
const ROOT_DURATION: float = 2
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
var knocked_time_remaining: float = 0
var knocked_direction: Vector3
@export var is_standing_back_up: bool = false;
@export var is_blocking: bool = false;
@export var is_respawning: bool = false;
@onready var global_combat_cooldown_next_use_tick: int = -1
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
	#state_machine.state = &"RespawnState"
	#state_machine.on_display_state_changed.connect(_on_display_state_changed)
	
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
	hero_socket.hero = hero
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
	process_movement(delta, tick, is_fresh)
	process_animations(delta, tick, is_fresh)
	process_menu_input(tick);
	process_combat_actions_state(tick);
	process_combat_actions(tick);
	process_knock();
	process_external_modifiers(delta, tick)
	process_status_effects(delta);

	if global_position.y <= -8 and tick > respawn_tick and is_fresh:
		is_respawning = true
		respawn_tick = tick
	
	if tick == respawn_tick:
		level.handle_player_death(self)

	#endregion

	#region Movement\
func process_movement(delta: float, tick: int, is_fresh: bool) -> void:
	var can_move: bool = true
	var xz_multiplier: float = 1
	var y_velocity_override: float = 0
	
	if is_burnt():
		y_velocity_override = BURN_Y_VELOCITY * (1 - (burnt_time_remaining / BURN_DURATION))
	elif is_shocked():
		can_move = false;
	else:
		# TODO Helper Function to get combat action by active action num
		match active_action_number:
			1:
				can_move = hero.combat_action_1.can_move()
				xz_multiplier = hero.combat_action_1.xz_multiplier()
				y_velocity_override = hero.combat_action_1.y_velocity_override()
			2:
				can_move = hero.combat_action_2.can_move()
				xz_multiplier = hero.combat_action_2.xz_multiplier()
				y_velocity_override = hero.combat_action_2.y_velocity_override()
			3:
				can_move = hero.combat_action_3.can_move()
				xz_multiplier = hero.combat_action_3.xz_multiplier()
				y_velocity_override = hero.combat_action_3.y_velocity_override()
				if hero.combat_action_3.y_velocity_override_deceleration():
					y_velocity_override *= 1.0 - (float(tick - active_action_start_tick) / float(active_action_end_tick - active_action_start_tick))
			4:
				can_move = hero.combat_action_4.can_move()
				xz_multiplier = hero.combat_action_4.xz_multiplier()
				y_velocity_override = hero.combat_action_4.y_velocity_override()
				if hero.combat_action_4.y_velocity_override_deceleration():
					y_velocity_override *= 1.0 - (float(tick - active_action_start_tick) / float(active_action_end_tick - active_action_start_tick))
			_:
				pass

	if y_velocity_override == 0:
		var is_jumping: bool = false;
		if can_jump():
			is_jumping = brain.jump_strength > 0
		if is_on_floor():
			if is_jumping:
				velocity.y = jump_velocity
			else:
				velocity.y = 0
		else:
			apply_gravity(delta)
	else:
		velocity.y = y_velocity_override

	if is_knocked():
		var knocked_velocity: float = knocked_time_remaining / 1.5
		velocity.x = knocked_direction.x * knocked_velocity
		velocity.z = knocked_direction.z * knocked_velocity
		knocked_time_remaining -= delta
		move_and_slide_physics_factor()
	elif can_move:
		var movement_direction: Vector3 = brain.move_direction
		var speed: float = movement_speed() * xz_multiplier
		var horizontal_velocity: Vector3 = movement_direction.normalized() * speed
		
		if horizontal_velocity:
			velocity.x = horizontal_velocity.x
			velocity.z = horizontal_velocity.z
			rotation.y = -atan2(-movement_direction.x, movement_direction.z)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		move_and_slide_physics_factor()

func process_animations(delta: float, tick: int, is_fresh: bool) -> void:
	if is_burnt():
		animator.play(ANIM_BURNT, .2)
		return
	elif is_shocked():
		animator.play(ANIM_TPOSE, .2)
		return
	elif is_knocked():
		animator.play(ANIM_FALL, .2)
		return

	if active_action_number != -1:
		match active_action_number:
			1:
				animator.play(ANIM_PUNCH, .2)
			2:
				animator.play(ANIM_BLOCK, .2)
			3:
				if hero.combat_action_3.is_action_state:
					animator.play(hero.combat_action_3.action_animation, .2)
			4:
				if hero.combat_action_4.is_action_state:
					animator.play(hero.combat_action_4.action_animation, .2)
		if tick > active_action_end_tick:
			active_action_number = -1
			active_action_end_tick = -1
	else:
		if is_on_floor():
			if brain.move_direction:
				animator.play(ANIM_RUN, .2)
			else:
				animator.play(ANIM_IDLE, .2)
		else:
			animator.play(ANIM_JUMP, .2)

func movement_speed() -> float:
	var modifier: float = 0
	if is_shocked(): modifier = max(modifier, SHOCK_SLOW_MODIFIER)
	if is_burnt(): modifier = max(modifier, BURN_SLOW_MODIFIER)
	if is_frozen(): modifier = max(modifier, FREEZE_SLOW_MODIFIER)
	if is_rooted(): modifier = max(modifier, ROOT_SLOW_MODIFIER)
	if is_cold(): modifier = max(modifier, COLD_SLOW_MODIFIER)
	return (hero.get_starting_move_speed() + speed_boost_modifier) * (1 - modifier)

func can_jump() -> bool:
	return not (is_burnt() or is_shocked() or is_frozen() or is_rooted() or is_knocked())

func strength() -> float:
	return hero.get_starting_strength() + current_strength_modifier

func process_knock() -> void:
	if(is_knocked()):
		pass;

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
	if is_shocked():
		shock_time_remaining -= delta
		if shock_time_remaining <= 0:
			remove_shock()
	elif shock_value > 3:
		apply_shock(SHOCK_DURATION)
	
	# BURNT
	if is_burnt():
		burnt_time_remaining -= delta
		if burnt_time_remaining <= 0:
			remove_burn()
	elif burn_value > 2:
		apply_burn(BURN_DURATION)
	
	# COLD
	if is_cold():
		cold_time_remaining -= delta
		if cold_time_remaining <= 0:
			remove_cold()
	
	# FROZEN
	if is_frozen():
		freeze_time_remaining -= delta
		if freeze_time_remaining <= 0:
			remove_freeze()
	elif freeze_value > 4:
		freeze_value = 0;
		apply_freeze(2)

	# ROOTED
	if is_rooted():
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
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	velocity = old_velocity

	#endregion
	#region Func:Actions

func process_combat_actions_state(tick: int) -> void:
	if not hero.combat_action_1:
		return
	if brain.using_combat_action_1 and hero.combat_action_1.is_usable(tick):
		hero.combat_action_1.execute(tick)
	elif brain.using_combat_action_2 and hero.combat_action_2.is_usable(tick):
		hero.combat_action_2.execute(tick)
	elif brain.using_combat_action_3 and hero.combat_action_3.is_usable(tick):
		hero.combat_action_3.execute(tick)
	elif brain.using_combat_action_4 and hero.combat_action_4.is_usable(tick):
		hero.combat_action_4.execute(tick)

func process_combat_actions(tick: int) -> void:
	if not hero.combat_action_1 or not hero.combat_action_2 or not hero.combat_action_3 or not hero.combat_action_4:
		return
	match hero.combat_action_1.get_status():
		RewindableAction.CONFIRMING, RewindableAction.ACTIVE:
			active_action_number = 1;
			active_action_start_tick = tick
			active_action_end_tick = tick + NetworkTime.seconds_to_ticks(animator.get_animation(ANIM_PUNCH).length)
			hero.combat_action_1.execute_child(tick)
		RewindableAction.CANCELLING:
			active_action_number = -1
			active_action_start_tick = -1
			active_action_end_tick = -1
			hero.combat_action_1.erase_context()
			hero.combat_action_4.rewind()
	match hero.combat_action_2.get_status():
		RewindableAction.CONFIRMING, RewindableAction.ACTIVE:
			active_action_number = 2;
			active_action_start_tick = tick
			active_action_end_tick = tick + NetworkTime.seconds_to_ticks(animator.get_animation(ANIM_BLOCK).length)
			hero.combat_action_2.execute_child(tick)
		RewindableAction.CANCELLING:
			active_action_number = -1
			active_action_start_tick = -1
			active_action_end_tick = -1
			hero.combat_action_2.erase_context()
			hero.combat_action_4.rewind()
	match hero.combat_action_3.get_status():
		RewindableAction.CONFIRMING, RewindableAction.ACTIVE:
			if hero.combat_action_3.is_action_state:
				active_action_number = 3;
				active_action_start_tick = tick
				active_action_end_tick = tick + NetworkTime.seconds_to_ticks(animator.get_animation(hero.combat_action_3.action_animation).length)
				hero.combat_action_3.execute_child(tick)
		RewindableAction.CANCELLING:
			active_action_number = -1
			active_action_start_tick = -1
			active_action_end_tick = -1
			hero.combat_action_3.erase_context()
			hero.combat_action_4.rewind()
	match hero.combat_action_4.get_status():
		RewindableAction.CONFIRMING, RewindableAction.ACTIVE:
			if hero.combat_action_4.is_action_state:
				active_action_number = 4;
				active_action_start_tick = tick
				active_action_end_tick = tick + NetworkTime.seconds_to_ticks(animator.get_animation(hero.combat_action_4.action_animation).length)
			hero.combat_action_4.execute_child(tick)
		RewindableAction.CANCELLING:
			active_action_number = -1
			active_action_start_tick = -1
			active_action_end_tick = -1
			hero.combat_action_4.erase_context()
			hero.combat_action_4.rewind()
	#endregion
	#region Func:Helpers
func has_control() -> bool:
	return !is_knocked() and !is_in_menu and active_action_number == -1;

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
	#region Func:ExternalAppliers
func knock_back(direction: Vector3, force: float) -> void:
	if(!is_immune_to_knockback and not is_knocked()):
		knocked_direction = direction * force
		knocked_time_remaining = 1.5

func is_knocked() -> bool:
	return knocked_time_remaining > 0

func is_cold() -> bool:
	return cold_time_remaining > 0

func apply_cold(duration: float = COLD_DURATION) -> void:
	level.status_effect_spawner.spawn({
		"owner_player_id" : player_id,
		"effect_ttl" : duration,
		"effect_type" : StatusEffect.Type.COLD
	})
	cold_value = 0
	cold_time_remaining = duration

func is_frozen() -> bool:
	return freeze_time_remaining > 0

func apply_freeze(duration: float = FREEZE_DURATION) -> void:
	level.status_effect_spawner.spawn({
		"owner_player_id" : player_id,
		"effect_ttl" : duration,
		"effect_type" : StatusEffect.Type.FROZEN
	})
	freeze_value = 0
	freeze_time_remaining = duration

func is_rooted() -> bool:
	return root_time_remaining > 0

func apply_root(duration: float = ROOT_DURATION) -> void:
	level.status_effect_spawner.spawn({
		"owner_player_id" : player_id,
		"effect_ttl" : duration,
		"effect_type" : StatusEffect.Type.ROOTED
	})
	root_value = 0
	root_time_remaining = duration

func is_burnt() -> bool:
	return burnt_time_remaining > 0

func apply_burn(duration: float = BURN_DURATION) -> void:
	level.status_effect_spawner.spawn({
			"owner_player_id" : player_id,
			"effect_ttl" : duration,
			"effect_type" : StatusEffect.Type.BURNT
		})
	burn_value = 0;
	burnt_time_remaining = duration

func is_shocked() -> bool:
	return shock_time_remaining > 0

func apply_shock(duration: float = SHOCK_DURATION) -> void:
	level.status_effect_spawner.spawn({
			"owner_player_id" : player_id,
			"effect_ttl" : duration,
			"effect_type" : StatusEffect.Type.SHOCKED
		})
	shock_value = 0
	shock_time_remaining = duration

func remove_shock() -> void:
	shock_time_remaining = 0
	
func remove_burn() -> void:
	burnt_time_remaining = 0
	
func remove_cold() -> void:
	cold_time_remaining = 0

func remove_freeze() -> void:
	freeze_time_remaining = 0

func remove_root() -> void:
	root_time_remaining = 0

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
