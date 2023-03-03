class_name Slot
extends Marker3D

enum Type { 
	hand
}

@export var type:Type

func try_add(child) -> bool:
	if child == null:
		return false

	if type != child.slot:
		return false
	
	if not has_node("root"):
		return false
	
	if $root.get_child_count() != 2: # this is dumb
		return false
	
	$root.add_child(child)

	return true
