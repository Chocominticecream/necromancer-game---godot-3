extends Node2D

signal playSpell()
signal playSummon(idx)
signal setCard(playbool, card)

var allfunc = Universalfunc.new()

var maxenergy = 0
export (int) var energy = 0 setget energyset, energyget 

enum{
    playSummon
    playSpell
    }

func energyset(val):
    $energyAmt.bbcode_text = "[center]" + str(val) + "/" + str(maxenergy) + "[/center]"
    energy = val 
    
func changeEnergy(value, factor):
     if factor:
        energyset(energy + value)
     elif !factor:
        energyset(energy - value)

func energyget():
    return energy
    
func energyCheck(value, node, idx = 0):
    if energy >= value:
      if node == playSpell:
        emit_signal("playSpell")
      elif node == playSummon:
        emit_signal("playSummon", idx)
    else:
       allfunc.genericPopUp(get_node("/root/levelFull/Camera2D/battleUI"), get_node("/root/levelFull/Camera2D/battleUI/energy"), "Not enough energy!")
       dataManager.selectedCard.state = dataManager.reOrganiseHand
       dataManager.phase = dataManager.playPhase
       dataManager.selectedCard.resetStats()
       emit_signal("setCard", false, dataManager.selectedCard)
    
func refillEnergy():
    energyset(maxenergy)
    allfunc.genericPopUp(get_node("/root/levelFull/Camera2D/battleUI"), get_node("/root/levelFull/Camera2D/battleUI/energy"), "energy refilled!")
#weird fix again
func connectSlot(node):
    connect("playSummon", node, "playSummoncard")

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("playSpell", get_node("/root/levelFull/Camera2D/battleUI/decks"), "playSpellcard")
    connect("setCard",get_node("/root/levelFull/Camera2D/battleUI/decks"), "setCard")
    
