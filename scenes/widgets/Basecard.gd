extends Node2D
class_name baseCard
#dimensions for art purposes
#dimensions of image ref are 460 x 256

#miscellaneous variables for calculation purposes
export (String) var printedname setget nameset, nameget
export (Array) var effect setget effectset, effectget
export (int) var energy setget energyset, energyget
export (String) var description setget descset, descget
export (String) var type

#drag and drop variable
var group = ""
var selected = false
var draggable = false
var startzindex = z_index

#animations
onready var animation = $cardflipper
onready var focus = $cardfocuser
var projresolution = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))
#these variables enable the system to check every frame if the card is ontop and play the animations
#only once
var playfocus = true
var playunfocus = true
var animationFinish = false
var tweenFinish = false

#tween
var TweenNode
var DRAWTIME = 0.2
var tweened = false

#rotation and position
var target
var targetrot
var focustarget
var focusrot

#signals
signal signalNeighbors(index)
signal resetNeighbors(index)
signal setCard(playbool, card) #true to send card in play, false to release the card. Sends a signal to decks script to detect held card
signal resetpos()

#for state machine of the card
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
    
#state machine for the battlefield
enum{
     playPhase
     battlePhase
     playingCard
     heldCard
    }
    
var state = inHand

#scaling variables to change font size programatically (cuz font size doesnt inherit)
onready var typeLabels =  load("res://assets/fonts/Basecard.tres")
#default sizes for scaling
var typeLabelsSize = 18 #also name label size
var descLabelSize = 14
var energyLabelSize = 30
var scaleFactor = 1
var offset = 0

#----------------------------setters and getters---------------------------------
    
func nameset(val):
    $textNodes/Name.bbcode_text = "[center]" + val + "[/center]"
    $spriteNodes/textNodes/Name.bbcode_text = "[center]" + val + "[/center]"
    printedname = val
    
func nameget():
    return printedname
    
func effectset(val):
    effect = val
    
func effectget():
    return effect

func energyset(val):
    $textNodes/energyCost.bbcode_text = "[center]" + str(val) + "[/center]"
    $spriteNodes/textNodes/energyCost.bbcode_text = "[center]" + str(val) + "[/center]"
    energy = val

func energyget():
    return energy
    
func descset(val):
    $textNodes/bigDesc.bbcode_text = "[center]" + val + "[/center]"
    $spriteNodes/textNodes/Desc.bbcode_text = "[center]" + val + "[/center]"
    description = val

func descget():
    return description

#--------------------------------end of setters/getters-------------------------------------

func _ready():
    TweenNode = get_node("cardTween")
    connect("signalNeighbors", get_node("/root/levelFull/Camera2D/battleUI/decks"), "reOrganiseNeighbors")
    connect("resetNeighbors", get_node("/root/levelFull/Camera2D/battleUI/decks"), "resetNeighbors")
    connect("resetpos",get_node("/root/levelFull/Camera2D/battleUI/decks"), "reorganiser")
    connect("setCard",get_node("/root/levelFull/Camera2D/battleUI/decks"), "setCard")
    
    animation.playback_speed = 1/DRAWTIME
    focus.playback_speed = 1/DRAWTIME
    
#    $spriteNodes/scalerSize/glow.visible = false
#    for node in $textNodes.get_children():
#        var fontVal = get_card_label_font(node)
#        set_card_label_font(node, fontVal)
        
#add one for other textnodes later!!!
        
#func _input(event):
#    if event is InputEventMouseMotion:
#        focus.play("simpleFocus")

func get_card_label_font(label: Label) -> Font:
    var label_font = label.get("custom_fonts/font").duplicate()
    return(label_font)
    
func set_card_label_font(label: Label, font: Font) -> void:
    label.add_font_override("font", font)
    
func _process(delta):
    scaleFactor = $spriteNodes/scalerSize.scale.x / 0.6
#    if selected and draggable and state == focusInHand and dataManager.phase == playPhase:
#       followMouse() 
           
func _physics_process(delta):
    
    match state:
       inHand:
        $spriteNodes/scalerSize/cardBack.visible = false
       inPlay:
        pass
       inMouse:
        pass
       #long series of checks so that the player can only select the top most card
       focusInHand:
          if onTop() and dataManager.phase == playPhase:
              z_index = 22
              var focuspt = target
              #1.62
              focuspt.y = projresolution.y*1.5 - $spriteNodes/scalerSize/card.texture.get_height()*scale.y*1.3
              move(focuspt)
              rotater(0)
              emit_signal("signalNeighbors", get_index())
              if playfocus:
                focus.play("simpleFocus")
                playfocus = false
                playunfocus = true
                tweened = false

          elif dataManager.phase == playPhase:
            z_index = startzindex
            move()
            rotater()
            if playunfocus:
              focus.play("simpleUnfocus")
              $spriteNodes/scalerSize/glow.visible = false
              playfocus = true
              emit_signal("resetNeighbors", get_index())
              playunfocus = false
       moveDrawnCardToHand:
        z_index = startzindex
        z_index = 22
        move()
        rotater()
        #custom tweening
        animation.play("flipToFront")
        tweened = false
        state = inHand
       reOrganiseHand:
        if $spriteNodes/scalerSize/glow.visible:
            $spriteNodes/scalerSize/glow.visible = false
            focus.play("simpleUnfocus")
            emit_signal("resetNeighbors", get_index())
        z_index = 22
        z_index = startzindex
        move()
        rotater()
        tweened = false
        state = inHand
       discardCard:
        move()
        rotater()
        animation.play("flipToBack")
        state = inDeck
        yield(get_tree().create_timer(DRAWTIME), "timeout");
        get_parent().remove_child(self)
        tweened = false
       inDeck:
         pass
       inSlot:
         pass
       
        
#    if state != focusInHand:
#       selected = false
#other functions

func followMouse():
    global_position = get_global_mouse_position()

#LOSER CODEEEE vvvvvvvvvvvvvvvvv-----------------------------
#func textScaler(label, defsize):
#    if label.get_font('font').size < scaleFactor*defsize:
#        label.get_font('font').size = label.get_font('font').size+(1/DRAWTIME)
#    if label.get_font('font').size > scaleFactor*defsize:
#        label.get_font('font').size = label.get_font('font').size-(1/DRAWTIME)
#
#func instantTextScaler(label, defsize):
#     label.get_font('font').size = scaleFactor*defsize
#------------------------------------------------------------
    
    
func _on_cardcollision_input_event(viewport, event, shape_idx):
    #hold the card in the hand
    if (event.is_action_pressed("left_click")):
        if onTop() and state == focusInHand:
            if dataManager.phase != heldCard and $spriteNodes/scalerSize/glow.visible:
              dataManager.phase = heldCard
              state = inMouse
              emit_signal("setCard", true, self)
              var focuspt = Vector2(0,0)
              focuspt.y = projresolution.y * 0.5
              focuspt.x = projresolution.x * 0.2
              move(focuspt)
#            elif dataManager.phase == heldCard and $spriteNodes/scalerSize/glow.visible:
              
    
    #focus function that replaces mouse entered signal so that it can check every frame
    #this function plays the focus animation when the card is in the hand
    if event is InputEventMouseMotion:
            add_to_group(group + "hovered")
            if get_parent().name == "hand":
               add_to_group(group + "hand")
            if dataManager.phase == playPhase and onTop():
              match state:
                inHand, reOrganiseHand:
                  emit_signal("signalNeighbors", get_index())
                  state = focusInHand
                

func _input(event):
    if(event.is_action_released("left_click")) and state == inMouse:
        if dataManager.selectedCard != null and dataManager.phase == heldCard and state == inMouse:
          dataManager.phase = playPhase
          state = reOrganiseHand
          resetStats()
          emit_signal("setCard", false, self)
        

#for clicking and dragging
#            if onTop():
#              self.z_index = 22
#              selected = true
#        else:
#            selected = false
#            self.z_index = startzindex

func move(val = target, draw = DRAWTIME):
    TweenNode.interpolate_property(self, "global_position", get_global_position(), val, DRAWTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
    TweenNode.start();
    
func rotater(val = targetrot, draw = DRAWTIME):
    TweenNode.interpolate_property(self, "rotation_degrees", get_rotation_degrees(), val, DRAWTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
    TweenNode.start();
    
func focustween(val = focustarget):
    TweenNode.interpolate_property(self, "global_position", get_global_position(), val, DRAWTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
    TweenNode.start();
    
func focusrot(val = focusrot):
    TweenNode.interpolate_property(self, "rotation_degrees", get_rotation_degrees(), val, DRAWTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
    TweenNode.start();
    
#only call tweens onces in the state machine to reduce jitter
func calltweensonce():
     if tweened == false:
        move()
        rotater()
     tweened = true
    
#top check for hand cards
func onTop():
    for card in get_tree().get_nodes_in_group(group + "hand"):
        if card.get_index() > get_index():
            return false
    return true

#top check for cards anywhere else
func onTopZ():
    for card in get_tree().get_nodes_in_group(group + "hovered"):
        if card.z_index > z_index:
            return false
    return true
    
#maybe have seperate animation players?
func _on_cardcollision_mouse_entered():
     pass

func _on_cardcollision_mouse_exited():
    remove_from_group(group + "hovered")
    remove_from_group(group + "hand")
    if dataManager.phase == playPhase:
      playfocus = true
      match state:
        focusInHand:
          emit_signal("resetNeighbors", get_index())
          #animation player plays again for mouse exited
          focus.play("simpleUnfocus")
          $spriteNodes/scalerSize/glow.visible = false
          state = reOrganiseHand
        
func resetStats():
    playfocus = true
    playunfocus = true
    animationFinish = false
    tweenFinish = false


func _on_cardfocuser_animation_finished(anim_name):
    animationFinish = true


func _on_cardfocuser_animation_started(anim_name):
    animationFinish = false
    
func _on_cardTween_tween_all_completed():
    tweenFinish = true


func _on_cardTween_tween_started(object, key):
    tweenFinish = false
    
