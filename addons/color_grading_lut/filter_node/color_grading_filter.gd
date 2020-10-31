tool
extends ColorRect

func _enter_tree():
	# Create Shader Material
	var shader_material = ShaderMaterial.new()
	material = shader_material
	# Assign Shader
	shader_material.shader = load("res://addons/color_grading_lut/filter_node/color_grading_lut.shader")
	shader_material.set_shader_param("lut", load("res://addons/color_grading_lut/default_luts/identity.png"))
	# Resize to screen
	anchor_left = 0
	anchor_right = 1
	anchor_top = 0
	anchor_bottom = 1
	pass

func _exit_tree():
	pass
