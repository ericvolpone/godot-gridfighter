class_name ParticleEffect extends Node3D

enum Type {
	PUNCH
}

@onready var particles: GPUParticles3D = $GPUParticles3D
var spawn_data: Dictionary;

func _ready() -> void:
	_init_from_spawn_data()
	particles.emitting = true

func _init_from_spawn_data() -> void:
	global_position = spawn_data["spawn_position"]

func _on_gpu_particles_3d_finished() -> void:
	if is_multiplayer_authority():
		queue_free()
