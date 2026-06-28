function gmmt_demo() {
	gmui_style_push("progress_bar_height", 8);
	if (gmui_begin("GMMT Showcase", 100, 100, 1280, 720)) {
        var easing_names = [
            "LINEAR", 
			"I_QUAD",		"O_QUAD",		"IO_QUAD",
            "I_CUBIC",		"O_CUBIC",		"IO_CUBIC",
            "I_QUART",		"O_QUART",		"IO_QUART",
            "I_QUINT",		"O_QUINT",		"IO_QUINT",
            "I_SINE",		"O_SINE",		"IO_SINE",
            "I_EXPO",		"O_EXPO",		"IO_EXPO",
            "I_CIRC",		"O_CIRC",		"IO_CIRC",
            "I_ELASTIC",	"O_ELASTIC",	"IO_ELASTIC",
            "I_BACK",		"O_BACK",		"IO_BACK",
            "I_BOUNCE",		"O_BOUNCE",		"IO_BOUNCE"
        ];
		
		if (gmui_begin_flex(gmui_split_dir.HORIZONTAL, [ 1, 0.8 ])) {
			if (gmui_begin_flex(gmui_split_dir.VERTICAL, [ 1.8, 0.83, 1 ])) {
				if (gmui_begin_flex_child()) { // easing
					gmui_text_disabled("EASING SHOWCASE");
					gmui_separator();
					static selected_ease = 0;
					if (gmui_begin_child("easing buttons", undefined, 210)) {
						gmui_get_current_container().context.flow = true;
						for (var i = 0; i < array_length(easing_names); i++) {
							if (gmui_button_ghost(easing_names[i])) {
								selected_ease = i;
								gmmt_tween_start("easing showcase tween", 0, 1, 2_000_000, selected_ease);
							};
						};
						gmui_end_child();
					}
					var value = gmmt_get_value("easing showcase tween") ?? 0;
					var progress = gmmt_get_progress("easing showcase tween") ?? 0;
					gmui_text_label(easing_names[selected_ease], string(floor(progress * 100)) + string("%"));
					gmui_progress(progress, 1, undefined, false);
					if (gmui_begin_child("easing graph", undefined, 80)) {
					    var steps = 64;
					    var container = gmui_get_current_container();
					    var padding = 4;
					    var graph_width = container.width - padding * 2;
					    var graph_height = container.height - padding * 2;
    
					    var min_val = 0;
					    var max_val = 1;
					    for (var i = 0; i <= steps; i++) {
					        var t = i / steps;
					        var val = gmmt_get_eased_value({ 
					            easing: selected_ease, 
					            easing_intensity: 1, 
					            easing_power: 1, 
					            easing_custom: undefined 
					        }, t);
					        min_val = min(min_val, val);
					        max_val = max(max_val, val);
					    }
    
					    for (var i = 0; i < steps; i++) {
					        var t1 = i / steps;
					        var t2 = (i + 1) / steps;
        
					        var eased1 = gmmt_get_eased_value({ 
					            easing: selected_ease, 
					            easing_intensity: 1, 
					            easing_power: 1, 
					            easing_custom: undefined 
					        }, t1);
					        var eased2 = gmmt_get_eased_value({ 
					            easing: selected_ease, 
					            easing_intensity: 1, 
					            easing_power: 1, 
					            easing_custom: undefined 
					        }, t2);
        
					        var normalized1 = (eased1 - min_val) / (max_val - min_val);
					        var normalized2 = (eased2 - min_val) / (max_val - min_val);
        
					        var lx1 = padding + t1 * graph_width;
					        var ly1 = padding + (1 - normalized1) * graph_height;
					        var lx2 = padding + t2 * graph_width;
					        var ly2 = padding + (1 - normalized2) * graph_height;
        
					        gmui_add_line_width(lx1, ly1, lx2, ly2, 2, make_color_rgb(75, 135, 210), 1);
					    }
					    
					    if (value != 0) {
					        var normalized_progress = (value - min_val) / (max_val - min_val);
					        var circle_x = padding + gmmt_get_progress("easing showcase tween") * graph_width;
					        var circle_y = padding + (1 - normalized_progress) * graph_height;
					        gmui_add_circle(circle_x, circle_y, 4, false, c_orange, 1);
					    }
					    gmui_end_child();
					}
					gmui_end_flex_child();
				}
				if (gmui_begin_flex_child()) { // control
					gmui_text_disabled("CONTROL");
					gmui_separator();
					
					static control_value = 0;
					if (gmui_button_small("PLAY")) {
						gmmt_tween_start("control tween", 0, 1, 1_000_000);
					}
					gmui_sameline();
					if (gmui_button_small("PAUSE")) {
						gmmt_pause("control tween");
					}
					gmui_sameline();
					if (gmui_button_small("STOP")) {
						gmmt_stop("control tween");
					}
					if (gmui_button_small("RESUME")) {
						gmmt_resume("control tween");
					}
					gmui_sameline();
					if (gmui_button_small("REVERSE")) {
						gmmt_reverse("control tween");
					}
					
					control_value = gmui_slider(control_value, 0, 1, 100);
					gmui_sameline();
					if (gmui_button_small("SEEK")) {
						gmmt_seek("control tween", control_value);
					}
					
					static time_scale = 1.0;
					time_scale = gmui_slider(time_scale, 0.1, 3, 100);
					gmmt_set_time_scale("control tween", time_scale);
					gmui_sameline();
					gmui_text("Time Scale");
					
					gmui_progress(gmmt_get_value("control tween") ?? 0, 1);
					
					gmui_separator_text_left("Group");
					if (gmui_button_success("Spawn 5")) {
						for (var i = 0; i < 5; i++) {
							var _id = "group tween id " + string(i);
							gmmt_tween(_id, 0, 1, 2_000_000);
							gmmt_set_group(_id, "tween group")
						};
					}
					gmui_sameline();
					if (gmui_button_danger("Kill Grp")) {
						gmmt_kill_group("tween group");
					}
					
					if (gmmt_exists("group tween id 0")) {
						gmui_progress(gmmt_get_value("group tween id 0"), 1, undefined, false);
						gmui_progress(gmmt_get_value("group tween id 1"), 1, undefined, false);
						gmui_progress(gmmt_get_value("group tween id 2"), 1, undefined, false);
						gmui_progress(gmmt_get_value("group tween id 3"), 1, undefined, false);
						gmui_progress(gmmt_get_value("group tween id 4"), 1, undefined, false);
					}
					
					gmui_end_flex_child();
				}
				if (gmui_begin_flex_child()) { // spring physics
					gmui_text_disabled("SPRING PHYSICS - CLICK TO SET TARGET");
					gmui_separator();
					
					static sp_tension = 0.8;
					static sp_friction = 0.25;
					static tx = 0;
					static ty = 0;
					static bx = 0;
					static by = 0;
					static _bx = 0;
					static _by = 0;
					
					bx = gmmt_get_value("spring tween x") ?? _bx;
					by = gmmt_get_value("spring tween y") ?? _by;
					_bx = bx;
					_by = by;
					
					sp_tension = gmui_slider(sp_tension, 0.05, 2.5, 100);
					gmui_sameline();
					gmui_text("Tension");
					
					sp_friction = gmui_slider(sp_friction, 0.05, 2.5, 100);
					gmui_sameline();
					gmui_text("Friction");
					
					if (gmui_button("Set")) {
						gmmt_stop("spring tween x");
						gmmt_stop("spring tween y");
					}
					
					if (gmui_begin_child("spring playground")) {
						var width = gmui_get_current_container().width;
						var height = gmui_get_current_container().height;
					
						static trail = array_create(8, array_create(2, 0));
						array_push(trail, [ bx, by ]);
						while (array_length(trail) > 8) { array_delete(trail, 0, 1); };
						for (var i = 1; i < array_length(trail); i++) {
							var a = 1 / array_length(trail);
							gmui_add_line_width(trail[i-1][0], trail[i-1][1], trail[i][0], trail[i][1], 2, make_color_rgb(50, 100, 210), a * 0.55);
						};
						gmui_add_circle(tx, ty, 5, true, make_color_rgb(220, 80, 60));
						gmui_add_line(tx - 10, ty, tx + 10, ty, make_color_rgb(220, 80, 60), 0.8);
						gmui_add_line(tx, ty - 10, tx, ty + 10, make_color_rgb(220, 80, 60), 0.8);
						
						gmui_add_circle(_bx, _by, 11, false, make_color_rgb(75, 175, 255));
						gmui_add_circle(_bx - 3, _by - 3, 3, false, make_color_rgb(190, 225, 255));
						
						if (gmui_get().input.hovered_container == gmui_get_current_container() && gmui_input_mouse_pressed()) {
							var offset = gmui_get_container_screen_offset(gmui_get_current_container());
							var cx = offset[0];
							var cy = offset[1];
							var mx = gmui_input_mouse_x();
							var my = gmui_input_mouse_y();
							var sx = mx - cx;
							var sy = my - cy;
						
							tx = sx;
							ty = sy;
						
							//gmmt_spring_start("spring tween x", gmmt_get_value("spring tween x") ?? bx, tx, sp_tension, sp_friction);
							//gmmt_spring_start("spring tween y", gmmt_get_value("spring tween y") ?? by, ty, sp_tension, sp_friction);
						}
						
						gmmt_spring("spring tween x", gmmt_get_value("spring tween x") ?? bx, tx, sp_tension, sp_friction);
						gmmt_spring("spring tween y", gmmt_get_value("spring tween y") ?? by, ty, sp_tension, sp_friction);
						
						gmui_end_child();
					}
					
					gmui_end_flex_child();
				}
				gmui_end_flex();
			}
			if (gmui_begin_flex(gmui_split_dir.VERTICAL, [ 1, 0.6 ])) {
				if (gmui_begin_flex_child()) { // motion paths
					gmui_text_disabled("MOTION PATHS - DRAG CONTROL POINTS");
					gmui_separator();
					
					static bezier_points = [
					    [0.0,  0.0 ],   // anchor
					    [0.1,  0.4 ],   // ctrl
					    [0.15, 0.6 ],   // ctrl
					    [0.25, 0.75],   // anchor
					    [0.4,  0.85],   // ctrl
					    [0.5,  0.5 ],   // ctrl
					    [0.5,  0.3 ],   // anchor
					    [0.6,  0.1 ],   // ctrl
					    [0.65, 0.85],   // ctrl
					    [0.75, 0.9 ],   // anchor
					    [0.85, 0.95],   // ctrl
					    [0.9,  1.0 ],   // ctrl
					    [1.0,  1.0 ],   // anchor
					];
					static path_progress = 0;
					static path_playing = false;
					static path_mode = 0; // 0 = bezier, 1 = spline

					static spline_anchors = [
					    [0.0,  0.0 ],
					    [0.25, 0.75],
					    [0.5,  0.3 ],
					    [0.75, 0.9 ],
					    [1.0,  1.0 ],
					];

					if (gmui_button_ghost("CUBIC BEZIER")) { path_mode = 0; }
					gmui_sameline();
					if (gmui_button_ghost("CATMULL-ROM SPLINE")) { path_mode = 1; }

					if (gmui_button("PLAY")) {
					    gmmt_tween_start("demo_path_showcase", 0, 1, 2_000_000, gmmt_ease.LINEAR);
					    path_playing = true;
					}
					gmui_sameline();
					if (gmui_button("STOP")) {
					    gmmt_stop("demo_path_showcase", false);
					    path_playing = false;
					}

					path_progress = gmmt_get_value("demo_path_showcase") ?? 0;

					if (gmui_begin_child("path viz")) {
					    var pv_container = gmui_get_current_container();
					    var pv_pad = 20;
					    var pv_w = pv_container.width - pv_pad * 2;
					    var pv_h = pv_container.height - pv_pad * 2;

					    var input  = gmui_get().input;
					    var offset = gmui_get_container_screen_offset(pv_container);
					    var mx     = input.m_x - offset[0];
					    var my     = input.m_y - offset[1];
					    var hit_r  = 8;
					    var cache  = gmui_get().cache;

					    if (!ds_map_exists(cache, "__bezier_drag")) { cache[? "__bezier_drag"] = -1; }
					    var dragging = cache[? "__bezier_drag"];

					    if (path_mode == 0) {
					        var n = array_length(bezier_points);
					        var n_segments = (n - 1) div 3;

					        var sx_arr = array_create(n);
					        var sy_arr = array_create(n);
					        for (var i = 0; i < n; i++) {
					            sx_arr[i] = pv_pad + bezier_points[i][0] * pv_w;
					            sy_arr[i] = pv_pad + (1 - bezier_points[i][1]) * pv_h;
					        }

					        if (input.m_pressed && input.hovered_container == pv_container) {
					            dragging = -1;
					            for (var i = 0; i < n; i++) {
					                if (point_distance(mx, my, sx_arr[i], sy_arr[i]) <= hit_r) {
					                    dragging = i;
					                    break;
					                }
					            }
					            cache[? "__bezier_drag"] = dragging;
					        }
					        if (!input.m_held) { cache[? "__bezier_drag"] = -1; dragging = -1; }

					        //if (input.m_held && dragging >= 0) {
					        //    var nx = clamp((mx - pv_pad) / pv_w, 0, 1);
					        //    var ny = clamp(1 - (my - pv_pad) / pv_h, 0, 1);
					        //    bezier_points[dragging][0] = nx;
					        //    bezier_points[dragging][1] = ny;
					        //    sx_arr[dragging] = pv_pad + nx * pv_w;
					        //    sy_arr[dragging] = pv_pad + (1 - ny) * pv_h;
					        //}
							
							if (input.m_held && dragging >= 0) {
					            var nx = clamp((mx - pv_pad) / pv_w, 0, 1);
					            var ny = clamp(1 - (my - pv_pad) / pv_h, 0, 1);

					            var old_x = bezier_points[dragging][0];
					            var old_y = bezier_points[dragging][1];
					            var dx = nx - old_x;
					            var dy = ny - old_y;

					            bezier_points[dragging][0] = nx;
					            bezier_points[dragging][1] = ny;
					            sx_arr[dragging] = pv_pad + nx * pv_w;
					            sy_arr[dragging] = pv_pad + (1 - ny) * pv_h;

					            var is_anchor = (dragging % 3 == 0);
					            if (is_anchor) {
					                if (dragging - 1 >= 0) {
					                    bezier_points[dragging - 1][0] = clamp(bezier_points[dragging - 1][0] + dx, 0, 1);
					                    bezier_points[dragging - 1][1] = clamp(bezier_points[dragging - 1][1] + dy, 0, 1);
					                    sx_arr[dragging - 1] = pv_pad + bezier_points[dragging - 1][0] * pv_w;
					                    sy_arr[dragging - 1] = pv_pad + (1 - bezier_points[dragging - 1][1]) * pv_h;
					                }
					                if (dragging + 1 < n) {
					                    bezier_points[dragging + 1][0] = clamp(bezier_points[dragging + 1][0] + dx, 0, 1);
					                    bezier_points[dragging + 1][1] = clamp(bezier_points[dragging + 1][1] + dy, 0, 1);
					                    sx_arr[dragging + 1] = pv_pad + bezier_points[dragging + 1][0] * pv_w;
					                    sy_arr[dragging + 1] = pv_pad + (1 - bezier_points[dragging + 1][1]) * pv_h;
					                }
					            }
					        }

					        for (var seg = 0; seg < n_segments; seg++) {
					            var i0 = seg * 3;
					            var p0x = sx_arr[i0],     p0y = sy_arr[i0];
					            var c1x = sx_arr[i0 + 1], c1y = sy_arr[i0 + 1];
					            var c2x = sx_arr[i0 + 2], c2y = sy_arr[i0 + 2];
					            var p3x = sx_arr[i0 + 3], p3y = sy_arr[i0 + 3];

					            gmui_add_line(p0x, p0y, c1x, c1y, make_color_rgb(100, 100, 100), 1);
					            gmui_add_line(c2x, c2y, p3x, p3y, make_color_rgb(100, 100, 100), 1);

					            var curve_steps = 32;
					            for (var i = 0; i < curve_steps; i++) {
					                var t1 = i / curve_steps;
					                var t2 = (i + 1) / curve_steps;
					                var bx1 = gmmt_lerp(gmmt_lerp(gmmt_lerp(p0x, c1x, t1), gmmt_lerp(c1x, c2x, t1), t1), gmmt_lerp(gmmt_lerp(c1x, c2x, t1), gmmt_lerp(c2x, p3x, t1), t1), t1);
					                var by1 = gmmt_lerp(gmmt_lerp(gmmt_lerp(p0y, c1y, t1), gmmt_lerp(c1y, c2y, t1), t1), gmmt_lerp(gmmt_lerp(c1y, c2y, t1), gmmt_lerp(c2y, p3y, t1), t1), t1);
					                var bx2 = gmmt_lerp(gmmt_lerp(gmmt_lerp(p0x, c1x, t2), gmmt_lerp(c1x, c2x, t2), t2), gmmt_lerp(gmmt_lerp(c1x, c2x, t2), gmmt_lerp(c2x, p3x, t2), t2), t2);
					                var by2 = gmmt_lerp(gmmt_lerp(gmmt_lerp(p0y, c1y, t2), gmmt_lerp(c1y, c2y, t2), t2), gmmt_lerp(gmmt_lerp(c1y, c2y, t2), gmmt_lerp(c2y, p3y, t2), t2), t2);
					                gmui_add_line_width(bx1, by1, bx2, by2, 2, make_color_rgb(75, 135, 210), 1);
					            }
					        }

					        if (path_progress > 0) {
					            var global_t = path_progress * n_segments;
					            var seg = min(floor(global_t), n_segments - 1);
					            var t   = global_t - seg;
					            var i0  = seg * 3;
					            var p0x = sx_arr[i0],     p0y = sy_arr[i0];
					            var c1x = sx_arr[i0 + 1], c1y = sy_arr[i0 + 1];
					            var c2x = sx_arr[i0 + 2], c2y = sy_arr[i0 + 2];
					            var p3x = sx_arr[i0 + 3], p3y = sy_arr[i0 + 3];
					            var ppx = gmmt_lerp(gmmt_lerp(gmmt_lerp(p0x, c1x, t), gmmt_lerp(c1x, c2x, t), t), gmmt_lerp(gmmt_lerp(c1x, c2x, t), gmmt_lerp(c2x, p3x, t), t), t);
					            var ppy = gmmt_lerp(gmmt_lerp(gmmt_lerp(p0y, c1y, t), gmmt_lerp(c1y, c2y, t), t), gmmt_lerp(gmmt_lerp(c1y, c2y, t), gmmt_lerp(c2y, p3y, t), t), t);
					            gmui_add_circle(ppx, ppy, 6, false, c_orange, 1);
					        }

					        for (var i = 0; i < n; i++) {
					            var is_anchor = (i mod 3 == 0);
					            var hov = (point_distance(mx, my, sx_arr[i], sy_arr[i]) <= hit_r) || dragging == i;
					            var base_col = is_anchor ? c_white : c_yellow;
					            gmui_add_circle(sx_arr[i], sy_arr[i], hov ? 7 : 5, false, hov ? c_orange : base_col, 1);
					        }

					    } else {
					        var n = array_length(spline_anchors);

					        var sx_arr = array_create(n);
					        var sy_arr = array_create(n);
					        for (var i = 0; i < n; i++) {
					            sx_arr[i] = pv_pad + spline_anchors[i][0] * pv_w;
					            sy_arr[i] = pv_pad + (1 - spline_anchors[i][1]) * pv_h;
					        }

					        if (input.m_pressed && input.hovered_container == pv_container) {
					            dragging = -1;
					            for (var i = 0; i < n; i++) {
					                if (point_distance(mx, my, sx_arr[i], sy_arr[i]) <= hit_r) {
					                    dragging = i;
					                    break;
					                }
					            }
					            cache[? "__bezier_drag"] = dragging;
					        }
					        if (!input.m_held) { cache[? "__bezier_drag"] = -1; dragging = -1; }

					        if (input.m_held && dragging >= 0) {
					            spline_anchors[dragging][0] = clamp((mx - pv_pad) / pv_w, 0, 1);
					            spline_anchors[dragging][1] = clamp(1 - (my - pv_pad) / pv_h, 0, 1);
					            sx_arr[dragging] = pv_pad + spline_anchors[dragging][0] * pv_w;
					            sy_arr[dragging] = pv_pad + (1 - spline_anchors[dragging][1]) * pv_h;
					        }

					        for (var i = 0; i < n - 1; i++) {
					            gmui_add_line(sx_arr[i], sy_arr[i], sx_arr[i+1], sy_arr[i+1], make_color_rgb(70, 70, 70), 1);
					        }

					        var curve_steps = 24;
					        var total_segments = n - 1;
					        for (var seg = 0; seg < total_segments; seg++) {
					            var p0x = sx_arr[max(seg - 1, 0)];
					            var p0y = sy_arr[max(seg - 1, 0)];
					            var p1x = sx_arr[seg];
					            var p1y = sy_arr[seg];
					            var p2x = sx_arr[seg + 1];
					            var p2y = sy_arr[seg + 1];
					            var p3x = sx_arr[min(seg + 2, n - 1)];
					            var p3y = sy_arr[min(seg + 2, n - 1)];

					            for (var i = 0; i < curve_steps; i++) {
					                var t1 = i / curve_steps;
					                var t2 = (i + 1) / curve_steps;

					                var t1sq = t1 * t1; var t1cu = t1sq * t1;
					                var t2sq = t2 * t2; var t2cu = t2sq * t2;

					                var lx1 = 0.5 * ((2*p1x) + (-p0x+p2x)*t1 + (2*p0x-5*p1x+4*p2x-p3x)*t1sq + (-p0x+3*p1x-3*p2x+p3x)*t1cu);
					                var ly1 = 0.5 * ((2*p1y) + (-p0y+p2y)*t1 + (2*p0y-5*p1y+4*p2y-p3y)*t1sq + (-p0y+3*p1y-3*p2y+p3y)*t1cu);
					                var lx2 = 0.5 * ((2*p1x) + (-p0x+p2x)*t2 + (2*p0x-5*p1x+4*p2x-p3x)*t2sq + (-p0x+3*p1x-3*p2x+p3x)*t2cu);
					                var ly2 = 0.5 * ((2*p1y) + (-p0y+p2y)*t2 + (2*p0y-5*p1y+4*p2y-p3y)*t2sq + (-p0y+3*p1y-3*p2y+p3y)*t2cu);

					                gmui_add_line_width(lx1, ly1, lx2, ly2, 2, make_color_rgb(75, 175, 100), 1);
					            }
					        }

					        if (path_progress > 0) {
					            var global_t = path_progress * total_segments;
					            var seg = min(floor(global_t), total_segments - 1);
					            var t   = global_t - seg;

					            var p0x = sx_arr[max(seg - 1, 0)];     var p0y = sy_arr[max(seg - 1, 0)];
					            var p1x = sx_arr[seg];                  var p1y = sy_arr[seg];
					            var p2x = sx_arr[seg + 1];              var p2y = sy_arr[seg + 1];
					            var p3x = sx_arr[min(seg + 2, n - 1)]; var p3y = sy_arr[min(seg + 2, n - 1)];

					            var tsq = t * t; var tcu = tsq * t;
					            var ppx = 0.5 * ((2*p1x) + (-p0x+p2x)*t + (2*p0x-5*p1x+4*p2x-p3x)*tsq + (-p0x+3*p1x-3*p2x+p3x)*tcu);
					            var ppy = 0.5 * ((2*p1y) + (-p0y+p2y)*t + (2*p0y-5*p1y+4*p2y-p3y)*tsq + (-p0y+3*p1y-3*p2y+p3y)*tcu);
					            gmui_add_circle(ppx, ppy, 6, false, c_orange, 1);
					        }

					        for (var i = 0; i < n; i++) {
					            var hov = (point_distance(mx, my, sx_arr[i], sy_arr[i]) <= hit_r) || dragging == i;
					            gmui_add_circle(sx_arr[i], sy_arr[i], hov ? 7 : 5, false, hov ? c_orange : c_white, 1);
					        }
					    }

					    gmui_end_child();
					}

					gmui_end_flex_child();
				}
				if (gmui_begin_flex_child()) { // game feel fx
				    gmui_text_disabled("GAME FEEL FX");
				    gmui_separator();

				    static z5_color     = make_color_rgb(70, 130, 220);
				    static z5_wiggle_on = false;
				    static z5_noise_on  = false;
				    static z5_noise_t   = 0;
				    static z5_ts_active = 1;
				    static z5_ts_scales = [0.5, 1.0, 2.0];
				    static z5_ts_labels = ["0.5×", "1×", "2×"];

				    if (z5_noise_on) { z5_noise_t += 0.04 * (gmmt_get_global_time_scale() ?? 1); }

				    if (gmui_button_small("Shake")) {
				        gmmt_shake("z5_shake", 12, 350000, 8);
				    }
				    gmui_sameline();
				    if (gmui_button_small("Pulse")) {
				        gmmt_pulse("z5_pulse", 1.0, 1.4, 280000, gmmt_ease.OUT_BACK);
				    }
				    gmui_sameline();
				    if (gmui_button_small("Flash")) {
				        gmmt_tween_color3("z5_col", z5_color, c_white, 110000);
				    }

				    if (gmui_button_small(z5_wiggle_on ? "Wiggle ON" : "Wiggle")) {
				        z5_wiggle_on = !z5_wiggle_on;
				        if (z5_wiggle_on) {
				            gmmt_wiggle("z5_wx", 0, 7, 4, -1);
				            gmmt_wiggle("z5_wy", 0, 7, 3, -1);
				        } else {
				            gmmt_stop("z5_wx", false);
				            gmmt_stop("z5_wy", false);
				        }
				    }
				    gmui_sameline();
				    if (gmui_button_small(z5_noise_on ? "Noise ON" : "Noise")) {
				        z5_noise_on = !z5_noise_on;
				        if (!z5_noise_on) {
				            z5_noise_t = 0;
				        }
				    }
				    gmui_sameline();
				    if (gmui_button_small("Stagger 5")) {
				        for (var i = 0; i < 5; i++) {
				            var _sid = "z5_stag_" + string(i);
				            gmmt_tween_start(_sid, 0, 1, 420000, gmmt_ease.OUT_BOUNCE);
				            gmmt_set_delay(_sid, i * 75000);
				        }
				    }

				    gmui_text("Time scale");
				    for (var i = 0; i < array_length(z5_ts_labels); i++) {
				        var _is_active = (z5_ts_active == i);
				        if (_is_active) { gmui_style_push("button_color", gmui_get().style.color_accent); }
				        if (gmui_button_small(z5_ts_labels[i])) {
				            z5_ts_active = i;
				            gmmt_set_global_time_scale(z5_ts_scales[i]);
				        }
				        if (_is_active) { gmui_style_pop("button_color"); }
						if (i != array_length(z5_ts_labels) - 1) { gmui_sameline(); };
				    }

				    if (gmui_begin_child("z5 viz")) {
				        var fv_c   = gmui_get_current_container();
				        var fv_cx  = fv_c.width  * 0.5;
				        var fv_cy  = fv_c.height * 0.5;
				        var sz     = 48;
				        var sc     = 1.0;
				        var scol   = z5_color;
				        var off_x  = 0;
				        var off_y  = 0;

				        var shake_v = gmmt_get_value("z5_shake");
				        if (shake_v != undefined) { off_x += shake_v; }

				        if (z5_wiggle_on) {
				            var wx = gmmt_get_value("z5_wx");
				            var wy = gmmt_get_value("z5_wy");
				            if (wx != undefined) { off_x += wx; }
				            if (wy != undefined) { off_y += wy; }
				        }

				        if (z5_noise_on) {
				            off_x += (sin(z5_noise_t * 2.3 + 42)  * 0.5 + sin(z5_noise_t * 3.7 + 54.6) * 0.3 + sin(z5_noise_t * 0.9 + 88.2) * 0.2) * 9;
				            off_y += (sin(z5_noise_t * 2.3 + 123) * 0.5 + sin(z5_noise_t * 3.7 + 159.9) * 0.3 + sin(z5_noise_t * 0.9 + 256.3) * 0.2) * 8;
				        }

				        var pulse_v = gmmt_get_value("z5_pulse");
				        if (pulse_v != undefined) { sc = pulse_v; }

				        var col_v = gmmt_get_value("z5_col");
				        if (col_v != undefined) { scol = col_v; }

				        var sx   = fv_cx + off_x;
				        var sy   = fv_cy + off_y;
				        var half = (sz * sc) / 2;

				        gmui_add_roundrect(sx - half, sy - half, sx + half, sy + half, false, scol, 1, 6);
				        gmui_add_roundrect(sx - half, sy - half, sx + half, sy - half + 8, false, c_white, 0.2, 4);

				        for (var i = 0; i < 5; i++) {
				            var sv = gmmt_get_value("z5_stag_" + string(i));
				            if (sv != undefined) {
				                var sp  = gmmt_get_progress("z5_stag_" + string(i));
				                var seg_w = fv_c.width / 5;
				                var stx   = i * seg_w + seg_w * 0.5 - 6;
				                var sty   = fv_c.height * 0.2 + (1 - sv) * fv_c.height * 0.6;
				                gmui_add_rectangle(stx, sty, stx + 12, sty + 12, false, make_color_rgb(255, 175, 55), sp);
				            }
				        }

				        gmui_end_child();
				    }

				    gmui_end_flex_child();
				}
				gmui_end_flex();
			}
			gmui_end_flex();
		}
		gmui_end();
	}
	gmui_style_pop("progress_bar_height");
};