extends CharacterBody3D

class_name Player

@export var rock_scene: PackedScene;
@export var is_player_controlled: bool;

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@onready var mesh: Node3D = $RockGuy;
@onready var animator: AnimationPlayer = $RockGuy/AnimationPlayer;

var combat_1_cd: float = 3.0;
var combat_1_is_ready: bool = true;

var is_knocked: bool = false
var is_standing_back_up: bool = false;
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_timer: float = 0.0

func _ready() -> void:
	if(!is_player_controlled):
		$BlueIndicatorCircle.queue_free();

func _physics_process(delta: float) -> void:
	# Add the gravity.
	process_movement(delta);
	process_combat_actions(delta);

func process_combat_actions(delta: float) -> void:
	if (is_player_controlled and Input.is_action_just_pressed("combat_1") and combat_1_is_ready):
		# Spawn a rock
		var rock: RigidBody3D = rock_scene.instantiate();
		get_parent_node_3d().add_child(rock);
		rock.global_position = global_position + (mesh.get_global_transform().basis.z.normalized());
		rock.global_position.y += 1;
		print(mesh.rotation);
		rock.apply_impulse(mesh.get_global_transform().basis.z * 30)
		
		combat_1_is_ready = false;
		var timer: Timer = Timer.new();
		add_child(timer)
		timer.wait_time = combat_1_cd;
		timer.timeout.connect(
			func() -> void: 
				combat_1_is_ready = true; 
				print("Done")
				if is_instance_valid(rock): rock.queue_free();
				timer.queue_free()
				);
		timer.start();

func process_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_knocked:
		knockback_velocity = knockback_velocity * (1 - .2*delta);
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		knockback_timer -= delta
		if(knockback_timer <= 0.55 and !is_standing_back_up):
			is_standing_back_up = true;
			animator.play("rockguy_anim_lib/RockGuy_Idle", .5);
		if knockback_timer <= 0.0:
			is_knocked = false
			velocity = Vector3.ZERO
			# TODO Make it so that walking is disabled until the blend is over?
	elif is_player_controlled:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			animator.play("rockguy_anim_lib/RockGuy_Run", 0.3)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			mesh.rotation.y = -atan2(-direction.x, direction.z)
		else:
			animator.play("rockguy_anim_lib/RockGuy_Idle", 0.3)
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func knock_back(direction: Vector3, strength: float, duration: float) -> void:
	knockback_velocity = direction * strength
	knockback_timer = duration
	is_knocked = true
	# Probably need a knockdown animation here!
	animator.play("rockguy_anim_lib/RockGuy_FallingDown", 0.3);
