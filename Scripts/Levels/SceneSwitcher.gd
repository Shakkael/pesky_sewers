extends Spatial

var Next_Scene
var Door

func _on_Player_doorFound(scene, doorId):
	if !$Cooldown.is_stopped():
		return
	scene = ("res://Scenes/Levels/"+scene+".tscn")
	Next_Scene = load(scene).instance()
	Door = Next_Scene.get_door(doorId)
	get_tree().paused = true
	$Cooldown.start()
	$Player.reasoning = "level_change"
	$Player.additionals = null
	$"/root/Sound_Control".play_Transition(0)
	$Player/AnimPlayer.play("Blackout")

func _on_Player_blackedOut(reason,additional):
	if reason == "level_change":
		get_child(2).queue_free()
		add_child(Next_Scene)
		if Next_Scene.is_in_group("connect"):
			Next_Scene.connect("unblock",self,"_do_unblock")
		$Player.global_transform.basis = Door.get_node("Position").global_transform.basis
		$Player.global_transform.origin = Door.get_node("Position").global_transform.origin
		$Player/AnimPlayer.play("Blackoff")
	elif reason == "unblock":
		get_child(2).unblock_door(additional)
		$"/root/Sound_Control".play_Event(0)
		$Player/AnimPlayer.play("Blackoff")

func _on_Player_blackedOff():
	get_tree().paused = false

func _do_unblock(path):
	get_tree().paused = true
	$Player.reasoning = "unblock"
	$Player.additionals = path
	$Player/AnimPlayer.play("Blackout")
