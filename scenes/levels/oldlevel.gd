extends Node2D

#tweening variables
var tweenLookDown;
var tweenLookUp;

#positions values
var yposup = 640
var yposdown = 1000

#player stats
var stats = Singleton.loaddata()
var battlestart = true

#debug variables
onready var scroll = -1

#custom signals
signal loadcards(deck)
signal drawcards(drawno)
signal endturn()

func _ready():
     tweenLookDown = get_node("Camera2D/lookDownTween")
     tweenLookUp = get_node("Camera2D/lookDownTween")
     connect("drawcards", get_node("decks"), "carddrawer")
     connect("loadcards", get_node("decks"), "cardloader")
     connect("endturn", get_node("decks"), "endturn")
     emit_signal("loadcards", stats.staticdeck.duplicate())
     startShuffle()

func _physics_process(delta):
     pass
    
func _on_lookdown_pressed():
     get_node("lookdown").visible = false;
     
     var cameranode = get_node("Camera2D")
     tweenLookDown.interpolate_property(cameranode, "position", cameranode.get_position(), Vector2(cameranode.position.x, yposdown), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT);
     tweenLookDown.start();
     
     get_node("lookup").visible = true;


func _on_lookup_pressed():
     get_node("lookup").visible = false;
     
     var cameranode = get_node("Camera2D")
     tweenLookUp.interpolate_property(cameranode, "position", cameranode.get_position(), Vector2(cameranode.position.x, yposup), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT);
     tweenLookUp.start();
     
     get_node("lookdown").visible = true;

#put all code that plays at the start of the turn here
func startShuffle():
     var cameranode = get_node("Camera2D")
     
     get_node("go button/goclick").visible = false;
     
     #pause for a little, allow player to view the battle view for a second
     yield(get_tree().create_timer(1.0), "timeout");
     #tween down
     tweenLookDown.interpolate_property(cameranode, "position", cameranode.get_position(), Vector2(cameranode.position.x, yposdown), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT);
     tweenLookDown.start();
     yield(get_tree().create_timer(1.0), "timeout")
    
     #code to play animation where card shuffles into hand here
     emit_signal("drawcards", 5)
     #--------------------------------------------------------
     get_node("lookup").visible = true;
     get_node("go button/goclick").visible = true;


func _on_goclick_pressed():
     var cameranode = get_node("Camera2D")
    
     get_node("lookdown").visible = false;
     get_node("lookup").visible = false;
     get_node("go button/goclick").visible = false;
     get_node("go button/goclick").rect_rotation = 90;
     
     #play end turn function in decks
     emit_signal("endturn")
     #scrolls up to the battle view
     var timeout = 0
     for card in $decks/hand.get_children():
         timeout += card.DRAWTIME + card.DRAWTIME/3
     yield(get_tree().create_timer(timeout), "timeout");
     tweenLookUp.interpolate_property(cameranode, "position", cameranode.get_position(), Vector2(cameranode.position.x, yposup), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT);
     tweenLookUp.start();
     yield(get_tree().create_timer(3.0), "timeout");
     
     #code to play battle animation here
     
     #shuffle the cards into the hand after go action executed
     startShuffle();

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
        
