extends Node

var horror_Humming = preload("res://Sounds/Ambient.ogg")

var open_Door_Wood = preload("res://Sounds/Door.ogg")

var move_Table = preload("res://Sounds/Table.ogg")

var ambients = [horror_Humming]
var transitions = [open_Door_Wood]
var events = [move_Table]

func play_Ambient(id):
	if id > len(ambients)-1:
		id = 0
	if $Ambient.stream != ambients[id]:
		$Ambient.stream = ambients[id]
	if not $Ambient.playing:
		$Ambient.play()

func play_Transition(id):
	if id > len(transitions)-1:
		id = 0
	$Transition.stream = transitions[id]
	$Transition.play()

func play_Event(id):
	if id > len(events)-1:
		id = 0
	$Transition.stream = events[id]
	$Transition.play()
