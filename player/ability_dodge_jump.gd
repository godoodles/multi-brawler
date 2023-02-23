extends AbilityDodge

func _ready() -> void:
	active_duration = 10.0

func _on_activate():
	player.velocity_v = 10.0

func _process_active(delta: float) -> void:
	player.process_movement(delta, player.movement_speed, 5.0, 5.0)

func _allow_use():
	return player.is_on_floor()
