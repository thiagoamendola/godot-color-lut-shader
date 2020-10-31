tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("ColorGradingFilter", "ColorRect", preload("filter_node/color_grading_filter.gd"), preload("filter_node/filter_node_icon.png"))
	add_custom_type("ColorGradingTool", "Node", preload("screenshot_tool/color_grading_tool.gd"), preload("screenshot_tool/tool_node_icon.png"))

func _exit_tree():
	remove_custom_type("ColorGradingFilter")
	remove_custom_type("ColorGradingTool")
