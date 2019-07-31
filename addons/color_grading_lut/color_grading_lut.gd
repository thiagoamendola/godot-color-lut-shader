tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("ColorGradingTool", "Node", preload("color_grading_tool.gd"), preload("icon.png"))

func _exit_tree():
    remove_custom_type("ColorGradingTool")
