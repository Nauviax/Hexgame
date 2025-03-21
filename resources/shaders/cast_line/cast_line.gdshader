shader_type canvas_item;

// Wiggle speed + height
const float VERTICAL_SPEED = 10.0;
const float VERTICAL_SPACING = 4.0;
const float VERTICAL_AMPLITUDE = 0.05;

// Segments in cast line (Control speed when stretched)
uniform float segments = 0.0;

// Gradient to apply
uniform sampler2D gradient_texture;

// Noise function, Generic noise 1 from: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float rand(float n){return fract(sin(n) * 43758.5453125);}
float noise(float p){
	float fl = floor(p);
	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc) * 2.0 - 1.0;
}

// Randomly oscillate in y, 'moving' in x direction based on wiggle
void fragment()
{
	// Noise
	vec2 uv = vec2(UV.x,
		UV.y - VERTICAL_AMPLITUDE * noise(
			TIME * VERTICAL_SPEED - UV.x * VERTICAL_SPACING * (segments + 0.1)
			)
		);
	vec4 texColor = texture(TEXTURE, uv);

	// Sample the gradient texture using the x-coordinate of the UV
	vec3 gradientValue = texture(gradient_texture, UV).rgb;

	// Apply
	COLOR = vec4(texColor.rgb * gradientValue, texColor.a);
}