extends Area2D

@export var tracker_radius := 8.0

var tracked_entity : Player:
	get:
		return tracked_entity
	set(value):
		tracked_entity = value
		value.tree_exiting.connect(queue_free)


func _ready():
	$CollisionShape2D.shape.radius = tracker_radius + 1.0

func _physics_process(_delta):
	position = Vector2(tracked_entity.position.x, tracked_entity.position.z)


func _on_area_entered(area:Area2D):
	area.reveal()


func _on_area_exited(area):
	area.start_fadein()
