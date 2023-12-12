extends Control

var dbloader = Universalfunc.new()

func _ready():
    dbloader.copyDatabase()

func _on_startButton_pressed():
    get_tree().change_scene("res://scenes/levels/Map.tscn")

func _on_quitButton_pressed():
    get_tree().quit()
