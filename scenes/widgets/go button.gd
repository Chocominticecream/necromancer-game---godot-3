extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

#test entering and exiting functions

func _on_goclick_mouse_entered():
       get_node("goclick").rect_rotation = 100;

func _on_goclick_mouse_exited():
       get_node("goclick").rect_rotation = 90;

