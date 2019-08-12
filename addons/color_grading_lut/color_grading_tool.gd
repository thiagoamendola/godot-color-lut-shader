tool
extends Node

export(int) var LUT_size = 8

func _enter_tree():
	#generate_identity_lut(LUT_size)
	pass

func _exit_tree():
    pass

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_F11:
            generate_lut_screenshot()


func generate_lut_screenshot():
	var screenshot = take_screenshot()
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

func generate_identity_lut(lut_size:int):
	var image: Image = Image.new()
	image.create(lut_size*lut_size, lut_size, false, Image.FORMAT_RGB8)
	image.lock()
	var divider:int = (lut_size-1)
	var div_step:float = 1.0/(lut_size-1)

	for b in range(lut_size):
		for g in range(lut_size):
			for r in range(lut_size):
				var pos = Vector2(r + lut_size*b, g)
				var cur_color = Color(float(r),float(g),float(b)) * div_step
				cur_color.a = 1
				image.set_pixelv(pos, cur_color)
	
	
	
	image.unlock()
	image.save_png("res://identity_lut_"+str(lut_size)+".png")
	pass