class_name PlayerDeath extends Node3D

@onready var explosion_particles: GPUParticles3D = $GPUParticles3D
var explosion_color: Color

func _ready() -> void:
	if explosion_color:
		explosion_particles.draw_pass_1.material.albedo_color = explosion_color
	explosion_particles.emitting = true

func _on_gpu_particles_3d_finished() -> void:
	queue_free()
