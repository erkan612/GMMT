# GMMT
## Tweening framework for GameMaker

> Native GML implementation of a complete motion and animation system. No extensions. No DLLs.

### What is GMMT?
GMMT is a comprehensive tweening framework that handles all interpolation, easing, and animation logic in a single update call. Create tweens by unique ID, read values where you need them. Supports real numbers, vectors, colors, arrays, paths, springs, and timeline-based clips.

### Features
- Tweening – 30+ built-in easing functions, custom easing, per-axis easing, intensity and power modifiers
- Value Types – Real, integer, color (RGB/RGBA), vector2/3/4, arrays, custom lerp functions
- Playback – Play, pause, resume, reverse, seek, repeat, ping-pong, staggered sequences
- Effects – Oscillation, perlin noise, wiggle, shake, pulse
- Curves – Bezier, quadratic, cubic 2D, Catmull-Rom splines, motion paths
- Physics – Spring simulation with configurable tension, friction, and mass
- Timeline – Keyframe-based multi-stage animations with per-segment easing
- Clips – Reusable named animation clips with markers, chaining, and stagger support
- Callbacks – on_start, on_update, on_complete, on_repeat, on_pingpong, on_pause, on_resume

### Quick Example
```gml
// In controller Step event
gmmt_update();

// Animate values anywhere in your code
x = gmmt_tween("player_x", x, target_x, 500000, gmmt_ease.OUT_BACK);
y = gmmt_tween("player_y", y, target_y, 400000, gmmt_ease.OUT_QUAD);
image_alpha = gmmt_tween("fade", 1, 0, 300000, gmmt_ease.OUT_CUBIC);
image_angle = gmmt_tween_angle("spin", 0, 360, 1000000, gmmt_ease.IN_OUT_QUAD);

// Create a clip with keyframes
var _clip = gmmt_clip_begin("bob");
gmmt_clip_key_vector2(_clip, 0,        [0, 0]);
gmmt_clip_key_vector2(_clip, 500000,   [0, -4]);
gmmt_clip_key_vector2(_clip, 1000000,  [0, 0]);
gmmt_clip_set_loop(_clip, true);
gmmt_clip_end(_clip);
gmmt_clip_play("bob", "bob_offset");

// Chain queued animations
gmmt_queue("chain", 0, 100, 500000);
gmmt_queue("chain", 100, 50, 300000);
gmmt_queue("chain", 50, 200, 700000);

// Spring physics
gmmt_spring("spring_x", 0, 100, 0.5, 0.3);

// Animate along a path
var _path = gmmt_path_begin("arc", [0, 0]);
gmmt_path_quadratic_to(_path, [100, -50], [200, 0]);
gmmt_path_cubic_to(_path, [300, 50], [400, -50], [500, 0]);
gmmt_path_end(_path);
gmmt_tween_path("follow", "arc", 3000000, gmmt_ease.IN_OUT_QUAD);

// Read values in Draw/Step
draw_sprite(sprite_index, image_index,
    x + gmmt_get_value("bob_offset")[0],
    y + gmmt_get_value("bob_offset")[1]);
```
