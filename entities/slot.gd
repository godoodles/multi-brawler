class_name Slot
extends Marker3D

enum Type { 
	hand,
	leg,
	carry,
	body,
	head
}

@export var type:Type

func try_add(child, allow_replace := false) -> bool:
	if child == null:
		return false

	if type != child.slot:
		return false

	for c in get_children():
		if c is Ability or c is AbilityAttack:
			if not allow_replace:
				return false
			else:
				c.get_parent().remove_child(c)
				c.queue_free()
				break

	add_child(child)

	return true
