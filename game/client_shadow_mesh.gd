extends MeshInstance3D

@export_node_path("Node3D") var camera_path
@onready var cam : Node3D = get_node(camera_path)


func _enter_tree():
	show()


func _process(_delta):
	position = Vector3(cam.position.x, 1, cam.position.z+0.5)
