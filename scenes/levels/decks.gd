extends Node2D

#this script contains deck and hand logic

#these global variables decide cardspread
#ew global variables 
var cardspreadmax = 0.20
var cardspreadval = cardspreadmax

#signals
signal changeEnergy(value, factor)
signal checkEnergy(value, node)

#deck that stores deck data in battle
onready var drawdeck = []
onready var discarddeck = []

#for card state machine
enum{
    inHand #check in hand, no focus
    inPlay #check in play, already assigned to a cardslot
    inMouse #check if its held in the mouse (ready to be played)
    focusInHand #check if in hand, focussing
    moveDrawnCardToHand #check if card is being moved to hand
    reOrganiseHand #reorganise (card is being moved to hand)
    discardCard #card is being discarded to the pile
    holdingCard #card is being held(discontinued)
    inSlot #card is held in mouse and about to be played into a cardslot
    inDeck #card is in a deck
    }

#for phase state machine    
enum{
     playPhase
     battlePhase 
     playingCard
     heldCard
    }
    
func _ready():
    connect("changeEnergy", get_node("/root/levelFull/Camera2D/battleUI/energy"), "changeEnergy")
    connect("checkEnergy", get_node("/root/levelFull/Camera2D/battleUI/energy"), "energyCheck")
    randomize()
    


#play a spell card

#surely is there a better way to execute the methods for playing the spell cards?
#i rather have this method inside the card itself...
func _input(event):
    #logic check
    if(event.is_action_pressed("left_click")) and dataManager.selectedCard != null and dataManager.phase == heldCard:
      if get_tree().get_nodes_in_group("hovered").empty() and dataManager.selectedCard.get_class() == "spellCard":
         #energy check (check if theres enough energy to play)
         emit_signal("checkEnergy", dataManager.selectedCard.energy, dataManager.playSpell)
           
    else:
      pass
        
        
func playSpellcard():
     dataManager.selectedCard.focus.play("simpleUnfocus")
     var idx = dataManager.selectedCard.get_index()
     emit_signal("changeEnergy", int(dataManager.selectedCard.energy), false)
            
     moveToDiscard($hand.get_child(idx))
            
     dataManager.phase = playPhase
     dataManager.selectedCard.resetStats()
     dataManager.selectedCard = null
            
     yield(get_tree().create_timer($hand.get_child(idx).DRAWTIME), "timeout")
     reorganiser()
     yield(get_tree().create_timer(0.01), "timeout")
     reorganiser()
     yield(get_tree().create_timer(0.2), "timeout")
            
     #warp the mouse so that the mouse can check for cards again 
     get_viewport().warp_mouse(get_global_mouse_position()-Vector2(0,100))
     yield(get_tree().create_timer(0.2), "timeout")
     get_viewport().warp_mouse(get_global_mouse_position()-Vector2(0,100))
           
func cardloader(deck):
     drawdeck = deck
     $drawPile/count.bbcode_text = "[center]" + str(len(drawdeck)) + "[/center]"
     drawdeck.shuffle()

#remove all cards in hand to the discard pile, end turn
func endturn():
    #print("stray nodes")
    #print_stray_nodes()
    for card in $hand.get_children():
        moveToDiscard(card)
        yield(get_tree().create_timer(card.DRAWTIME), "timeout");
        reorganiser()

#draw top cards from the deck
func carddrawer(drawno):
     var drawglobal = $drawPile
     var drawvalue = drawno
     
     #append the top card to hand and then remove it 
     for i in range(drawvalue):
         if len(drawdeck) < 1:
            reshuffleIntoDraw()
            if len(drawdeck) < 1:
               break
          
         var childcard = drawdeck[0]
         
         #reorganise the hand
         $hand.add_child(childcard)
         #to be used to play card drawing animation
         childcard.global_position = drawglobal.global_position
         childcard.target = cardpositioner(i)
         childcard.targetrot = cardrotater(i)
         childcard.state = moveDrawnCardToHand
         yield(get_tree().create_timer(childcard.DRAWTIME), "timeout");
         childcard.z_index = 22
         childcard.z_index = childcard.startzindex
         $drawPile/count.bbcode_text = "[center]" + str(int($drawPile/count.text) - 1) + "[/center]"
         #if is_instance_valid(drawdeck[0]):
         #   drawdeck[0].free()
         drawdeck.erase(drawdeck[0])
         reorganiser()
        
     for i in range(drawvalue):
         pass
         
     #reorganise the hand one last time
     reorganiser()
     #warp the mouse so that the mouse can check for cards again 
     get_viewport().warp_mouse(get_global_mouse_position()-Vector2(0,100))

#take in a card object and move it to the discard
func moveToDiscard(card):
     card.target = $discardPile.global_position
     card.targetrot = 0
     discarddeck.append(card)
     card.state = discardCard
     $discardPile/count.bbcode_text = "[center]" + str(int($discardPile/count.bbcode_text) + 1) + "[/center]"
    
func reshuffleIntoDraw():
    
     for i in range(len(discarddeck)):
         drawdeck.append(discarddeck[0])
         discarddeck.erase(discarddeck[0])
         $drawPile/count.bbcode_text = "[center]" + str(int($drawPile/count.bbcode_text) + 1) + "[/center]"
         $discardPile/count.bbcode_text = "[center]" + str(int($discardPile/count.bbcode_text) - 1) + "[/center]"
     drawdeck.shuffle()
     
#take an integer value and positions the card
func cardpositioner(i):
    
    var cardspread = cardspreadval
    
    var num_cards = $hand.get_child_count()-1
    var newposition
    
    var projresolution = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))
    var centreCardOval = projresolution * Vector2(0.5, 1.4)
    var Hor_rad = projresolution.x * 0.45
    var Ver_rad = projresolution.y * 0.4
    var angle = PI/2 + cardspread * (float(num_cards)/2 - num_cards)
    var ovalAngleVector = Vector2()
    
    angle+= cardspread * i 
    ovalAngleVector = Vector2(Hor_rad * cos(angle), -Ver_rad * sin(angle))
    newposition = centreCardOval + ovalAngleVector 
         #might need this later (- Vector2(67,100)/2)
    
    return newposition

#rotates the card accordingly after positioning them, take an integer
func cardrotater(i):
    var cardspread = cardspreadval
    var num_cards = $hand.get_child_count()-1
    
    var angle = PI/2 + cardspread * (float(num_cards)/2 - num_cards)
    var newrotation
    
    angle += cardspread * i
    newrotation = (90 - rad2deg(angle))/4
    return newrotation

#reogranise the hand (after drawing or discarding)
func reorganiser():
     var increment = 0
     #first find the amount of cildren to set cardspread accordingly
     for card in $hand.get_children():
         cardspreadval = cardspreadmax - 0.01 * increment
         increment += 1
     increment = 0  
     for card in $hand.get_children():
         card.target = cardpositioner(increment)
         card.targetrot = cardrotater(increment)
         card.startzindex = 1 + 2 * increment
         card.state = reOrganiseHand
         increment += 1
     cardspreadval = cardspreadmax
    
func reOrganiseNeighbors(index):
     #get number of children
     var cardNumb = $hand.get_child_count()-1
     #spread factor for cards with difference of two indexes
     var spreadFactor = 0.25
     #take up to -2 indexes and +2 indexes and move them when a card is selected
     if index-2 >= 0:
        var child = $hand.get_child(index-2)
        child.move(child.target + spreadFactor*Vector2(65,0), child.DRAWTIME/3)
     
     if index-1 >= 0:
        var child = $hand.get_child(index-1)
        child.move(child.target + Vector2(65,0), child.DRAWTIME/3)
     
     if index+2 <= cardNumb:
        var child = $hand.get_child(index+2)
        child.move(child.target - spreadFactor*Vector2(65,0), child.DRAWTIME/3)
     
     if index+1 <= cardNumb:
        var child = $hand.get_child(index+1)
        child.move(child.target - Vector2(65,0), child.DRAWTIME/3)
        
func resetNeighbors(index):
     #get number of children
     var cardNumb = $hand.get_child_count()-1
     #spread factor for cards with difference of two indexes
     var spreadFactor = 0.25
     #take up to -2 indexes and +2 indexes and move them when a card is selected
     if index-2 >= 0:
        var child = $hand.get_child(index-2)
        child.move(child.target, child.DRAWTIME/3)
     
     if index-1 >= 0:
        var child = $hand.get_child(index-1)
        child.move(child.target, child.DRAWTIME/3)
     
     if index+2 <= cardNumb:
        var child = $hand.get_child(index+2)
        child.move(child.target, child.DRAWTIME/3)
     
     if index+1 <= cardNumb:
        var child = $hand.get_child(index+1)
        child.move(child.target, child.DRAWTIME/3)

func setCard(playbool, card):
    if playbool:
        dataManager.selectedCard = card
    elif !playbool:
        dataManager.selectedCard = null
    
func debugprinter():
    print("drawdeck")
    print(drawdeck)
    print()
    print("discarddeck")
    print(discarddeck)
    

    
