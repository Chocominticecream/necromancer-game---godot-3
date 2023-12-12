extends cardSlot
class_name cardSlotSummon


func _ready():
    pass # Replace with function body.

func _on_Area2DSummon_input_event(viewport, event, shape_idx):
    #summon logic
    if (event.is_action_released("left_click")) and dataManager.phase == heldCard:
      if dataManager.selectedCard != null and dataManager.selectedCard.get_class() == "summonCard" and playedCard == null and dataManager.selectedCard.animationFinish and dataManager.selectedCard.tweenFinish:
          #energy check
          emit_signal("getEnergy", dataManager.selectedCard.energy, dataManager.playSummon, get_index())
    
    if event is InputEventMouseMotion:
        print("morestuff")
        
func playSummoncard(idx):
    #assign played card to this node
    if get_index() == idx:
           playedCard = dataManager.selectedCard
           emit_signal("depleteEnergy", int(playedCard.energy), false)
           
           #empty the selectedCard holding variable
           dataManager.selectedCard = null
           #emit signals
           #reposition card upon reparent
           playedCard.focus.play("scaleToPlay")
           yield(get_tree().create_timer(0.3), "timeout");
           
        
           emit_signal("reParentChild", playedCard, self)
           #change phases and card state
           playedCard.state = inPlay
           playedCard.z_index = 0
           playedCard.startzindex = 0
           dataManager.phase = playPhase
           
           playedCard.move(global_position)
           playedCard.playfocus = true 
           emit_signal("reOrganiseHand")
           yield(get_tree().create_timer(0.2), "timeout");
           get_viewport().warp_mouse(get_global_mouse_position()-Vector2(0,100))
    else:
        return
    

func attack():
    playedCard.attack()
    yield(get_tree().create_timer(0.36), "timeout")
    emit_signal("depleteEnemyHp", int(playedCard.attack), false)

