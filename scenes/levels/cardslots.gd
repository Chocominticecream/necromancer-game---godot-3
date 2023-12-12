extends Node2D

#play the attack animations
func playAttack():
  for cardslot in get_children():
    if cardslot.playedCard != null:
       #execute attack logic for the cardslot
       cardslot.attack()
       yield(get_tree().create_timer(0.4), "timeout");

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.
