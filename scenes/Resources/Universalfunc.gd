extends Resource
class_name Universalfunc

#list of functions that are used throughout the code

func copyDatabase():
    var original_sql_file = File.new()
    original_sql_file.open("res://assets/gamedata.cdb", File.READ)
    var original_sql_file_buffer = original_sql_file.get_buffer(original_sql_file.get_len())
    original_sql_file.close()
   
    var new_sql_file = File.new()
    var dir = Directory.new()
    dir.make_dir("user://data/")
    new_sql_file.open("user://gamedata.cdb", File.WRITE)
    new_sql_file.store_buffer(original_sql_file_buffer)
    new_sql_file.close()
    

#read the dataabase
func readDatabase():
     var data_read = File.new()
     if OS.get_name() == "HTML5":
        #fix for web versions
        #not save data so it should be ok
        data_read.open("res://assets/gamedata.cdb", File.READ)
     else:
        data_read.open("user://gamedata.cdb", File.READ)
     var data_cbd = parse_json(data_read.get_as_text())
     data_read.close()
     return data_cbd

#using a for loop, this function will find a card or effect in the database using the id value
#returns a dictionary
func findCard(data_cbd, idvalue, sheettype, targetcolumn):
     var targetentry
     for sheet in data_cbd['sheets']:
         if sheet['name'] == sheettype:
            for entry in sheet["lines"]:
                if entry[targetcolumn] == idvalue:
                   targetentry = entry.duplicate()
     return targetentry

#this function creates a custom description based on the card's effect
#to be called from the card, take the card's type string and effect array
func createEffectDesc(effectlist, type):
     #return empty string if effect array is empty
     if len(effectlist) < 1:
        return ''
    
     var sheetTarget #sheetraget value for finding a effect's description
     var effectdesc = '' #final effect description, to be returned
     var data_cbd = readDatabase() #read database
     if type == 'summon':
        sheetTarget = 'summon_effect_sheet'
     elif type == 'spell':
        sheetTarget = 'spell_effect_sheet'
    
     for effect in effectlist:
         var carddict = findCard(data_cbd, effect['effectID'], sheetTarget, 'effectName')
         var substring = carddict['description']
         #edit the description with the appropriate value
         effectdesc += substring.replace('[...]', effect['value']) + '. '
     return effectdesc

#create a card using the base card, take in a dictionary
func createCard(carddict, type):
     #load all card values into variables
     var base
     #create a base empty card
     if type == 'summon_data':
       base = load("res://scenes/widgets/Basesummoncard.tscn").instance()
       var att = carddict["attack"]
       var hp = carddict["hp"]
       var printedname = carddict["printedName"]
       var energy = carddict["energyCost"]
       var effect = carddict["effect"]
       var description = carddict["description"]
    
       base.attack = att
       base.hp = hp
       base.printedname = printedname
       base.effect = effect
       base.energy = energy
       base.description = description + '. ' + createEffectDesc(effect, base.type)
    
     elif type == 'spell_sheet':
       base = load("res://scenes/widgets/Basespellcard.tscn").instance()
       var printedname = carddict["printedName"]
       var energy = carddict["energyCost"]
       var effect = carddict["effect"]
       var description = carddict["description"]
       
       base.printedname = printedname
       base.effect = effect
       base.energy = energy
       base.description = description + '. ' + createEffectDesc(effect, base.type)
     
     return base

#spawn a generic pop up message to a node
#this function behaves very weirdly, it will not spawn text properly when passing self as a reference
#but does fine with getnode and $node
func genericPopUp(spawnParent, nodepos, textMsg):
    var popLabel = load("res://scenes/widgets/placeholderPopUp.tscn").instance()
    popLabel.get_node("Label").text = textMsg
    #center the message on the object
    var centrepos = nodepos.get_global_position()
    popLabel.global_position = centrepos
    spawnParent.add_child(popLabel)
    popLabel.popUp()

    
func _ready():
    copyDatabase()
