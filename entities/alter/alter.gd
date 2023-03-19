class_name Alter
extends Node3D

signal effect
signal capture_begin
signal capture_end

@export var activation_radius := 2.0
@export var capture_radius := 22.0
@export var capture_speed := 0.05

var capture_progress := 0.0
var captures := {}

func _ready():
	$Ring.size.x = activation_radius * 2.0
	$Ring.size.z = activation_radius * 2.0
	$ActivationArea/CollisionShape3D.shape.radius = activation_radius
	$CaptureArea/CollisionShape3D.shape.radius = capture_radius
	set_process(false)

func _process(delta):
	if captures.is_empty():
		capture_progress *= 0.0
		abandon_()
	else:
		capture_progress += delta * capture_speed
	
	$CaptureProgress.size.x = capture_progress * capture_radius * 2.0
	$CaptureProgress.size.z = capture_progress * capture_radius * 2.0
	
	if capture_progress >= 1.0:
		capture_()

func activate_() -> void:
	capture_begin.emit()
	set_process(true)
	ImpactText.popin(self, "Cleansing", Color.DEEP_PINK, 2.0)
	var tween = create_tween()
	var r = capture_radius * 2.0
	var outline_width = 1.0
	tween.tween_property($Ring, "size", Vector3(r + outline_width, $Ring.size.y, r + outline_width), 0.5)
	$CaptureArea.set_deferred("monitoring", true)
	$CaptureArea.set_deferred("monitorable", true)
	$ActivationArea.set_deferred("monitoring", false)
	_e.shadow_add_dynamic_revealer.emit(self, capture_radius)

func capture_() -> void:
	ImpactText.popin(self, "Cleansed", Color.WHITE, 2.0)
	set_process(false)
	_e.shadow_update_revealer.emit(self, capture_radius * 1.5)
	var tween = create_tween()
	tween.set_speed_scale(0.5)
	tween.set_parallel()
	tween.tween_property($CaptureProgress, "size", Vector3(capture_radius * 3.0, $CaptureProgress.size.y, capture_radius * 3.0), 0.2)
	tween.tween_property($CaptureProgress, "modulate:a", 0.0, 0.2)
	tween.tween_property($Ring, "modulate:a", 0.0, 0.01)
	var cleanse = preload("res://entities/abilities/ability_effects/cleanse.tscn").instantiate()
	cleanse.position = position
	effect.emit(cleanse)
	$CaptureArea.diffuse = true
	$CaptureArea/CollisionShape3D.shape.radius = capture_radius * 1.5
	emit_signal("capture_end")

func abandon_() -> void:
	ImpactText.popin(self, "Abandoned", Color.RED, 1.5)
	set_process(false)
	
	var tween = create_tween()
	tween.tween_property($Ring, "size", Vector3(0.00001, activation_radius * 2.0, 0.00001), 0.5)
	tween.tween_property($Sprite3D, "position:y", -2.0, 0.1).set_delay(0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func find_candle_(color:Color, ignore_extinguish = true):
	for candle in $Sprite3D/Candles.get_children():
		if candle.color == color:
			if ignore_extinguish and not candle.color.a:
				return null
			return candle
	return null

func light_candle(color:Color) -> void:
	var candle = find_candle_(Color.TRANSPARENT, false)
	if candle:
		candle.color = color

func extinguish_candle(color:Color) -> void:
	var candle = find_candle_(color)
	if candle:
		candle.color = Color.TRANSPARENT

func _activation_entered(body):
	if capture_progress >= 1.0:
		return

	if capture_progress > 0.0:
		return

	if not body is Player:
		return

	captures[body] = body

	if captures.size() == 1:
		activate_()

func _capture_entered(body):
	if capture_progress <= 0.0:
		return
	_activation_entered(body)

func _capture_exited(body):
	captures.erase(body)

func find_best_alter(from_position:Vector3, color:Color) -> Alter:
	var alters := []
	for alter in get_tree().get_nodes_in_group("alters"):
		alters.push_back({ "alter": alter, "score": alter.score_(from_position, color) })
	
	alters.sort_custom(func(a, b): return a.score > b.score)
	
	if alters.is_empty():
		return null
	
	if alters[0].score <= 0.0:
		return null
	
	return alters[0].alter

func score_(from:Vector3, color:Color) -> float:
	if capture_progress < 1.0:
		return 0.0
		
	if not find_candle_(color):
		return 0.0

	return 1.0 / max(from.distance_to(position), 0.00001)
