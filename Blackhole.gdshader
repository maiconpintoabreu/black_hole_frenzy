shader_type canvas_item;

uniform vec4 color_signal : source_color = vec4 (1.0);
uniform sampler2D textureNoise: repeat_enable;
uniform float size : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float zoom : hint_range(0.0, 20, 1) = 8.0;
uniform float speed : hint_range(-10.0, 10.0, 1.0) = 1.0;
uniform float angular_speed : hint_range(-5.0, 5.0, 0.01) = 2.5;
uniform float thickness : hint_range(0.0, 1.0, 0.01) = .2;
uniform float radius : hint_range(0.0, 1.0, 0.01) = .7;
uniform float radial_speed : hint_range(-5.0, 5.0, 0.01) = 1.4;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = .5;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}
void fragment(){
	
	float d = length((UV-0.5)*2.0);
	float t = pow(smoothstep(0.5,0.1,d),0.35);
	
	// For rainbow effect, keep this line :
	vec3 rainbow = random(UV)*t*color_signal.rgb;
	vec4 color = vec4(rainbow.rgb,1.0);
	vec2 v = vec2(.5) - UV;
	float angle = atan(v.y, v.x) + (TIME * angular_speed);
	float thick_ratio = 1. - (abs(d - max(0., radius)) / max(.0001, thickness));
	vec2 polar = fract(vec2(angle / 6.28, d + (TIME * radial_speed)));
	// For idle color, delete "//" below :
	//color = vec4(color_signal.rgb,1.0);

	d = sin(zoom*d - speed*TIME);
	d = abs(d);
	d = size/d;
	color *= d*t;
	vec4 col = thick_ratio * 1.0 * color;
	vec3 tex = texture(textureNoise, polar).rgb;
	col.a = (alpha * (tex.r + tex.g + tex.b) * clamp(thick_ratio, 0., 1.)) / 3.;
	
	
	//COLOR = vec4(color);
	COLOR = col;
}