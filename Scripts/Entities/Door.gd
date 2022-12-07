extends StaticBody

export var this_Id := 0
export var next_Scene := "TestLevel0"
export var entrance_Id := 0
export var locked := false
export var knob_Missing := false

func _ready():
	if knob_Missing:
		$Knob.visible = false

func is_available():
	return locked or knob_Missing
	
func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"locked" : locked,
		"knob_Missing" : knob_Missing
	}
	return save_dict

func looks_at():
	if knob_Missing:
		$KnobLack.visible = true
		return true
	else:
		return false

func stops_looking():
	if $KnobLack.visible:
		$KnobLack.visible = false
