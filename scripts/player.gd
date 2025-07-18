extends CharacterBody3D

@export var rock_scene: PackedScene;

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@onready var mesh: Node3D = $RockGuy;
@onready var animator: AnimationPlayer = $RockGuy/AnimationPlayer;

var combat_1_cd: float = 3.0;
var combat_1_is_ready: bool = true;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	process_movement(delta);
	process_combat_actions(delta);

func process_combat_actions(delta: float) -> void:
	if (Input.is_action_just_pressed("combat_1") and combat_1_is_ready):
		print("Combat 1");
		combat_1_is_ready = false;
		var timer: Timer = Timer.new();
		add_child(timer)
		timer.wait_time = combat_1_cd;
		timer.timeout.connect(
			func() -> void: 
				combat_1_is_ready = true; 
				print("Done")
				timer.queue_free()
				);
		timer.start();
		
		# Spawn a rock
		var rock: Node = rock_scene.instantiate();
		get_parent_node_3d().add_child(rock);
		rock.global_position = global_position;
		rock.global_position.y += 2;
		var rock_rb: RigidBody3D = rock.get_node("RigidBody3D");
		print(mesh.rotation);
		rock_rb.apply_impulse(mesh.get_global_transform().basis.z * 25
	);

func process_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		animator.play("rockguy_anim_lib/RockGuy_Run")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		mesh.rotation.y = -atan2(-direction.x, direction.z)
	else:
		animator.play("rockguy_anim_lib/RockGuy_Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
