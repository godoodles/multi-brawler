extends AbilityAttack

func _ready() -> void:
	reload_duration = 0.1

func _process_active(delta: float) -> void:
	pass

func _attack():
	if closest_mob and distance_to_closest_mob < range:
		closest_mob.hit(self, damage)
		return true
	return false
