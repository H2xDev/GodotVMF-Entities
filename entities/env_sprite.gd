@tool
class_name env_sprite
extends VMFEntityNode

## Sprite flags
const FLAG_START_ON = 1;
const FLAG_PLAY_ONCE = 2;
const FLAG_ORIENTED = 4;  # Orient sprite to face camera

var sprite_scale: float:
	get: return entity.get("scale", 0.1) * config.import.scale;

var sprite_texture_path: String:
	get: return entity.get("model", "");

var framerate: float:
	get: return entity.get("framerate", 10.0);

var render_amt: float:
	get: return float(entity.get("renderamt", 255)) / 255.0;

var render_color: Color:
	get:
		var color_str = entity.get("rendercolor", "255 255 255");
		var color_parts = color_str.split(" ");
		if color_parts.size() >= 3:
			return Color(
				float(color_parts[0]) / 255.0,
				float(color_parts[1]) / 255.0,
				float(color_parts[2]) / 255.0,
				render_amt
			);
		return Color.WHITE;

var sprite_3d: Sprite3D = null;

func _entity_setup(e: VMFEntity) -> void:
	sprite_3d = $Sprite3D as Sprite3D;
	if not sprite_3d:
		push_error("env_sprite: Sprite3D node not found!");
		return;
	
	# Load sprite texture/material
	var loaded_texture: Texture2D = null;
	if sprite_texture_path:
		# Clean up the path - remove .vmt extension if present (VMTLoader adds it)
		var clean_path = sprite_texture_path;
		if clean_path.ends_with(".vmt"):
			clean_path = clean_path.substr(0, clean_path.length() - 4);
		
		# Try to load as VMT material first
		var material = VMTLoader.get_material(clean_path.to_lower());
		if material and material.albedo_texture:
			loaded_texture = material.albedo_texture;
		else:
			# Try loading as direct texture path
			loaded_texture = load(sprite_texture_path) as Texture2D;
			if not loaded_texture:
				push_warning("env_sprite: Could not load sprite texture '%s'" % sprite_texture_path);
	
	# Set texture on Sprite3D
	if loaded_texture:
		sprite_3d.texture = loaded_texture;
	
	# Set scale
	sprite_3d.pixel_size = sprite_scale;
	
	# Set opacity/alpha - ensure it's fully opaque if renderamt is 255
	if render_amt >= 1.0:
		sprite_3d.opacity = 1.0;
	else:
		sprite_3d.opacity = render_amt;
	
	# Set billboard mode - Y-billboard (rotate around Y-axis to face camera)
	if has_flag(FLAG_ORIENTED):
		sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y;
	else:
		sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y;  # Always use Y-billboard for sprites
	
	# Ensure sprite renders correctly without ghosting
	sprite_3d.centered = true;
	sprite_3d.offset = Vector2.ZERO;
	
	# Set modulate color for tinting (if needed, can be set via modulate property)
	# sprite_3d.modulate = render_color;  # Uncomment if you want color tinting
	
	# Handle animated sprites (if texture is an AnimatedTexture)
	if sprite_3d.texture is AnimatedTexture:
		var anim_texture = sprite_3d.texture as AnimatedTexture;
		anim_texture.fps = framerate;
	
	# Start disabled if flag is not set
	if not has_flag(FLAG_START_ON):
		sprite_3d.visible = false;

func _entity_ready():
	pass;

## INPUTS

func ShowSprite(_param = null):
	if sprite_3d:
		sprite_3d.visible = true;

func HideSprite(_param = null):
	if sprite_3d:
		sprite_3d.visible = false;

func ToggleSprite(_param = null):
	if sprite_3d:
		sprite_3d.visible = !sprite_3d.visible;
