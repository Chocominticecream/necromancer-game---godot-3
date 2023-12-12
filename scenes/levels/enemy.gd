extends Node2D

var maxhp = 0
export (int) var hp = 0 setget hpset, hpget 

func hpset(val):
    $hp.bbcode_text = "[center]" + str(val) + "/" + str(maxhp) + "[/center]"
    hp = val 

func hpget():
    return hp

func changeHp(value, factor):
     if factor:
        hpset(hp + value)
     elif !factor:
        hpset(hp - value)
        
func _ready():
    pass # Replace with function body.

