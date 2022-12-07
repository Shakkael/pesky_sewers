extends KinematicBody

onready var camera = $Pivot/Camera

export var PRONE_SPEED = 2
export var SPEED = 4
export var RUN_SPEED = 16

var gravity = -100
var max_speed = 8
var velocity = Vector3()
var material = 0

var reasoning = ""
var additionals = ""

var moving = false

var mouse_sensitivity = 0.008  # radians/pixel
var mouse_visible = false

signal doorFound(body)
signal blackedOut(reason,addition)
signal blackedOff()

var footsteps_Concrete = [preload("res://Sounds/FootStep1.ogg"),preload("res://Sounds/FootStep2.ogg"),preload("res://Sounds/FootStep3.ogg")]

var footsteps = [footsteps_Concrete]
enum {concrete}

var can_stand = []
var crouching := false

var looking_at

func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = true

func get_input():
	if Input.is_action_just_pressed("pause_menu"):
		if mouse_visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_visible = true
	
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
	input_dir = input_dir.normalized()
	
	if input_dir != Vector3.ZERO:
		moving = true
	else:
		moving = false
	
	if Input.is_action_pressed("run") and not Input.is_action_pressed("prone"):
		max_speed = RUN_SPEED
		$Footstep.wait_time = 8.0/RUN_SPEED
	elif Input.is_action_pressed("prone"):
		max_speed = PRONE_SPEED
		$Footstep.wait_time = 5.0/PRONE_SPEED
	else:
		max_speed = SPEED
		$Footstep.wait_time = 8.0/SPEED
		
	if Input.is_action_just_pressed("run"):
		$Footstep.stop()
	if Input.is_action_just_pressed("prone"):
		$Footsteps.unit_db = -15
		$Footstep.stop()
		duck()
	if !Input.is_action_pressed("prone") and len(can_stand) == 0 and crouching:
		transform.origin.y += 1.4
		$CollisionShape.transform.origin.y -= 0.7
		$CollisionShape.shape.set("height",3)
		$Footsteps.unit_db = 0
		$Footstep.stop()
		stand()
		
	return input_dir
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
	

func duck():
	crouching = true
	transform.origin.y -= 1.4
	$CollisionShape.transform.origin.y += 0.7
	$CollisionShape.shape.set("height",1.6)

func stand():
	crouching = false

func _physics_process(delta):
	var next_looking_at = $Pivot/Camera/RayCast.get_collider()
	if looking_at != null:
		if next_looking_at != looking_at and is_instance_valid(looking_at):
			if looking_at.has_method("stops_looking"):
				looking_at.stops_looking()
	looking_at = next_looking_at
	if looking_at != null:
		if looking_at.is_in_group("lookable"):
			var lacking_knob = looking_at.looks_at()
	
	velocity = Vector3.ZERO
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	if velocity.x != 0 and velocity.z != 0 and moving:
		footstepping()
	var collision = move_and_collide(velocity*delta)
	
	if collision:
		if collision.collider.is_in_group("door"):
			var door = collision.collider
			if !door.is_available():
				emit_signal("doorFound",door.next_Scene,door.entrance_Id)
		elif collision.collider.is_in_group("unlock"):
			pass

func footstepping():
	var sounds = footsteps[material]
	var random = randi()%len(sounds)
	if $Footstep.is_stopped():
		$Footstep.start()
		$Footsteps.play(0.2)
		$Footsteps.stream = sounds[random]

func _on_AnimPlayer_animation_finished(anim_name):
	if anim_name == "Blackout":
		emit_signal("blackedOut",reasoning,additionals)
	elif anim_name == "Blackoff":
		emit_signal("blackedOff")

func _on_CanStand_body_entered(body):
	if body.name != "Player":
		can_stand.append(body)


func _on_CanStand_body_exited(body):
	if body.name != "Player":
		can_stand.erase(body)

