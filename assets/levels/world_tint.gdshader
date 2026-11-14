shader_type canvas_item;
// Barevný nádech světa. Přítomnost: vybledlá a studená, minulost: sytě zelená.
// Nastavení jsou v present_world.tres a past_world.tres.
// Stejný výpočet má editor úrovní (tools/level_editor/editor.html, funkce tinted).

uniform float desaturation : hint_range(0.0, 1.0) = 0.0;  // 1 = úplně šedé
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	c.rgb = mix(c.rgb, vec3(gray), desaturation) * tint.rgb * brightness;
	COLOR = c;
}
