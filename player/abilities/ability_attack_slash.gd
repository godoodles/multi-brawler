extends AbilityAttack

func _ready() -> void:
	reload_duration = 0.1

func _attack():
	var effect:AbilityEffect = preload("res://player/abilities/ability_effects/melee/melee.tscn").instantiate()
	effect.emitter = player
	effect.position = global_position
	effect.velocity = effect.position.direction_to(closest_mob.position)
	effect.velocity.y = 0.0
	player.attack.emit(effect)
	effect.apply(closest_mob)
	return true

