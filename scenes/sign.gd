extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D  


func _ready():
	interaction_area.interact = Callable(self, "_show_tutorial")

func _show_tutorial():
	pass



