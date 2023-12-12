extends Node2D

#universal data
var stats = dataManager.playerStats
var enemy = dataManager.enemyStats
var cardfunc = Universalfunc.new()

onready var maindeck = []
# Called when the node enters the scene tree for the first time.

func _ready():
    createStarterDeck(maindeck)
    initialiseStats()
    initialiseEnemyStats()
    stats.staticdeck = maindeck
    
#might change this to directly edit save data in the database  
#create a starter deck by making 5 copies of the zombie card
#MAJOR CHANGES TO THIS
#to be placed into main level code instead of battle code
func createStarterDeck(deck):
     var data_cbd = cardfunc.readDatabase()
     var zombieentry = cardfunc.findCard(data_cbd, 0, 'summon_data', 'numID')
     var zombiecard = cardfunc.createCard(zombieentry, 'summon_data')
     
     var manaballentry = cardfunc.findCard(data_cbd, 0, 'spell_sheet', 'numID')
     var manaballcard = cardfunc.createCard(manaballentry, 'spell_sheet')
    
     for i in range(5):
         deck.append(zombiecard.duplicate())
     
     for i in range(5):
         deck.append(manaballcard.duplicate())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
func debugprinter():
    for i in stats.staticdeck:
         print(i)
        
func initialiseStats():
    stats.health = 50
    stats.maxhealth = 50
    stats.energy = 3
    
func initialiseEnemyStats():
    enemy.health = 50

func _on_testButton_pressed():
    #might have to use methods to pass data later on to free up memory
    #dataManager.passdata(stats)
    get_tree().change_scene("res://scenes/levels/levelFull.tscn")
