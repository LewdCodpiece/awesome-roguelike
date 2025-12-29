@tool
class_name LigneInventaire extends PanelContainer

@onready var panel_non_focus = preload("res://thèmes/style_box_control_panel_non_focus.tres")
@onready var panel_focus = preload("res://thèmes/style_box_control_panel_focus.tres")

func _on_focus_entered() -> void:
	add_theme_stylebox_override("panel", panel_focus)

func _on_focus_exited() -> void:
	add_theme_stylebox_override("panel", panel_non_focus)
