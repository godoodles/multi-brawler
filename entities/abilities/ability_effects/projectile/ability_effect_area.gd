extends AbilityEffect

@export var area:float = 15.0

func _ready() -> void:
	super._ready()
	
	# wait for physics_init
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for node in $Area.get_overlapping_bodies():
		velocity = position.direction_to(node.position)
		apply(node)
