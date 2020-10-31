tool
extends ColorRect

export(StreamTexture) var lut : StreamTexture

var shader_material

func _init():
	# Create Shader Material
	shader_material = ShaderMaterial.new()
	material = shader_material
	# Assign Shader
	lut = load("res://addons/color_grading_lut/default_luts/identity.png")
	shader_material.shader = load("res://addons/color_grading_lut/filter_node/color_grading_lut.shader")
	shader_material.set_shader_param("lut", lut)
	# Resize to screen
	anchor_left = 0
	anchor_right = 1
	anchor_top = 0
	anchor_bottom = 1
	pass

func _enter_tree():
	pass

func _exit_tree():
	pass

func _draw():
	shader_material.set_shader_param("filter_alpha", color.a)
	shader_material.set_shader_param("lut", lut)
