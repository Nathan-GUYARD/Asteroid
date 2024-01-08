extends Label

class_name TimeLabel


@export var label : String = "Temps"

func set_time(time : int) -> void:
	
	var minutes : int = (time/60)%60
	var second : int = time%60
	var hour : int = time/3600
	
	text = "{label} : {hours}h {minutes}min {seconds}s".format({"label":label, "hours":hour, "minutes":minutes, "seconds":second})
