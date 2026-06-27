# GMMT — GameMaker Motion Toolkit
## API Reference

---

## Table of Contents

1. [Enums](#enums)
2. [Initialization](#initialization)
3. [Core Tween Creation](#core-tween-creation)
4. [Configuration](#configuration)
5. [Playback Control](#playback-control)
6. [Value Getters](#value-getters)
7. [Global Settings](#global-settings)
8. [Update Loop](#update-loop)
9. [Convenience Functions](#convenience-functions)
10. [Queue System](#queue-system)
11. [Stagger](#stagger)
12. [Per-Axis Easing](#per-axis-easing)
13. [Typed Tween Helpers](#typed-tween-helpers)
14. [Spring Physics](#spring-physics)
15. [Wiggle / Oscillation](#wiggle--oscillation)
16. [Perlin Noise Wiggle](#perlin-noise-wiggle)
17. [Timeline](#timeline)
18. [Clip System](#clip-system)
19. [Motion Paths](#motion-paths)
20. [Bezier & Spline](#bezier--spline)
21. [Color Utilities](#color-utilities)
22. [Cleanup](#cleanup)

---

## Enums

### `gmmt_ease`
Easing type passed to most tween functions.

| Value | Description |
|---|---|
| `LINEAR` | No easing |
| `IN_QUAD` … `IN_OUT_QUINT` | Polynomial easing families (quad, cubic, quart, quint) |
| `IN_SINE` … `IN_OUT_SINE` | Sinusoidal |
| `IN_EXPO` … `IN_OUT_EXPO` | Exponential |
| `IN_CIRC` … `IN_OUT_CIRC` | Circular |
| `IN_ELASTIC` … `IN_OUT_ELASTIC` | Elastic overshoot |
| `IN_BACK` … `IN_OUT_BACK` | Back overshoot |
| `IN_BOUNCE` … `IN_OUT_BOUNCE` | Bounce |
| `CUSTOM` | Use a custom easing function set via `gmmt_set_custom_ease()` |

### `gmmt_repeat_mode`
| Value | Description |
|---|---|
| `NONE` | Play once |
| `LOOP` | Restart from beginning |
| `PING_PONG` | Reverse direction each cycle indefinitely |
| `PING_PONG_ONCE` | Reverse once then stop |

### `gmmt_tween_direction`
| Value | Description |
|---|---|
| `FORWARD` | Start → end |
| `BACKWARD` | End → start |

### `gmmt_tween_state`
| Value | Description |
|---|---|
| `IDLE` | Created, not yet playing |
| `PLAYING` | Actively updating |
| `PAUSED` | Suspended |
| `COMPLETED` | Finished, pending removal |
| `KILLED` | Stopped manually |

### `gmmt_value_type`
| Value | Description |
|---|---|
| `REAL` | Single number |
| `INT` | Integer (snaps to whole numbers) |
| `COLOR3` | GML BGR color |
| `COLOR4` | RGBA packed color (GMMT format) |
| `VECTOR2` | `[x, y]` array |
| `VECTOR3` | `[x, y, z]` array |
| `VECTOR4` | `[x, y, z, w]` array |
| `ARRAY` | Arbitrary-length numeric array |
| `CUSTOM` | User-managed via custom `value_lerp` |

### `gmmt_tween_flags`
Bitfield flags. Combine with `|`.

| Flag | Description |
|---|---|
| `NONE` | No flags |
| `OVERRIDE_EXISTING` | Kill any tween with the same ID before creating |
| `DELETE_ON_COMPLETE` | *(default)* Remove tween when done |
| `IGNORE_TIME_SCALE` | Immune to `global_time_scale` |
| `CLAMP_VALUES` | *(default)* Clamp output to `[start, end]`. Skipped automatically for overshoot easings |
| `QUEUE` | Internal — set when a pending queue is active |
| `REPEAT_RESET_ON_DELAY` | Reset progress to 0 during repeat delay instead of holding at 1 |

---

## Initialization

### `gmmt_init()`
Initializes the GMMT global state. Call once at game start (e.g. in a persistent controller object's Create event).

```gml
gmmt_init();
```

### `gmmt_init_check_safe()`
Calls `gmmt_init()` only if GMMT has not been initialized yet. Called internally by all public functions — you rarely need this directly.

### `gmmt_get()`
Returns the global GMMT state struct. Useful for reading internal data (`active_tweens`, `total_tweens_created`, etc.).

```gml
var state = gmmt_get();
show_debug_message(state.active_tweens);
```

---

## Core Tween Creation

### `gmmt_create(id, start_val, end_val, [duration])`
Creates a tween in `IDLE` state without starting it. Returns the tween struct.

| Parameter | Type | Description |
|---|---|---|
| `id` | any | Unique identifier for this tween |
| `start_val` | real / array | Starting value |
| `end_val` | real / array | Target value |
| `duration` | real | Duration in microseconds. Default: `global.gmmt.default_duration` (300000 µs = 0.3 s) |

After calling `gmmt_create()`, configure the tween with the functions below, then call `gmmt_play()`.

```gml
var t = gmmt_create("my_alpha", 0, 1, 500000);
gmmt_set_easing("my_alpha", gmmt_ease.OUT_CUBIC);
gmmt_play("my_alpha");
```

---

## Configuration

All configuration functions accept a tween `id` and return the tween struct (chainable by re-calling, though GML has no fluent syntax).  
Call these **after** `gmmt_create()` and **before** `gmmt_play()`.

### `gmmt_set_easing(id, easing)`
Sets the easing type.

```gml
gmmt_set_easing("my_tween", gmmt_ease.OUT_BOUNCE);
```

### `gmmt_set_custom_ease(id, func)`
Sets `easing` to `CUSTOM` and assigns a function `func(t) → real` mapping `[0,1]` → `[0,1]`.

```gml
gmmt_set_custom_ease("my_tween", function(t) { return t * t; });
```

### `gmmt_set_repeat(id, count, [delay], [even_only])`
Loops the tween.

| Parameter | Type | Description |
|---|---|---|
| `count` | int | Number of repeats. `-1` = infinite |
| `delay` | real | Pause in microseconds between repeats. Default `0` |
| `even_only` | bool | Reserved for future use |

### `gmmt_set_pingpong(id, [count])`
Ping-pong repeat. `count = -1` loops forever.

### `gmmt_set_pingpong_once(id)`
Plays forward then backward once, then stops.

### `gmmt_set_delay(id, delay)`
Delays playback start by `delay` microseconds.

### `gmmt_set_time_scale(id, scale)`
Per-tween time scale multiplier. `1.0` = normal, `2.0` = double speed.

### `gmmt_set_callbacks(id, [on_start], [on_update], [on_complete])`
Assigns lifecycle callbacks. Each receives the tween struct as its argument.

```gml
gmmt_set_callbacks("my_tween",
    function(t) { show_debug_message("started"); },
    undefined,
    function(t) { show_debug_message("done"); }
);
```

> Additional callbacks are set directly on the tween struct:  
> `tween.on_pause`, `tween.on_resume`, `tween.on_kill`, `tween.on_repeat`, `tween.on_pingpong`, `tween.on_direction_change`

### `gmmt_set_value_type(id, type)`
Overrides auto-detected value type. Use a `gmmt_value_type.*` constant.

### `gmmt_set_oscillation(id, amplitude, frequency, [phase])`
Adds a sinusoidal oscillation on top of the tweened value. Amplitude decays toward the end unless `duration` is near `999999999`.

### `gmmt_set_noise(id, amount, [seed])`
Adds per-frame random noise in the range `[-amount, +amount]`.

### `gmmt_set_snap(id, threshold, [to_integer])`
Snaps the value to `end_value` when within `threshold`. If `to_integer` is `true`, rounds to the nearest integer every frame.

### `gmmt_set_flags(id, flags)`
Replaces all flags with `flags`.

### `gmmt_add_flags(id, flags)`
OR-assigns `flags` into the existing flags.

```gml
gmmt_add_flags("my_tween", gmmt_tween_flags.IGNORE_TIME_SCALE);
```

### `gmmt_set_group(id, group_name)`
Assigns the tween to a named group for bulk control.

### `gmmt_set_user_data(id, data)`
Attaches arbitrary data to `tween.user_data`.

### `gmmt_set_easing_per_axis(id, easings)`
For array-type values: array of `gmmt_ease.*` values, one per component.

```gml
// Vector2 tween with different easing per axis
gmmt_set_easing_per_axis("pos", [gmmt_ease.OUT_BOUNCE, gmmt_ease.OUT_QUAD]);
```

---

## Playback Control

### `gmmt_play(id)`
Starts a tween that is in `IDLE` state. Fires `on_start`.

### `gmmt_pause(id)`
Pauses a `PLAYING` tween. Fires `on_pause`.

### `gmmt_resume(id)`
Resumes a `PAUSED` tween. Fires `on_resume`.

### `gmmt_toggle(id)`
Toggles between play and pause.

### `gmmt_stop(id, [go_to_end])`
Kills a tween. If `go_to_end` is `true`, snaps `current_value` to `end_value`. Fires `on_kill`.

### `gmmt_reverse(id)`
Swaps start/end values and adjusts elapsed time to continue smoothly in reverse. Only works while `PLAYING`.

### `gmmt_seek(id, progress)`
Jumps to a normalized position `[0, 1]` in the tween, updating `current_value`.

### `gmmt_kill_group(group_name)`
Stops all tweens in a named group.

### `gmmt_kill_all()`
Stops all currently playing tweens.

---

## Value Getters

### `gmmt_get_value(id)`
Returns `current_value` of the tween, or `undefined` if it doesn't exist.

```gml
draw_set_alpha(gmmt_get_value("my_alpha"));
```

### `gmmt_get_progress(id)`
Returns normalized playback position `[0, 1]`.

### `gmmt_is_playing(id)`
Returns `true` if the tween is in `PLAYING` state.

### `gmmt_exists(id)`
Returns `true` if the tween exists and is not `KILLED`.

---

## Global Settings

### `gmmt_set_global_time_scale(scale)`
Sets a multiplier applied to all tweens that don't have `IGNORE_TIME_SCALE`. Use `0` to pause everything, `2.0` for double speed.

### `gmmt_get_global_time_scale()`
Returns the current global time scale.

### `gmmt_get_active_count()`
Returns the number of currently playing tweens.

### `gmmt_get_total_count()`
Returns the total number of tweens created since init.

---

## Update Loop

### `gmmt_update()`
Must be called **every frame** (Step event of a persistent controller). Advances all active tweens using `delta_time`.

```gml
// obj_gmmt_controller — Step event
gmmt_update();
```

Returns `true` on success, `false` if GMMT is not initialized.

---

## Convenience Functions

These functions combine create + configure + play in one call. If a tween with the given `id` already exists and is active, they return the current value immediately without restarting.

### `gmmt_tween(id, from, to, [duration], [easing])`
Fire-and-forget tween. Returns `current_value`.

```gml
x = gmmt_tween("obj_x", x, 400, 300000, gmmt_ease.OUT_QUAD);
```

### `gmmt_tween_start(id, from, to, [duration], [easing])`
Same as `gmmt_tween()` but always restarts, killing any existing tween with the same `id`. Returns the tween struct.

### `gmmt_pulse(id, base_value, pulse_to, [duration], [easing])`
Tweens to `pulse_to` then back to `base_value` (ping-pong once). Returns `current_value`. Does nothing if already playing.

### `gmmt_pulse_start(id, base_value, pulse_to, [duration], [easing])`
Always restarts a pulse. Returns the tween struct.

### `gmmt_shake(id, center_value, intensity, [duration], [frequency])`
Oscillates around `center_value`. Returns `current_value`. Does nothing if already playing.

| Parameter | Default | Description |
|---|---|---|
| `duration` | 100000 µs | How long the shake lasts |
| `frequency` | `4` | Oscillations per second |

### `gmmt_shake_start(id, center_value, intensity, [duration], [frequency])`
Always restarts a shake. Returns the tween struct.

---

## Queue System

Chains tweens sequentially on the same `id`.

### `gmmt_queue(id, from, to, [duration], [easing])`
If a tween with `id` is playing, appends a new segment to its queue instead of starting immediately. When the current segment completes, the next queued segment plays automatically. Returns `current_value`.

```gml
gmmt_queue("obj_x", 0, 400, 300000, gmmt_ease.OUT_QUAD);
gmmt_queue("obj_x", 400, 400, 100000); // pause
gmmt_queue("obj_x", 400, 0,   300000, gmmt_ease.IN_QUAD);
```

### `gmmt_queue_clear(id)`
Removes all pending queue entries without stopping the current segment.

### `gmmt_get_queue_count(id)`
Returns the number of pending segments in the queue.

---

## Stagger

### `gmmt_stagger(ids, from, to, [duration], [stagger_delay], [easing])`
Starts the same tween on an array of IDs, each delayed by `stagger_delay` microseconds more than the previous.

```gml
gmmt_stagger(["a", "b", "c"], 0, 1, 300000, 50000, gmmt_ease.OUT_CUBIC);
```

### `gmmt_stagger_ex(items, [duration], [stagger_delay], [easing])`
Same as `gmmt_stagger()` but each item specifies its own `from`/`to`.

```gml
var items = [
    { id: "a", from: 0, to: 100 },
    { id: "b", from: 50, to: 200 },
];
gmmt_stagger_ex(items, 300000, 60000);
```

---

## Per-Axis Easing

### `gmmt_set_easing_per_axis(id, easings)`
Array of `gmmt_ease.*` values, one per vector component. The tween must be an array type (`VECTOR2`, `VECTOR3`, etc.).

---

## Typed Tween Helpers

Each type has two variants: one that skips if already playing (`gmmt_tween_*`), and one that always restarts (`gmmt_tween_*_start`).

| Function | Value Type |
|---|---|
| `gmmt_tween_color3(id, from, to, [dur], [ease])` | `COLOR3` (GML BGR) |
| `gmmt_tween_color4(id, from, to, [dur], [ease])` | `COLOR4` (RGBA packed) |
| `gmmt_tween_vector2(id, from, to, [dur], [ease])` | `VECTOR2` `[x,y]` |
| `gmmt_tween_vector3(id, from, to, [dur], [ease])` | `VECTOR3` `[x,y,z]` |
| `gmmt_tween_vector4(id, from, to, [dur], [ease])` | `VECTOR4` `[x,y,z,w]` |
| `gmmt_tween_array(id, from, to, [dur], [ease])` | `ARRAY` (arbitrary length) |
| `gmmt_tween_int(id, from, to, [dur], [ease])` | `INT` (rounded) |
| `gmmt_tween_angle(id, from, to, [dur], [ease])` | Angle (no shortest-path wrapping) |
| `gmmt_tween_scale(id, from_x, from_y, to_x, to_y, [dur], [ease])` | `VECTOR2` shorthand |
| `gmmt_tween_position(id, from_x, from_y, to_x, to_y, [dur], [ease])` | `VECTOR2` shorthand |

---

## Spring Physics

Simulates a damped spring. Runs indefinitely until the value settles near the target.

### `gmmt_spring(id, from, to, [tension], [friction], [mass], [precision])`
Starts a spring if not already playing. If a spring with this `id` is active, updates its target to `to`. Returns `current_value`.

### `gmmt_spring_start(id, from, to, [tension], [friction], [mass], [precision])`
Always restarts the spring.

| Parameter | Default | Description |
|---|---|---|
| `tension` | `0.5` | Stiffness. Higher = faster, snappier |
| `friction` | `0.3` | Damping. Higher = less bouncy |
| `mass` | `1.0` | Inertia |
| `precision` | `0.001` | Settle threshold |

```gml
// Follow mouse with spring physics
x = gmmt_spring("spring_x", x, mouse_x, 0.4, 0.25);
```

### `gmmt_spring_update(current, target, velocity, [tension], [friction], [mass], [dt])`
Low-level spring step. Returns `[new_value, new_velocity]`. Useful for manual spring simulation outside the tween system.

---

## Wiggle / Oscillation

### `gmmt_wiggle(id, center, amplitude, [frequency], [duration])`
Sine-wave oscillation around `center`. Updates amplitude/frequency live if already playing. Returns `current_value`.

### `gmmt_wiggle_start(id, center, amplitude, [frequency], [duration])`
Always restarts.

| Parameter | Default | Description |
|---|---|---|
| `frequency` | `2` | Oscillations per second |
| `duration` | infinite | `-1` = run forever |

```gml
y = gmmt_wiggle("float_y", base_y, 8, 1.5);
```

---

## Perlin Noise Wiggle

### `gmmt_perlin_wiggle(id, center, [amplitude], [speed], [seed], [duration])`
Smooth organic movement using Perlin noise. Updates amplitude/speed live if already playing. Returns `current_value`.

### `gmmt_perlin_wiggle_start(id, center, [amplitude], [speed], [seed], [duration])`
Always restarts.

| Parameter | Default | Description |
|---|---|---|
| `amplitude` | `0.5` | Max deviation from center |
| `speed` | `1` | How fast the noise position advances |
| `seed` | `0` | Noise seed for differentiation |
| `duration` | infinite | `-1` = run forever |

### `gmmt_perlin_noise(x, [seed])`
Returns a raw Perlin noise value in `[-0.5, 0.5]` at position `x`.

---

## Timeline

Keyframe-based animation over a single tween ID.

### `gmmt_timeline(id, keyframes, [loop], [default_easing])`
Plays a keyframe timeline. Does nothing if already playing. Returns `current_value`.

### `gmmt_timeline_start(id, keyframes, [loop], [default_easing])`
Always restarts.

### `gmmt_keyframe(time, value, [easing])`
Helper to create a keyframe struct.

| Parameter | Type | Description |
|---|---|---|
| `time` | real | Time in microseconds |
| `value` | real / array | Value at this keyframe |
| `easing` | `gmmt_ease.*` | Easing from this keyframe to the next. `undefined` = default |

```gml
var kfs = [
    gmmt_keyframe(0,      0),
    gmmt_keyframe(200000, 100, gmmt_ease.OUT_BOUNCE),
    gmmt_keyframe(500000, 50,  gmmt_ease.IN_QUAD),
];
gmmt_timeline_start("anim", kfs, false, gmmt_ease.LINEAR);
```

---

## Clip System

Reusable, named animation clips. Define once, play on any target ID.

### Defining a Clip

```gml
var clip = gmmt_clip_begin("bounce_in");
gmmt_clip_key_float(clip, 0,      0.0);
gmmt_clip_key_float(clip, 300000, 1.0, gmmt_ease.OUT_BOUNCE);
gmmt_clip_set_loop(clip, false);
gmmt_clip_on_complete(clip, function(id) { show_debug_message(id + " done"); });
gmmt_clip_end(clip);
```

### Clip Builder Functions

| Function | Description |
|---|---|
| `gmmt_clip_begin(name)` | Creates and returns a new clip struct |
| `gmmt_clip_key_float(clip, time, value, [ease])` | Adds a `REAL` keyframe |
| `gmmt_clip_key_vector2(clip, time, value, [ease])` | Adds a `VECTOR2` keyframe |
| `gmmt_clip_key_color3(clip, time, value, [ease])` | Adds a `COLOR3` keyframe |
| `gmmt_clip_key_color4(clip, time, value, [ease])` | Adds a `COLOR4` keyframe |
| `gmmt_clip_set_loop(clip, loop, [direction])` | Enables looping. `direction` = `gmmt_repeat_mode.*` |
| `gmmt_clip_on_complete(clip, callback)` | `callback(target_id)` called on completion |
| `gmmt_clip_on_marker(clip, callback)` | `callback(target_id, time)` called at each keyframe time |
| `gmmt_clip_chain(clip, next_clip_name)` | Auto-plays another clip when this one completes |
| `gmmt_clip_set_stagger(clip, count, delay_per_item, [initial_delay])` | Plays the clip on `count` staggered instances |
| `gmmt_clip_end(clip)` | Registers the clip in the global clip registry |

### Playback

| Function | Description |
|---|---|
| `gmmt_clip_play(clip_name, target_id)` | Plays the named clip on `target_id`. Returns tween struct (or array for stagger) |
| `gmmt_clip_stop(target_id)` | Stops playback |
| `gmmt_clip_is_playing(target_id)` | Returns `true` if playing |
| `gmmt_clip_get_float(target_id)` | Returns `current_value` as real (default `0`) |
| `gmmt_clip_get_vector2(target_id)` | Returns `current_value` as `[x,y]` (default `[0,0]`) |
| `gmmt_clip_get_color3(target_id)` | Returns `current_value` as COLOR3 (default `c_black`) |
| `gmmt_clip_get_color4(target_id)` | Returns `current_value` as COLOR4 |

---

## Motion Paths

Composite bezier paths stored by name.

### Defining a Path

```gml
var path = gmmt_path_begin("arc", [0, 0]);
gmmt_path_quadratic_to(path, [200, -150], [400, 0]);
gmmt_path_end(path);
```

### Path Builder Functions

| Function | Description |
|---|---|
| `gmmt_path_begin(name, start)` | Creates a path starting at `[x,y]` |
| `gmmt_path_quadratic_to(path, control, end)` | Appends a quadratic bezier segment |
| `gmmt_path_cubic_to(path, control1, control2, end)` | Appends a cubic bezier segment |
| `gmmt_path_end(path)` | Registers the path globally |
| `gmmt_path_evaluate(path, t)` | Returns `[x, y]` at normalized position `t ∈ [0,1]` |

### Tweening Along a Path

#### `gmmt_tween_path(id, path_name, [duration], [easing])`
Tweens along a registered path. Returns `current_value` (`[x,y]`). Does nothing if already playing.

#### `gmmt_tween_path_start(id, path_name, [duration], [easing])`
Always restarts.

```gml
var pos = gmmt_tween_path("player_path", "arc", 600000, gmmt_ease.IN_OUT_SINE);
x = pos[0];
y = pos[1];
```

---

## Bezier & Spline

### `gmmt_tween_bezier(id, p0, p1, p2, p3, [duration], [easing])`
1D cubic bezier tween (scalar output). Returns `current_value`.

### `gmmt_tween_bezier_start(...)`
Always restarts.

### `gmmt_tween_bezier_2d(id, p0, p1, p2, p3, [duration], [easing])`
2D cubic bezier tween (array output `[x,y]`). Returns `current_value`.

### `gmmt_tween_bezier_2d_start(...)`
Always restarts.

### `gmmt_tween_spline(id, points, [duration], [loop], [easing])`
Catmull-Rom spline through an array of points. Points can be scalars or `[x,y]` arrays. Returns `current_value`.

### `gmmt_tween_spline_start(...)`
Always restarts.

### Low-Level Bezier Functions

| Function | Description |
|---|---|
| `gmmt_bezier_cubic(p0, p1, p2, p3, t)` | 1D cubic bezier at `t` |
| `gmmt_bezier_quadratic(p0, p1, p2, t)` | 1D quadratic bezier at `t` |
| `gmmt_bezier_cubic_2d(p0, p1, p2, p3, t)` | 2D cubic bezier, returns `[x,y]` |
| `gmmt_catmull_rom(points, t, [loop])` | Catmull-Rom interpolation over a point array |

---

## Color Utilities

GMMT uses its own RGBA format: `R | G<<8 | B<<16 | A<<24` (distinct from GML's BGR).

| Function | Description |
|---|---|
| `gmmt_make_color_rgba(r, g, b, a)` | Pack RGBA into GMMT color int |
| `gmmt_color_rgba_get_red(color)` | Extract R channel |
| `gmmt_color_rgba_get_green(color)` | Extract G channel |
| `gmmt_color_rgba_get_blue(color)` | Extract B channel |
| `gmmt_color_rgba_get_alpha(color)` | Extract A channel |
| `ggmmt_color_rgb_to_rgba(color, [alpha])` | Convert GML BGR → GMMT RGBA |
| `gmmt_color_rgba_to_rgb(color)` | Convert GMMT RGBA → GML BGR |
| `gmmt_color_rgba_to_array(color)` | Returns `[r, g, b, a]` |
| `gmmt_color_rgb_to_array(color)` | Returns `[r, g, b]` from GML BGR |
| `gmmt_color_rgba_from_array(arr)` | Pack `[r,g,b,a]` into GMMT RGBA |

---

## Cleanup

### `gmmt_cleanup()`
Destroys all GMMT data structures and resets state. Call in a Game End event or when tearing down a scene that owned the GMMT controller.

```gml
// Game End event
gmmt_cleanup();
```

---

## Utility

| Function | Description |
|---|---|
| `gmmt_lerp(a, b, t)` | Clamped linear interpolation |
| `gmmt_remap(value, from_start, from_end, to_start, to_end)` | Remaps a value from one range to another |
| `gmmt_lerp_angle(from, to, t)` | Linear angle interpolation (no shortest-path) |

---

## Duration Reference

GMMT uses **microseconds** (`delta_time` units) for all duration/delay parameters.

| Milliseconds | Microseconds |
|---|---|
| 100 ms | 100000 |
| 300 ms | 300000 |
| 500 ms | 500000 |
| 1 s | 1000000 |
| 2 s | 2000000 |