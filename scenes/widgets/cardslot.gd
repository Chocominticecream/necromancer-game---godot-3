extends Node2D
class_name cardSlot

#stored card value here
onready var playedCard = null

#for state machine of the card
enum{
    inHand
    inPlay
    inMouse
    focusInHand
    moveDrawnCardToHand
    reOrganiseHand 
    discardCard  
    inDeck
    inSlot
    }

#state machine for the battlefield
enum{
     playPhase
     battlePhase
     playingCard
     heldCard
    }
    
#signals
signal reParentChild(card, target)
signal depleteEnemyHp(value,factor)
signal depleteEnergy(value, factor)
signal getEnergy(value)
signal reOrganiseHand()
signal connectSelf()

func _ready():
    connect("reParentChild", get_node("/root/levelFull/Camera2D/battleUI"), "reParentChild")
    connect("reOrganiseHand", get_node("/root/levelFull/Camera2D/battleUI/decks"), "reorganiser")
    connect("depleteEnemyHp", get_node("/root/levelFull/Camera2D/battleUI/enemy"), "changeHp")
    connect("depleteEnergy", get_node("/root/levelFull/Camera2D/battleUI/energy"), "changeEnergy")
    connect("getEnergy", get_node("/root/levelFull/Camera2D/battleUI/energy"), "energyCheck")
    connect("connectSelf", get_node("/root/levelFull/Camera2D/battleUI/energy"), "connectSlot")
    emit_signal("connectSelf", self)

func _on_Area2D_input_event(viewport, event, shape_idx):
     #note that clicking on a summon card while holding another card will not work as the below condition's code would 
     #already execute for what is included below
    
     #this is a check to see if the person is holding a card AND also inside the cardslot collision
    if event is InputEventMouseMotion:
        print("stuff")
        if dataManager.selectedCard != null:
           if dataManager.selectedCard.state == inMouse:
             dataManager.selectedCard.state = inSlot
    
    #testing purpose (call back cards)
    elif (event.is_action_pressed("left_click")):
      if playedCard != null and playedCard.onTopZ() and playedCard.state == inPlay and dataManager.selectedCard == null and dataManager.phase == playPhase:
           emit_signal("reParentChild", playedCard, get_node("/root/levelFull/Camera2D/battleUI/decks/hand"))
           emit_signal("reOrganiseHand")
           emit_signal("reOrganiseHand")
           playedCard = null
           yield(get_tree().create_timer(0.2), "timeout");
           get_viewport().warp_mouse(get_global_mouse_position()-Vector2(0,100))
        
func _on_Area2D_mouse_exited():
    if dataManager.selectedCard != null:
      dataManager.selectedCard.state = inMouse
