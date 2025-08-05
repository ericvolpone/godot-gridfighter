extends CharacterBody3D


class_name Player

const ANIM_IDLE: String = "rockguy_anim_lib/RockGuy_Idle"
const ANIM_RUN: String = "rockguy_anim_lib/RockGuy_Run"
const ANIM_FALL: String = "rockguy_anim_lib/RockGuy_FallingDown"
const ANIM_PUNCH: String = "rockguy_anim_lib/RockGuy_Hook"
const ANIM_BLOCK: String = "rockguy_anim_lib/RockGuy_Block"

# Parent Level Accessor Nodes
@onready var level: Level = get_parent();

# Children Node Accessors
@onready var animator: AnimationPlayer = $RockGuy/AnimationPlayer;
@onready var mesh: RockGuy = $RockGuy;

# Packed Scenes
@onready var rock_scene: PackedScene = preload("res://entities/objects/combat/rock.tscn");

var player_id: int;
var player_name: String;
@export var brain: Brain;

# Menu Variables
var is_in_menu: bool = false;
@onready var in_game_menu: Node = load("res://entities/menu/in_game_menu.tscn").instantiate();

# Movement / Control variables
@export var is_player_controlled: bool;
@export var starting_move_speed: float = 4.0;
@onready var current_move_speed: float = starting_move_speed;
@export var jump_velocity: float = 4.5;
var snapshot_velocity: Vector3 = Vector3(0,0,0)


# Combat Actions Data
@onready var global_combat_cooldown_next_use: float = Time.get_unix_time_from_system()
@onready var combat_action_1: AbstractCombatAction = ThrowRockAction.new()
@onready var combat_action_2: AbstractCombatAction = BlockAction.new()
@onready var combat_action_3: AbstractCombatAction = PunchAction.new()

# State variables
@export var is_knocked: bool = false;
@export var is_standing_back_up: bool = false;
@export var knockback_velocity: Vector3 = Vector3.ZERO;
@export var knockback_timer: float = 0.0;
@export var current_animation: String = "rockguy_anim_lib/RockGuy_Idle"
@export var current_animation_blend_time: float = 0.0
@export var is_blocking: bool = false;
@export var is_punching: bool = false;
@export var is_walking: bool = false;

func _ready() -> void:
	add_to_group(Groups.PLAYER)
	
	add_child(combat_action_1)
	add_child(combat_action_2)
	add_child(combat_action_3)
	mesh.connect("punch_frame", combat_action_3.handle_animation_signal)
	
	if(is_player_controlled and is_multiplayer_authority()):
		# TODO Probably put this elsewhere?
		add_child(in_game_menu)
		in_game_menu.hide()
	else:
		$BlueIndicatorCircle.queue_free();

# TODO See if we can delete
#func _enter_tree() -> void:
#	set_multiplayer_authority(name.to_int())

func _input(event: InputEvent) -> void:
	if event.is_action("menu_open") and event.is_pressed():
		if(is_in_menu):
			is_in_menu = false
			in_game_menu.hide()
		else:
			is_in_menu = true
			in_game_menu.show()

func _physics_process(delta: float) -> void:
	if(animator.current_animation != current_animation):
		animator.play(current_animation, current_animation_blend_time)

	process_movement(delta);
	process_combat_actions();
	
	if(global_position.y <= -5):
		level.handle_player_death(self)

func has_control() -> bool:
	return !is_knocked and !is_blocking and !is_punching and !is_in_menu;

func process_combat_actions() -> void:
	if brain.should_use_combat_action_1() and combat_action_1.is_usable():
		combat_action_1.execute()
	elif brain.should_use_combat_action_2() and combat_action_2.is_usable():
		combat_action_2.execute()
	elif brain.should_use_combat_action_3() and combat_action_3.is_usable():
		combat_action_3.execute()

func process_movement(delta: float) -> void:
	if not is_mp_authority(): return;
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_knocked:
		knockback_velocity = knockback_velocity * (1 - delta);
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		knockback_timer -= delta
		if(knockback_timer <= 0.55 and !is_standing_back_up):
			print("Player " + player_name + " is standing back up")
			is_standing_back_up = true;
			play_anim(ANIM_IDLE, 0.5)
		if knockback_timer <= 0.0:
			print("Player " + player_name + " is no longer knocked")
			is_knocked = false
			is_standing_back_up = false
			velocity = Vector3.ZERO
		snapshot_velocity = velocity
	elif has_control():
		# Handle jump.
		if brain.should_jump() and is_on_floor():
			velocity.y = jump_velocity

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var move_direction: Vector3 = brain.get_movement_direction()
		if move_direction != Vector3.ZERO:
			var blocking_modifier: float = 0.2 if is_blocking else 1.0
			play_anim(ANIM_RUN, 0.3)
			velocity.x = move_direction.x * current_move_speed * blocking_modifier
			velocity.z = move_direction.z * current_move_speed * blocking_modifier
			mesh.rotation.y = -atan2(-move_direction.x, move_direction.z)
		else:
			play_anim(ANIM_IDLE, 0.3)
			velocity.x = move_toward(velocity.x, 0, current_move_speed)
			velocity.z = move_toward(velocity.z, 0, current_move_speed)
		snapshot_velocity = velocity
	elif is_blocking or is_punching:
		velocity.x = snapshot_velocity.x * 0.3
		velocity.z = snapshot_velocity.z * 0.3
		
	
	move_and_slide()

func add_brain(_brain: Brain) -> void:
	brain = _brain;
	if(_brain is PlayerBrain):
		is_player_controlled = true;

	add_child(brain);

func knock_back(direction: Vector3, strength: float, duration: float) -> void:
	if(!is_blocking and !is_knocked):
		knockback_velocity = direction * strength
		knockback_timer = duration
		is_knocked = true
		play_anim(ANIM_FALL, 0.3)

func play_anim(animation_name: String, blend_time: float = 0) -> void:
	if not is_mp_authority(): return;
	
	animator.play(animation_name, blend_time)
	current_animation = animation_name
	current_animation_blend_time = blend_time

# Common physics functions
func get_facing_direction() -> Vector3:
	return mesh.global_transform.basis.z.normalized()

func is_mp_authority() -> bool:
	return is_multiplayer_authority() or brain is not PlayerBrain;
