extends Node2D

#this script contains button logic and top down logic

#universal functions
var deckfunc = Universalfunc.new()

#tweening variables
var tweenLookDown;
var tweenLookUp;

#positions values
var yposup = 640
var yposdown = 1000

#player stats
var stats = dataManager.loaddata()
var battlestart = true

#debug variables
onready var scroll = -1

#custom signals


#state machine for what happens during phases
enum{
     playPhase
     battlePhase
     heldCard
     playingCard
    }
    
func _process(delta):
     match dataManager.phase:
        playPhase:
            $go_button/goclick.disabled = false
        battlePhase:
            $go_button/goclick.disabled = true
        #this code activates when the player is selecting a card
        heldCard:
            $go_button/goclick.disabled = true
        #when card aniamtion is played
        playingCard:
            $go_button/goclick.disabled = true

func _ready():
     $decks.cardloader(stats.staticdeck.duplicate())
     onStart()

func _physics_process(delta):
     pass

#MIGHT DELETE!!!!!DEAD CODE----------------------------------   
#func _on_lookdown_pressed():
#     get_node("lookdown").visible = false;
#
#     var cameranode = get_node("Camera2D")
#     tweenLookDown.interpolate_property(cameranode, "position", cameranode.get_position(), Vector2(cameranode.position.x, yposdown), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT);
#     tweenLookDown.start();
#
#     get_node("lookup").visible = true;
#
#
#func _on_lookup_pressed():
#     get_node("lookup").visible = false;
#
#     var cameranode = get_node("Camera2D")
#     tweenLookUp.interpolate_property(cameranode, "position", cameranode.get_position(), Vector2(cameranode.position.x, yposup), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT);
#     tweenLookUp.start();
#
#     get_node("lookdown").visible = true;
    
#----------------------------------------------------------   

#put all code that plays at the start of the turn here
func onStart():
     initialise()
     startShuffle()
    
func startShuffle():
     var cameranode = get_node("Camera2D")
     #code to play animation where card shuffles into hand here
     var drawval = 5
     $decks.carddrawer(drawval)
     #--------------------------------------------------------
     #code that disables button when cards are drawn 
     var cardsample = preload("res://scenes/widgets/Basecard.tscn").instance()
     yield(get_tree().create_timer(drawval*cardsample.DRAWTIME), "timeout");
     cardsample.queue_free()
     dataManager.phase = playPhase


func _on_goclick_pressed():
     dataManager.phase = battlePhase
     deckfunc.genericPopUp(get_node("/root/levelFull/Camera2D/battleUI"), $go_button/goTarget , "End turn!")
     #play end turn function in decks
     $decks.endturn()
     #scrolls up to the battle view
     var timeout = 0
     $go_button/goclick.disabled = true
     for card in $decks/hand.get_children():
         timeout += card.DRAWTIME
     yield(get_tree().create_timer(timeout), "timeout");
    
     for cardslot in $cardslots.get_children():
       if cardslot.playedCard != null:
         #execute attack logic for the cardslot
         cardslot.attack()
         yield(get_tree().create_timer(0.4), "timeout");
     
     yield(get_tree().create_timer(0.1), "timeout");
     $energy.refillEnergy()
    
     startShuffle();
    
func initialise():
    $hero.maxhp = dataManager.playerStats.maxhealth
    $hero.hp = dataManager.playerStats.health
    
    $enemy.maxhp = dataManager.enemyStats.health
    $enemy.hp = dataManager.enemyStats.health
    
    $energy.maxenergy = dataManager.playerStats.energy
    $energy.energy = dataManager.playerStats.energy

#signal functions
func reParentChild(card, target):
    var targetcard = card
    
    #save position and scale before reparenting
    var startGlob = targetcard.global_position
    var startScale = targetcard.scale
    #gets grandparent scale 
    var parentScale = targetcard.get_parent().get_parent().scale
    #reparent the child to target node
    card.get_parent().remove_child(targetcard)
    target.add_child(targetcard)
    #reset values
    targetcard.global_position = startGlob

func debugprinter():
    for i in stats.staticdeck:
         print(i)


func _on_debugbutton_pressed():
     scroll += 1
     if scroll > len(stats.staticdeck)-1:
        scroll = -1
        for n in get_node("/root/level/decks/hand").get_children():
            get_node("/root/level/hand").remove_child(n)
            n.queue_free()
     else:
        var childcard = stats.staticdeck[scroll].duplicate()
        childcard.position.y -= 500
        get_node("/root/level/hand").add_child(childcard)
        

    

        
