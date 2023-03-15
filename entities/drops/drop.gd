extends Node3D

var lock

func _ready() -> void:
	set_physics_process(false)
	animate_fall()
	position.y = 0

func _physics_process(delta:float) -> void:
	if lock:
		position = position.move_toward(lock.global_position, delta * 15.0)

func _area_entered(area) -> void:
	if lock:
		return

	lock = area.get_parent()
	
	set_physics_process(true)
	
	# if the drop spawns inside the body, the collision entered signalis never emitted
	# so manually check here
	if $Area3D.overlaps_body(lock):
		_body_entered(lock)

func _body_entered(body):
	if body == lock:
		$Sprite3D.visible = false
		$ShadowDecal.visible = false
		ImpactText.popin(self, "+1", Color.GREEN).connect("done", self.queue_free)
		set_physics_process(false)

func animate_fall() -> void:
	create_tween().tween_property($Sprite3D, "position:y", $Sprite3D.position.y, 0.1).set_ease(Tween.EASE_IN)
	$Sprite3D.position.y = 1.5
