/*********************************************************************************************
*                                        MIT License                                         *
*--------------------------------------------------------------------------------------------*
* Copyright (c) 2026 erkan612                                                                *
*                                                                                            *
* Permission is hereby granted, free of charge, to any person obtaining a copy of this       *
* software and associated documentation files (the "Software"), to deal in the Software      *
* without restriction, including without limitation the rights to use, copy, modify, merge,  *
* publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons *
* to whom the Software is furnished to do so, subject to the following conditions:           *
*                                                                                            *
* The above copyright notice and this permission notice shall be included in all copies or   *
* substantial portions of the Software.                                                      *
*                                                                                            *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,        *
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR   *
* PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE  *
* FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR       *
* OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER     *
* DEALINGS IN THE SOFTWARE.                                                                  *
**********************************************************************************************
*--------------------------------------------------------------------------------------------*
*   						****************************************                         *
*   					     ██████╗ ███╗   ███╗███╗   ███╗████████╗		                 *
*   					    ██╔════╝ ████╗ ████║████╗ ████║╚══██╔══╝		                 *
*   					    ██║  ███╗██╔████╔██║██╔████╔██║   ██║   		                 *
*   					    ██║   ██║██║╚██╔╝██║██║╚██╔╝██║   ██║   		                 *
*   					    ╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║   ██║   		                 *
*   					     ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝   ╚═╝   		                 *
*   						       GameMaker Motion Toolkit									 *
*   						  Tweening framework for GameMaker								 *
*   						            Version 1.0.0					                     *
*   																                         *
*   						             by erkan612					                     *
*   						****************************************                         *
*********************************************************************************************/

// enums
enum gmmt_ease {
	LINEAR,
	IN_QUAD,
	OUT_QUAD,
	IN_OUT_QUAD,
	IN_CUBIC,
	OUT_CUBIC,
	IN_OUT_CUBIC,
	IN_QUART,
	OUT_QUART,
	IN_OUT_QUART,
	IN_QUINT,
	OUT_QUINT,
	IN_OUT_QUINT,
	IN_SINE,
	OUT_SINE,
	IN_OUT_SINE,
	IN_EXPO,
	OUT_EXPO,
	IN_OUT_EXPO,
	IN_CIRC,
	OUT_CIRC,
	IN_OUT_CIRC,
	IN_ELASTIC,
	OUT_ELASTIC,
	IN_OUT_ELASTIC,
	IN_BACK,
	OUT_BACK,
	IN_OUT_BACK,
	IN_BOUNCE,
	OUT_BOUNCE,
	IN_OUT_BOUNCE,
	CUSTOM,
	TOTAL,
}

enum gmmt_repeat_mode {
	NONE,
	LOOP,
	PING_PONG,
	PING_PONG_ONCE,
}

enum gmmt_tween_direction {
	FORWARD,
	BACKWARD,
}

enum gmmt_tween_state {
	IDLE,
	PLAYING,
	PAUSED,
	COMPLETED,
	KILLED,
}

enum gmmt_value_type {
	REAL,
	COLOR3,
	COLOR4,
	VECTOR2,
	VECTOR3,
	VECTOR4,
	ARRAY,
	INT,
	CUSTOM,
}

enum gmmt_tween_flags {
	NONE						= 0,
	OVERRIDE_EXISTING			= 1 << 0,
	DELETE_ON_COMPLETE			= 1 << 1,
	IGNORE_TIME_SCALE			= 1 << 2,
	REVERSE_EASE_ON_PINGPONG	= 1 << 3, // [[DEPRECATED]]
	CLAMP_VALUES				= 1 << 4,
	SYNC_TO_AUDIO				= 1 << 5,
	QUEUE						= 1 << 6,
	REPEAT_RESET_ON_DELAY		= 1 << 7,
}

// color stuff
function gmmt_make_color_rgba(r, g, b, a) { // (R | G<<8 | B<<16 | A<<24)
    return (clamp(r, 0, 255))
         | (clamp(g, 0, 255) << 8)
         | (clamp(b, 0, 255) << 16)
         | (clamp(a, 0, 255) << 24);
}

function gmmt_color_rgba_get_red(color)   { return  color        & 0xFF; }
function gmmt_color_rgba_get_green(color) { return (color >>  8) & 0xFF; }
function gmmt_color_rgba_get_blue(color)  { return (color >> 16) & 0xFF; }
function gmmt_color_rgba_get_alpha(color) { return (color >> 24) & 0xFF; }

function ggmmt_color_rgb_to_rgba(color, alpha = 255) { // GML BGR to RGBA
    return gmmt_make_color_rgba(
        color_get_red(color),
        color_get_green(color),
        color_get_blue(color),
        alpha
    );
}

function gmmt_color_rgba_to_rgb(color) { // GMMT RGBA to GML BGR
    return make_color_rgb(
        gmmt_color_rgba_get_red(color),
        gmmt_color_rgba_get_green(color),
        gmmt_color_rgba_get_blue(color)
    );
}

function gmmt_color_rgba_to_array(color) {
    return [
        gmmt_color_rgba_get_red(color),
        gmmt_color_rgba_get_green(color),
        gmmt_color_rgba_get_blue(color),
        gmmt_color_rgba_get_alpha(color)
    ];
}

function gmmt_color_rgb_to_array(color) {
    return [color_get_red(color), color_get_green(color), color_get_blue(color)];
}

function gmmt_color_rgba_from_array(arr) {
    return gmmt_make_color_rgba(arr[0], arr[1], arr[2], arr[3]);
}

// init
function gmmt_init() {
	global.gmmt = {
		tweens: [ ],
		tweens_map: ds_map_create(),
		groups: ds_map_create(),
		timelines: ds_map_create(),
		global_time_scale: 1.0,
		active_tweens: 0,
		total_tweens_created: 0,
		default_easing: gmmt_ease.IN_OUT_QUAD,
		default_duration: 300000,
		clips: ds_map_create(),
		paths: ds_map_create(),
	};
}

function gmmt_get() {
	return global.gmmt;
}

function gmmt_init_check_safe() {
	if (!variable_global_exists("gmmt")) { gmmt_init(); };
}

// value lerp functions
function gmmt_lerp_color3(_c1, _c2, _t) {
	var _r = lerp(color_get_red(_c1), color_get_red(_c2), _t);
	var _g = lerp(color_get_green(_c1), color_get_green(_c2), _t);
	var _b = lerp(color_get_blue(_c1), color_get_blue(_c2), _t);
	return make_color_rgb(_r, _g, _b);
}

function gmmt_lerp_color4(_c1, _c2, _t) {
	var _a1 = gmmt_color_rgba_to_array(_c1);
	var _a2 = gmmt_color_rgba_to_array(_c2);
	var _r = lerp(_a1[0], _a2[0], _t);
	var _g = lerp(_a1[1], _a2[1], _t);
	var _b = lerp(_a1[2], _a2[2], _t);
	var _a = lerp(_a1[3], _a2[3], _t);
	return gmmt_make_color_rgba(_r, _g, _b, _a);
}

function gmmt_lerp_vector2(_v1, _v2, _t) {
	return [lerp(_v1[0], _v2[0], _t), lerp(_v1[1], _v2[1], _t)];
}

function gmmt_lerp_vector3(_v1, _v2, _t) {
	return [lerp(_v1[0], _v2[0], _t), lerp(_v1[1], _v2[1], _t), lerp(_v1[2], _v2[2], _t)];
}

function gmmt_lerp_vector4(_v1, _v2, _t) {
	return [lerp(_v1[0], _v2[0], _t), lerp(_v1[1], _v2[1], _t), lerp(_v1[2], _v2[2], _t), lerp(_v1[3], _v2[3], _t)];
}

function gmmt_lerp_array(_a1, _a2, _t) {
	var _len = min(array_length(_a1), array_length(_a2));
	var _result = array_create(_len);
	for (var i = 0; i < _len; i++) {
		_result[i] = lerp(_a1[i], _a2[i], _t);
	}
	return _result;
}

// type detection
function gmmt_detect_value_type(_value) {
	if (is_array(_value)) {
		var _len = array_length(_value);
		switch (_len) {
			case 2: return gmmt_value_type.VECTOR2;
			case 3: return gmmt_value_type.VECTOR3;
			case 4: return gmmt_value_type.VECTOR4;
			default: return gmmt_value_type.ARRAY;
		}
	}
	return gmmt_value_type.REAL;
}

function gmmt_get_lerp_function(_type) {
	switch (_type) {
		case gmmt_value_type.COLOR3: return method({}, gmmt_lerp_color3);
		case gmmt_value_type.COLOR4: return method({}, gmmt_lerp_color4);
		case gmmt_value_type.VECTOR2: return method({}, gmmt_lerp_vector2);
		case gmmt_value_type.VECTOR3: return method({}, gmmt_lerp_vector3);
		case gmmt_value_type.VECTOR4: return method({}, gmmt_lerp_vector4);
		case gmmt_value_type.ARRAY: return method({}, gmmt_lerp_array);
		case gmmt_value_type.INT: return undefined;
		default: return undefined;
	}
}

function gmmt_is_value_simple(_type) {
	return (_type == gmmt_value_type.REAL || 
	        _type == gmmt_value_type.INT || 
	        _type == gmmt_value_type.COLOR3);
}

function gmmt_is_value_array_type(_type) {
	return (_type == gmmt_value_type.VECTOR2 || 
	        _type == gmmt_value_type.VECTOR3 || 
	        _type == gmmt_value_type.VECTOR4 || 
	        _type == gmmt_value_type.ARRAY);
}

// value manipulation (helpers)
function gmmt_lerp_values(_start, _end, _type, _t, _lerp_func) {
	if (_lerp_func != undefined) {
		return _lerp_func(_start, _end, _t);
	}
	switch (_type) {
		case gmmt_value_type.COLOR3: return gmmt_lerp_color3(_start, _end, _t);
		case gmmt_value_type.COLOR4: return gmmt_lerp_color4(_start, _end, _t);
		case gmmt_value_type.VECTOR2: return gmmt_lerp_vector2(_start, _end, _t);
		case gmmt_value_type.VECTOR3: return gmmt_lerp_vector3(_start, _end, _t);
		case gmmt_value_type.VECTOR4: return gmmt_lerp_vector4(_start, _end, _t);
		case gmmt_value_type.ARRAY: return gmmt_lerp_array(_start, _end, _t);
		default: return lerp(_start, _end, _t);
	}
}

function gmmt_add_scalar_to_value(_value, _type, _scalar) {
	switch (_type) {
		case gmmt_value_type.REAL:
			return _value + _scalar;
		case gmmt_value_type.VECTOR2:
			return [_value[0] + _scalar, _value[1] + _scalar];
		case gmmt_value_type.VECTOR3:
			return [_value[0] + _scalar, _value[1] + _scalar, _value[2] + _scalar];
		case gmmt_value_type.VECTOR4:
			return [_value[0] + _scalar, _value[1] + _scalar, _value[2] + _scalar, _value[3] + _scalar];
		default:
			return _value;
	}
}

function gmmt_clamp_values(_value, _start, _end, _type) {
	if (!gmmt_is_value_simple(_type) && !gmmt_is_value_array_type(_type)) return _value;
	
	if (_type == gmmt_value_type.REAL) {
		var _min = min(_start, _end);
		var _max = max(_start, _end);
		return clamp(_value, _min, _max);
	}
	
	if (gmmt_is_value_array_type(_type)) {
		var _result = array_create(array_length(_value));
		for (var i = 0; i < array_length(_value); i++) {
			var _min = min(_start[i], _end[i]);
			var _max = max(_start[i], _end[i]);
			_result[i] = clamp(_value[i], _min, _max);
		}
		return _result;
	}
	
	return _value;
}

function gmmt_snap_value(_value, _end, _type, _threshold, _to_integer) {
	if (_type == gmmt_value_type.REAL) {
		if (_threshold > 0 && abs(_end - _value) <= _threshold) return _end;
		if (_to_integer) return round(_value);
		return _value;
	}
	
	if (gmmt_is_value_array_type(_type)) {
		var _result = array_create(array_length(_value));
		var _is_close = true;
		
		for (var i = 0; i < array_length(_value); i++) {
			if (_threshold > 0 && abs(_end[i] - _value[i]) <= _threshold) {
				_result[i] = _end[i];
			} else {
				_result[i] = _to_integer ? round(_value[i]) : _value[i];
				if (_result[i] != _end[i]) _is_close = false;
			}
		}
		
		if (_is_close && _threshold > 0) return _end;
		return _result;
	}
	
	return _value;
}

function gmmt_process_value(_value, _type, _processor) {
	if (_processor == undefined) return _value;
	
	if (_type == gmmt_value_type.REAL) {
		return _processor(_value);
	}
	
	if (gmmt_is_value_array_type(_type)) {
		var _result = array_create(array_length(_value));
		for (var i = 0; i < array_length(_value); i++) {
			_result[i] = _processor(_value[i]);
		}
		return _result;
	}
	
	return _value;
}

// create tween
function gmmt_remove_existing_tween(_id) {
	var _anim = gmmt_get();
	var _tweens = _anim.tweens;
	
	for (var i = 0; i < array_length(_tweens); i++) {
		if (_tweens[i] != undefined && _tweens[i].id == _id) {
			var _old = _tweens[i];
			if (_old.group != undefined) {
				var _group_list = ds_map_find_value(_anim.groups, _old.group);
				if (_group_list != undefined) {
					var _idx = array_get_index(_group_list, _id);
					if (_idx >= 0) array_delete(_group_list, _idx, 1);
				}
			}
			if (_old.state == gmmt_tween_state.PLAYING) _anim.active_tweens--;
			array_delete(_tweens, i, 1);
			ds_map_delete(_anim.tweens_map, _id);
			return true;
		}
	}
	return false;
}

function gmmt_create(_id, _start_val, _end_val, _duration = -1) {
	gmmt_init_check_safe();
	var _anim = gmmt_get();
	
	if (_duration < 0) { _duration = _anim.default_duration; }
	
	var _detected_type = gmmt_detect_value_type(_start_val);
	
	if (!is_array(_start_val) && _start_val >= 0 && _start_val <= 16777215) { // 16777215 ?
		// default is REAL for numbers, can be changed to COLOR3/COLOR4 by user
	}
	
	var _tween = {
		id: _id,
		group: undefined,
		
		value_type: _detected_type,
		start_value: _start_val,
		current_value: _start_val,
		end_value: _end_val,
		original_start: _start_val,
		original_end: _end_val,
		
		value_lerp: gmmt_get_lerp_function(_detected_type),
		value_processor: undefined,
		
		duration: _duration,
		elapsed: 0,
		delay: 0,
		direction: gmmt_tween_direction.FORWARD,
		
		pending_queue: [ ],  // { _from, _to, _duration, _easing }
		easing_per_axis: undefined,  // array of easing types, one per component
		
		use_system_delta: true,
		dt_override: undefined,
		time_scale_override: 1.0,
		
		easing: _anim.default_easing,
		easing_custom: undefined,
		easing_power: 1.0,
		easing_intensity: 1.0,
		
		state: gmmt_tween_state.IDLE,
		completed: false,
		
		repeat_mode: gmmt_repeat_mode.NONE,
		repeat_count: 0,
		repeat_delay: 0,
		repeat_elapsed: 0,
		repeat_even_only: false,
		
		ping_pong_forward: true,
		
		flags: gmmt_tween_flags.DELETE_ON_COMPLETE | gmmt_tween_flags.CLAMP_VALUES,
		oscillation_amplitude: 0,
		oscillation_frequency: 0,
		oscillation_phase: 0,
		noise_amount: 0,
		noise_seed: 0,
		
		snap_threshold: 0,
		snap_to_integer: false,
		
		on_start: undefined,
		on_update: undefined,
		on_complete: undefined,
		on_repeat: undefined,
		on_pingpong: undefined,
		on_pause: undefined,
		on_resume: undefined,
		on_kill: undefined,
		on_direction_change: undefined,
		
		user_data: undefined,
		
		creation_time: current_time,
		update_count: 0,
	};
	
	if (_tween.delay > 0) {
		_tween.elapsed = -_tween.delay;
	}
	
	if (_tween.direction == gmmt_tween_direction.BACKWARD) {
		var _temp = _tween.start_value;
		_tween.start_value = _tween.end_value;
		_tween.end_value = _temp;
		_tween.elapsed = _tween.duration;
	}
	
	array_push(_anim.tweens, _tween);
	ds_map_add(_anim.tweens_map, _id, _tween);
	_anim.total_tweens_created++;
	
	return _tween;
}

// configuration functions
function gmmt_set_easing(_id, _easing) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) { _tween.easing = _easing; }
	return _tween;
}

function gmmt_set_custom_ease(_id, _func) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.easing = gmmt_ease.CUSTOM;
		_tween.easing_custom = method({}, _func);
	}
	return _tween;
}

function gmmt_set_repeat(_id, _count, _delay = 0, _even_only = false) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.repeat_mode = gmmt_repeat_mode.LOOP;
		_tween.repeat_count = _count;
		_tween.repeat_delay = _delay;
		_tween.repeat_even_only = _even_only;
	}
	return _tween;
}

function gmmt_set_pingpong(_id, _count = -1) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.repeat_mode = gmmt_repeat_mode.PING_PONG;
		_tween.repeat_count = _count;
		_tween.ping_pong_forward = true;
	}
	return _tween;
}

function gmmt_set_pingpong_once(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.repeat_mode = gmmt_repeat_mode.PING_PONG_ONCE;
		_tween.repeat_count = 1;
		_tween.ping_pong_forward = true;
	}
	return _tween;
}

function gmmt_set_delay(_id, _delay) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.delay = _delay;
		_tween.elapsed = -_delay;
	}
	return _tween;
}

function gmmt_set_time_scale(_id, _scale) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) { _tween.time_scale_override = _scale; }
	return _tween;
}

function gmmt_set_callbacks(_id, _on_start = undefined, _on_update = undefined, _on_complete = undefined) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		if (_on_start != undefined) _tween.on_start = method({}, _on_start);
		if (_on_update != undefined) _tween.on_update = method({}, _on_update);
		if (_on_complete != undefined) _tween.on_complete = method({}, _on_complete);
	}
	return _tween;
}

function gmmt_set_value_type(_id, _type) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.value_type = _type;
		_tween.value_lerp = gmmt_get_lerp_function(_type);
	}
	return _tween;
}

function gmmt_set_oscillation(_id, _amplitude, _frequency, _phase = 0) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.oscillation_amplitude = _amplitude;
		_tween.oscillation_frequency = _frequency;
		_tween.oscillation_phase = _phase;
	}
	return _tween;
}

function gmmt_set_noise(_id, _amount, _seed = 0) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.noise_amount = _amount;
		_tween.noise_seed = _seed;
	}
	return _tween;
}

function gmmt_set_snap(_id, _threshold, _to_integer = false) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.snap_threshold = _threshold;
		_tween.snap_to_integer = _to_integer;
	}
	return _tween;
}

function gmmt_set_flags(_id, _flags) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) { _tween.flags = _flags; }
	return _tween;
}

function gmmt_add_flags(_id, _flags) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) { _tween.flags |= _flags; }
	return _tween;
}

function gmmt_set_group(_id, _group_name) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	var _anim = gmmt_get();
	
	if (_tween != undefined) {
		_tween.group = _group_name;
		var _group_list = ds_map_find_value(_anim.groups, _group_name);
		if (_group_list == undefined) {
			_group_list = [];
			ds_map_add(_anim.groups, _group_name, _group_list);
		}
		array_push(_group_list, _id);
	}
	return _tween;
}

function gmmt_set_user_data(_id, _data) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) { _tween.user_data = _data; }
	return _tween;
}

// tween control
function gmmt_play(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined && _tween.state == gmmt_tween_state.IDLE) {
		_tween.state = gmmt_tween_state.PLAYING;
		var _anim = gmmt_get();
		_anim.active_tweens++;
		if (_tween.on_start != undefined) { _tween.on_start(_tween); }
	}
}

function gmmt_pause(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined && _tween.state == gmmt_tween_state.PLAYING) {
		_tween.state = gmmt_tween_state.PAUSED;
		var _anim = gmmt_get();
		_anim.active_tweens--;
		if (_tween.on_pause != undefined) { _tween.on_pause(_tween); }
	}
}

function gmmt_resume(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined && _tween.state == gmmt_tween_state.PAUSED) {
		_tween.state = gmmt_tween_state.PLAYING;
		var _anim = gmmt_get();
		_anim.active_tweens++;
		if (_tween.on_resume != undefined) { _tween.on_resume(_tween); }
	}
}

function gmmt_toggle(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		if (_tween.state == gmmt_tween_state.PLAYING) {
			gmmt_pause(_id);
		} else if (_tween.state == gmmt_tween_state.PAUSED) {
			gmmt_resume(_id);
		}
	}
}

function gmmt_stop(_id, _go_to_end = false) {
	var _anim = gmmt_get();
	var _tween = ds_map_find_value(_anim.tweens_map, _id);
	if (_tween != undefined) {
		if (_go_to_end) {
			_tween.current_value = _tween.end_value;
		}
		if (_tween.state == gmmt_tween_state.PLAYING) {
			_anim.active_tweens--;
		}
		_tween.state = gmmt_tween_state.KILLED;
		_tween.completed = true;
		
		ds_map_delete(_anim.tweens_map, _id);
		
		if (_tween.group != undefined) {
			var _group_list = ds_map_find_value(_anim.groups, _tween.group);
			if (_group_list != undefined) {
				var _group_idx = array_get_index(_group_list, _id);
				if (_group_idx >= 0) {
					array_delete(_group_list, _group_idx, 1);
				}
			}
		}
		
		if (_tween.on_kill != undefined) { _tween.on_kill(_tween); }
	}
}

function gmmt_kill_group(_group_name) {
	var _anim = gmmt_get();
	var _group_list = ds_map_find_value(_anim.groups, _group_name);
	if (_group_list != undefined) {
		for (var i = array_length(_group_list) - 1; i >= 0; i--) {
			gmmt_stop(_group_list[i], false);
		}
	}
}

function gmmt_kill_all() {
	var _anim = gmmt_get();
	var _tweens = _anim.tweens;
	for (var i = array_length(_tweens) - 1; i >= 0; i--) {
		var _tween = _tweens[i];
		if (_tween != undefined && _tween.state == gmmt_tween_state.PLAYING) {
			gmmt_stop(_tween.id, false);
		}
	}
}

function gmmt_reverse(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined && _tween.state == gmmt_tween_state.PLAYING) {
		var _temp = _tween.start_value;
		_tween.start_value = _tween.end_value;
		_tween.end_value = _temp;
		_tween.elapsed = max(0, _tween.duration - _tween.elapsed);
		if (_tween.on_direction_change != undefined) { _tween.on_direction_change(_tween); }
	}
}

function gmmt_seek(_id, _progress) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_progress = clamp(_progress, 0, 1);
		_tween.elapsed = _tween.duration * _progress;
		var _eased = gmmt_get_eased_value(_tween, _progress);
		_tween.current_value = gmmt_lerp_values(_tween.start_value, _tween.end_value, _tween.value_type, _eased, _tween.value_lerp);
	}
}

// value getters
function gmmt_get_value(_id) {
	gmmt_init_check_safe();
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) { return _tween.current_value; }
	return undefined;
}

function gmmt_get_progress(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined && _tween.duration > 0) {
		return clamp(_tween.elapsed / _tween.duration, 0, 1);
	}
	return 0;
}

function gmmt_is_playing(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	return (_tween != undefined && _tween.state == gmmt_tween_state.PLAYING);
}

function gmmt_exists(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	return (_tween != undefined && _tween.state != gmmt_tween_state.KILLED);
}

// global settings
function gmmt_set_global_time_scale(_scale) {
	var _anim = gmmt_get();
	if (_anim != undefined) { _anim.global_time_scale = _scale; }
}

function gmmt_get_global_time_scale() {
	var _anim = gmmt_get();
	if (_anim != undefined) { return _anim.global_time_scale; }
	return 1.0;
}

// update call
function gmmt_update() {
	var _anim = gmmt_get();
	if (_anim == undefined) { return false; }
	
	var _tweens = _anim.tweens;
	
	for (var i = 0; i < array_length(_tweens); i++) {
		var _tween = _tweens[i];
		if (_tween == undefined || _tween.state == gmmt_tween_state.KILLED) continue;
		if (_tween.state != gmmt_tween_state.PLAYING) continue;
		
		var _dt = _tween.use_system_delta ? delta_time : _tween.dt_override;
		
		if (!(_tween.flags & gmmt_tween_flags.IGNORE_TIME_SCALE)) {
			_dt *= _anim.global_time_scale;
		}
		_dt *= _tween.time_scale_override;
		
		if (_tween.direction == gmmt_tween_direction.BACKWARD) {
			_dt = -_dt;
		}
		
		_tween.elapsed += _dt;
		_tween.update_count++;
		
		if (_tween.elapsed < 0) continue;
		
		var _progress = (_tween.duration > 0) ? (_tween.elapsed / _tween.duration) : 1.0;
		
		if (_tween.direction == gmmt_tween_direction.BACKWARD && _progress <= 0.0) {
			_tween.current_value = _tween.end_value;
			gmmt_complete_tween(_tween);
			continue;
		}
		
		if (_progress >= 1.0) {
			if (_tween.repeat_mode == gmmt_repeat_mode.LOOP && 
			    (_tween.repeat_count == -1 || _tween.repeat_count > 0)) {
				
				if (_tween.repeat_count > 0) {
					_tween.repeat_count--;
				}
				
				if (_tween.repeat_delay > 0) {
					_tween.repeat_elapsed = 0;
					_tween.elapsed = -_tween.repeat_delay;
				    if (_tween.flags & gmmt_tween_flags.REPEAT_RESET_ON_DELAY) {
				        _progress = 0;
				    } else {
				        _progress = 1.0;
				    }
				} else {
					_tween.elapsed = _tween.elapsed - _tween.duration;
					_progress = _tween.elapsed / _tween.duration;
				}
				
				if (_tween.on_repeat != undefined) { _tween.on_repeat(_tween); }
				
			} else if (_tween.repeat_mode == gmmt_repeat_mode.PING_PONG || 
			           _tween.repeat_mode == gmmt_repeat_mode.PING_PONG_ONCE) {
				
				if (_tween.repeat_count == -1 || _tween.repeat_count > 0) {
					if (_tween.repeat_count > 0) {
						_tween.repeat_count--;
					}
					
					//_tween.ping_pong_forward = !_tween.ping_pong_forward;
					//var _temp = _tween.start_value;
					//_tween.start_value = _tween.end_value;
					//_tween.end_value = _temp;
					_tween.ping_pong_forward = !_tween.ping_pong_forward;
			        var _temp = _tween.start_value;
			        _tween.start_value = _tween.end_value;
			        _tween.end_value = _temp;
        
			        if (_tween.repeat_delay > 0) {
			            _tween.repeat_elapsed = 0;
			            _tween.elapsed = -_tween.repeat_delay;
					    if (_tween.flags & gmmt_tween_flags.REPEAT_RESET_ON_DELAY) {
					        _progress = 0;
					    } else {
					        _progress = 1.0;
					    }
			        } else {
			            _tween.elapsed = _tween.elapsed - _tween.duration;
            
			            if (_tween.value_type == gmmt_value_type.REAL || _tween.value_type == gmmt_value_type.INT) {
			                var _range = _tween.end_value - _tween.start_value;
			                if (abs(_range) > 0.00001) {
			                    _tween.elapsed = ((_tween.current_value - _tween.start_value) / _range) * _tween.duration;
			                }
			            }
			        }
			        _progress = _tween.elapsed / _tween.duration;
					
					if (_tween.on_pingpong != undefined) { _tween.on_pingpong(_tween); }
				} else {
					_tween.current_value = _tween.end_value;
					gmmt_complete_tween(_tween);
					continue;
				}
			} else {
				_tween.current_value = _tween.end_value;
				gmmt_complete_tween(_tween);
				continue;
			}
		}
		
		if (_tween.easing_per_axis != undefined && gmmt_is_value_array_type(_tween.value_type)) { // per axis easing
			var _len = array_length(_tween.easing_per_axis);
			var _vals = array_create(_len);
			var _start_arr = _tween.start_value;
			var _end_arr = _tween.end_value;
			for (var j = 0; j < _len; j++) {
				var _per_axis_tween = { easing: _tween.easing_per_axis[j], easing_power: _tween.easing_power, easing_intensity: _tween.easing_intensity, easing_custom: undefined, flags: _tween.flags, ping_pong_forward: _tween.ping_pong_forward };
				var _ep = gmmt_get_eased_value(_per_axis_tween, clamp(_progress, 0, 1));
				_vals[j] = lerp(_start_arr[j], _end_arr[j], _ep);
			}
			_tween.current_value = _vals;
		} else {
		    var _eased_progress = gmmt_get_eased_value(_tween, clamp(_progress, 0, 1));
		    if (_tween.value_type == gmmt_value_type.REAL && _tween.value_lerp == undefined) {
		        _tween.current_value = lerp(_tween.start_value, _tween.end_value, _eased_progress);
		    } else {
		        _tween.current_value = gmmt_lerp_values(_tween.start_value, _tween.end_value, _tween.value_type, _eased_progress, _tween.value_lerp);
		    }
		}
		
		//if (_tween.oscillation_amplitude > 0) {
		//	var _osc = sin(_progress * _tween.oscillation_frequency * 2 * pi + _tween.oscillation_phase) * _tween.oscillation_amplitude * (1 - _progress);
		//	_tween.current_value = gmmt_add_scalar_to_value(_tween.current_value, _tween.value_type, _osc);
		//}
		if (_tween.oscillation_amplitude > 0) {
			var _time = _tween.elapsed / 1000000;
			var _decay = (_tween.duration >= 999999999) ? 1.0 : (1 - _progress);
			var _osc = sin(_time * _tween.oscillation_frequency * 2 * pi + _tween.oscillation_phase) * _tween.oscillation_amplitude * _decay;
			_tween.current_value = gmmt_add_scalar_to_value(_tween.current_value, _tween.value_type, _osc);
		}
		
		if (_tween.noise_amount > 0 && (gmmt_is_value_simple(_tween.value_type) || gmmt_is_value_array_type(_tween.value_type))) {
			random_set_seed(_tween.noise_seed + _tween.update_count);
			var _noise = random_range(-_tween.noise_amount, _tween.noise_amount);
			_tween.current_value = gmmt_add_scalar_to_value(_tween.current_value, _tween.value_type, _noise);
		}
		
		if (_tween.value_type == gmmt_value_type.INT) { // forces int to be snapped
			_tween.snap_to_integer = true;
		}
		_tween.current_value = gmmt_snap_value(_tween.current_value, _tween.end_value, _tween.value_type, _tween.snap_threshold, _tween.snap_to_integer); // snaps all types
		
		_tween.current_value = gmmt_process_value(_tween.current_value, _tween.value_type, _tween.value_processor);
		
		if (_tween.flags & gmmt_tween_flags.CLAMP_VALUES) {
			//_tween.current_value = gmmt_clamp_values(_tween.current_value, _tween.start_value, _tween.end_value, _tween.value_type);
		    var _easing = _tween.easing;
		    var _is_overshoot = (_easing == gmmt_ease.IN_ELASTIC || _easing == gmmt_ease.OUT_ELASTIC || _easing == gmmt_ease.IN_OUT_ELASTIC ||
		                         _easing == gmmt_ease.IN_BACK || _easing == gmmt_ease.OUT_BACK || _easing == gmmt_ease.IN_OUT_BACK ||
		                         _easing == gmmt_ease.IN_BOUNCE || _easing == gmmt_ease.OUT_BOUNCE || _easing == gmmt_ease.IN_OUT_BOUNCE);
    
		    if (!_is_overshoot) {
		        _tween.current_value = gmmt_clamp_values(_tween.current_value, _tween.start_value, _tween.end_value, _tween.value_type);
		    }
		}
		
		if (_tween.on_update != undefined) { _tween.on_update(_tween); }
	}
	
	for (var i = array_length(_tweens) - 1; i >= 0; i--) {
		var _tween = _tweens[i];
		if (_tween == undefined) { array_delete(_tweens, i, 1); continue; }
		if (_tween.state != gmmt_tween_state.COMPLETED && _tween.state != gmmt_tween_state.KILLED) continue;
		
		if (ds_map_find_value(_anim.tweens_map, _tween.id) != undefined) {
			ds_map_delete(_anim.tweens_map, _tween.id);
		}
		if (_tween.group != undefined) {
			var _group_list = ds_map_find_value(_anim.groups, _tween.group);
			if (_group_list != undefined) {
				var _group_idx = array_get_index(_group_list, _tween.id);
				if (_group_idx >= 0) { array_delete(_group_list, _group_idx, 1); }
			}
		}
		array_delete(_tweens, i, 1);
	}
	
	return true;
}

function gmmt_complete_tween(_tween) {
	if (is_array(_tween.pending_queue) && array_length(_tween.pending_queue) > 0) { // should work now ?
		var _q = _tween.pending_queue[0];
		array_delete(_tween.pending_queue, 0, 1);
		
		if (array_length(_tween.pending_queue) == 0) {
			_tween.pending_queue = [];
			_tween.flags &= ~gmmt_tween_flags.QUEUE;
		}
		
		_tween.start_value = _tween.current_value;
		_tween.end_value = _q._to;
		_tween.original_start = _tween.current_value;
		_tween.original_end = _q._to;
		_tween.duration = _q._duration;
		_tween.elapsed = 0;
		_tween.delay = 0;
		_tween.repeat_count = 0;
		_tween.repeat_mode = gmmt_repeat_mode.NONE;
		_tween.ping_pong_forward = true;
		_tween.completed = false;
		_tween.direction = gmmt_tween_direction.FORWARD;
		
		if (_q._easing != undefined) {
			_tween.easing = _q._easing;
		}
		
		_tween.state = gmmt_tween_state.PLAYING; // reset
		
		if (_tween.on_start != undefined) { _tween.on_start(_tween); }
		return; // keeps playing
	}
	
	// complete
	_tween.state = gmmt_tween_state.COMPLETED;
	_tween.completed = true;
	var _anim = gmmt_get();
	_anim.active_tweens--;
	
	if (_tween.on_complete != undefined) { _tween.on_complete(_tween); }
}

// easing functions
function gmmt_get_eased_value(_tween, _t) {
	var _easing = _tween.easing;
	var _intensity = _tween.easing_intensity;
	
	//if (_tween.flags & gmmt_tween_flags.REVERSE_EASE_ON_PINGPONG && !_tween.ping_pong_forward) {
	//	_t = 1 - _t;
	//}
	
	_t = clamp(power(clamp(_t, 0, 1), _tween.easing_power), 0, 1);
	
	var _result = 0;
	
	switch (_easing) {
		case gmmt_ease.LINEAR:				_result  = _t;																															break;
		case gmmt_ease.IN_QUAD:				_result  = power(_t, 2);																												break;
		case gmmt_ease.OUT_QUAD:			_result  = -_t * (_t - 2);																												break;
		case gmmt_ease.IN_OUT_QUAD:			_result  = (_t < 0.5) ? 2 * power(_t, 2) : -1 + (4 - 2 * _t) * _t;																		break;
		case gmmt_ease.IN_CUBIC:			_result  = power(_t, 3);																												break;
		case gmmt_ease.OUT_CUBIC:			_t		-= 1; _result = power(_t, 3) + 1;																								break;
		case gmmt_ease.IN_OUT_CUBIC:		_result  = (_t < 0.5) ? 4 * power(_t, 3) : power(2 * _t - 2, 3) * 0.5 + 1;																break;
		case gmmt_ease.IN_QUART:			_result  = power(_t, 4);																												break;
		case gmmt_ease.OUT_QUART:			_t		-= 1; _result = -(power(_t, 4) - 1);																							break;
		case gmmt_ease.IN_OUT_QUART:		_result  = (_t < 0.5) ? 8 * power(_t, 4) : -1/2 * power(2 * _t - 2, 4) + 1;																break;
		case gmmt_ease.IN_QUINT:			_result  = power(_t, 5);																												break;
		case gmmt_ease.OUT_QUINT:			_t		-= 1; _result = power(_t, 5) + 1;																								break;
		case gmmt_ease.IN_OUT_QUINT:		_result  = (_t < 0.5) ? 16 * power(_t, 5) : power(2 * _t - 2, 5) * 0.5 + 1;																break;
		case gmmt_ease.IN_SINE:				_result  = -cos(_t * pi / 2) + 1;																										break;
		case gmmt_ease.OUT_SINE:			_result  = sin(_t * pi / 2);																											break;
		case gmmt_ease.IN_OUT_SINE:			_result  = -(cos(pi * _t) - 1) / 2;																										break;
		case gmmt_ease.IN_EXPO:				_result  = (_t == 0) ? 0 : power(2, 10 * (_t - 1));																						break;
		case gmmt_ease.OUT_EXPO:			_result  = (_t == 1) ? 1 : -power(2, -10 * _t) + 1;																						break;
		case gmmt_ease.IN_OUT_EXPO:
			if (_t == 0 || _t == 1) { _result = _t; break; }
			_result = (_t < 0.5) ? power(2, 20 * _t - 10) / 2 : (2 - power(2, -20 * _t + 10)) / 2;
			break;
		case gmmt_ease.IN_CIRC:				_result  = -(sqrt(1 - power(_t, 2)) - 1);																								break;
		case gmmt_ease.OUT_CIRC: _t -= 1;	_result  = sqrt(1 - power(_t, 2));																										break;
		case gmmt_ease.IN_OUT_CIRC:			_result  = (_t < 0.5) ? (1 - sqrt(1 - power(2 * _t, 2))) / 2 : (sqrt(1 - power(-2 * _t + 2, 2)) + 1) / 2;								break;
		case gmmt_ease.IN_ELASTIC:
			if (_t == 0 || _t == 1) { _result = _t; break; }
			var _p = 0.3 * _intensity;
			_result = -power(2, 10 * (_t - 1)) * sin((_t - 1 - _p / 4) * (2 * pi) / _p);
			break;
		case gmmt_ease.OUT_ELASTIC:
			if (_t == 0 || _t == 1) { _result = _t; break; }
			_result = power(2, -10 * _t) * sin((_t - 1) * (2 * pi) / (0.3 * _intensity)) + 1;
			break;
		case gmmt_ease.IN_OUT_ELASTIC:
			if (_t == 0 || _t == 1) { _result = _t; break; }
			_t *= 2; var _p2 = 0.45 * _intensity;
			if (_t < 1) { _result = -0.5 * power(2, 10 * (_t - 1)) * sin((_t - 1 - _p2 / 4) * (2 * pi) / _p2); }
			else { _result = power(2, -10 * (_t - 1)) * sin((_t - 1 - _p2 / 4) * (2 * pi) / _p2) * 0.5 + 1; }
			break;
		case gmmt_ease.IN_BACK:
			var _s = 1.70158 * _intensity;
			_result = _t * _t * ((_s + 1) * _t - _s);
			break;
		case gmmt_ease.OUT_BACK:
			_t -= 1; var _s2 = 1.70158 * _intensity;
			_result = _t * _t * ((_s2 + 1) * _t + _s2) + 1;
			break;
		case gmmt_ease.IN_OUT_BACK:
			var _s3 = 1.70158 * _intensity; _t *= 2;
			if (_t < 1) { _result = 0.5 * _t * _t * ((_s3 * 1.525 + 1) * _t - _s3 * 1.525); }
			else { _t -= 2; _result = 0.5 * (_t * _t * ((_s3 * 1.525 + 1) * _t + _s3 * 1.525) + 2); }
			break;
		case gmmt_ease.IN_BOUNCE:			_result  = 1 - gmmt_ease_out_bounce(1 - _t);																							break;
		case gmmt_ease.OUT_BOUNCE:			_result  = gmmt_ease_out_bounce(_t);																									break;
		case gmmt_ease.IN_OUT_BOUNCE:		_result  = (_t < 0.5) ? (1 - gmmt_ease_out_bounce(1 - 2 * _t)) / 2 : (1 + gmmt_ease_out_bounce(2 * _t - 1)) / 2;						break;
		case gmmt_ease.CUSTOM:
			if (_tween.easing_custom != undefined) { _result = _tween.easing_custom(_t); }
			else { _result = _t; }
			break;
		default: _result = _t; break;
	}
	
	//return clamp(_result, 0, 1);
	return _result; // should fix elastic types not overshooting
}

function gmmt_ease_out_bounce(_t) {
	var _n1 = 7.5625, _d1 = 2.75;
	if (_t < 1 / _d1) { return _n1 * _t * _t; }
	else if (_t < 2 / _d1) { _t -= 1.5 / _d1; return _n1 * _t * _t + 0.75; }
	else if (_t < 2.5 / _d1) { _t -= 2.25 / _d1; return _n1 * _t * _t + 0.9375; }
	else { _t -= 2.625 / _d1; return _n1 * _t * _t + 0.984375; }
}

// convenience/quick start functions
function gmmt_tween(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_start(_id, _from, _to, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_start(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	return gmmt_tween_internal(_id, _from, _to, _duration, _easing);
}

function gmmt_tween_internal(_id, _from, _to, _duration, _easing) {
	var _tween = gmmt_create(_id, _from, _to, _duration);
	
	var _anim = gmmt_get();
	var _existing = ds_map_find_value(_anim.tweens_map, _id);
	
	if (_existing != undefined && _tween.flags & gmmt_tween_flags.OVERRIDE_EXISTING) {
		gmmt_remove_existing_tween(_id);
		_tween = gmmt_create(_id, _from, _to, _duration);
	}
	
	if (_easing != undefined) { gmmt_set_easing(_id, _easing); }
	
	_tween.state = gmmt_tween_state.PLAYING;
	_anim.active_tweens++;
	
	if (_tween.on_start != undefined) { _tween.on_start(_tween); }
	
	return _tween;
}

function gmmt_pulse(_id, _base_value, _pulse_to, _duration = 200000, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	
	gmmt_pulse_start(_id, _base_value, _pulse_to, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_pulse_start(_id, _base_value, _pulse_to, _duration = 200000, _easing = undefined) {
	var _tween = gmmt_tween_start(_id, _base_value, _pulse_to, _duration, _easing);
	gmmt_set_pingpong_once(_id);
	return _tween;
}

function gmmt_shake(_id, _center_value, _intensity, _duration = 100000, _frequency = 4) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	
	gmmt_shake_start(_id, _center_value, _intensity, _duration, _frequency);
	return gmmt_get_value(_id);
}

function gmmt_shake_start(_id, _center_value, _intensity, _duration = 100000, _frequency = 4) {
	var _tween = gmmt_create(_id, _center_value, _center_value, _duration);
	_tween.oscillation_amplitude = _intensity;
	_tween.oscillation_frequency = _frequency;
	_tween.flags = _tween.flags & ~gmmt_tween_flags.CLAMP_VALUES;
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

// queue
function gmmt_queue(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _anim = gmmt_get();
	var _existing = ds_map_find_value(_anim.tweens_map, _id);
	
	if (_existing != undefined && _existing.state == gmmt_tween_state.PLAYING) {
		if (!is_array(_existing.pending_queue)) {
			_existing.pending_queue = [];
		}
		array_push(_existing.pending_queue, {
			_from: _from,
			_to: _to,
			_duration: _duration < 0 ? _anim.default_duration : _duration,
			_easing: _easing
		});
		_existing.flags |= gmmt_tween_flags.QUEUE;
		return _existing.current_value;
	}
	
	return gmmt_tween_start(_id, _from, _to, _duration, _easing);
}

function gmmt_queue_clear(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.pending_queue = [ ];
		_tween.flags &= ~gmmt_tween_flags.QUEUE;
	}
}

function gmmt_get_queue_count(_id) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined && is_array(_tween.pending_queue)) {
		return array_length(_tween.pending_queue);
	}
	return 0;
}

// stagger
function gmmt_stagger(_ids, _from, _to, _duration = -1, _stagger = 100000, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _count = array_length(_ids);
	for (var i = 0; i < _count; i++) {
		var _tween = gmmt_create(_ids[i], _from, _to, _duration);
		_tween.delay = i * _stagger;
		_tween.elapsed = -_tween.delay;
		if (_easing != undefined) {
			_tween.easing = _easing;
		}
		gmmt_play(_ids[i]);
	}
}

function gmmt_stagger_ex(_items, _duration = -1, _stagger = 100000, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _count = array_length(_items);
	for (var i = 0; i < _count; i++) {
		var _item = _items[i];
		var _tween = gmmt_create(_item.id, _item.from, _item.to, _duration);
		_tween.delay = i * _stagger;
		_tween.elapsed = -_tween.delay;
		if (_easing != undefined) {
			_tween.easing = _easing;
		}
		gmmt_play(_item.id);
	}
}

// per axis easing
function gmmt_set_easing_per_axis(_id, _easings) {
	var _tween = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_tween != undefined) {
		_tween.easing_per_axis = _easings;
	}
	return _tween;
}

// wiggle
function gmmt_wiggle(_id, _center, _amplitude, _frequency = 2, _duration = -1) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state == gmmt_tween_state.PLAYING) {
		_exists.oscillation_amplitude = _amplitude;
		_exists.oscillation_frequency = _frequency;
		return gmmt_get_value(_id);
	}
	
	gmmt_wiggle_start(_id, _center, _amplitude, _frequency, _duration);
	return gmmt_get_value(_id);
}

function gmmt_wiggle_start(_id, _center, _amplitude, _frequency = 2, _duration = -1) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _tween = gmmt_create(_id, _center, _center, _duration < 0 ? 999999999 : _duration);
	_tween.oscillation_amplitude = _amplitude;
	_tween.oscillation_frequency = _frequency;
	_tween.oscillation_phase = 0;
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

// timeline
function gmmt_timeline(_id, _keyframes, _loop = false, _default_easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) {
		return gmmt_get_value(_id);
	}
	
	gmmt_timeline_start(_id, _keyframes, _loop, _default_easing);
	return gmmt_get_value(_id);
}

function gmmt_timeline_start(_id, _keyframes, _loop = false, _default_easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _count = array_length(_keyframes);
	if (_count < 2) {
		//show_debug_message("ERROR: Timeline requires at least 2 keyframes");
		return undefined;
	}
	
	array_sort(_keyframes, function(a, b) { return a.time - b.time; });
	
	var _first = _keyframes[0];
	var _last = _keyframes[_count - 1];
	var _total_duration = _last.time;
	
	var _tween = gmmt_create(_id, _first.value, _last.value, _total_duration);
	
	_tween.value_type = gmmt_detect_value_type(_first.value);
	
	_tween.timeline_data = {
		keyframes: _keyframes,
		loop: _loop,
		default_easing: _default_easing != undefined ? _default_easing : gmmt_ease.LINEAR,
		current_keyframe: 0,
	};
	
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _td = self.timeline_data;
		var _kfs = _td.keyframes;
		var _count = array_length(_kfs);
		
		if (_td.loop) {
			_t = frac(_t);
		} else {
			_t = clamp(_t, 0, 1);
		}
		
		var _elapsed = _t * self.duration;
		
		var _kf_from = _kfs[0];
		var _kf_to = _kfs[_count - 1];
		
		for (var i = 0; i < _count - 1; i++) {
			if (_elapsed >= _kfs[i].time && _elapsed <= _kfs[i + 1].time) {
				_kf_from = _kfs[i];
				_kf_to = _kfs[i + 1];
				break;
			}
		}
		
		if (_elapsed >= _kfs[_count - 1].time && !_td.loop) {
			return _kfs[_count - 1].value;
		}
		
		var _segment_duration = _kf_to.time - _kf_from.time;
		var _local_t = (_segment_duration > 0) ? (_elapsed - _kf_from.time) / _segment_duration : 0;
		
		var _easing = (_kf_from.easing != undefined) ? _kf_from.easing : _td.default_easing;
		var _ease_tween = {
			easing: _easing,
			easing_power: self.easing_power,
			easing_intensity: self.easing_intensity,
			easing_custom: undefined,
			flags: self.flags,
			ping_pong_forward: self.ping_pong_forward
		};
		var _eased_t = gmmt_get_eased_value(_ease_tween, clamp(_local_t, 0, 1));
		
		return gmmt_lerp_values(_kf_from.value, _kf_to.value, self.value_type, _eased_t, undefined);
	});
	
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	
	if (_loop) {
		gmmt_set_repeat(_id, -1);
	}
	
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_keyframe(_time, _value, _easing = undefined) {
	return { time: _time, value: _value, easing: _easing };
}

// spring physics
//function gmmt_spring_update(_current, _target, _velocity_ref, _tension = 0.5, _friction = 0.3, _mass = 1.0, _dt = -1) {
//	if (_dt < 0) { _dt = delta_time / 1000000; }
	
//	var _force = -_tension * (_current - _target);
//	var _damping = -_friction * _velocity_ref;
//	var _acceleration = (_force + _damping) / _mass;
	
//	_velocity_ref += _acceleration * _dt;
	
//	return _current + _velocity_ref * _dt;
//}
//function gmmt_spring_update(_current, _target, _velocity_ref, _tension = 0.5, _friction = 0.3, _mass = 1.0, _dt = -1) {
//	if (_dt < 0) { _dt = delta_time / 1000000; }
	
//	var _stiffness = _tension * 10;
//	var _damping = _friction * 5;
	
//	var _force = (_target - _current) * _stiffness;
//	var _acceleration = _force / _mass;
	
//	_velocity_ref += _acceleration * _dt;
//	_velocity_ref *= (1 - _damping * _dt);
	
//	return _current + _velocity_ref * _dt;
//}
function gmmt_spring_update(_current, _target, _velocity, _tension = 0.5, _friction = 0.3, _mass = 1.0, _dt = -1) {
	if (_dt < 0) { _dt = delta_time / 1000000; }
	
	var _omega = _tension * 20;
	var _zeta = _friction;
	
	var _k = _mass * _omega * _omega;
	var _c = 2 * _mass * _omega * _zeta;
	
	var _force = -_k * (_current - _target) - _c * _velocity;
	var _accel = _force / _mass;
	
	var _new_velocity = _velocity + _accel * _dt;
	var _new_value = _current + _new_velocity * _dt;
	
	return [_new_value, _new_velocity];
}

function gmmt_spring(_id, _from, _to, _tension = 0.5, _friction = 0.3, _mass = 1.0, _precision = 0.001) {
	gmmt_init_check_safe();
	
	var _existing = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_existing != undefined && _existing.state == gmmt_tween_state.PLAYING && _existing.spring_data != undefined) {
		_existing.spring_data.target = _to;
		return gmmt_get_value(_id);
	}
	
	return gmmt_spring_start(_id, _from, _to, _tension, _friction, _mass, _precision);
}

function gmmt_spring_start(_id, _from, _to, _tension = 0.5, _friction = 0.3, _mass = 1.0, _precision = 0.001) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _tween = gmmt_create(_id, _from, _to, 999999999);
	_tween.value_type = gmmt_value_type.REAL;
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	
	_tween.spring_data = {
		tension: _tension,
		friction: _friction,
		mass: _mass,
		precision: _precision,
		velocity: 0,
		target: _to,
	};
	
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _sd = self.spring_data;
		var _dt = delta_time / 1000000;
		var _result = gmmt_spring_update(self.current_value, _sd.target, _sd.velocity, _sd.tension, _sd.friction, _sd.mass, _dt);
		
		var _new_val = _result[0];
		var _new_vel = _result[1];
		
		_sd.velocity = _new_vel;
		
		if (abs(_new_vel) < 0.01 && abs(_new_val - _sd.target) < 0.01) {
			_sd.velocity = 0;
			gmmt_complete_tween(self);
			return _sd.target;
		}
		
		return _new_val;
	});
	
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

// perlin noise
function _gmmt_hash(_n, _s) {
	_n = (_n + _s) * 374761393 + 668265263;
	_n = ((_n >> 16) ^ _n) * 1274126177;
	return ((_n >> 16) ^ _n) % 1000 / 1000;
}

function gmmt_perlin_noise(_x, _seed = 0) {
	var _xi = floor(_x);
	var _xf = _x - _xi;
	
	var _hash = _gmmt_hash;
	
	var _g0 = _hash(_xi, _seed) * 2 - 1;
	var _g1 = _hash(_xi + 1, _seed) * 2 - 1;
	
	var _u = _xf * _xf * (3 - 2 * _xf);
	
	return lerp(_g0 * _xf, _g1 * (_xf - 1), _u);
}

function gmmt_perlin_wiggle(_id, _center, _amplitude = 0.5, _speed = 1, _seed = 0, _duration = -1) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state == gmmt_tween_state.PLAYING && _exists.perlin_data != undefined) {
		_exists.perlin_data.amplitude = _amplitude;
		_exists.perlin_data.speed = _speed;
		return gmmt_get_value(_id);
	}
	
	gmmt_perlin_wiggle_start(_id, _center, _amplitude, _speed, _seed, _duration);
	return gmmt_get_value(_id);
}

function gmmt_perlin_wiggle_start(_id, _center, _amplitude = 0.5, _speed = 1, _seed = 0, _duration = -1) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _tween = gmmt_create(_id, _center, _center, _duration < 0 ? 999999999 : _duration);
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	
	_tween.perlin_data = {
		center: _center,
		amplitude: _amplitude,
		speed: _speed,
		seed: _seed,
		time_offset: 0,
	};
	
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _pd = self.perlin_data;
		_pd.time_offset += (delta_time / 1000000) * _pd.speed;
		var _noise = gmmt_perlin_noise(_pd.time_offset, _pd.seed);
		return _pd.center + _noise * _pd.amplitude;
	});
	
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

// rotation & transform helpers
function gmmt_lerp_angle(_from, _to, _t) {
	var _diff = _to - _from;
	return _from + _diff * _t;
}

function gmmt_tween_angle(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) {
		return gmmt_get_value(_id);
	}
	
	return gmmt_tween_angle_start(_id, _from, _to, _duration, _easing);
}

function gmmt_tween_angle_start(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _tween = gmmt_create(_id, _from, _to, _duration);
	_tween.value_type = gmmt_value_type.CUSTOM;
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	_tween.user_data = { from: _from, to: _to };
	
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _ud = self.user_data;
		return gmmt_lerp_angle(_ud.from, _ud.to, _t);
	});
	
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_scale(_id, _from_x, _from_y, _to_x, _to_y, _duration = -1, _easing = undefined) {
	return gmmt_tween_vector2(_id, [_from_x, _from_y], [_to_x, _to_y], _duration, _easing);
}

function gmmt_tween_position(_id, _from_x, _from_y, _to_x, _to_y, _duration = -1, _easing = undefined) {
	return gmmt_tween_vector2(_id, [_from_x, _from_y], [_to_x, _to_y], _duration, _easing);
}

// clip system
function gmmt_clip_begin(_name) {
	gmmt_init_check_safe();
	var _anim = gmmt_get();
	
	var _clip = {
		name: _name,
		keyframes: [ ],
		total_duration: 0,
		loop: false,
		loop_direction: gmmt_repeat_mode.NONE,
		on_complete: undefined,
		on_marker: undefined,
		next_clip: undefined, // for chaining
	    stagger_count: 0,
	    stagger_delay: 0,
	    stagger_initial: 0,
	};
	
	return _clip;
}

function gmmt_clip_key_float(_clip, _time, _value, _easing = undefined) {
	array_push(_clip.keyframes, {
		time: _time,
		value: _value,
		type: gmmt_value_type.REAL,
		easing: _easing
	});
	if (_time > _clip.total_duration) {
		_clip.total_duration = _time;
	}
	return _clip;
}

function gmmt_clip_key_vector2(_clip, _time, _value, _easing = undefined) {
	array_push(_clip.keyframes, {
		time: _time,
		value: _value,
		type: gmmt_value_type.VECTOR2,
		easing: _easing
	});
	if (_time > _clip.total_duration) {
		_clip.total_duration = _time;
	}
	return _clip;
}

function gmmt_clip_key_color3(_clip, _time, _value, _easing = undefined) {
	array_push(_clip.keyframes, {
		time: _time,
		value: _value,
		type: gmmt_value_type.COLOR3,
		easing: _easing
	});
	if (_time > _clip.total_duration) {
		_clip.total_duration = _time;
	}
	return _clip;
}

function gmmt_clip_key_color4(_clip, _time, _value, _easing = undefined) {
	array_push(_clip.keyframes, {
		time: _time,
		value: _value,
		type: gmmt_value_type.COLOR4,
		easing: _easing
	});
	if (_time > _clip.total_duration) {
		_clip.total_duration = _time;
	}
	return _clip;
}

function gmmt_clip_set_loop(_clip, _loop, _direction = undefined) {
	_clip.loop = _loop;
	_clip.loop_direction = (_direction != undefined) ? _direction : gmmt_repeat_mode.LOOP;
	return _clip;
}

function gmmt_clip_on_complete(_clip, _callback) {
	_clip.on_complete = _callback;
	return _clip;
}

function gmmt_clip_on_marker(_clip, _callback) {
	_clip.on_marker = _callback;
	return _clip;
}

function gmmt_clip_chain(_clip, _next_clip_name) {
	_clip.next_clip = _next_clip_name;
	return _clip;
}

function gmmt_clip_set_stagger(_clip, _count, _delay_per_item, _initial_delay = 0) {
	_clip.stagger_count = _count;
	_clip.stagger_delay = _delay_per_item;
	_clip.stagger_initial = _initial_delay;
	return _clip;
}

function gmmt_clip_end(_clip) {
	var _anim = gmmt_get();
	
	if (array_length(_clip.keyframes) < 2) {
		//show_debug_message("ERROR: Clip '" + _clip.name + "' needs at least 2 keyframes");
		return;
	}
	
	array_sort(_clip.keyframes, function(a, b) { return a.time - b.time; });
	
	ds_map_add(_anim.clips, _clip.name, _clip);
	
	//show_debug_message("Clip '" + _clip.name + "' defined with " + string(array_length(_clip.keyframes)) + " keyframes, duration: " + string(_clip.total_duration) + "us");
}

// clip playback
function gmmt_clip_play(_clip_name, _target_id) {
	gmmt_init_check_safe();
	
	var _anim = gmmt_get();
	var _clip = ds_map_find_value(_anim.clips, _clip_name);
	
	if (_clip == undefined) {
		//show_debug_message("ERROR: Clip '" + _clip_name + "' not found");
		return undefined;
	}
	
	if (_clip.stagger_count != undefined && _clip.stagger_count > 1) {
		var _tweens = [];
		for (var s = 0; s < _clip.stagger_count; s++) {
			var _sid = _target_id + "_" + string(s);
			var _kfs = [];
			for (var i = 0; i < array_length(_clip.keyframes); i++) {
				var _kf = _clip.keyframes[i];
				array_push(_kfs, {
					time: _kf.time,
					value: _kf.value,
					easing: _kf.easing
				});
			}
			var _tween = gmmt_timeline_start(_sid, _kfs, false);
			var _total_delay = _clip.stagger_initial + s * _clip.stagger_delay;
			_tween.delay = _total_delay;
			_tween.elapsed = -_total_delay;
			
			_tween.clip_data = {
				clip_name: _clip_name,
				loop: _clip.loop,
				loop_direction: _clip.loop_direction,
				next_clip: _clip.next_clip,
				user_on_complete: _clip.on_complete,
				user_on_marker: _clip.on_marker,
				markers_triggered: [],
				original_on_complete: _tween.on_complete,
				original_on_update: _tween.on_update,
				stagger_index: s,
				stagger_total: _clip.stagger_count,
			};
			
			if (_clip.loop) {
				if (_clip.loop_direction == gmmt_repeat_mode.PING_PONG) {
					gmmt_set_pingpong(_sid, -1);
				} else {
					gmmt_set_repeat(_sid, -1);
				}
			}
			
			_tween.on_complete = method(_tween, function(_t) {
				var _cd = self.clip_data;
				if (_cd.user_on_complete != undefined) {
					_cd.user_on_complete(self.id);
				}
				if (_cd.next_clip != undefined && _cd.stagger_index == _cd.stagger_total - 1) {
					gmmt_clip_play(_cd.next_clip, string_replace(self.id, "_" + string(_cd.stagger_index), ""));
				}
				if (_cd.original_on_complete != undefined) {
					_cd.original_on_complete(_t);
				}
			});
			
			_tween.on_update = method(_tween, function(_t) {
				var _cd = self.clip_data;
				if (_cd.user_on_marker != undefined) {
					var _clip_ref = ds_map_find_value(gmmt_get().clips, _cd.clip_name);
					if (_clip_ref != undefined) {
						for (var i = 0; i < array_length(_clip_ref.keyframes); i++) {
							var _kf_time = _clip_ref.keyframes[i].time;
							var _already = false;
							for (var j = 0; j < array_length(_cd.markers_triggered); j++) {
								if (_cd.markers_triggered[j] == _kf_time) { _already = true; break; }
							}
							if (!_already && self.elapsed >= _kf_time) {
								array_push(_cd.markers_triggered, _kf_time);
								_cd.user_on_marker(self.id, _kf_time);
							}
						}
					}
				}
				if (_cd.original_on_update != undefined) {
					_cd.original_on_update(_t);
				}
			});
			
			array_push(_tweens, _tween);
		}
		return _tweens;
	}
	
	var _kfs = [];
	var _count = array_length(_clip.keyframes);
	for (var i = 0; i < _count; i++) {
		var _kf = _clip.keyframes[i];
		array_push(_kfs, {
			time: _kf.time,
			value: _kf.value,
			easing: _kf.easing
		});
	}
	
	var _tween = gmmt_timeline_start(_target_id, _kfs, false);
	
	_tween.clip_data = {
		clip_name: _clip_name,
		loop: _clip.loop,
		loop_direction: _clip.loop_direction,
		next_clip: _clip.next_clip,
		user_on_complete: _clip.on_complete,
		user_on_marker: _clip.on_marker,
		markers_triggered: [],
		original_on_complete: _tween.on_complete,
		original_on_update: _tween.on_update,
		stagger_index: 0,
		stagger_total: 1,
	};
	
	if (_clip.loop) {
		if (_clip.loop_direction == gmmt_repeat_mode.PING_PONG) {
			gmmt_set_pingpong(_target_id, -1);
		} else {
			gmmt_set_repeat(_target_id, -1);
		}
	}
	
	_tween.on_complete = method(_tween, function(_t) {
		var _cd = self.clip_data;
		if (_cd.user_on_complete != undefined) {
			_cd.user_on_complete(self.id);
		}
		if (_cd.next_clip != undefined) {
			gmmt_clip_play(_cd.next_clip, self.id);
		}
		if (_cd.original_on_complete != undefined) {
			_cd.original_on_complete(_t);
		}
	});
	
	_tween.on_update = method(_tween, function(_t) {
		var _cd = self.clip_data;
		if (_cd.user_on_marker != undefined) {
			var _clip_ref = ds_map_find_value(gmmt_get().clips, _cd.clip_name);
			if (_clip_ref != undefined) {
				for (var i = 0; i < array_length(_clip_ref.keyframes); i++) {
					var _kf_time = _clip_ref.keyframes[i].time;
					var _already = false;
					for (var j = 0; j < array_length(_cd.markers_triggered); j++) {
						if (_cd.markers_triggered[j] == _kf_time) { _already = true; break; }
					}
					if (!_already && self.elapsed >= _kf_time) {
						array_push(_cd.markers_triggered, _kf_time);
						_cd.user_on_marker(self.id, _kf_time);
					}
				}
			}
		}
		if (_cd.original_on_update != undefined) {
			_cd.original_on_update(_t);
		}
	});
	
	return _tween;
}

function gmmt_clip_stop(_target_id) {
	gmmt_stop(_target_id, false);
}

function gmmt_clip_is_playing(_target_id) {
	return gmmt_is_playing(_target_id);
}

function gmmt_clip_get_float(_target_id) {
	return gmmt_get_value(_target_id) ?? 0;
}

function gmmt_clip_get_vector2(_target_id) {
	return gmmt_get_value(_target_id) ?? [0, 0];
}

function gmmt_clip_get_color3(_target_id) {
	return gmmt_get_value(_target_id) ?? c_black;
}

function gmmt_clip_get_color4(_target_id) {
	return gmmt_get_value(_target_id) ?? gmmt_make_color_rgba(0, 0, 0, 255);
}

// motion path
function gmmt_path_begin(_name, _start) {
	gmmt_init_check_safe();
	
	var _path = {
		name: _name,
		points: [_start],
		segments: [], // { type: "quadratic"/"cubic", points: [...] }
	};
	
	return _path;
}

function gmmt_path_quadratic_to(_path, _control, _end) {
	array_push(_path.segments, {
		type: "quadratic",
		control: _control,
		end_point: _end
	});
	var _last = _path.points[array_length(_path.points) - 1];
	array_push(_path.points, _end);
	return _path;
}

function gmmt_path_cubic_to(_path, _control1, _control2, _end) {
	array_push(_path.segments, {
		type: "cubic",
		control1: _control1,
		control2: _control2,
		end_point: _end
	});
	var _last = _path.points[array_length(_path.points) - 1];
	array_push(_path.points, _end);
	return _path;
}

function gmmt_path_end(_path) {
	var _anim = gmmt_get();
	ds_map_add(_anim.paths, _path.name, _path);
	//show_debug_message("Path '" + _path.name + "' defined with " + string(array_length(_path.segments)) + " segments");
}

function gmmt_path_evaluate(_path, _t) {
	_t = clamp(_t, 0, 1);
	var _seg_count = array_length(_path.segments);
	if (_seg_count == 0) return _path.points[0];
	
	var _seg_t = _t * _seg_count;
	var _seg_idx = floor(_seg_t);
	if (_seg_idx >= _seg_count) _seg_idx = _seg_count - 1;
	var _local_t = _seg_t - _seg_idx;
	
	var _seg = _path.segments[_seg_idx];
	var _start = _path.points[_seg_idx];
	var _end_pt = _seg.end_point;
	
	if (_seg.type == "quadratic") {
		return [
			gmmt_bezier_quadratic(_start[0], _seg.control[0], _end_pt[0], _local_t),
			gmmt_bezier_quadratic(_start[1], _seg.control[1], _end_pt[1], _local_t)
		];
	} else {
		return gmmt_bezier_cubic_2d(_start, _seg.control1, _seg.control2, _end_pt, _local_t);
	}
}

function gmmt_tween_path(_id, _path_name, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	
	gmmt_tween_path_start(_id, _path_name, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_path_start(_id, _path_name, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _anim = gmmt_get();
	var _path = ds_map_find_value(_anim.paths, _path_name);
	
	if (_path == undefined) {
		//show_debug_message("ERROR: Path '" + _path_name + "' not found");
		return undefined;
	}
	
	var _start = _path.points[0];
	var _end = _path.points[array_length(_path.points) - 1];
	
	var _tween = gmmt_create(_id, _start, _end, _duration);
	_tween.value_type = gmmt_value_type.VECTOR2;
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	_tween.user_data = { path_name: _path_name };
	
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _path_ref = ds_map_find_value(gmmt_get().paths, self.user_data.path_name);
		return gmmt_path_evaluate(_path_ref, _t);
	});
	
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

// utility stuff
function gmmt_lerp(_a, _b, _t) { return _a + (_b - _a) * clamp(_t, 0, 1); }

function gmmt_remap(_value, _from_start, _from_end, _to_start, _to_end) {
	return gmmt_lerp(_to_start, _to_end, (_value - _from_start) / (_from_end - _from_start));
}

function gmmt_get_active_count() {
	var _anim = gmmt_get();
	return (_anim != undefined) ? _anim.active_tweens : 0;
}

function gmmt_get_total_count() {
	var _anim = gmmt_get();
	return (_anim != undefined) ? _anim.total_tweens_created : 0;
}

// cleanup
function gmmt_cleanup() {
	var _anim = gmmt_get();
	if (_anim == undefined) { return; }
	
	 var _path_keys = ds_map_keys_to_array(_anim.paths);
	 for (var p = 0; p < array_length(_path_keys); p++) { ds_map_delete(_anim.paths, _path_keys[p]); };
	 ds_map_destroy(_anim.paths);
	
	var _clip_keys = ds_map_keys_to_array(_anim.clips);
	for (var c = 0; c < array_length(_clip_keys); c++) {
	    ds_map_delete(_anim.clips, _clip_keys[c]);
	}
	ds_map_destroy(_anim.clips);
	
	var _group_keys = ds_map_keys_to_array(_anim.groups);
	for (var g = 0; g < array_length(_group_keys); g++) {
		var _key = _group_keys[g];
		var _group_list = _anim.groups[? _key];
		if (_group_list != undefined) {
			_group_list = undefined;
		}
		ds_map_delete(_anim.groups, _key);
	}
	ds_map_destroy(_anim.groups);
	
	ds_map_destroy(_anim.tweens_map);
	
	var _timeline_keys = ds_map_keys_to_array(_anim.timelines);
	for (var t = 0; t < array_length(_timeline_keys); t++) {
		ds_map_delete(_anim.timelines, _timeline_keys[t]);
	}
	ds_map_destroy(_anim.timelines);
	
	_anim.tweens = [ ];
	
	_anim.active_tweens = 0;
	_anim.total_tweens_created = 0;
	_anim.global_time_scale = 1.0;
	_anim.groups = undefined;
	_anim.tweens_map = undefined;
	_anim.timelines = undefined;
}

// type specific creation
function gmmt_tween_color3_start(_id, _from_color, _to_color, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from_color, _to_color, _duration);
	_tween.value_type = gmmt_value_type.COLOR3;
	_tween.value_lerp = method({}, gmmt_lerp_color3);
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_color3(_id, _from_color, _to_color, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_color3_start(_id, _from_color, _to_color, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_color4_start(_id, _from_color, _to_color, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from_color, _to_color, _duration);
	_tween.value_type = gmmt_value_type.COLOR4;
	_tween.value_lerp = method({}, gmmt_lerp_color4);
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_color4(_id, _from_color, _to_color, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_color4_start(_id, _from_color, _to_color, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_vector2_start(_id, _from_vec2, _to_vec2, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from_vec2, _to_vec2, _duration);
	_tween.value_type = gmmt_value_type.VECTOR2;
	_tween.value_lerp = gmmt_get_lerp_function(gmmt_value_type.VECTOR2);
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_vector2(_id, _from_vec2, _to_vec2, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_vector2_start(_id, _from_vec2, _to_vec2, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_vector3_start(_id, _from_vec3, _to_vec3, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from_vec3, _to_vec3, _duration);
	_tween.value_type = gmmt_value_type.VECTOR3;
	_tween.value_lerp = gmmt_get_lerp_function(gmmt_value_type.VECTOR3);
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_vector3(_id, _from_vec3, _to_vec3, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_vector3_start(_id, _from_vec3, _to_vec3, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_vector4_start(_id, _from_vec4, _to_vec4, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from_vec4, _to_vec4, _duration);
	_tween.value_type = gmmt_value_type.VECTOR4;
	_tween.value_lerp = gmmt_get_lerp_function(gmmt_value_type.VECTOR4);
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_vector4(_id, _from_vec4, _to_vec4, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_vector4_start(_id, _from_vec4, _to_vec4, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_array_start(_id, _from_array, _to_array, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from_array, _to_array, _duration);
	_tween.value_type = gmmt_value_type.ARRAY;
	_tween.value_lerp = gmmt_get_lerp_function(gmmt_value_type.ARRAY);
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_array(_id, _from_array, _to_array, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_array_start(_id, _from_array, _to_array, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_int(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	gmmt_tween_int_start(_id, _from, _to, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_int_start(_id, _from, _to, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	var _tween = gmmt_create(_id, _from, _to, _duration);
	_tween.value_type = gmmt_value_type.INT;
	_tween.snap_to_integer = true;
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

// bezier paths
function gmmt_bezier_cubic(_p0, _p1, _p2, _p3, _t) {
	var _u = 1 - _t;
	var _tt = _t * _t;
	var _uu = _u * _u;
	return _uu * _u * _p0 + 3 * _uu * _t * _p1 + 3 * _u * _tt * _p2 + _tt * _t * _p3;
}

function gmmt_bezier_quadratic(_p0, _p1, _p2, _t) {
	var _u = 1 - _t;
	return _u * _u * _p0 + 2 * _u * _t * _p1 + _t * _t * _p2;
}

function gmmt_bezier_cubic_2d(_p0, _p1, _p2, _p3, _t) {
	return [
		gmmt_bezier_cubic(_p0[0], _p1[0], _p2[0], _p3[0], _t),
		gmmt_bezier_cubic(_p0[1], _p1[1], _p2[1], _p3[1], _t)
	];
}

function gmmt_catmull_rom(_points, _t, _loop = false) {
	var _count = array_length(_points);
	if (_count < 2) return _points[0];
	
	if (_loop) {
		_t = frac(_t);
	} else {
		_t = clamp(_t, 0, 1);
	}
	
	var _segments = _loop ? _count : _count - 1;
	var _scaled_t = _t * _segments;
	var _idx = floor(_scaled_t);
	var _local_t = _scaled_t - _idx;
	
	var _p0, _p1, _p2, _p3;
	
	if (_loop) {
		_p0 = _points[(_idx - 1 + _count) % _count];
		_p1 = _points[_idx % _count];
		_p2 = _points[(_idx + 1) % _count];
		_p3 = _points[(_idx + 2) % _count];
	} else {
		_idx = clamp(_idx, 0, _count - 2);
		_p0 = (_idx > 0) ? _points[_idx - 1] : _points[0];
		_p1 = _points[_idx];
		_p2 = _points[_idx + 1];
		_p3 = (_idx < _count - 2) ? _points[_idx + 2] : _points[_count - 1];
	}
	
	// catmull-rom formula
	var _tt = _local_t * _local_t;
	var _ttt = _tt * _local_t;
	
	if (is_array(_p0)) {
		var _result = [0, 0];
		for (var i = 0; i < 2; i++) {
			_result[i] = 0.5 * ((2 * _p1[i]) + 
			                     (-_p0[i] + _p2[i]) * _local_t + 
			                     (2 * _p0[i] - 5 * _p1[i] + 4 * _p2[i] - _p3[i]) * _tt + 
			                     (-_p0[i] + 3 * _p1[i] - 3 * _p2[i] + _p3[i]) * _ttt);
		}
		return _result;
	} else {
		return 0.5 * ((2 * _p1) + 
		              (-_p0 + _p2) * _local_t + 
		              (2 * _p0 - 5 * _p1 + 4 * _p2 - _p3) * _tt + 
		              (-_p0 + 3 * _p1 - 3 * _p2 + _p3) * _ttt);
	}
}

function gmmt_tween_bezier(_id, _p0, _p1, _p2, _p3, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	
	gmmt_tween_bezier_start(_id, _p0, _p1, _p2, _p3, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_bezier_start(_id, _p0, _p1, _p2, _p3, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _tween = gmmt_create(_id, _p0, _p3, _duration);
	_tween.value_type = gmmt_value_type.CUSTOM;
	_tween.user_data = { p0: _p0, p1: _p1, p2: _p2, p3: _p3 };
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _ud = self.user_data;
		return gmmt_bezier_cubic(_ud.p0, _ud.p1, _ud.p2, _ud.p3, _t);
	});
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_bezier_2d(_id, _p0, _p1, _p2, _p3, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	
	gmmt_tween_bezier_2d_start(_id, _p0, _p1, _p2, _p3, _duration, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_bezier_2d_start(_id, _p0, _p1, _p2, _p3, _duration = -1, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _tween = gmmt_create(_id, _p0, _p3, _duration);
	_tween.value_type = gmmt_value_type.VECTOR2;
	_tween.user_data = { p0: _p0, p1: _p1, p2: _p2, p3: _p3 };
	_tween.value_lerp = method(_tween, function(_start, _end, _t) {
		var _ud = self.user_data;
		return gmmt_bezier_cubic_2d(_ud.p0, _ud.p1, _ud.p2, _ud.p3, _t);
	});
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}

function gmmt_tween_spline(_id, _points, _duration = -1, _loop = false, _easing = undefined) {
	gmmt_init_check_safe();
	
	var _exists = ds_map_find_value(gmmt_get().tweens_map, _id);
	if (_exists != undefined && _exists.state != gmmt_tween_state.KILLED) { return gmmt_get_value(_id); }
	
	gmmt_tween_spline_start(_id, _points, _duration, _loop, _easing);
	return gmmt_get_value(_id);
}

function gmmt_tween_spline_start(_id, _points, _duration = -1, _loop = false, _easing = undefined) {
	gmmt_init_check_safe();
	gmmt_remove_existing_tween(_id);
	
	var _start = _points[0];
	var _end = _loop ? _points[0] : _points[array_length(_points) - 1];
	
	var _tween = gmmt_create(_id, _start, _end, _duration);
	_tween.value_type = is_array(_start) ? gmmt_value_type.VECTOR2 : gmmt_value_type.REAL;
	_tween.user_data = { points: _points, loop: _loop };
	_tween.value_lerp = method(_tween, function(_s, _e, _t) {
		var _ud = self.user_data;
		return gmmt_catmull_rom(_ud.points, _t, _ud.loop);
	});
	_tween.flags &= ~gmmt_tween_flags.CLAMP_VALUES;
	if (_easing != undefined) gmmt_set_easing(_id, _easing);
	_tween.state = gmmt_tween_state.PLAYING;
	gmmt_get().active_tweens++;
	return _tween;
}