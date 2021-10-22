/**
Simpler (but less accurate) version of the LUT filter.
It also works on GLES2.
**/
shader_type canvas_item;
uniform sampler2D lut;
uniform float lut_size = 16.0;
uniform bool interpolate = true;
/**
Converts an vec3(R,G,B) color into a vec2(u,v) coordinate that can be used for the LUT.
Expects all values to be in the range [0.0, lut_size - 1.0].
**/
vec2 color_to_uv(vec3 lut_color) {
	lut_color = floor(lut_color);
	return vec2(
		lut_color.r / lut_size + lut_color.b,
		lut_color.g
	) / lut_size;
}
/**
Applies the Look-Up Table effect, given the original color (RGB).
**/
vec3 apply_lut(vec3 original_color) {
	if (!interpolate) {
		vec3 lut_color = floor(min(original_color, vec3(0.99999)) * lut_size);
		return texture(lut, color_to_uv(lut_color)).rgb;
	}
	// Multiply the original color into the range [0.0, lut_size).
	vec3 lut_color = min(original_color, vec3(0.99999)) * lut_size;
	// Get the color for the 8 neighboring pixels.
	// (d = round down, u = round up)
	vec3 ddd = texture(lut, color_to_uv(lut_color					   )).rgb;
	vec3 ddu = texture(lut, color_to_uv(lut_color + vec3(0.0, 0.0, 1.0))).rgb;
	vec3 dud = texture(lut, color_to_uv(lut_color + vec3(0.0, 1.0, 0.0))).rgb;
	vec3 duu = texture(lut, color_to_uv(lut_color + vec3(0.0, 1.0, 1.0))).rgb;
	vec3 udd = texture(lut, color_to_uv(lut_color + vec3(1.0, 0.0, 0.0))).rgb;
	vec3 udu = texture(lut, color_to_uv(lut_color + vec3(1.0, 0.0, 1.0))).rgb;
	vec3 uud = texture(lut, color_to_uv(lut_color + vec3(1.0, 1.0, 0.0))).rgb;
	vec3 uuu = texture(lut, color_to_uv(lut_color + vec3(1.0, 1.0, 1.0))).rgb;
	// Linear interpolate between the 8 pixels. (m = merge)
	vec3 subpixel = fract(lut_color);
	vec3 ddm = mix(ddd, ddu, subpixel.b);
	vec3 dum = mix(dud, duu, subpixel.b);
	vec3 udm = mix(udd, udu, subpixel.b);
	vec3 uum = mix(uud, uuu, subpixel.b);
	vec3 dmm = mix(ddm, dum, subpixel.g);
	vec3 umm = mix(udm, uum, subpixel.g);
	vec3 mmm = mix(dmm, umm, subpixel.r);
	return mmm;
}

/**
The main body of the shader.
**/
void fragment(){
	vec3 original_color = texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
	vec3 final_color = apply_lut(original_color);
	COLOR.rgb = final_color;
}