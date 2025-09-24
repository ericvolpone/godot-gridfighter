class_name StatusEffectApplier extends Node

const BURN_THRESHOLD: float = 3.0;

@onready var burn_action: RewindableAction = $BurnAction
@onready var player: Player = get_parent()
@onready var rollback_synchronizer: RollbackSynchronizer = %RollbackSynchronizer

func _ready() -> void:
	burn_action.mutate(self)
	burn_action.mutate(player)
	NetworkTime.after_tick_loop.connect(_after_loop)

func _rollback_tick(_delta: float, tick: int, is_fresh: bool) -> void:
	if rollback_synchronizer.is_predicting():
		return

	burn_action.set_active(player.burn_value > BURN_THRESHOLD)
	match burn_action.get_status():
		RewindableAction.CONFIRMING, RewindableAction.ACTIVE:
			player.apply_burn(1.9)
		RewindableAction.CANCELLING:
			burn_action.erase_context()

func _after_loop() -> void:
	pass
