class_name HeroSocket extends Node3D

@onready var rollback_synchronizer: RollbackSynchronizer = %RollbackSynchronizer
var hero: Hero;

func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	if not hero:
		return;
	if rollback_synchronizer.is_predicting():
		return;
