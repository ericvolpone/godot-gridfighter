class_name Player extends CharacterBody3D
#region Variables
	#region Var:Animation
const ANIM_IDLE: StringName = "master_animations/Idle"
const ANIM_RUN: StringName = "master_animations/Run"
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
const HERO_DB: Dictionary[int, HeroDefinition] = {
	BOLTY_HERO_ID : BOLTY_HERO_DEF,
	ROCKY_HERO_ID : ROCKY_HERO_DEF
}
	#endregion
	#region Var:TreeNodes
@onready var player_spawner: PlayerSpawner = get_parent() # TODO Not really needed
@onready var level: Level = player_spawner.get_parent(); # TODO Probably just signal this up
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
	#endregion
	#region Var:PlayerBaseAttributes
var player_id: String;
var player_name: String;
@onready var brain: Brain = $Brain;
	#endregion
	#region Var:Hero
@onready var hero_socket: Node3D = $HeroSocket
var hero: Hero;
# Maybe move "change hero" into the set function, exposing it is confusing
# need this for multiplayer though
var chosen_hero_id: int = 0;
@export var _current_hero_id: int = -1;
	#endregion
	#region Var:Menu
# TODO Make this default in scene and disable if brain not multiplayer authority (have a task)
var is_in_menu: bool = false;
@onready var in_game_menu: InGameMenu = load("res://entities/menu/in_game_menu.tscn").instantiate();
	#endregion
	#region Var:PlayerStats
		#region Var:PlayerStats:Modifiers
var xz_velocity_override: VelocityOverride;
var xz_speed_modifier: float = 1;
var y_velocity_override: VelocityOverride;
var y_speed_modifier: float = 1;

var gust_total_direction: Vector3 = Vector3.ZERO
		#endregion
		#region Var:PlayerStats:Movement
var jump_velocity: float = 4.5;

var starting_move_speed: float = 4.0;
var current_move_speed: float = starting_move_speed;
var speed_boost_modifier: float = 0;
var max_player_speed: float = 10;
		#endregion
		#region Var:PlayerStats:Strength
var starting_strength: float = 5;
var current_strength: float = starting_strength;
var current_strength_modifier: float = 0;
var max_player_strength: float = 10;
		#endregion
	#endregion
	#region Var:State
@export var current_animation: String = ANIM_IDLE
@export var current_animation_blend_time: float = 0.0
@export var is_knocked: bool = false;
@export var knockback_timer: float = 0.0;
@export var is_standing_back_up: bool = false;
@export var is_blocking: bool = false; # TODO Maybe can use channeling_action instead
@export var is_respawning: bool = false;
@export var is_channeling: bool = false;
@export var channeling_action: CombatAction;
@onready var global_combat_cooldown_next_use: float = Time.get_unix_time_from_system()
var is_immune_to_knockback: bool = false;
	#endregion
#endregion

#region Functions
	#region Func:Initialization
func _enter_tree() -> void:
	hero_socket = $HeroSocket

func _ready() -> void:
	add_to_group(Groups.PLAYER)
	# We're doing this nonsense so the player can ready up on time...
	change_hero(chosen_hero_id)
	animator = hero.animator
	
	if not brain.is_ai() and brain.is_multiplayer_authority():
		# TODO Probably put this elsewhere?
		add_child(in_game_menu)
		in_game_menu.hide()
	else:
		$BlueIndicatorCircle.queue_free();

func add_brain(_brain: Brain, peer_id: int) -> void:
	if(_brain is PlayerBrain):
		_brain.set_multiplayer_authority(peer_id)
	brain = _brain;
	brain.name = "Brain"
	add_child(brain)

func change_hero(hero_id: int) -> void:
	_current_hero_id = hero_id
	var hero_definition: HeroDefinition = HERO_DB[hero_id];
	if hero:
		hero.queue_free()
		await get_tree().process_frame
	
	var _hero := hero_definition.instantiate()
	_hero.set_multiplayer_authority(get_multiplayer_authority())
	hero_socket.add_child(_hero)
	hero = _hero
	hero.call_deferred("init_combat_actions")
	animator = hero.animator

	#endregion
	#region Func:Menu
func process_menu_input() -> void:
	if brain.opening_in_game_menu:
		if(is_in_menu):
			is_in_menu = false
			in_game_menu.hide()
		else:
			is_in_menu = true
			in_game_menu.show()
	#endregion
	#region Func:Native
#func _physics_process(_delta: float) -> void:
	#if not is_multiplayer_authority():
		#if _current_hero_id != hero.definition.hero_id:
			#print("Hero is changing for player: " + player_name + " on client: " + str(multiplayer.get_unique_id()))
			#change_hero(_current_hero_id)
		#if(animator.current_animation != current_animation):
			#print("Animation for player: " + player_name + " on client: " + str(multiplayer.get_unique_id()) + " is changing to " + current_animation + " from " + animator.current_animation)
			#animator.play(current_animation, current_animation_blend_time)

func _rollback_tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	print("Rollback Global Position : ", global_position)
	process_menu_input();
	process_combat_actions();
	process_gust(delta)
	process_movement(delta);
	if is_multiplayer_authority() and global_position.y <= -8:
		level.handle_player_death(self)

	#endregion

	#region Movement
func process_gust(delta: float) -> void:
	if gust_total_direction:
		_snapshot_and_apply_velocity(gust_total_direction * delta * 30)

func process_combat_actions() -> void:
	if brain.using_combat_action_1 and hero.combat_action_1.is_usable():
		hero.combat_action_1.execute()
	elif brain.using_combat_action_2 and hero.combat_action_2.is_usable():
		hero.combat_action_2.execute()
	elif brain.using_combat_action_3 and hero.combat_action_3.is_usable():
		hero.combat_action_3.execute()
	elif brain.using_combat_action_4 and hero.combat_action_4.is_usable():
		hero.combat_action_4.execute()

func process_movement(delta: float) -> void:
	if is_respawning: return;

	if is_knocked:
		print("Hero is knocked with time life: " + str(knockback_timer) + " and xz override: " + str(xz_velocity_override))
		knockback_timer -= delta
		if(knockback_timer <= 0.55 and !is_standing_back_up):
			print("Standing back up")
			is_standing_back_up = true;
			play_anim(ANIM_IDLE, 0.5)
		if knockback_timer <= 0.0:
			print("Stood up!")
			is_knocked = false
			is_standing_back_up = false
			xz_velocity_override = null
			velocity = Vector3.ZERO
	
	if xz_velocity_override:
		velocity.x = xz_velocity_override.velocity.x
		velocity.z = xz_velocity_override.velocity.z
		xz_velocity_override.apply_acceleration(delta)
	elif !is_respawning:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var move_direction: Vector3 = brain.move_direction
		if move_direction != Vector3.ZERO:
			if !is_channeling:
				play_anim(ANIM_RUN, 0.3)
			velocity.x = move_direction.x * current_move_speed * xz_speed_modifier
			velocity.z = move_direction.z * current_move_speed * xz_speed_modifier
			rotation.y = -atan2(-move_direction.x, move_direction.z)
		else:
			if !is_channeling:
				play_anim(ANIM_IDLE, 0.3)
			velocity.x = move_toward(velocity.x, 0, current_move_speed)
			velocity.z = move_toward(velocity.z, 0, current_move_speed)

	_force_update_is_on_floor()
	if y_velocity_override:
		velocity.y = y_velocity_override.velocity.y
		y_velocity_override.apply_acceleration(delta)
	elif not is_on_floor():
		velocity += get_gravity() * delta
	elif brain.jump_strength and is_on_floor():
		velocity.y = jump_velocity * brain.jump_strength

	move_and_slide_physics_factor()

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
	#region Func:Helpers
func has_control() -> bool:
	return !is_knocked and !is_channeling and !is_in_menu;

func get_facing_direction() -> Vector3:
	return global_transform.basis.z.normalized()

	#endregion
	#region Func:PowerUp
func apply_speed_boost(value: int) -> void:
	if not is_multiplayer_authority():
		return;
	speed_boost_modifier += value;
	current_move_speed += value;
	
	if current_move_speed >= max_player_speed:
		current_move_speed = max_player_speed

func apply_strength_boost(value: int) -> void:
	if not is_multiplayer_authority():
		return;
	current_strength_modifier += value;
	current_strength += value;
	
	if current_strength >= max_player_strength:
		current_strength = max_player_strength

#endregion
	#region Func:Animation
func play_anim(animation_name: StringName, blend_time: float = 0) -> void:
	animator.play(animation_name, blend_time)
	current_animation = animation_name
	current_animation_blend_time = blend_time

	#endregion
	#region Func:Actions
func channel_action(_action: CombatAction) -> void:
	is_channeling = true;
	channeling_action = _action;

func end_channel_action() -> void:
	is_channeling = false;
	channeling_action = null;
	#endregion
	#region Func:ExternalAppliers
func knock_back(direction: Vector3, strength: float) -> void:
	if not is_multiplayer_authority(): return

	if(!is_immune_to_knockback and !is_knocked):
		print("Knocking Back player ", player_name, " on client: ", multiplayer.get_unique_id())
		xz_velocity_override = VelocityOverride.new((direction * strength), -.8)
		velocity.y = (direction*strength).y
		is_knocked = true
		knockback_timer = 1.9
		if is_channeling:
			end_channel_action()
		play_anim(ANIM_FALL, 0.3)
	else:
		print("Can't knock")
	#endregion
	#region Func:Unused?
@rpc("any_peer","reliable")
func rpc_request_change_hero(requested_id: int) -> void:
	if not multiplayer.is_server(): return
	if HERO_DB.has(requested_id):
		# Setting hero_id on the server triggers replication via MultiplayerSynchronizer
		change_hero(requested_id)
	#endregion
#endregion
