@tool
extends SceneTree

func _init():
    var files = [
        "res://scenes/ui/origin_select_ui.tscn",
        "res://scenes/ui/research_ui.tscn",
        "res://scenes/ui/crafting_ui.tscn"
    ]
    for file in files:
        var scene = ResourceLoader.load(file, "", ResourceLoader.CACHE_MODE_IGNORE)
        if scene:
            ResourceSaver.save(scene, file)
            print("Saved " + file)
    quit()
