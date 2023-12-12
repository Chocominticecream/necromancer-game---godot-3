extends Node

#playerinfo and phase status
var playerStats = Playerinfo.new()
var enemyStats = Enemyinfo.new()
var phase = mapPhase

#held card
onready var selectedCard = null

#phases
enum{
     playPhase
     battlePhase
     mapPhase
     }
    
#stupid fixy enum for playing cards
enum{
    playSummon
    playSpell
    }
    
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

func _ready():
    pass

#code to load player stats into the singleton for transfer between scenes
func passdata(resource):
    playerStats = resource

#code to load data from a singleton 
func loaddata():
    return playerStats

