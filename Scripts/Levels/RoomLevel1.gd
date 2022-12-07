extends Spatial

var playerSpawn := Vector3(0,3,0)
signal unblock(path)

func _ready():
	$"/root/Sound_Control".play_Ambient(0)

func get_door(eId):
	for node in get_node("Doors").get_children():
		if node.this_Id == eId:
			return node

func unblock_door(_id):
	$Props/WardrobeEmpty.global_transform.origin.z = -3
	$Events/Unblock/ClearDoor.disabled = true
	$Doors/Door1.locked = false

func _on_Unblock_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("unblock","Doors/Door1")
