extends SceneTree

func _init():
    var theme = Theme.new()
    var bg_style = StyleBoxFlat.new()
    bg_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
    bg_style.border_width_left = 2
    bg_style.border_width_top = 2
    bg_style.border_width_right = 2
    bg_style.border_width_bottom = 2
    bg_style.border_color = Color(0.4, 0.4, 0.5, 1.0)
    bg_style.corner_detail = 1
    
    theme.set_stylebox("panel", "Panel", bg_style)
    theme.set_stylebox("panel", "PanelContainer", bg_style)
    
    ResourceSaver.save(theme, "res://PixelTheme.tres")
    print("Theme saved.")
    quit()