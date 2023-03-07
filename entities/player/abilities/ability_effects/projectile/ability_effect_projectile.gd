extends AbilityEffect

@export var speed:float = 15.0
@export var penetration:int = 1

var hit_cache := []

func _ready() -> void:
	super._ready()
	look_at(position + velocity)

func _process(delta):
	position += velocity * delta * speed

func _area_entered(area):
	if penetration <= 0:
		return

	penetration -= 1
	
	if hit_cache.has(area):
		return

	hit_cache.push_back(area)

	apply(area.get_parent())

	if penetration <= 0:
		if multiplayer.is_server():
			queue_free()
