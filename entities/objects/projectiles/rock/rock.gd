class_name Rock extends Projectile

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var shader_material: ShaderMaterial = mesh.get_active_material(0)
@onready var original_albedo: Color = shader_material.get_shader_parameter("albedo_color")
@onready var transparant_albedo: Color = original_albedo;

const LOW_VELOCITY_THRESHOLD = 1.0;
const HIGH_VELOCITY_THRESHOLD = 20.0;
const TIME_FOR_LOW_VELOCITY_REMOVAL: float = 1.0;
var time_under_removable_velocity: float = 0;

var is_slow_disappearing: bool = true;


func _ready() -> void:
	add_to_group(Groups.PUNCHABLE_RB)
	contact_monitor = true
	max_contacts_reported = 4
	transparant_albedo.a = .8;
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_multiplayer_authority(): return

	if body is CharacterBody3D:
		var player := body as Player
		var impact_force: float = linear_velocity.length()
		if impact_force > LOW_VELOCITY_THRESHOLD:
			if(player.is_blocking):
				var throw_direction: Vector3 = (global_transform.origin - player.global_transform.origin).normalized()
				apply_central_force(throw_direction * 10000);
			else:
				var throw_direction: Vector3 = (player.global_transform.origin - global_transform.origin).normalized()
				# TODO debug what makes sense for clamp values and force here
				var knockback_velocity: float = clamp(impact_force, LOW_VELOCITY_THRESHOLD, HIGH_VELOCITY_THRESHOLD);
				player.knock_back(throw_direction, knockback_velocity)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return

	if(global_position.y < -5.0):
		queue_free();
	
	# TODO: Figure out how to animate "transparancy" per instance
	if is_slow_disappearing:
		if(linear_velocity.length() > LOW_VELOCITY_THRESHOLD):
			#mesh.set_instance_shader_parameter("albedo_color", original_albedo);
			time_under_removable_velocity = 0;
		else:
			#mesh.set_instance_shader_parameter("albedo_color", transparant_albedo);
			time_under_removable_velocity += delta
			if(time_under_removable_velocity >= TIME_FOR_LOW_VELOCITY_REMOVAL):
				queue_free()
