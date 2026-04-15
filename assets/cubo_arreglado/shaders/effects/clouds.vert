
// [COMBO] {"material":"ui_editor_properties_perspective","combo":"PERSPECTIVE","type":"options","default":0}

uniform mat4 g_ModelViewProjectionMatrix;
uniform vec4 g_Texture0Resolution;

#if MASK == 1
uniform vec4 g_Texture2Resolution;
#endif


attribute vec3 a_Position;
attribute vec2 a_TexCoord;

varying vec4 v_TexCoord;

#if PERSPECTIVE == 0
varying vec4 v_TexCoordClouds;
uniform float g_Time;
uniform vec2 g_CloudSpeeds; // {"material":"speed","label":"ui_editor_properties_speed","default":"0.01 -0.02"}
uniform vec4 g_CloudScales; // {"material":"scale","label":"ui_editor_properties_scale","default":"1.3 1.3 0.5 0.5"}
#else
uniform vec4 g_PerspectiveVars; // {"material":"ui_editor_properties_perspective_warp","default":"0 0 0 0"}
// uniform vec4 g_PerspectivePaddingVars; // {"material":"ui_editor_properties_perspective_padding","default":"0 0 0 0"}

varying vec3 v_TexCoordPerspective;

vec3 performPerspectiveTransformation(vec2 texCoord)
{
	vec2 p3 = vec2(g_PerspectiveVars.x, g_PerspectiveVars.y);
	vec2 p2 = vec2(1 - g_PerspectiveVars.x, g_PerspectiveVars.w);
	vec2 p1 = vec2(1 - g_PerspectiveVars.z, 1 - g_PerspectiveVars.w);
	vec2 p0 = vec2(g_PerspectiveVars.z, 1 - g_PerspectiveVars.y);
	
	float ax = p2.x - p0.x;
	float ay = p2.y - p0.y;
	float bx = p3.x - p1.x;
	float by = p3.y - p1.y;

	float cross = ax * by - ay * bx;

	float cy = p0.y - p1.y;
	float cx = p0.x - p1.x;

	float s = (ax * cy - ay * cx) / cross;
	float t = (bx * cy - by * cx) / cross;

	float q0 = 1 / (1 - t);
	float q1 = 1 / (1 - s);
	float q2 = 1 / t;
	float q3 = 1 / s;

	float q = mix(
				mix(q3, q2, texCoord.x),
				mix(q0, q1, texCoord.x),
				texCoord.y
				);

	vec3 result;
	result.xy = texCoord;
	
	result.xy -= 0.5;
	result.x *= 0.5 / (0.5 - mix(g_PerspectiveVars.x, g_PerspectiveVars.z, step(0.5, texCoord.y)));
	result.y *= 0.5 / (0.5 - mix(g_PerspectiveVars.y, g_PerspectiveVars.w, step(0.5, texCoord.x)));
	result.xy += 0.5;
	
	result.xy *= q;
	result.z = q;
		
	return result;
}
#endif

void main() {
	gl_Position = mul(vec4(a_Position, 1.0), g_ModelViewProjectionMatrix);
	v_TexCoord = a_TexCoord.xyxy;
	
#if PERSPECTIVE == 0
	float aspect = g_Texture0Resolution.z / g_Texture0Resolution.w;
	v_TexCoordClouds.xy = (a_TexCoord + g_Time * g_CloudSpeeds.x) * g_CloudScales.xy;
	v_TexCoordClouds.zw = (a_TexCoord + g_Time * g_CloudSpeeds.y) * g_CloudScales.zw;
	v_TexCoordClouds.xz *= aspect;
	v_TexCoordClouds.zw = vec2(-v_TexCoordClouds.w, v_TexCoordClouds.z);
#else
	v_TexCoordPerspective = performPerspectiveTransformation(a_TexCoord.xy);
#endif
	
#if MASK == 1
	v_TexCoord.zw = vec2(v_TexCoord.x * g_Texture2Resolution.z / g_Texture2Resolution.x,
						v_TexCoord.y * g_Texture2Resolution.w / g_Texture2Resolution.y);
#endif
}
