extends AbilityEffect

func _ready():
	super._ready()
	apply(get_node(original_target))
