extends baseCard
class_name summonCard

#this is a summon card
export (int) var hp setget hpset, hpget
export (int) var attack setget attset, attget

onready var hplabel = $hpSprite/hp
onready var attacklabel = $attackSprite/attack

func hpset(val):
    $textNodes/hp.bbcode_text = "[center]" + str(val) + "[/center]"
    $spriteNodes/textNodes/hp.bbcode_text = "[center]" + str(val) + "[/center]"
    hp = val 

func hpget():
    return hp

func attset(val):
    $textNodes/attack.bbcode_text = "[center]" + str(val) + "[/center]"
    $spriteNodes/textNodes/attack.bbcode_text = "[center]" + str(val) + "[/center]"
    attack = val 

func attget():
    return attack
    
func get_class(): 
    return "summonCard"

#attack logic here   
func attack():
    var originalpos = get_global_position()
    move(get_global_position()+Vector2(0,50),0.1)
    yield(get_tree().create_timer(0.12), "timeout")
    move(get_global_position()+Vector2(0,-250),0.1)
    yield(get_tree().create_timer(0.12), "timeout")
    move(originalpos,0.1)
    yield(get_tree().create_timer(0.12), "timeout")

#summon logic here   
func summon():
    pass

func _ready():
    pass


