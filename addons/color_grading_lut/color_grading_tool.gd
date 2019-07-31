tool
extends Node


func _enter_tree():
	pass

func _exit_tree():
    pass

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_F11:
            generate_lut_screenshot()


func generate_lut_screenshot():
	var screenshot = take_screenshot()
	screenshot.lock()
	var identity_lut = Image.new()
	identity_lut.load("res://addons/color_grading_lut/identity_lut.png")
	screenshot = insert_lut(screenshot, identity_lut)
	screenshot.save_png("res://screenshot_lut.png")
	

func take_screenshot():
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	return image


func insert_lut(screenshot:Image, lut:Image):
	lut.lock()
	screenshot.lock()
	for i in range(lut.get_width()):
		for j in range(lut.get_height()):
			var pos = Vector2(i, j)
			screenshot.set_pixelv(pos, lut.get_pixelv(pos))
	lut.unlock()
	screenshot.unlock()
	return screenshot