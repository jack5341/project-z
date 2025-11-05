shader_type canvas_item;

//
// Water level shader
// - Set `level` 0..1 (0 = empty, 1 = full)
// - Put this on a TextureRect / Sprite whose rect defines the vertical bar
//

// Group: Level & Colors
group_uniforms Level;
uniform float level : hint_range(0.0,1.0) = 0.6; // fill fraction from bottom
uniform vec4 shallow_color : source_color = vec4(0.45, 0.9, 1.0, 1.0); // top (light) color
uniform vec4 deep_color    : source_color = vec4(0.02, 0.05, 0.6, 1.0); // bottom (dark) color

// Group: Wave
group_uniforms Wave;
uniform float wave_amp = 0.035;     // vertical wave amplitude (in UV space)
uniform float wave_freq = 6.0;      // horizontal wave frequency
uniform float wave_speed = 0.9;     // how fast the waves move
uniform bool simple_wave = true;    // if true, use a minimal sine wave
// optional external noise for wave shaping
uniform sampler2D wave_noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform bool use_wave_noise_texture = false;
uniform float wave_noise_scale = 1.0;
uniform float wave_noise_amp = 0.6;  // phase perturbation strength

// Group: Foam
group_uniforms Foam;
uniform float foam_width = 0.03;         // thickness of foam band (vertical falloff depth)
uniform float foam_strength = 1.0;       // foam brightness multiplier
uniform float foam_noise_scale = 6.0;    // noise scale for foam texture
uniform float foam_noise_amp = 0.6;      // noise amplitude for foam mask

// optional external noise texture (allows authoring custom noise)
uniform sampler2D foam_noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform bool use_noise_texture = false;

// end grouping
group_uniforms;

// small helper functions: value noise + fbm
float hash(vec2 p){
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}
float noise(vec2 p){
	vec2 i = floor(p);
	vec2 f = fract(p);
	// four corners
	float a = hash(i + vec2(0.0,0.0));
	float b = hash(i + vec2(1.0,0.0));
	float c = hash(i + vec2(0.0,1.0));
	float d = hash(i + vec2(1.0,1.0));
	// smooth interp
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
float fbm(vec2 p){
	float v = 0.0;
	float a = 0.5;
	for(int i=0;i<5;i++){
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment(){
	// uv: (0,0) top-left, (1,1) bottom-right for CanvasItem
	vec2 uv = UV;

	// compute baseline water top position in UV coordinates
	// level = 0 => y_line = 1.0 (no water); level = 1 => y_line = 0.0 (full)
	float y_line = 1.0 - clamp(level, 0.0, 1.0);

	// Wave shape
	float wave = 0.0;
	if (simple_wave) {
		float phase = uv.x * (2.0 * PI) * max(wave_freq, 0.01) + TIME * wave_speed;
		if (use_wave_noise_texture) {
			float wn = texture(wave_noise_tex, vec2(uv.x * wave_noise_scale + TIME * 0.02, 0.5)).r;
			wn = (wn - 0.5) * 2.0; // -1..1
			phase += wn * wave_noise_amp;
		}
		wave = sin(phase) * wave_amp;
	} else {
		// fallback: fbm-based crest
		float wave_base = fbm(vec2(uv.x * wave_freq, TIME * wave_speed));
		wave_base = (wave_base - 0.5) * 2.0; // normalize to -1..1
		wave = wave_base * wave_amp;
	}

	// vertical position of the noisy/wavy top at this x
	float top_y = y_line + wave;

	// crisp water boundary: inside water is 1, outside is 0 (no blur)
	float water_mask = step(top_y, uv.y);
	// water_mask = 1.0 for pixels below (i.e. "inside" the water), 0.0 for pixels above

	// depth gradient tied to absolute container depth (top=0 → shallow, bottom=1 → deep)
	// This ensures at low water levels we don't see the shallow color at all.
	float depth_abs = clamp(uv.y, 0.0, 1.0);
	float blend_t = pow(depth_abs, 1.2);
	vec4 base_color = mix(shallow_color, deep_color, blend_t);

    // Foam generation: concentrated near the crest (top_y) and modulated by noise
    // Choose between procedural fbm or provided noise texture
    float fnoise = 0.0;
    if (use_noise_texture) {
        // Sample red channel from provided texture; scroll slowly for life
        fnoise = texture(foam_noise_tex, uv * foam_noise_scale + vec2(TIME * 0.02)).r;
    } else {
        fnoise = fbm(vec2(uv.x * foam_noise_scale, uv.y * foam_noise_scale + TIME * 0.2));
    }
    // remap/clip to emphasize bright foam speckles only
    fnoise = clamp((fnoise - 0.45) * 2.5, 0.0, 1.0);

	// Foam mask that blends downward only (inside water), no effect outside
	float dy = uv.y - top_y;                    // positive only inside the water
	float inside = step(0.0, dy);
	// 1 at the crest, fading to 0 over foam_width downward
	float foam_down = 1.0 - smoothstep(0.0, foam_width, dy);
	float foam_mask = inside * foam_down * fnoise * foam_noise_amp * water_mask;

	// white-only foam overlay (crisp); avoid pre-multiplying alpha to prevent dark artifacts
	float foam_overlay = clamp(foam_mask * foam_strength, 0.0, 1.0);
    vec3 final_rgb = mix(base_color.rgb, vec3(1.0), foam_overlay);
    // keep alpha strictly from water mask so areas outside remain transparent
    float final_a = water_mask;

	COLOR = vec4(final_rgb, final_a);
}
