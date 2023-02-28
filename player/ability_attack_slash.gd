extends AbilityAttack

func _ready() -> void:
	reload_duration = 0.1

func _process_active(delta: float) -> void:
	pass

func _attack():
	# Maybe this check should be in AbilityAttack if it's the same for each attack
	# so we don't have to redefine it ever time
	if closest_mob and distance_to_closest_mob < range:
		closest_mob.hit(self, damage, Vector3.ZERO)
		return true
	return false
