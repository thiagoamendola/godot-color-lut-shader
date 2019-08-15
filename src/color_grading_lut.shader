shader_type canvas_item;

uniform sampler2D lut;
uniform float lut_size = 16.0;

//
vec4 get_lut_mapping_floor(vec4 old_color){
	float lut_div = lut_size;
	float pixel_center = float(0.5/(lut_div*lut_div));
	vec2 slice_pos = vec2(floor(lut_div*old_color.r)/lut_div, floor(lut_div*old_color.g)/lut_div);
	float slice_index = (floor(lut_div*old_color.b))/lut_div;
	vec2 lut_pos = vec2(pixel_center + slice_index + (slice_pos.x/lut_div), pixel_center + slice_pos.y);
	vec4 final_color = texture(lut, lut_pos);
	final_color.a = old_color.a;
	return final_color;
}

// Retrieve percentage from color diff

float get_interp_percent_float(float color_value, float floor_value, float diff_value){
	// Workaround to avoid division by zero and return zero
	float div_sign = abs(sign(diff_value));
	return (color_value-floor_value)*div_sign/(diff_value + (div_sign-1.0));
}

vec3 get_interp_percent_color(vec3 color, vec3 floor, vec3 diff){
	vec3 res = vec3(0.0);
	res.r = get_interp_percent_float(color.r, floor.r, diff.r);
	res.g = get_interp_percent_float(color.g, floor.g, diff.g);
	res.b = get_interp_percent_float(color.b, floor.b, diff.b);
	return res;
}

// Retrieve interpolated color

vec3 get_interpolated_color_vec(vec3 floorc, vec3 diff, vec3 perc){
	return floorc.rgb + diff.rgb * perc.rgb;
}

vec3 get_interpolated_color(vec3 floorc, vec3 diff, float perc){
	return floorc.rgb + diff.rgb * perc;
}

//
vec4 get_lut_mapping_linear(vec4 old_color){
	float lut_div = lut_size - 1.0;
	vec3 old_color_lut_base = lut_div * old_color.rgb;
	vec3 old_color_floor_vec = floor(old_color_lut_base);
	vec3 old_color_ceil_vec = ceil(old_color_lut_base);
	vec3 old_color_diff = (old_color_floor_vec - old_color_ceil_vec)/lut_div;
	vec3 old_color_percentages = get_interp_percent_color(old_color.rgb, old_color_floor_vec/lut_div, old_color_diff);

	ivec2 lut_color_floor_pos = ivec2(int(lut_size*old_color_floor_vec.b + old_color_floor_vec.r),  int(old_color_floor_vec.g));
	ivec2 lut_color_ceil_pos = ivec2(int(lut_size*old_color_ceil_vec.b + old_color_ceil_vec.r), int(old_color_ceil_vec.g));
	vec3 lut_color_floor = texelFetch(lut, lut_color_floor_pos, 0).rgb;
	vec3 lut_color_ceil = texelFetch(lut, lut_color_ceil_pos, 0).rgb;
	vec3 lut_color_diff = lut_color_floor - lut_color_ceil;

	vec3 lut_color_interpolated = get_interpolated_color_vec(lut_color_floor, lut_color_diff, old_color_percentages);
	vec4 final_color = vec4(lut_color_interpolated, old_color.a);
	return final_color;
}

//
vec4 get_lut_mapping_trilinear(vec4 old_color){
	float lut_div = lut_size - 1.0;
	// Get floor and ceil colors and diff from identity lut
	vec3 old_color_lut_base = lut_div * old_color.rgb;
	vec3 old_color_floor_vec = floor(old_color_lut_base);
	vec3 old_color_ceil_vec = ceil(old_color_lut_base);
	vec3 old_color_diff = (old_color_floor_vec - old_color_ceil_vec)/lut_div;
	vec3 old_color_percentages = get_interp_percent_color(old_color.rgb, old_color_floor_vec/lut_div, old_color_diff);
	// Get the surround 8 samples
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
	vec3 lut_color_fff = texelFetch(lut, lut_color_fff_pos, 0).rgb;
	vec3 lut_color_ffc = texelFetch(lut, lut_color_ffc_pos, 0).rgb;
	vec3 lut_color_fcf = texelFetch(lut, lut_color_fcf_pos, 0).rgb;
	vec3 lut_color_fcc = texelFetch(lut, lut_color_fcc_pos, 0).rgb;
	vec3 lut_color_cff = texelFetch(lut, lut_color_cff_pos, 0).rgb;
	vec3 lut_color_cfc = texelFetch(lut, lut_color_cfc_pos, 0).rgb;
	vec3 lut_color_ccf = texelFetch(lut, lut_color_ccf_pos, 0).rgb;
	vec3 lut_color_ccc = texelFetch(lut, lut_color_ccc_pos, 0).rgb;
	// Calculate first level interpolations
	vec3 lut_color_iff = get_interpolated_color(lut_color_fff, lut_color_fff - lut_color_cff , old_color_percentages.r);
	vec3 lut_color_ifc = get_interpolated_color(lut_color_ffc, lut_color_ffc - lut_color_cfc, old_color_percentages.r);
	vec3 lut_color_icf = get_interpolated_color(lut_color_fcf, lut_color_fcf - lut_color_ccf, old_color_percentages.r);
	vec3 lut_color_icc = get_interpolated_color(lut_color_fcc, lut_color_fcc - lut_color_ccc, old_color_percentages.r);
	// Calculate second level interpolations
	vec3 lut_color_iif = get_interpolated_color(lut_color_iff, lut_color_iff - lut_color_icf, old_color_percentages.g);
	vec3 lut_color_iic = get_interpolated_color(lut_color_ifc, lut_color_ifc - lut_color_icc, old_color_percentages.g);
	// Calculate third and final interpolation
	vec3 lut_color_iii = get_interpolated_color(lut_color_iif, lut_color_iif - lut_color_iic, old_color_percentages.b);
	// Get final color with original alpha
	vec4 final_color = vec4(lut_color_iii, old_color.a);
	return final_color;
}

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE,SCREEN_UV);
	// color = get_lut_mapping_floor(color);
	//color = get_lut_mapping_linear(color);
	color = get_lut_mapping_trilinear(color);
	COLOR = color;
}