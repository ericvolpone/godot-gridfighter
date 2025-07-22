class_name Rock extends RigidBody3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

const LOW_VELOCITY_THRESHOLD = 1.0;
const HIGH_VELOCITY_THRESHOLD = 4.0;
const TIME_FOR_LOW_VELOCITY_REMOVAL: float = 1.0;
var time_under_removable_velocity: float = 0;

var is_slow_disappearing: bool = true;


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		var player := body as Player
		var impact_force: float = linear_velocity.length()
		if impact_force > LOW_VELOCITY_THRESHOLD:
			if(player.is_blocking):
				var direction: Vector3 = (global_transform.origin - player.global_transform.origin).normalized()
				apply_central_force(direction * 10000);
			else:
				var direction: Vector3 = (player.global_transform.origin - global_transform.origin).normalized()
				# TODO debug what makes sense for clamp values and force here
				var knockback_velocity: float = clamp(impact_force, LOW_VELOCITY_THRESHOLD, HIGH_VELOCITY_THRESHOLD);
				player.knock_back(direction, knockback_velocity, 2.5)

func _physics_process(delta: float) -> void:
	if(global_position.y < -5.0):
		queue_free();
		
	if is_slow_disappearing:
		if(linear_velocity.length() > LOW_VELOCITY_THRESHOLD):
			mesh.get_active_material(0).albedo_color.a = 1;
			time_under_removable_velocity = 0;
		else:
			mesh.get_active_material(0).albedo_color.a = .8; # Maybe some sin wave function here to blink
			time_under_removable_velocity += delta
			if(time_under_removable_velocity >= TIME_FOR_LOW_VELOCITY_REMOVAL):
				queue_free()
