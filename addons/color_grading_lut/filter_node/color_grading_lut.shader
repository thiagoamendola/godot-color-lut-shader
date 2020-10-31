shader_type canvas_item;

uniform sampler2D lut;
uniform float lut_size = 16.0;

uniform float filter_alpha : hint_range(0, 1) = 1.0;

// Gets interpolation percentage for color  channel using floor and diff values.
float get_interp_percent_channel(float channel_value, float floor_value, float diff_value){
	// Workaround to avoid division by zero and return zero
	float div_sign = abs(sign(diff_value));
	return (channel_value-floor_value)*div_sign/(diff_value + (div_sign-1.0));
}

// Gets interpolation percentage for color using floor and diff values.
vec3 get_interp_percent_color(vec3 color, vec3 floorc, vec3 diff){
	vec3 res = vec3(0.0);
	res.r = get_interp_percent_channel(color.r, floorc.r, diff.r);
	res.g = get_interp_percent_channel(color.g, floorc.g, diff.g);
	res.b = get_interp_percent_channel(color.b, floorc.b, diff.b);
	return res;
}

// Get interpolated color using color floor, diff and channel percentage.
vec3 get_interpolated_color(vec3 floorc, vec3 diff, float perc){
	return floorc.rgb + diff.rgb * perc;
}

// Applies gamma correction to convert color from linear space to sRGB.
vec3 convert_linear_to_srgb(vec3 linear_color){
	float gamma = 2.2;
	return pow(linear_color.rgb, vec3(1.0/gamma));
}

// Gets LUT mapped color using trilinear interpolation.
vec4 get_lut_mapping_trilinear(vec4 old_color){
	float lut_div = lut_size - 1.0;
	// Get floor and ceil colors and diff from identity lut
	vec3 old_color_lut_base = lut_div * old_color.rgb;
	vec3 old_color_floor_vec = floor(old_color_lut_base);
	vec3 old_color_ceil_vec = ceil(old_color_lut_base);
	vec3 old_color_diff = (old_color_floor_vec - old_color_ceil_vec)/lut_div;
	vec3 old_color_percentages = get_interp_percent_color(old_color.rgb, old_color_floor_vec/lut_div, old_color_diff);
	// Get the surrounding 8 samples positions
	vec3 lut_color_fff_vec = vec3(old_color_floor_vec.r, old_color_floor_vec.g, old_color_floor_vec.b);
	vec3 lut_color_ffc_vec = vec3(old_color_floor_vec.r, old_color_floor_vec.g, old_color_ceil_vec.b);
	vec3 lut_color_fcf_vec = vec3(old_color_floor_vec.r, old_color_ceil_vec.g, old_color_floor_vec.b);
	vec3 lut_color_fcc_vec = vec3(old_color_floor_vec.r, old_color_ceil_vec.g, old_color_ceil_vec.b);
	vec3 lut_color_cff_vec = vec3(old_color_ceil_vec.r, old_color_floor_vec.g, old_color_floor_vec.b);
	vec3 lut_color_cfc_vec = vec3(old_color_ceil_vec.r, old_color_floor_vec.g, old_color_ceil_vec.b);
	vec3 lut_color_ccf_vec = vec3(old_color_ceil_vec.r, old_color_ceil_vec.g, old_color_floor_vec.b);
	vec3 lut_color_ccc_vec = vec3(old_color_ceil_vec.r, old_color_ceil_vec.g, old_color_ceil_vec.b);
	ivec2 lut_color_fff_pos = ivec2(int(lut_size*lut_color_fff_vec.b + lut_color_fff_vec.r), int(lut_color_fff_vec.g));
	ivec2 lut_color_ffc_pos = ivec2(int(lut_size*lut_color_ffc_vec.b + lut_color_ffc_vec.r), int(lut_color_ffc_vec.g));
	ivec2 lut_color_fcf_pos = ivec2(int(lut_size*lut_color_fcf_vec.b + lut_color_fcf_vec.r), int(lut_color_fcf_vec.g));
	ivec2 lut_color_fcc_pos = ivec2(int(lut_size*lut_color_fcc_vec.b + lut_color_fcc_vec.r), int(lut_color_fcc_vec.g));
	ivec2 lut_color_cff_pos = ivec2(int(lut_size*lut_color_cff_vec.b + lut_color_cff_vec.r), int(lut_color_cff_vec.g));
	ivec2 lut_color_cfc_pos = ivec2(int(lut_size*lut_color_cfc_vec.b + lut_color_cfc_vec.r), int(lut_color_cfc_vec.g));
	ivec2 lut_color_ccf_pos = ivec2(int(lut_size*lut_color_ccf_vec.b + lut_color_ccf_vec.r), int(lut_color_ccf_vec.g));
	ivec2 lut_color_ccc_pos = ivec2(int(lut_size*lut_color_ccc_vec.b + lut_color_ccc_vec.r), int(lut_color_ccc_vec.g));
	// Get gamma corrected color from LUT.
	vec3 lut_color_fff = convert_linear_to_srgb(texelFetch(lut, lut_color_fff_pos, 0).rgb);
	vec3 lut_color_ffc = convert_linear_to_srgb(texelFetch(lut, lut_color_ffc_pos, 0).rgb);
	vec3 lut_color_fcf = convert_linear_to_srgb(texelFetch(lut, lut_color_fcf_pos, 0).rgb);
	vec3 lut_color_fcc = convert_linear_to_srgb(texelFetch(lut, lut_color_fcc_pos, 0).rgb);
	vec3 lut_color_cff = convert_linear_to_srgb(texelFetch(lut, lut_color_cff_pos, 0).rgb);
	vec3 lut_color_cfc = convert_linear_to_srgb(texelFetch(lut, lut_color_cfc_pos, 0).rgb);
	vec3 lut_color_ccf = convert_linear_to_srgb(texelFetch(lut, lut_color_ccf_pos, 0).rgb);
	vec3 lut_color_ccc = convert_linear_to_srgb(texelFetch(lut, lut_color_ccc_pos, 0).rgb);
	// Calculate first level interpolations.
	vec3 lut_color_iff = get_interpolated_color(lut_color_fff, lut_color_fff - lut_color_cff , old_color_percentages.r);
	vec3 lut_color_ifc = get_interpolated_color(lut_color_ffc, lut_color_ffc - lut_color_cfc, old_color_percentages.r);
	vec3 lut_color_icf = get_interpolated_color(lut_color_fcf, lut_color_fcf - lut_color_ccf, old_color_percentages.r);
	vec3 lut_color_icc = get_interpolated_color(lut_color_fcc, lut_color_fcc - lut_color_ccc, old_color_percentages.r);
	// Calculate second level interpolations.
	vec3 lut_color_iif = get_interpolated_color(lut_color_iff, lut_color_iff - lut_color_icf, old_color_percentages.g);
	vec3 lut_color_iic = get_interpolated_color(lut_color_ifc, lut_color_ifc - lut_color_icc, old_color_percentages.g);
	// Calculate third and final interpolation.
	vec3 lut_color_iii = get_interpolated_color(lut_color_iif, lut_color_iif - lut_color_iic, old_color_percentages.b);
	// Get final color with original alpha.
	vec4 final_color = vec4(lut_color_iii, old_color.a);
	return final_color;
}


void fragment(){
	vec4 original_color = texture(SCREEN_TEXTURE,SCREEN_UV);
	vec4 filtered_color = get_lut_mapping_trilinear(original_color);
	// Calculate filter alpha.
	vec3 diff_color = filtered_color.rgb - original_color.rgb;
	vec4 final_color = vec4(get_interpolated_color(original_color.rgb, diff_color, filter_alpha), filtered_color.a);
	COLOR = final_color;
}
