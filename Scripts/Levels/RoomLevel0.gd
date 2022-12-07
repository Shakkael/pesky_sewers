extends Spatial

var playerSpawn := Vector3(0,3,0)

func _ready():
	$"/root/Sound_Control".play_Ambient(0)

func get_door(eId):
	for node in get_node("Doors").get_children():
		if node.this_Id == eId:
			return node
	pass
