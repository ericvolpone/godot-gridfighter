class_name KothRing extends MultiMeshInstance3D

@onready var point_count: int = multimesh.instance_count;
@export var ring_radius: float = 2.0

@export var flash_strength: float = 3.0
@export var flash_duration: float = 0.3

var is_active: bool = false;
var original_emission: Color
var material: StandardMaterial3D

func _ready() -> void:
	# Position each point in a circle
	for i in range(multimesh.instance_count):
		var angle: float = TAU * i / point_count
		var x: float = cos(angle) * ring_radius
		var z: float = sin(angle) * ring_radius
		var my_transform: Transform3D = Transform3D(Basis(), Vector3(x, 0, z))
		multimesh.set_instance_transform(i, my_transform)
	
	material = multimesh.mesh.material
	original_emission = material.emission
	material.emission_enabled = true

func flash_ring() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(material, "emission", original_emission * flash_strength, flash_duration * 0.5).as_relative()
	tween.tween_property(material, "emission", original_emission, flash_duration * 0.5)

func mark_active() -> void:
	show();
	is_active = true;

func mark_inactive() -> void:
	hide();
	is_active = false;
