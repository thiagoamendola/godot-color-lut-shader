tool
extends Node

export(int) var LUT_size = 16
export(bool) var save_identity_LUT = false

var lut_image: Image

func _enter_tree():
	lut_image = generate_identity_lut(LUT_size)
	pass

func _exit_tree():
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_F11:
			generate_lut_screenshot()


func generate_lut_screenshot():
	var screenshot = take_screenshot()
	var identity_lut = lut_image
	var final_image_size = Vector2(max(screenshot.get_width(),identity_lut.get_width()), max(screenshot.get_height(),identity_lut.get_height()))
	var final_image: Image = Image.new()
	final_image.create(final_image_size.x, final_image_size.y, false, Image.FORMAT_RGB8)
	final_image = insert_image(final_image, screenshot)
	final_image = insert_image(final_image, identity_lut)
	final_image.save_png("res://screenshot_lut.png")
	if save_identity_LUT:
		identity_lut.save_png("res://identity_lut_"+str(LUT_size)+".png")
	print("COLOR GRADING LUT: Screenshot with LUT of size "+str(LUT_size)+" was successfully created!\nTarget path: res://screenshot_lut.png")


func take_screenshot():
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	return image


func insert_image(target:Image, inserted:Image):
	inserted.lock()
	target.lock()
	for i in range(inserted.get_width()):
		for j in range(inserted.get_height()):
			var pos = Vector2(i, j)
			target.set_pixelv(pos, inserted.get_pixelv(pos))
	inserted.unlock()
	target.unlock()
	return target


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
	return image
