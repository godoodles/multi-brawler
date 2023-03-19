extends Node3D
class_name ImpactText

signal done

@export var text := ""
@export var color := Color.WHITE
@export var hang_time := 0.0

static func popin(node:Node3D, text, color:Color = Color.WHITE, hang_time := 0.0) -> ImpactText:
	var n = preload("res://gui/number.tscn").instantiate()
	n.position = node.position
	n.text = str(text)
	n.color = color
	n.hang_time = hang_time
	node.get_parent().add_child(n)
	return n

func _ready() -> void:
	$Label3D.modulate = color
	$Label3D.text = text
	var tween := create_tween()
	tween.tween_property($Label3D, "position:y", position.y + 2, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Label3D, "position:y", position.y + 1.5, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Label3D, "scale", Vector3.ZERO, 0.8).set_delay(hang_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(self.queue_free)
	tween.tween_callback(self.emit_signal.bind("done"))
