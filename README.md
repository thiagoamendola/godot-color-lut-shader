# Godot Color LUT Shader

Color Grading with LUT shader for Godot 3.

This shader maps all rendered pixels and convert their colors according to a provided 3D lookup table (LUT) texture. It's a highly efficient color correction method for real-time applications in Godot.


## Implementation

This fragment shader uses a precomputed lookup table mapping the RGB domain to match your current pixel color with its respective position in the lookup and swap it with lookup's one.

For the values that are not present in the table, a linear interpolation is made using the surrounding color samples to build an approximated value.

As we only look at the lookups, this method can acquire the same results of multiple real-time color operations with only a cheap texture read cost.

## References

- Adrian Courrèges' Metal Gear Solid V Graphic Study: http://www.adriancourreges.com/blog/2017/12/15/mgs-v-graphics-study/
- NVIDIA's GPU Gems - Lookup Tables to Accelerate Color Transformations: https://developer.nvidia.com/gpugems/GPUGems2/gpugems2_chapter24.html
