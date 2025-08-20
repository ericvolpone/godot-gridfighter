class_name Player extends CharacterBody3D

const ANIM_IDLE: String = "master_animations/Idle"
const ANIM_RUN: String = "master_animations/Run"
const ANIM_FALL: String = "master_animations/Fall"
const ANIM_PUNCH: String = "master_animations/Punch"
const ANIM_BLOCK: String = "master_animations/Block"
const ANIM_SHOUT: String = "master_animations/Shout"
const ANIM_CAST: String = "master_animations/Cast"

# Hero Definitions
const BOLTY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/bolty/bolty.tres")
const BOLTY_HERO_ID: int = BOLTY_HERO_DEF.hero_id;
const ROCKY_HERO_DEF: HeroDefinition = preload("res://entities/player/heroes/rocky/rocky.tres")
const ROCKY_HERO_ID: int = ROCKY_HERO_DEF.hero_id;
const HERO_DB: Dictionary[int, HeroDefinition] = {
	BOLTY_HERO_ID : BOLTY_HERO_DEF,
	ROCKY_HERO_ID : ROCKY_HERO_DEF
}

# Parent Level Accessor Nodes
@onready var player_spawner: PlayerSpawner = get_parent()
@onready var level: Level = player_spawner.get_parent();

# Children Node Accessors
var animator: AnimationPlayer;
@onready var model: Node3D = $HeroSocket;

var player_id: String;
var player_name: String;
@export var brain: Brain;


# Menu Variables
var is_in_menu: bool = false;
@onready var in_game_menu: Node = load("res://entities/menu/in_game_menu.tscn").instantiate();

# Movement / Control variables
@export var is_player_controlled: bool;
@export var starting_move_speed: float = 4.0;
@onready var current_move_speed: float = starting_move_speed;
var speed_boost_modifier: float = 0;
var max_player_speed: float = 10;

var starting_strength: float = 5;
var current_strength: float = starting_strength;
var current_strength_modifier: float = 0;
var max_player_strength: float = 10;

@export var jump_velocity: float = 4.5;
var snapshot_velocity: Vector3 = Vector3(0,0,0)


# Combat Actions Data

# Hero Data
var hero_socket: Node3D
var hero: Hero;
# Maybe move "change hero" into the set function, exposing it is confusing
# need this for multiplayer though
var chosen_hero_id: int = 0;
@export var _current_hero_id: int = -1;

# State variables
@export var is_knocked: bool = false;
@export var is_standing_back_up: bool = false;
@export var knockback_velocity: Vector3 = Vector3.ZERO;
@export var knockback_timer: float = 0.0;
@export var current_animation: String = ANIM_IDLE
@export var current_animation_blend_time: float = 0.0
@export var is_blocking: bool = false;
@export var is_casting: bool = false;
@export var is_punching: bool = false;
@export var is_walking: bool = false;

@export var is_respawning: bool = false;
@export var is_dead: bool = false;
@onready var global_combat_cooldown_next_use: float = Time.get_unix_time_from_system()
@export var is_channeling: bool = false;
@export var channeling_action: CombatAction;
# This may not be... needed?  Actions might just need to tell us if they are interuptable or something
@export var channeling_action_name: StringName;
var xz_velocity_override: VelocityOverride;
var xz_speed_modifier: float = 1;
var y_velocity_override: VelocityOverride;
var y_speed_modifier: float = 1;
var is_animation_locked: bool = false;
var is_immune_to_knockback: bool = false;

func _enter_tree() -> void:
	hero_socket = $HeroSocket

func _ready() -> void:
	add_to_group(Groups.PLAYER)
	# We're doing this nonsense so the player can ready up on time...
	change_hero(chosen_hero_id)
	animator = hero.animator
	
	if(is_player_controlled and is_multiplayer_authority()):
		# TODO Probably put this elsewhere?
		add_child(in_game_menu)
		in_game_menu.hide()
	else:
		$BlueIndicatorCircle.queue_free();

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return;

	if event.is_action("menu_open") and event.is_pressed():
		if(is_in_menu):
			is_in_menu = false
			in_game_menu.hide()
		else:
			is_in_menu = true
			in_game_menu.show()

	if event.is_action("change_hero"):
		pass

func _physics_process(delta: float) -> void:
	if _current_hero_id != hero.definition.hero_id:
		change_hero(_current_hero_id)
	if(animator.current_animation != current_animation):
		animator.play(current_animation, current_animation_blend_time)

	if is_multiplayer_authority():
		process_movement(delta);
		process_combat_actions();
	
	if(global_position.y <= -8):
		level.handle_player_death(self)

func has_control() -> bool:
	return !is_knocked and !is_channeling and !is_in_menu;

func process_combat_actions() -> void:
	if brain.should_use_combat_action_1() and hero.combat_action_1.is_usable():
		hero.combat_action_1.execute()
	elif brain.should_use_combat_action_2() and hero.combat_action_2.is_usable():
		hero.combat_action_2.execute()
	elif brain.should_use_combat_action_3() and hero.combat_action_3.is_usable():
		hero.combat_action_3.execute()
	elif brain.should_use_combat_action_4() and hero.combat_action_4.is_usable():
		hero.combat_action_4.execute()

func process_movement(delta: float) -> void:
	if is_knocked:
		knockback_timer -= delta
		if(knockback_timer <= 0.55 and !is_standing_back_up):
			is_standing_back_up = true;
			play_anim(ANIM_IDLE, 0.5)
		if knockback_timer <= 0.0:
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
		var move_direction: Vector3 = brain.get_movement_direction()
		if move_direction != Vector3.ZERO:
			if !is_channeling:
				play_anim(ANIM_RUN, 0.3)
			velocity.x = move_direction.x * current_move_speed * xz_speed_modifier
			velocity.z = move_direction.z * current_move_speed * xz_speed_modifier
			model.rotation.y = -atan2(-move_direction.x, move_direction.z)
		else:
			if !is_channeling:
				play_anim(ANIM_IDLE, 0.3)
			velocity.x = move_toward(velocity.x, 0, current_move_speed)
			velocity.z = move_toward(velocity.z, 0, current_move_speed)

	if y_velocity_override:
		velocity.y = y_velocity_override.velocity.y
		y_velocity_override.apply_acceleration(delta)
	elif not is_on_floor():
		velocity += get_gravity() * delta
	elif brain.should_jump() and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

func add_brain(_brain: Brain) -> void:
	brain = _brain;
	if(_brain is PlayerBrain):
		is_player_controlled = true;
	add_child(brain);

func channel_action(_action: CombatAction) -> void:
	is_channeling = true;
	channeling_action = _action;
	channeling_action_name = ActionDB.get_name_for_action(_action)

func end_channel_action() -> void:
	is_channeling = false;
	channeling_action = null;
	channeling_action_name = "";

func knock_back(direction: Vector3, strength: float) -> void:
	if(!is_immune_to_knockback and !is_knocked):
		print("Knocking Back")
		xz_velocity_override = VelocityOverride.new((direction * strength), -.8)
		velocity.y = (direction*strength).y
		is_knocked = true
		knockback_timer = 1.9
		if is_channeling:
			end_channel_action()
		play_anim(ANIM_FALL, 0.3)
	else:
		print("Can't knock")

func play_anim(animation_name: String, blend_time: float = 0) -> void:
	animator.play(animation_name, blend_time)
	current_animation = animation_name
	current_animation_blend_time = blend_time

# Common physics functions
func get_facing_direction() -> Vector3:
	return model.global_transform.basis.z.normalized()

@rpc("any_peer", "call_local", "reliable")
func apply_speed_boost(value: int) -> void:
	if not is_multiplayer_authority():
		return;
	speed_boost_modifier += value;
	current_move_speed += value;
	
	if current_move_speed >= max_player_speed:
		current_move_speed = max_player_speed

@rpc("any_peer", "call_local", "reliable")
func apply_strength_boost(value: int) -> void:
	if not is_multiplayer_authority():
		return;
	current_strength_modifier += value;
	current_strength += value;
	
	if current_strength >= max_player_strength:
		current_strength = max_player_strength

# Clients call this to request a change. Server validates and sets hero_id.
@rpc("any_peer","reliable")
func rpc_request_change_hero(requested_id: int) -> void:
	if not multiplayer.is_server(): return
	if HERO_DB.has(requested_id):
		# Setting hero_id on the server triggers replication via MultiplayerSynchronizer
		change_hero(requested_id)

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
