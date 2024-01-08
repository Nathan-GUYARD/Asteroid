extends Label

class_name ScoreLabel


@export var label : String = "Score"

func set_score(score : int) -> void:
	text = "{label} : {score}".format({"label":label, "score":score})
