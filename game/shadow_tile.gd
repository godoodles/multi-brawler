extends Area2D

signal stop_tween

var reveal_timer : Timer
var map_object : Node = null 
var fading := false
var mark_for_cleanup := false
var map_pos := Vector2.ZERO

@onready var fade_in_timer := $FadeInTimer

func _ready():
	$CollisionShape2D/Shadow.rotation = randf()*TAU


func reveal():
	fading = false
	mark_for_cleanup = false
	fade_in_timer.stop()
	emit_signal("stop_tween")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)


func start_fadein():
	if fading or mark_for_cleanup:
		return
	mark_for_cleanup = true
#	modulate = Color.GREEN


func start_fade_in_timer():
	fading = true
#	modulate = Color.RED
	fade_in_timer.start()


func _on_fade_in_timer_timeout():
	var tween = create_tween()
	var fadeout_time := randf_range(0.6, 0.8)
	self.stop_tween.connect(tween.kill)
	tween.tween_property(self, "modulate:a", 0, fadeout_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true).tween_callback(queue_free).set_delay(fadeout_time)
