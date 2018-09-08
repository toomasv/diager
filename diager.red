Red [
	Author: "Toomas Vooglaid"
	Date: 2018-08-24
	Changed: 2018-09-08
	Purpose: {Simple interactive diagramming tool}
]
do %../drawing/pallette1.red
ctx: context [
	s: none
	short-text: function [title-text /htext hint-text][
		view/flags [
			title title-text 
			result: field 100 focus hint hint-text 
			on-enter [result: result/text unview]
			button "OK" [result: result/text unview]
		][modal popup] 
		result
	]
	ask-text: does [short-text/htext "Enter text" "Enter text"]
	long-text: function [title-text][
		view/flags/options [
			title title-text 
			below
			result: area 300x100 focus
			return
			button "OK" [result: result/text unview]
			button "Cancel" [result: copy "" unview]
		][modal popup resize][
			actors: object [
				on-resizing: func [f e][
					result/size: f/size - 92x20
					foreach-face/with f [
						face/offset/x: f/size/x - face/size/x - 10
					][face/type = 'button]
					show result
				]
			]
		]
		either string? result [result][copy ""]
	]
	ask-long-text: does [long-text "Enter text"]
	text-box: make face! [type: 'box]
	get-text: func [ser /local sz ofs wc hc][
		last-text: ask-long-text
		sz: size-text/with text-box last-text
		ofs: s/2
		switch ser/1 [
			box [
				wc: s/3/x - s/2/x / 2
				hc: s/3/y - s/2/y / 2
				as-pair s/2/x + wc - (sz/x / 2) s/2/y + hc - (sz/y / 2)
			]
			ellipse [
				wc: s/3/x / 2
				hc: s/3/y / 2
				as-pair s/2/x + wc - (sz/x / 2) s/2/y + hc - (sz/y / 2)
			]
			translate [
				wc: s/3/2/4/x - s/3/2/6/x / 2 + s/3/2/6/x
				hc: s/3/2/5/y - s/3/2/2/y / 2 + s/3/2/2/y
				as-pair s/2/x + wc - (sz/x / 2) s/2/y + hc - (sz/y / 2)
			]
			circle [
				as-pair s/2/x - (sz/x / 2) s/2/y - (sz/y / 2)
			]
		]
	]
	last-text: none
	between: func [n1 n2 n3][any [all [n1 >= n2 n1 <= n3] all [n1 <= n2 n1 >= n3]]]
	gather: func [s /local out][
		out: copy []
		switch s/1 [
			box [
				parse head s [
					some [ser: if (ser = s) 4 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse
						within? ser/1 s/2 - 2 s/3 - s/2 + 3
					])( (probe skip ser -2) append/only out ser) | skip]
				]
			]
			ellipse [
				parse head s [
					some [ser: if (ser = s) 3 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse 
						within? ser/1 s/2 - 2 s/3 + 4
					])(append/only out ser) | skip]
				]
			]
			circle [
				parse head s [
					some [ser: if (ser = s) 3 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse 
						within? ser/1 -2 + s/2 - as-pair s/3 s/3 2 * (to-pair s/3) + 4
					])(append/only out ser) | skip]				
				]
			]
			translate [
				parse head s [
					some [ser: if (ser = s) 3 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse 
						within? ser/1 -2 + s/2 + as-pair s/3/2/6/x s/3/2/2/y as-pair s/3/2/4/x - s/3/2/6/x s/3/2/5/y - s/3/2/2/y + 4
					])(append/only out ser) | skip]
				]
			]
		]
		out
	]
	connected: none
	filename: none
	select-size: func [s][
		either s/1 = 'circle [
			either attempt [s/2 = s/5][12][9]
		][
			select [box 10 ellipse 9 translate 9 line 11 text 9] s/1
		]
		;switch s/1 [
		;	box [10] 
		;	ellipse [9] 
		;	circle [either attempt [s/2 = s/5][12][9]] 
		;	translate [9] 
		;	line [11]
		;	text [9]
		;]
	]
	view/no-wait/flags/options lay: layout [
		backdrop rebolor 
		panel 120x420 [
			; Left-hand exemplary shapes
			style _shape: box 101x61
				on-down [
					upper/color: 0.0.0.254
					append upper/pane layout/only compose/deep [
						at (face/offset) base (face/extra/size) transparent loose 
							draw [(head change at face/draw 2 255.255.255.150)]
							on-up [
								append canvas/draw head change at copy/deep face/draw (face/extra/pos) reduce [(face/extra/calc)]
								clear upper/pane
								upper/color: transparent
								;set-focus canvas
							]
							on-drag [face/offset: either event/ctrl? [round/to face/offset 10][face/offset]]
					]
				]
			below
			; Box
			_shape draw [fill-pen snow pen black line-width 1 box 0x0 100x59 10] 
				extra [size 101x60 pos 8 calc [beg: face/offset - 130x0 beg + face/draw/9]]
			; Ellipse
			_shape draw [fill-pen snow pen black line-width 1 ellipse 0x0 100x59]
				extra [size 101x60 pos 8 calc [face/offset - 130x0]]
			; Diamond
			_shape draw [fill-pen snow pen black line-width 1 translate 0x0 [shape [move 30x0 line 60x30 30x60 0x30]]]
				extra [size 61x61 pos 8 calc [face/offset - 130x0]]
			; Circle
			_shape draw [fill-pen snow pen black line-width 1 circle 30x30 30]
				extra [size 61x61 pos 8 calc [face/offset - 100x-30]]
			; Double circle
			_shape draw [fill-pen snow pen black line-width 1 circle 30x30 30 circle 30x30 27]
				extra [size 61x61 pos 8 calc [face/offset - 100x-30 30 'circle face/offset - 100x-30]]
			do [foreach-face self [face/offset/x: 120 - face/extra/size/x / 2]]
		] 
		panel 620x420 [
			at 0x0 canvas: box 0.0.0.254 620x420 all-over draw []
				on-down [
					clear at edit/draw 7
					parse face/draw [some [s: ;(probe "s1" probe s probe index? s)
						'box set start pair! set end pair! integer! 
						if (within? event/offset start end - start + 1) (len: 4) break
					|	'ellipse set start pair! set size pair!
						if (within? event/offset start size) (len: 3) break
					|	'circle set center pair! set radius number! opt ['circle set cent2 pair!]
						(diff: event/offset - center)
						if (radius > sqrt add diff/x ** 2 diff/y ** 2) (len: either attempt [center = cent2] [6][3]) break
					|	'translate set start pair!
						if (within? event/offset start as-pair s/3/2/4/x s/3/2/5/y) (len: 3) break
					|	['line | 'spline] set p1 pair! set p2 pair! set p3 pair! set p4 pair!
						if (
							any [
								within? event/offset (min p1 p2) - 2 (absolute p2 - p1) + 5
								within? event/offset (min p2 p3) - 2 (absolute p3 - p2) + 5
								within? event/offset (min p3 p4) - 2 (absolute p4 - p3) + 5
							]
						)(len: 5) break
					| 	'text set start pair! set txt string!
						if (within? event/offset start size-text/with text-box txt) (len: 3) break
					|	skip
					]]
					either event/shift? [
						ofs: either event/ctrl? [round/to event/offset 10][event/offset]
						append face/draw compose/deep [
							fill-pen transparent pen black line-width 1 line (ofs) (ofs) (ofs) (ofs)
						]
						dlen: length? face/draw
						start?: yes
						dir: none
					][
						if 1 < length? s [append edit/draw copy/deep/part s len]
					]
					;probe "s2" probe s
				]
				on-over [
					any [
						all [
							event/shift? event/down?
							ofs: either event/ctrl? [round/to event/offset 10][event/offset]
							either start? [
								case [
									3 < absolute face/draw/:dlen/x - ofs/x [dir: 'horizontal]
									3 < absolute face/draw/:dlen/y - ofs/y [dir: 'vertical]
								]
								either dir [start?: no][true]
							][
								switch dir [
									horizontal [
										either event/alt-down? [
											face/draw/(dlen - 2)/x: face/draw/(dlen - 1)/x: ofs/x - face/draw/(dlen - 3)/x + face/draw/(dlen - 3)/x 
										][
											face/draw/(dlen - 2)/x: face/draw/(dlen - 1)/x: ofs/x - face/draw/(dlen - 3)/x / 2 + face/draw/(dlen - 3)/x 
											face/draw/(dlen - 1)/y: ofs/y 
										]
									]
									vertical [
										either event/alt-down? [
											face/draw/(dlen - 2)/y: face/draw/(dlen - 1)/y: ofs/y - face/draw/(dlen - 3)/y + face/draw/(dlen - 3)/y 
										][
											face/draw/(dlen - 2)/y: face/draw/(dlen - 1)/y: ofs/y - face/draw/(dlen - 3)/y / 2 + face/draw/(dlen - 3)/y 
											face/draw/(dlen - 1)/x: ofs/x 
										]
									]
								]
								face/draw/:dlen: ofs
							]
						]
						all [; Direct drawing of items
							;event/down?
							
						]
					]
				]
		]
		; Upper layer to transport shapes onto canvas (see first panel `style _shape`)
		at 10x10 upper: base 750x420 transparent with [pane: copy []]
		; Editing panel - transparent layer upon canvas
		; `extra is a block of 2 elements: 
		;	1) diff btw event/offset and "shape/offset"` 
		;	2) usually `size` of shape (except in case of lines)
		at 140x10 edit: box 620x420 extra [0 0] draw [fill-pen 0.0.0.254 pen blue line-width 2] all-over 
			; On-down remember some values
			on-down [
				pos1: pos3: either event/ctrl? [round/to event/offset 10][event/offset]
				pos2: face/draw/8
				face/extra/1: event/offset - face/draw/8
				switch face/draw/7 [
					; In case of normal shapes register size ; NB circle?
					box [face/extra/2: face/draw/9 - face/draw/8 + 1]
					ellipse [face/extra/2: face/draw/9]
					translate [face/extra/2: as-pair face/draw/9/2/4/x face/draw/9/2/5/y]
					; In case of lines register segments
					line spline [
						case [
							within? event/offset (min p1 p2) - 7 (absolute p2 - p1) + 15 [face/extra/1: min p1 p2 face/extra/2: max p1 p2]
							within? event/offset (min p2 p3) - 7 (absolute p3 - p2) + 15 [face/extra/1: min p2 p3 face/extra/2: max p2 p3]
							within? event/offset (min p3 p4) - 7 (absolute p4 - p3) + 15 [face/extra/1: min p3 p4 face/extra/2: max p3 p4]
						]
					]
				]
				unless find [line spline] face/draw/7 [
					connected: gather s
				]
			]
			on-over [
				if event/down? [
					either find [line spline] s/1 [
						;df: either event/ctrl? [round/to event/offset 10][event/offset]
						case [
							within? event/offset s/2 - 5 11x11 [face/draw/8: s/2: either event/ctrl? [round/to event/offset 5][event/offset]]
							within? event/offset s/3 - 5 11x11 [face/draw/9: s/3: either event/ctrl? [round/to event/offset 5][event/offset]]
							within? event/offset s/4 - 5 11x11 [face/draw/10: s/4: either event/ctrl? [round/to event/offset 5][event/offset]]
							within? event/offset s/5 - 5 11x11 [face/draw/11: s/5: either event/ctrl? [round/to event/offset 5][event/offset]]
							within? event/offset (min s/2 s/3) - 5 (absolute s/3 - s/2) + 11 [
								either s/2/x = s/3/x [
									face/draw/8/x: face/draw/9/x: s/2/x: s/3/x: either event/ctrl? [round/to event/offset/x 5][event/offset/x]
								][
									face/draw/8/y: face/draw/9/y: s/2/y: s/3/y: either event/ctrl? [round/to event/offset/y 5][event/offset/y]
								]
							]
							within? event/offset (min s/3 s/4) - 5 (absolute s/4 - s/3) + 11 [
								either s/3/x = s/4/x [
									face/draw/9/x: face/draw/10/x: s/3/x: s/4/x: either event/ctrl? [round/to event/offset/x 5][event/offset/x]
								][
									face/draw/9/y: face/draw/10/y: s/3/y: s/4/y: either event/ctrl? [round/to event/offset/y 5][event/offset/y]
								]
							]
							within? event/offset (min s/4 s/5) - 5 (absolute s/5 - s/4) + 11 [
								either s/4/x = s/5/x [
									face/draw/10/x: face/draw/11/x: s/4/x: s/5/x: either event/ctrl? [round/to event/offset/x 5][event/offset/x]
								][
									face/draw/10/y: face/draw/11/y: s/4/y: s/5/y: either event/ctrl? [round/to event/offset/y 5][event/offset/y]
								]
							]
						]
					][
						df: event/offset - face/extra/1
						if event/ctrl? [df: round/to df 10]
						diff: either event/ctrl? [round/to event/offset 10][event/offset]
						pos3diff: diff - pos3
						switch face/draw/7 [
							box [
								case [
									within? event/offset s/2 - 0x7 as-pair face/extra/2/x 15 [
										face/draw/8/y: s/2/y: diff/y 
										either event/shift? [
											face/draw/9/y: s/3/y: pos2/y + face/extra/2/y - (diff/y - pos1/y)
										][
											face/extra/2: s/3 - s/2 + 1
										]
									]
									within? event/offset (as-pair s/2/x s/3/y) - 0x7 as-pair face/extra/2/x 15 [
										face/draw/9/y: s/3/y: diff/y 
										either event/shift? [
											face/draw/8/y: s/2/y: pos2/y - (diff/y - pos1/y)
										][
											face/extra/2: s/3 - s/2 + 1
										]
									]
									within? event/offset s/2 - 7x0 as-pair 15 face/extra/2/y [
										face/draw/8/x: s/2/x: diff/x
										either event/shift? [
											face/draw/9/x: s/3/x: pos2/x + face/extra/2/x - (diff/x - pos1/x)
										][
											face/extra/2: s/3 - s/2 + 1
										]
									]
									within? event/offset (as-pair s/3/x s/2/y) - 7x0 as-pair 15 face/extra/2/y [
										face/draw/9/x: s/3/x: diff/x
										either event/shift? [
											face/draw/8/x: s/2/x: pos2/x - (diff/x - pos1/x)
										][
											face/extra/2: s/3 - s/2 + 1
										]
									]
									true [
										face/draw/8: s/2: df 
										face/draw/9: s/3: s/2 + face/extra/2 - 1
										unless event/shift? [forall connected [change connected/1 connected/1/1 + pos3diff]]
									]
								]
							]
							circle [
								case [
									between dist: sqrt add power first dis: event/offset - s/2 2 dis/y ** 2 s/3 - 7 s/3 + 7 [
										face/draw/9: s/3: either event/ctrl? [round/to dist 10][dist]
										if attempt [face/draw/8 = face/draw/11] [
											face/draw/12: s/6: s/3 - 3
										]
									]
									true [
										if attempt [face/draw/8 = face/draw/11] [
											face/draw/11: s/5: df
										]
										face/draw/8: s/2: df 
										unless event/shift? [forall connected [change connected/1 connected/1/1 + pos3diff]]
									]
								]
							]
							ellipse [
								;probe reduce [df event/offset s/2 face/extra]
								diff2: either event/ctrl? [round/to df - s/2 10][df - s/2]
								case [
									within? event/offset s/2 - 0x7 as-pair s/3/x 15 [
										face/draw/8/y: s/2/y: df/y 
										face/draw/9/y: s/3/y: s/3/y - either event/shift? [2 * diff2/y][diff2/y]
									]
									within? event/offset (as-pair s/2/x s/2/y + s/3/y - 1) - 0x7 as-pair s/3/x 15 [
										;if event/shift? [
										;	face/draw/8/y: s/2/y: pos2/y - (event/offset/y - pos1/y)
										;]
										face/draw/9/y: s/3/y: face/extra/2/y + diff2/y ;either event/shift? [2 * diff2/y][diff2/y]
										;pos1: event/offset pos2: face/draw/8
									]
									within? event/offset s/2 - 7x0 as-pair 15 s/3/y [
										face/draw/8/x: s/2/x: df/x
										face/draw/9/x: s/3/x: s/3/x - either event/shift? [2 * diff2/x][diff2/x]
									]
									within? event/offset (as-pair s/2/x + s/3/x - 1 s/2/y) - 7x0 as-pair 15 s/3/y [
										;if event/shift? [face/draw/8/x: s/2/x: pos2/x - diff2/x]
										face/draw/9/x: s/3/x: face/extra/2/x + diff2/x ;either event/shift? [2 * diff2/x][diff2/x]
									]
									true [
										face/draw/8: s/2: df
										unless event/shift? [forall connected [change connected/1 connected/1/1 + pos3diff]]
									]
								]
							]
							translate [
								case [
									within? event/offset s/2 + s/3/2/2 - 7 15x15 [
										face/draw/9/2/2/y: s/3/2/2/y: diff/y - s/2/y
										if event/shift? [
											face/draw/9/2/5/y: s/3/2/5/y: negate s/3/2/2/y - 60
										]
									]
									within? event/offset s/2 + s/3/2/5 - 7 15x15 [
										face/draw/9/2/5/y: s/3/2/5/y: diff/y - s/2/y
										if event/shift? [
											face/draw/9/2/2/y: s/3/2/2/y: negate s/3/2/5/y - 60
										]
									]
									within? event/offset s/2 + s/3/2/4 - 7 15x15 [
										face/draw/9/2/4/x: s/3/2/4/x: diff/x - s/2/x
										if event/shift? [
											face/draw/9/2/6/x: s/3/2/6/x: negate s/3/2/4/x - 60
										]
									]
									within? event/offset s/2 + s/3/2/6 - 7 15x15 [
										face/draw/9/2/6/x: s/3/2/6/x: diff/x - s/2/x
										if event/shift? [
											face/draw/9/2/4/x: s/3/2/4/x: negate s/3/2/6/x - 60
										]
									]
									true [
										face/draw/8: s/2: df 
										unless event/shift? [forall connected [change connected/1 connected/1/1 + pos3diff]]
									]
								]
							]
							text [
								face/draw/8: s/2: df
							]
						]
						pos3: diff;event/offset ;
					]
				]
			]
			with [
				menu: [
					"fill-pen" fill-pen 
					"pen" pen 
					"line-width" line-width
					"text" text
					"connector" [
						"line" line 
						"spline" spline
						"start-arrow" sarrow ; TBD
						"end-arrow" earrow ; TBD
					]
					"delete" delete
					"order" [
						"back" back 
						"backward" backward 
						"forward" forward 
						"front" front
					]
				]
			]
			on-menu [
				switch event/picked [
					fill-pen [change skip s -5 select-color]
					pen [change skip s -3 select-color]
					line-width [
						view/flags [field "2" 30 focus [also change back s face/data unview]][modal popup]
					]
					text [append s compose [fill-pen snow pen black line-width 1 text (get-text s) (last-text)]]
					spline [edit/draw/7: 'spline change s 'spline]
					line [edit/draw/7: 'line change s 'line]
					sarrow [] ; TBD
					earrow [] ; TBD
					delete [
						clear at edit/draw 7 
						change/part skip s -6 [] select-size s
					]
					back [move/part skip s -6 head s select-size s]
					backward [move/part skip s -6 skip find/reverse skip s -6 word! -6 select-size s]
					forward [
						probe head s 
						move/part probe skip s -6 
							probe skip probe s2: 
								probe skip s -6 + select-size s 
								select-size skip s2 6
							select-size s 
						probe head s
					]
					front [move/part skip s -6 tail s select-size s]
				]
			]
	][resize][
		menu: [
			"File" ["New" new "Open" open "Add" add "Save" save "Save as ..." save-as "Export" export]
		]
		actors: object [
			on-resizing: func [face event][
				face/pane/1/size/y: face/size/y - 20 
				face/pane/2/size: canvas/size: edit/size: face/size - 150x20
				face/pane/3/size: face/size - 20
			]
			on-menu: func [face event /local fn][
				switch event/picked [
					new [filename: none clear canvas/draw]
					open [if fn: request-file/filter ["*.dgr"][append clear canvas/draw load filename: fn]]
					add [if fn: request-file/filter ["*.dgr"][append canvas/draw load fn]]
					save [either filename [save filename canvas/draw][if fn: request-file/save [save fn canvas/draw]]]
					save-as [if fn: request-file/save [save fn canvas/draw]]
					export [if fn: request-file/save/filter ["*.png" "*.jpeg" "*.gif"] [save fn draw canvas/size canvas/draw]]
				]
			]
		]
	]
	;do-events
]
