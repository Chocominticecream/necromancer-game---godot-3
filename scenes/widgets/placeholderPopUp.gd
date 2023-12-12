extends Node2D

var TweenNode
var POPTIME = 0.4

func _ready():
    TweenNode = get_node("Tween")
    
func popUp():
    TweenNode.interpolate_property(self, "global_position", get_global_position(), Vector2(get_global_position().x , get_global_position().y - 200), POPTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
    TweenNode.start();
    yield(get_tree().create_timer(POPTIME), "timeout");
    self.queue_free()
