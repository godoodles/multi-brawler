class_name AbilityAttack
extends Node3D

var damage := 10
var range := 3.0
var reload_duration := 0.3

var player: Player

var closest_mob: Mob
var distance_to_closest_mob := 9999.0
var direction_to_closest_mob := Vector2()

var reload_t := 0.0

func process_active(delta: float) -> void:
	reload_t -= delta
	if reload_t <= 0:
		_find_closest_mob()
		if _attack():
			reload_t += reload_duration
	_process_active(delta)

func _process_active(delta: float) -> void: pass

func _attack() -> bool: return false

func _find_closest_mob() -> void:
	closest_mob = null
	distance_to_closest_mob = 99999.0
	# Choosing a random direction so not every attack targets the same enemy
	# it could instead work like brotato where the weapons are rotating, or something more original
	var direction = Vector2.RIGHT.rotated(randf() * TAU)
	for mob in get_tree().get_nodes_in_group("mobs"):
		var distance = player.position.distance_to(mob.position)
		if distance < distance_to_closest_mob:
			direction_to_closest_mob = player.position_h.direction_to(mob.position_h)
			if direction.dot(direction_to_closest_mob) > 0.5:
				distance_to_closest_mob = distance
				closest_mob = mob
