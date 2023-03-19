extends Node3D

signal spawn_enemy(_enemy_scene:PackedScene)

var enemy_scene : PackedScene = null
var triggered := false
var size := 1.0

func _enter_tree():
	$Effect.scale = Vector3.ZERO

func _ready():
	var tween = create_tween()
	tween.tween_property($Effect, "scale", Vector3.ONE*randf_range(0.8, 1.0) * size, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func trigger():
	var tween = create_tween()
	tween.tween_property($Effect, "scale", Vector3.ZERO, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	if multiplayer.is_server():
		tween.set_parallel(true).tween_callback(queue_free).set_delay(0.1)

func _on_area_entered(area:EnemySpawnTrigger):
	if triggered:
		return
		
	triggered = true
	
	if area.diffuse:
		if multiplayer.is_server():
			queue_free()
	else:
		trigger()
		emit_signal("spawn_enemy", enemy_scene, position)
