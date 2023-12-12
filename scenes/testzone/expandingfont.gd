extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _physics_process(delta):
    get_font('font').size = get_font('font').size+1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
