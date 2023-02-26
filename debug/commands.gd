extends Node

func help() -> String:
	var n := Node.new()
	n.queue_free()
	var res := ""
	for method in get_method_list():
		if n.has_method(method.name):
			continue
		if method.name[0] == "_":
			continue
		res += method.name + "\n"
	return res

func echo(value) -> String:
	return str(value)

func restart_server() -> int:
	_restart_server.rpc_id(1)
	return 0
	
@rpc("any_peer", "call_local")
func _restart_server():
	print("sam")
	get_tree().reload_current_scene()
