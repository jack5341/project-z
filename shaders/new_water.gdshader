// Simple Godot 4 Ocean Shader
//
// How to use:
// 1. Create a PlaneMesh.
// 2. Create a new ShaderMaterial for it.
// 3. Create a new Shader and paste this code.
// 4. In the Shader Parameters:
//    - Click [Empty] next to "Noise Texture"
//    - Select "New NoiseTexture2D"
//    - Click the new texture to edit it.
//    - Click [Empty] next to "Noise"
//    - Select "New FastNoiseLite"
//    - (Optional) Tweak the FastNoiseLite settings (e.g., set Type to SimplexSmooth)
// 5. Adjust the other parameters (colors, speed) to your liking!

shader_type spatial;

group_uniforms Colors;
uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.5, 1.0);
uniform vec4 foam_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);

group_uniforms Wave;
uniform sampler2D noise_texture : hint_default_white;
uniform float wave_scale : hint_range(1.0, 20.0) = 5.0;
uniform float wave_speed : hint_range(0.0, 1.0) = 0.1;
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.65;
uniform float foam_softness : hint_range(0.0, 0.5) = 0.05;


uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.05;


// ----- Shader Code -----
void fragment() {
	// Scale the UVs to make the waves bigger or smaller
	vec2 scaled_uv = UV * wave_scale;

	// --- Wave Movement ---
	// We sample the noise texture twice, moving in different directions
	// and at slightly different speeds. This breaks up repetition.

	// First wave layer
	vec2 uv_wave_1 = scaled_uv;
	uv_wave_1.x += TIME * wave_speed * 1.0; // Move in x
	uv_wave_1.y += TIME * wave_speed * 0.3; // Move in y
	float noise_1 = texture(noise_texture, uv_wave_1).r;

	// Second wave layer (different direction, different scale)
	vec2 uv_wave_2 = scaled_uv * 0.7; // Sample at a different scale
	uv_wave_2.x += TIME * wave_speed * -0.4; // Move in -x
	uv_wave_2.y += TIME * wave_speed * 0.8; // Move in +y
	float noise_2 = texture(noise_texture, uv_wave_2).r;

	// Combine the noise values. We multiply them for a sharper,
	// more "oceanic" look, but averaging ( (n1+n2) * 0.5 ) also works.
	float combined_noise = (noise_1 + noise_2) * 0.5;

	// --- Foam ---
	// Use smoothstep to create a foam line where the "waves" (noise) are highest.
	float foam_amount = smoothstep(foam_threshold - foam_softness, foam_threshold + foam_softness, combined_noise);

	// --- Final Color ---
	// Mix the base water color and the foam color based on the foam amount.
	vec3 final_color = mix(water_color.rgb, foam_color.rgb, foam_amount);

	// --- PBR Outputs ---
	// Set the shader's final properties
	ALBEDO = final_color;

	// Water is not metallic
	METALLIC = metallic;

	// Water is very reflective (high specular)
	SPECULAR = specular;

	// Water is very smooth (low roughness)
	// We can use the noise to make the water *slightly* rougher
	// where the foam is, but a constant low value is simplest.
	ROUGHNESS = roughness;
}