extends AbilityAttack

func _ready() -> void:
	active_duration = 0.2
	cooldown_duration = 1.0

func _on_start() -> void:
	# Hit enemies
	pass

func _process_active(delta: float) -> void:
	# Player walks at half the speed during this attack
	player.process_movement(delta, player.movement_speed * 0.5)
