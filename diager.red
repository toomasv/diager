Red [
	Author: "Toomas Vooglaid"
	Date: 2018-08-24
	Changed: 2018-09-17
	Purpose: {Simple interactive diagramming tool}
]
do %../drawing/pallette1.red
ctx: context [
	s: h1: h2: h3: v1: v2: v3: diff: df: pos1: pos2: pos3: lw: point-idx: le: none
	df-points: copy []
	ctrl-points: copy []
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
	last-text: none
	text-size: func [text][size-text/with text-box text]
	text-pos: func [ser /local sz ofs wc hc out][
		last-text: ask-long-text
		sz: text-size last-text; size-text/with text-box last-text
		ofs: s/2
		out: switch ser/1 [
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
			; Diamond representation replaced
			;translate [
			;	wc: s/3/2/4/x - s/3/2/6/x / 2 + s/3/2/6/x
			;	hc: s/3/2/5/y - s/3/2/2/y / 2 + s/3/2/2/y
			;	as-pair s/2/x + wc - (sz/x / 2) s/2/y + hc - (sz/y / 2)
			;]
			polygon [
				as-pair s/2/x - (sz/x / 2) s/3/y - (sz/y / 2)
			]			
			circle [
				as-pair s/2/x - (sz/x / 2) s/2/y - (sz/y / 2)
			]
		] 
		out - 2
	]
	between: func [n1 n2 n3][any [all [n1 >= n2 n1 <= n3] all [n1 <= n2 n1 >= n3]]]
	gather: func [s /local out ser][
		out: copy []
		switch s/1 [
			box [
				parse head s [
					some [ser: if (ser = s) 4 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse
						within? ser/1 s/2 - 2 s/3 - s/2 + 3
					])( (skip ser -2) append/only out ser) | skip]
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
			comment {
			translate [
				parse head s [
					some [ser: if (ser = s) 3 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse 
						within? ser/1 -2 + s/2 + as-pair s/3/2/6/x s/3/2/2/y as-pair s/3/2/4/x - s/3/2/6/x s/3/2/5/y - s/3/2/2/y + 4
					])(append/only out ser) | skip]
				]
			]}
			polygon [
				parse head s [
					some [ser: if (ser = s) 5 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse 
						within? ser/1 -2 + as-pair s/5/x s/2/y as-pair s/3/x - s/5/x + 1 s/4/y - s/2/y + 5
					])(append/only out ser) | skip]
				]
			]
			text [
				parse head s [
					some [ser: if (ser = s) 3 skip | ser: pair! if (all [
						not ser/-2 = 'ellipse
						within? ser/1 s/2 - 2 (text-size s/3) + 5
					])(append/only out ser) | skip]
				]
			]
		]
		out
	]
	get-angle: func [ang][180 / pi * arctangent2 ang/y ang/x]
	connected: none
	move-connected: func [p3d][
		forall connected [
			either all [
				any [
					find [line spline] connected/1/-1
					parse skip connected/1 -2 [some [l: ['line | 'spline] to end | pair! (l: back l) :l | reject]]
				]
				any [
					; start- arrow
					block? connected/1/-2
					'transform = connected/1/3
					; end-arrow
					'transform = connected/1/2
					block? connected/1/-3
				]
			][
				; transform's offset is changed already (catched automatically)
				; but we have to change line's point manually because we have intercepted this
				change connected/1 connected/1/1 + p3d
				case/all [
					block? connected/1/-2 [
						ang: connected/1/2 - connected/1/1
						connected/1/-6: get-angle ang
					]
					'transform = connected/1/3 [
						ang: connected/1/2 - connected/1/1
						connected/1/5: get-angle ang					
					]
					'transform = connected/1/2 [
						ang: connected/1/1 - connected/1/-1
						connected/1/4: get-angle ang
					]
					block? connected/1/-3 [
						ang: connected/1/1 - connected/1/-1
						connected/1/-7: get-angle ang
					]
				]
			][
				change connected/1 connected/1/1 + p3d
			]
		]
	]
	filename: none
	line-rule: [['line | 'spline] some pair! opt ['transform 6 skip] le:]
	select-size: func [s][ ; TBD arrows
		switch/default s/1 [
			circle [
				either attempt [s/2 = s/5][12][9]
			]
			line spline [
				parse s line-rule
				len: (index? le) - (index? s)
				either block? s/-1 [len + 13][len + 6]
			]
		][select [box 10 ellipse 9 polygon 11 text 9] s/1] ; translate 9
	]
	follow: function [series pos /part size /abs ][
		if integer? pos [
			pos: either abs [at head series pos][skip series pos]
		] 
		size: any [size 1] 
		switch/default pos [
			head [move/part series s: head series size] 
			tail [move/part series tail series size s: skip tail series negate size]
		][
			either (index? pos) > (index? series) [
				move/part series s: back pos size 
				s: skip pos negate size -1
			][
				move/part series s: pos size
			]
		] s
	]
	at-distance-from-line?: function [point line-start line-end distance][
		offset-line: line-end - line-start 
		offset-point: point - line-start 
		angle-line: arctangent2 offset-line/y offset-line/x 
		angle-point: arctangent2 offset-point/y offset-point/x 
		angle: angle-point - angle-line 
		length-line: sqrt (offset-line/x ** 2) + (offset-line/y ** 2) 
		length-hypotenuse: sqrt (offset-point/x ** 2) + (offset-point/y ** 2) 
		length-opposite-side: absolute angle * length-hypotenuse 
		length-adjacent-side: sqrt (length-hypotenuse ** 2) - (length-opposite-side ** 2) 
		all [length-adjacent-side >= 0 length-adjacent-side <= length-line length-opposite-side <= distance]
	]
	view/no-wait/flags/options lay: layout [
		backdrop rebolor 
		shapes: panel 120x420 [
			; Left-hand shape species
			style _shape: box 102x62
				with [
					menu: ["fill-pen" fill-pen "pen" pen "line-width" line-width]
					actors: object [
						on-menu: func [face event] [;copy/deep 
							switch event/picked [
								fill-pen [face/draw/fill-pen: select-color]
								pen [face/draw/pen: select-color]
								line-width [
									lw: 1
									view/flags [field "2" 30 focus [also lw: face/data unview]][modal popup]
									face/draw/line-width: lw
								]
								e-arrow [
									if pair? last face/draw [
										append face/draw compose/deep [
											;rotate 0 (face/draw/(-1 + length? face/draw)) [triangle (end: last face/draw) (end - 10x5) (end - 10x-5)]
											transform 0x0 0 1 1 100x5 [shape [move -10x-5 line 0x0 -10x5]]
										]
										change/part at face/menu 7 ["wo end arrow" woe-arrow] 2
										if face/menu/10 = 'wos-arrow [
											change/part at face/menu 11 ["wo end/start arrows" wose-arrow] 2
										]
									]
								]
								s-arrow [
									if 'line = face/draw/7 [
										insert at face/draw 7 compose/deep [
											;rotate 0 (face/draw/9) [triangle (end: face/draw/8) (end + 10x5) (end + 10x-5)]
											transform 0x0 0 1 1 0x5 [shape [move 10x-5 line 0x0 10x5]]
										]
										change/part at face/menu 9 ["wo start arrow" wos-arrow] 2
										if face/menu/8 = 'woe-arrow [
											change/part at face/menu 11 ["wo end/start arrows" wose-arrow] 2
										]
									]
								]
								se-arrow [
									case/all [
										pair? last face/draw [
											append face/draw compose/deep [
												;rotate 0 (face/draw/(-1 + length? face/draw)) [triangle (end: last face/draw) (end - 10x5) (end - 10x-5)]
												transform 0x0 0 1 1 100x5 [shape [move -10x-5 line 0x0 -10x5]]
											]
										]
										'line = face/draw/7 [
											insert at face/draw 7 compose/deep [
												;rotate 0 (face/draw/9) [triangle (end: face/draw/8) (end + 10x5) (end + 10x-5)]
												transform 0x0 0 1 1 0x5 [shape [move 10x-5 line 0x0 10x5]]
											]
										]
									]
									change/part at face/menu 7 ["wo end arrow" woe-arrow "wo start arrow" wos-arrow "wo end/start arrows" wose-arrow] 6
								]
								woe-arrow [
									if block? last face/draw [
										clear find/last face/draw 'transform
										change/part at face/menu 7 ["end arrow" e-arrow] 2
										if face/menu/12 = 'wose-arrow [
											change/part at face/menu 11 ["end/start arrows" se-arrow] 2
										]
									]
								]
								wos-arrow [
									if 'transform = face/draw/7 [
										change/part at face/draw 7 [] 7
										change/part at face/menu 9 ["start arrow" s-arrow] 2
										if face/menu/12 = 'wose-arrow [
											change/part at face/menu 11 ["end/start arrows" se-arrow] 2
										]
									]
								]
								wose-arrow [
									case/all [
										block? last face/draw [
											clear find/last face/draw 'transform
										]
										'transform = face/draw/7 [
											change/part at face/draw 7 [] 7
										]
									]
									change/part at face/menu 7 ["end arrow" e-arrow "start arrow" s-arrow "end/start arrows" se-arrow] 6
								]
							]
							'done
						]
						on-down: func [face event] [
							append upper/pane layout/only compose/deep/only [
								at (face/offset + 5) base (face/extra/size) glass loose
									draw (face/draw)
									on-up [
										; Append to canvas only if released upon working area...
										if face/offset/x > 130 [
											; append from beginning but change offsets according to calc in each shapes' extra block
											append canvas/draw head change at copy/deep face/draw (face/extra/pos) reduce (face/extra/calc)
										]
										;... otherwise just unselect (clear transport layer)
										clear upper/pane
										; Make transport layer unresponsive
										upper/color: transparent
										;set-focus canvas
									]
									on-drag [face/offset: either event/ctrl? [round/to face/offset 10][face/offset]]
							]
							; Make transport layer responsive
							upper/color: 0.0.0.254
						]
					]
				]
			below
			; Box
			_shape draw [fill-pen snow pen black line-width 1 box 0x0 100x60 10] 
				extra [size 101x61 pos 8 calc [beg: face/offset - 130x0 beg + face/draw/9]]
			; Ellipse
			_shape draw [fill-pen snow pen black line-width 1 ellipse 0x0 100x60]
				extra [size 102x62 pos 8 calc [face/offset - 130x0]]
			; Diamond
			;_shape draw [fill-pen snow pen black line-width 1 translate 0x0 [shape [move 30x0 line 60x30 30x60 0x30]]]
			_shape draw [fill-pen snow pen black line-width 1 polygon 30x0 60x30 30x60 0x30]
				extra [size 61x61 pos 8 calc [beg: face/offset - 100x0 beg + 30x30 beg + 0x60 beg + -30x30]]
			; Circle
			_shape draw [fill-pen snow pen black line-width 1 circle 30x30 30]
				extra [size 61x61 pos 8 calc [face/offset - 100x-30]]
			; Double circle
			_shape draw [fill-pen snow pen black line-width 1 circle 30x30 30 circle 30x30 27]
				extra [size 61x61 pos 8 calc [face/offset - 100x-30 30 'circle face/offset - 100x-30]]
			; Line / Arrow
			_shape snow draw [fill-pen black pen black line-width 1 line 0x5 100x5]
				with [
					append menu ["end arrow" e-arrow "start arrow" s-arrow "end/start arrows" se-arrow]
					extra: [size 101x11 pos 7 calc ;[beg: face/offset - 130x-5 beg + 100x0]]
						(parse face/draw [
							thru ['line-width integer!]
							collect [
								opt ['transform keep (to-lit-word 'transform) keep skip keep skip keep skip keep skip skip keep (face/offset - 130x-5) keep skip]
								'line keep (to-lit-word 'line) skip keep (p1: face/offset - 130x-5) skip keep (p1 + 100x0)
								opt ['transform keep (to-lit-word 'transform) keep skip keep skip keep skip keep skip skip keep (p1 + 100x0) keep skip]
							]
						])
					]
				]
			do [
				;probe self/pane/(length? self/pane)/extra
				foreach-face self [face/offset/x: 120 - face/extra/size/x / 2]
			]
		] 
		drawing: panel white 620x420 [
			at 0x0 grid: box 620x420 draw [
				fill-pen pattern 100x100 [
					fill-pen pattern 10x10 [
						pen 200.200.200 box 0x0 10x10
					] pen 120.120.120 box 0x0 100x100 
				]
				pen off box 0x0 620x420
			]
			
			at 0x0 canvas: box 0.0.0.254 620x420 all-over draw []
				on-down [
					clear at edit1/draw 7
					clear at edit2/draw 7
					parse face/draw [some [s: ;(probe "s1" probe s probe index? s)
						'box set start pair! set end pair! set radius integer! 
						if (within? event/offset start end - start + 1) (len: 4) break
					|	'ellipse set start pair! set size pair!
						if (within? event/offset start size) (len: 3) break
					|	'circle set center pair! set radius number! opt ['circle set cent2 pair!]
						(diff: event/offset - center)
						if (radius > sqrt add diff/x ** 2 diff/y ** 2) (len: either attempt [center = cent2] [6][3]) break
					;|	'translate set start pair!
					;	if (within? event/offset start as-pair s/3/2/4/x s/3/2/5/y) (len: 3) break
					|	'polygon set p1 pair! set p2 pair! set p3 pair! set p4 pair!
						if (
							within? event/offset as-pair p4/x p1/y as-pair p2/x - p4/x + 1 p3/y - p1/y + 1
						)(len: 5) break
					|	['line | 'spline] copy points some pair! 
						if (
							is-within?: no
							while [1 < length? points][
								either at-distance-from-line? event/offset points/1 points/2 3 [is-within?: true break][points: next points]
							]
							is-within?
						)(
							points: parse at s 2 [collect some keep pair!]
							len: 1 + length? points
						) break
					| 	'text set start pair! set txt string!
						if (within? event/offset start text-size txt) (len: 3) break  ; size-text/with text-box txt
					|	skip
					]]
					either event/shift? [
						ofs: either event/ctrl? [round/to event/offset 10][event/offset]
						append face/draw compose/deep [
							fill-pen black pen black line-width 1 line (ofs) (ofs) (ofs) (ofs)
						]
						dlen: length? face/draw
						start?: yes
						dir: none
					][
						if 1 < length? s [append edit1/draw copy/deep/part s len]
						switch s/1 [
							box [append edit2/draw compose [
								circle (start) 5 circle (end) 5 circle (as-pair end/x - radius start/y + radius) 3]
							]
							ellipse [append edit2/draw compose [circle (start) 5 circle (start + size) 5]]
							polygon [append edit2/draw compose [circle (p1) 5 circle (p2) 5 circle (p3) 5 circle (p4) 5]]
							line spline [
								clear ctrl-points 
								foreach point points [append ctrl-points compose [circle (point) 5]] 
								append edit2/draw ctrl-points
								points: head points
								change/part at edit1/menu/10 5 either wos: block? s/-1 [["wo start arrow" wos-arrow]][["start arrow" s-arrow]] 2
								change/part at edit1/menu/10 7 either woe: 'transform = s/(2 + length? points) [["wo end arrow" woe-arrow]][["end arrow" e-arrow]] 2
								change/part at edit1/menu/10 9 either all [wos woe] [["wo start/end arrow" wose-arrow]][["start/end arrow" se-arrow]] 2
							]
							;text []
						]
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
						;all [; Direct drawing of items
							;event/down?
							
						;]
					]
				]
		]
		; Upper layer to transport shapes onto canvas (see first panel `style _shape`)
		at 10x10 upper: base 750x420 transparent with [pane: copy []]
			on-up [
				either event/offset/x > 130 [
					pos1: either event/ctrl? [round/to event/offset 10][event/offset]
					append canvas/draw head change at copy/deep face/pane/1/draw 8 reduce switch face/pane/1/draw/7 [
						box [[beg: pos1 - 130x0 beg + face/pane/1/draw/9]]
						ellipse [[pos1 - 130x0]]
						;translate [[pos1 - 130x0]]
						polygon [[pos1 - 130x0 pos1 - 100x30 pos1 - 130x60 pos1 - 160x30]]
						circle [
							either face/pane/1/draw/10 = 'circle [
								[pos1 - 100x-30 30 'circle pos1 - 100x-30]
							][
								[pos1 - 100x-30]
							]
						]
						transform [
							(parse at face/pane/1/draw 8 [
								collect [
									keep skip keep skip keep skip keep skip skip keep (p1: pos1 - 130x0) keep skip
									'line keep (to-lit-word 'line) skip keep (p1) skip keep (p1 + 100x0)
									opt ['transform keep (to-lit-word 'transform) keep skip keep skip keep skip keep skip skip keep (p1 + 100x0) keep skip]
								]
							])
						]
						line [
							(parse at face/pane/1/draw 8 [
								collect [
									skip keep (p1: pos1 - 130x0) skip keep (p1 + 100x0)
									opt ['transform keep (to-lit-word 'transform) keep skip keep skip keep skip keep skip skip keep (p1 + 100x0) keep skip]
								]
							])
						]
					] 
				][
					clear upper/pane
					upper/color: transparent
				]
			]
		; Editing panel - transparent layer upon canvas
		; `extra is a block of 2 elements: 
		;	1) diff btw event/offset and "shape/offset"` 
		;	2) usually `size` of shape (except in case of lines)
		style edit: box 620x420 draw [fill-pen 0.0.0.254 pen purple line-width 2] all-over
		at 140x10 edit3: edit hidden draw [
			pen papaya line-width 1 
			h1: line 0x-2 620x-2 h2: line 0x-2 620x-2 h3: line 0x-2 620x-2 
			v1: line -2x0 -2x420 v2: line -2x0 -2x420 v3: line -2x0 -2x420 
		]
		at 140x10 edit1: edit extra [0 0] 
			; On-down remember some values
			on-down [
				pos1: pos3: either event/ctrl? [round/to event/offset 10][event/offset]
				; Original start point
				pos2: face/draw/8
				; Difference from event/offset to start
				face/extra/1: event/offset - face/draw/8
				switch face/draw/7 [
					; In case of normal shapes register size ; NB circle?
					; Horizontal and vertical guides
					box [
						face/extra/2: face/draw/9 - face/draw/8 + 1 
						; upper horizontal
						h1/2/y: h1/3/y: s/2/y 
						; center horizontal
						h2/2/y: h2/3/y: s/3/y - s/2/y / 2 + s/2/y
						; lower horizontal
						h3/2/y: h3/3/y: s/3/y
						; left vertical
						v1/2/x: v1/3/x: s/2/x 
						; center vertical
						v2/2/x: v2/3/x: s/3/x - s/2/x / 2 + s/2/x 
						; right vertical
						v3/2/x: v3/3/x: s/3/x
						;df11: df12: dist11: dist12: none
					]
					ellipse [
						face/extra/2: face/draw/9
						; upper horizontal
						h1/2/y: h1/3/y: s/2/y 
						; center horizontal
						h2/2/y: h2/3/y: s/3/y / 2 + s/2/y
						; lower horizontal
						h3/2/y: h3/3/y: s/2/y + s/3/y
						; left vertical
						v1/2/x: v1/3/x: s/2/x 
						; center vertical
						v2/2/x: v2/3/x: s/3/x / 2 + s/2/x 
						; right vertical
						v3/2/x: v3/3/x: s/2/x + s/3/x
					]
					;translate [face/extra/2: as-pair face/draw/9/2/4/x face/draw/9/2/5/y]
					polygon [
						face/extra/2: as-pair face/draw/9/x - face/draw/11/x + 1 face/draw/10/y - face/draw/8/y + 1
						; upper horizontal
						h1/2/y: h1/3/y: s/2/y 
						; center horizontal
						h2/2/y: h2/3/y: s/3/y
						; lower horizontal
						h3/2/y: h3/3/y: s/4/y
						; left vertical
						v1/2/x: v1/3/x: s/5/x 
						; center vertical
						v2/2/x: v2/3/x: s/2/x 
						; right vertical
						v3/2/x: v3/3/x: s/3/x
					]
					; For circle there is no need for edit2 (control-points)
					circle [
						; upper horizontal
						h1/2/y: h1/3/y: s/2/y - s/3 
						; center horizontal
						h2/2/y: h2/3/y: s/2/y
						; lower horizontal
						h3/2/y: h3/3/y: s/2/y + s/3
						; left vertical
						v1/2/x: v1/3/x: s/2/x - s/3 
						; center vertical
						v2/2/x: v2/3/x: s/2/x 
						; right vertical
						v3/2/x: v3/3/x: s/2/x + s/3
					]
					; In case of lines register segments
					line spline [
						;points: copy at face/draw 8
						clear df-points
						forall points [append df-points pos3 - points/1]
						forall points [
							if all [
								1 < length? points 
								at-distance-from-line? event/offset points/1 points/2 7
							][
								point-idx: index? points
								;face/extra/1: min points/1 points/2 
								;face/extra/2: max points/1 points/2
								break
							]
						]
						points: head points
					]
				]
				either find [line spline] face/draw/7 [
					;???
				][
					connected: gather s
				]
				edit3/visible?: yes
			]
			on-over [
				if event/down? [
					either find [line spline] s/1 [
						;df: either event/ctrl? [round/to event/offset 10][event/offset]
						pos3: either event/ctrl? [round/to event/offset 5][event/offset]
						case [
							s/(1 + point-idx)/x = s/(2 + point-idx)/x [dim: 'x ortho?: yes] ; veritcal line - horizontal move
							s/(1 + point-idx)/y = s/(2 + point-idx)/y [dim: 'y ortho?: yes] ; horizontal line - vertical move
							'else [ortho?: no]
						]
						case [
							ortho? [
								face/draw/(7 + point-idx)/:dim: 
								face/draw/(8 + point-idx)/:dim: 
								s/(1 + point-idx)/:dim: 
								s/(2 + point-idx)/:dim: 
								edit2/draw/(point-idx - 1 * 3 + 1 + 7)/:dim: 
								edit2/draw/(point-idx * 3 + 1 + 7)/:dim: 
								points/:point-idx/:dim:
								points/(point-idx + 1)/:dim:
									pos3/:dim
								case/all [
									all [1 = point-idx block? s/-1][s/-2/:dim: pos3/:dim]
									all [2 = point-idx block? s/-1][
										ang: s/3 - s/2
										; compute angle of arrowhead
										s/-5: get-angle ang
									]
									all [
										point-idx + 1 = length? points
										'transform = s/(len: -5 + length? face/draw)
									][s/(len + 5)/:dim: pos3/:dim]
									all [
										(length? points) - point-idx = 2
										'transform = s/(len: 2 + length? points)
									][	
										ang: s/(point-idx + 3) - s/(point-idx + 2)
										s/(len + 2): get-angle ang
									]
								]
							]
							; slanted  probe
							'else [
								face/draw/(7 + point-idx): s/(1 + point-idx): edit2/draw/(point-idx - 1 * 3 + 1 + 7): pos3 - df-points/:point-idx
								face/draw/(8 + point-idx): s/(2 + point-idx): edit2/draw/(point-idx * 3 + 1 + 7): pos3 - df-points/(point-idx + 1)
								case/all [
									all [1 = point-idx block? s/-1] [s/-2: s/2]
									all [2 = point-idx block? s/-1][
										ang: s/3 - s/2
										; compute angle of arrowhead
										s/-5: get-angle ang
									]
									all [
										point-idx + 1 = length? points
										'transform = s/(len: point-idx + 3)
									][
										s/(len + 5): s/(point-idx + 2)
									]
									all [
										(length? points) - point-idx = 2
										'transform = s/(len: 2 + length? points)
									][	
										ang: s/(point-idx + 3) - s/(point-idx + 2)
										s/(len + 2): get-angle ang
									]
								] 
								points/:point-idx: s/(point-idx + 1)
								points/(point-idx + 1): s/(point-idx + 2)
							]
						]
					][
						df: event/offset - face/extra/1
						if event/ctrl? [df: round/to df 10]
						diff: either event/ctrl? [round/to event/offset 10][event/offset]
						;pos3: either event/ctrl? [round/to event/offset 5][event/offset]
						pos3diff: diff - pos3
						switch face/draw/7 [
							box [
								case [
									; upper border
									within? event/offset s/2 - 0x7 as-pair face/extra/2/x 15 [
										face/draw/8/y: s/2/y: edit2/draw/8/y: diff/y 
										edit2/draw/14/y: diff/y + s/4
										either event/shift? [
											face/draw/9/y: s/3/y: edit2/draw/11/y: pos2/y + face/extra/2/y - (diff/y - pos1/y)
											h3/2/y: h3/3/y: s/3/y
										][
											face/extra/2: s/3 - s/2 + 1
										]
										h1/2/y: h1/3/y: s/2/y
										h2/2/y: h2/3/y: s/3/y - s/2/y / 2 + s/2/y
									]
									; lower border
									within? event/offset (as-pair s/2/x s/3/y) - 0x7 as-pair face/extra/2/x 15 [
										face/draw/9/y: s/3/y: edit2/draw/11/y: diff/y 
										either event/shift? [
											face/draw/8/y: s/2/y: edit2/draw/8/y: pos2/y - (diff/y - pos1/y)
											h1/2/y: h1/3/y: s/2/y
										][
											face/extra/2: s/3 - s/2 + 1
										]
										h3/2/y: h3/3/y: s/3/y
										h2/2/y: h2/3/y: s/3/y - s/2/y / 2 + s/2/y
									]
									; left border
									within? event/offset s/2 - 7x0 as-pair 15 face/extra/2/y [
										face/draw/8/x: s/2/x: edit2/draw/8/x: diff/x
										either event/shift? [
											face/draw/9/x: s/3/x: edit2/draw/11/x: pos2/x + face/extra/2/x - (diff/x - pos1/x)
											v3/2/x: v3/3/x: s/3/x
										][
											face/extra/2: s/3 - s/2 + 1
										]
										v1/2/x: v1/3/x: s/2/x
										v2/2/x: v2/3/x: s/3/x - s/2/x / 2 + s/2/x
									]
									; right border
									within? event/offset (as-pair s/3/x s/2/y) - 7x0 as-pair 15 face/extra/2/y [
										face/draw/9/x: s/3/x: edit2/draw/11/x: diff/x
										edit2/draw/14/x: diff/x - s/4
										either event/shift? [
											face/draw/8/x: s/2/x: edit2/draw/8/x: pos2/x - (diff/x - pos1/x)
											v1/2/x: v1/3/x: s/2/x
										][
											face/extra/2: s/3 - s/2 + 1
										]
										v3/2/x: v3/3/x: s/3/x
										v2/2/x: v2/3/x: s/3/x - s/2/x / 2 + s/2/x
									]
									true [
										face/draw/8: s/2: edit2/draw/8: df 
										face/draw/9: s/3: edit2/draw/11: s/2 + face/extra/2 - 1
										edit2/draw/14: as-pair s/3/x - s/4 s/2/y + s/4
										h1/2/y: h1/3/y: s/2/y
										h3/2/y: h3/3/y: s/3/y
										h2/2/y: h2/3/y: s/3/y - s/2/y / 2 + s/2/y
										v1/2/x: v1/3/x: s/2/x
										v3/2/x: v3/3/x: s/3/x
										v2/2/x: v2/3/x: s/3/x - s/2/x / 2 + s/2/x
										unless event/shift? [move-connected pos3diff]
									]
								]
							]
							ellipse [
								;probe reduce [df event/offset s/2 face/extra]
								diff2: either event/ctrl? [round/to df - s/2 10][df - s/2]
								cent: s/3 / 2 + s/2
								case [
									; upper border
									within? event/offset s/2 - 0x7 as-pair s/3/x 15 [
										face/draw/8/y: s/2/y: edit2/draw/8/y: df/y 
										face/draw/9/y: s/3/y: s/3/y - either event/shift? [2 * diff2/y][diff2/y]
										edit2/draw/11/y: s/2/y + s/3/y
										h1/2/y: h1/3/y: s/2/y
										h3/2/y: h3/3/y: s/2/y + s/3/y
										h2/2/y: h2/3/y: s/3/y / 2 + s/2/y
									]
									; lower border
									within? event/offset (as-pair s/2/x s/2/y + s/3/y) - 0x7 as-pair s/3/x 15 [
										face/draw/9/y: s/3/y: face/extra/2/y + diff2/y 
										if event/shift? [face/draw/8/y: s/2/y: cent/y - (s/3/y / 2)]
										edit2/draw/11/y: s/2/y + s/3/y
										h1/2/y: h1/3/y: s/2/y
										h3/2/y: h3/3/y: s/2/y + s/3/y
										h2/2/y: h2/3/y: s/3/y / 2 + s/2/y
									]
									; left border
									within? event/offset s/2 - 7x0 as-pair 15 s/3/y [
										face/draw/8/x: s/2/x: edit2/draw/8/x: edit2/draw/8/x: df/x
										face/draw/9/x: s/3/x: s/3/x - either event/shift? [2 * diff2/x][diff2/x]
										edit2/draw/11/x: s/2/x + s/3/x
										v1/2/x: v1/3/x: s/2/x
										v3/2/x: v3/3/x: s/2/x + s/3/x
										v2/2/x: v2/3/x: s/3/x / 2 + s/2/x
									]
									; rigth border
									within? event/offset (as-pair s/2/x + s/3/x s/2/y) - 7x0 as-pair 15 s/3/y [
										face/draw/9/x: s/3/x: face/extra/2/x + diff2/x
										if event/shift? [face/draw/8/x: s/2/x: cent/x - (s/3/x / 2)]
										edit2/draw/11/x: s/2/x + s/3/x
										v1/2/x: v1/3/x: s/2/x
										v3/2/x: v3/3/x: s/2/x + s/3/x
										v2/2/x: v2/3/x: s/3/x / 2 + s/2/x
									]
									true [
										face/draw/8: s/2: edit2/draw/8: df
										edit2/draw/11: s/2 + s/3
										h1/2/y: h1/3/y: s/2/y
										h3/2/y: h3/3/y: s/2/y + s/3/y
										h2/2/y: h2/3/y: s/3/y / 2 + s/2/y
										v1/2/x: v1/3/x: s/2/x
										v3/2/x: v3/3/x: s/2/x + s/3/x
										v2/2/x: v2/3/x: s/3/x / 2 + s/2/x
										unless event/shift? [
											forall connected [move-connected pos3diff]
										]
									]
								]
							]
							circle [
								case [
									between dist: sqrt add power first dis: event/offset - s/2 2 dis/y ** 2 s/3 - 7 s/3 + 7 [
										face/draw/9: s/3: either event/ctrl? [round/to dist 10][to-integer dist]
										if attempt [face/draw/8 = face/draw/11] [
											face/draw/12: s/6: s/3 - 3
										]
									]
									true [
										if attempt [face/draw/8 = face/draw/11] [
											face/draw/11: s/5: df
										]
										face/draw/8: s/2: df 
										unless event/shift? [
											forall connected [move-connected pos3diff]
										]
									]
								]
								h1/2/y: h1/3/y: s/2/y - s/3
								h2/2/y: h2/3/y: s/2/y
								h3/2/y: h3/3/y: s/2/y + s/3
								v1/2/x: v1/3/x: s/2/x - s/3
								v2/2/x: v2/3/x: s/2/x
								v3/2/x: v3/3/x: s/2/x + s/3
							]
							comment {
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
							]}
							polygon [
								df2: s/3 - s/2 df3: s/4 - s/2 df4: s/5 - s/2
								face/draw/8: s/2: edit2/draw/8: df 
								face/draw/9: s/3: edit2/draw/11: s/2 + df2
								face/draw/10: s/4: edit2/draw/14: s/2 + df3 
								face/draw/11: s/5: edit2/draw/17: s/2 + df4 
								h1/2/y: h1/3/y: s/2/y
								h2/2/y: h2/3/y: s/3/y
								h3/2/y: h3/3/y: s/4/y
								v1/2/x: v1/3/x: s/5/x
								v2/2/x: v2/3/x: s/2/x
								v3/2/x: v3/3/x: s/3/x
								unless event/shift? [move-connected pos3diff]
							]
							text [
								face/draw/8: s/2: df
								unless event/shift? [move-connected pos3diff]
							]
						]
						pos3: diff;event/offset ;
					]
				]
			]
			on-up [edit3/visible?: no]
			with [
				menu: [
					"fill-pen" fill-pen 
					"pen" pen 
					"line-width" line-width
					"text" text
					"connector" [
						"line" line 
						"spline" spline
						"start-arrow" s-arrow ; TBD
						"end-arrow" e-arrow ; TBD
						"start/end arrow" se-arrow
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
					fill-pen [change skip s either all [find [line spline] s/1 block? s/-1][-12][-5] select-color]
					pen [change skip s either all [find [line spline] s/1 block? s/-1][-10][-3] select-color]
					line-width [
						view/flags [field "2" 30 focus [also change skip s either all [find [line spline] s/1 block? s/-1][-8][-1] face/data unview]][modal popup]
					]
					text [append s compose [fill-pen snow pen black line-width 1 text (text-pos s) (last-text)]]
					spline [edit1/draw/7: 'spline change s 'spline]
					line [edit1/draw/7: 'line change s 'line]
					e-arrow [
						if 'transform <> s/(2 + length? points) [
							ang: (last points) - (first skip tail points -2)
							insert at s 2 + length? points compose [
								transform 0x0 (get-angle ang) 1 1 (s/(1 + length?  points)) [shape [move -10x-5 line 0x0 -10x5]]
							]
							change/part at face/menu/10 7 ["wo end arrow" woe-arrow] 2
							if face/menu/10/6 = 'wos-arrow [
								change/part at face/menu/10 9 ["wo end/start arrows" wose-arrow] 2
							]
						]
					]
					s-arrow [
						if not block? s/-1 [
							ang: s/3 - s/2
							insert s compose [
								transform 0x0 (get-angle ang) 1 1 (s/2) [shape [move 10x-5 line 0x0 10x5]]
							]
							s: skip s 7
							change/part at face/menu/10 5 ["wo start arrow" wos-arrow] 2
							if face/menu/10/8 = 'woe-arrow [
								change/part at face/menu/10 9 ["wo end/start arrows" wose-arrow] 2
							]
						]
					]
					se-arrow [
						case/all [
							'transform <> s/(2 + length? points) [
								ang: (last points) - (first skip tail points -2)
								insert at s 2 + length? points compose [
									transform 0x0 (get-angle ang) 1 1 (s/(1 + length?  points)) [shape [move -10x-5 line 0x0 -10x5]]
								]
							]
							not block? s/-1 [
								ang: s/3 - s/2
								insert s compose [
									transform 0x0 (get-angle ang) 1 1 (s/2) [shape [move 10x-5 line 0x0 10x5]]
								]
								s: skip s 7
							]
						]
						change/part at face/menu/10 5 ["wo start arrow" wos-arrow "wo end arrow" woe-arrow "wo end/start arrows" wose-arrow] 6
					]
					woe-arrow [
						if 'transform = s/(2 + length? points) [
							change/part at s (2 + length? points) [] 7
							change/part at face/menu/10 7 ["end arrow" e-arrow] 2
							if face/menu/10/10 = 'wose-arrow [
								change/part at face/menu/10 9 ["end/start arrows" se-arrow] 2
							]
						]
					]
					wos-arrow [
						if block? s/-1 [
							change/part at s -7 [] 7
							change/part at face/menu/10 5 ["start arrow" s-arrow] 2
							s: skip s -7
							if face/menu/10/10 = 'wose-arrow [
								change/part at face/menu/10 9 ["end/start arrows" se-arrow] 2
							]
						]
					]
					wose-arrow [
						case/all [
							'transform = s/(2 + length? points) [
								change/part at s (2 + length? points) [] 7
							]
							block? s/-1 [
								change/part at s -7 [] 7
								s: skip s -7
							]
						]
						change/part at face/menu/10 5 ["start arrow" s-arrow "end arrow" e-arrow "end/start arrows" se-arrow] 6
					]
					delete [
						clear at edit1/draw 7 
						clear at edit2/draw 7 
						change/part skip s either all [find [line spline] s/1 block? s/-1][-13][-6] [] select-size s 
					]
					back [s: skip follow/part skip s -6 'head select-size s 6]
					backward [
						s: skip follow/part skip s -6 skip (
							found: find/reverse skip s -6 word!
							either found/-3 = 'circle [
								found: skip found -3
							][found]
						) -6 select-size s 6
					]
					; Double circle doesn't work and shapes cannot be `forwarded` to uppermost position due to bug in `move`
					;forward [
					;	sz: select-size s
					;	s: skip follow/part skip s -6 (
					;		probe s2: skip s sz - 6
					;		probe skip s2 select-size skip s2 6
					;	) sz 6
					;]
					forward [
						sz: select-size s
						unless tail? skip s sz - 6 [
							shape: take/part skip s -6 sz
							s: skip insert skip s -6 + select-size s shape 6 - sz
						]
					]
					front [s: skip follow/part skip s -6 'tail sz: select-size s 6]
				]
				'done 
			]
		at 140x10 edit2: edit 
			on-down [
				pos1: pos3: either event/ctrl? [round/to event/offset 10][event/offset]
				parse edit1/draw [some [
					'box set start pair! set end pair! set radius integer! (
						diff-start: sqrt add power first ds: pos1 - start 2 power second ds 2
						diff-end: sqrt add power first ds: pos1 - end 2 power second ds 2
						diff-rad: sqrt add power first ds: pos1 - as-pair s/3/x - s/4 s/2/y + s/4 2 power second ds 2
					)[
						if (diff-start <= 5) (face/extra: [2 8 8]) 
					| 	if (diff-end <= 5) (face/extra: [3 9 11])
					| 	if (diff-rad <= 3) (face/extra: [4 10 14])
					]
				|	'ellipse set start pair! set size pair! (
						diff-start: sqrt add power first ds: pos1 - start 2 power second ds 2
						diff-end: sqrt add power first ds: pos1 - (start + size) 2 power second ds 2
					)[
						if (diff-start <= 5) (face/extra: [2 8 8]) 
					| 	if (diff-end <= 5) (face/extra: [3 9 11])
					]
				|	['line | 'spline | 'polygon] copy points some pair! (
						forall points [
							if 5 >= sqrt add power first ds: pos1 - points/1 2 power second ds 2 [
								i: index? points 
								; register offsets of the point for s, edit1 and edit2
								face/extra: reduce [1 + i    7 + i    7 + (i - 1 * 3 + 1)]
							]
						]
					)
				| 	skip
				]]
				edit3/visible?: yes
			]
			on-over [
				if event/down? [
					pos3: either event/ctrl? [round/to event/offset 10][event/offset]
					switch s/1 [
						box [
							edit2/draw/(face/extra/3): either face/extra/1 = 4 [
								case/all [
									pos3/x > s/3/x [pos3/x: s/3/x]
									pos3/y < s/2/y [pos3/y: s/2/y]
								]
								pos3
							][pos3]
							s/(face/extra/1): edit1/draw/(face/extra/2): either face/extra/1 = 4 [
								df: pos3 - (as-pair s/3/x s/2/y)
								df: max absolute df/x absolute df/y
							][pos3]
							switch face/extra/1 [
								2 [edit2/draw/14/y: s/2/y + s/4]
								3 [edit2/draw/14/x: s/3/x - s/4]
							]
							h1/2/y: h1/3/y: s/2/y
							h3/2/y: h3/3/y: s/3/y
							h2/2/y: h2/3/y: s/3/y - s/2/y / 2 + s/2/y
							v1/2/x: v1/3/x: s/2/x
							v3/2/x: v3/3/x: s/3/x
							v2/2/x: v2/3/x: s/3/x - s/2/x / 2 + s/2/x
						]
						ellipse [
							s/(face/extra/1): edit1/draw/(face/extra/2): either face/extra/1 = 2 [pos3][pos3 - s/2]
							if face/extra/1 = 2 [s/3: edit1/draw/9: face/draw/11 - s/2]
							edit2/draw/(face/extra/3): pos3
							h1/2/y: h1/3/y: s/2/y
							h3/2/y: h3/3/y: s/2/y + s/3/y
							h2/2/y: h2/3/y: s/3/y / 2 + s/2/y
							v1/2/x: v1/3/x: s/2/x
							v3/2/x: v3/3/x: s/2/x + s/3/x
							v2/2/x: v2/3/x: s/3/x / 2 + s/2/x
						]
						polygon [
							dim: pick [x y] odd? face/extra/1 
							s/(face/extra/1)/:dim: edit1/draw/(face/extra/2)/:dim: edit2/draw/(face/extra/3)/:dim: pos3/:dim
							if event/shift? [
								switch face/extra/1 [
									2 [edit1/draw/10/y: s/4/y: face/draw/14/y: s/2/y + (s/3/y - s/2/y * 2)]
									3 [edit1/draw/11/x: s/5/x: face/draw/17/x: s/2/x - s/3/x + s/2/x]; trying different things
									4 [edit1/draw/8/y: s/2/y: face/draw/8/y: s/3/y - s/4/y + s/3/y]
									5 [edit1/draw/9/x: s/3/x: face/draw/11/x: s/2/x + s/2/x - s/5/x]
								]
							]
							h1/2/y: h1/3/y: s/2/y
							h3/2/y: h3/3/y: s/4/y
							h2/2/y: h2/3/y: s/3/y
							v1/2/x: v1/3/x: s/5/x
							v3/2/x: v3/3/x: s/3/x
							v2/2/x: v2/3/x: s/2/x
						]
						line spline [
							; use offsets registered on `down`-event
							s/(face/extra/1): edit1/draw/(face/extra/2): edit2/draw/(face/extra/3): points/(face/extra/1 - 1): pos3
							; check for arrowheads
							case/all [
								; first point
								all [2 = face/extra/1 block? s/-1] [
									; set rotation center (because first point was just moved)
									s/-2: s/2 
									; set offset of second point
									ang: s/3 - s/2
									; compute angle of arrowhead
									s/-5: get-angle ang
								]
								; second point
								all [3 = face/extra/1 block? s/-1] [
									ang: s/3 - s/2
									s/-5: get-angle ang
								]
								; last point
								all [
									face/extra/1 - 1 = length? points
									'transform = s/(len: face/extra/1 + 1)
								][
									; adjust rotation center (because last point was just moved)
									s/(len + 5): s/(face/extra/1)
									ang: s/(face/extra/1) - s/(face/extra/1 - 1)
									s/(len + 2): get-angle ang
								]
								; penultimate point
								all [
									face/extra/1 = length? points
									'transform = s/(len: face/extra/1 + 2)
								][
									ang: s/(face/extra/1 + 1) - s/(face/extra/1)
									s/(len + 2): get-angle ang
								]
							]
						]
					]
				]
			]
			on-up [edit3/visible?: no]
	][resize][
		menu: [
			"File" ["New" new "Open" open "Add" add "Save" save "Save as ..." save-as "Export" export]
			"Edit" ["Clear" clear "Grid off" grid-off ];"Edit grid" edit-grid]
			"Style" [
				;"backdrop" backdrop
				"fill-pen" fill-pen 
				"pen" pen 
				"line-width" line-width
			]
		]
		actors: object [
			on-resizing: func [face event][
				shapes/size/y: face/size/y - 20 
				drawing/size: grid/size: grid/draw/9: canvas/size: edit1/size: edit2/size: edit3/size: face/size - 150x20
				upper/size: face/size - 20
				h1/3/x: h3/3/x: h3/3/x: edit3/size/x
				v1/3/y: v3/3/y: v3/3/y: edit3/size/y
			]
			on-menu: func [face event /local fn][
				switch event/picked [
					new [filename: none clear canvas/draw]
					open [if fn: request-file/filter ["*.dgr"][append clear canvas/draw load filename: fn]]
					add [if fn: request-file/filter ["*.dgr"][append canvas/draw load fn]]
					save [either filename [save filename canvas/draw][if fn: request-file/save [save fn canvas/draw]]]
					save-as [if fn: request-file/save [save fn canvas/draw]]
					export [if fn: request-file/save/filter ["*.png" "*.jpeg" "*.gif"] [save fn draw canvas/size canvas/draw]]
					
					clear [clear canvas/draw clear at edit1/draw 7 clear at edit2/draw 7]
					grid-off [grid/visible?: no change/part find face/menu/4 "Grid off" ["Grid on" grid-on] 2]
					grid-on [grid/visible?: yes change/part find face/menu/4 "Grid on" ["Grid off" grid-off] 2]
					edit-grid []; TBD
					
					;backdrop [drawing/color: select-color]
					fill-pen [color: select-color foreach shape shapes/pane [shape/draw/fill-pen: color]]
					pen [color: select-color foreach shape shapes/pane [shape/draw/pen: color]]
					line-width [
						lw: 1 
						view/flags [field "2" 30 focus [also lw: face/data unview]][modal popup]
						foreach shape shapes/pane [shape/draw/line-width: lw]
					]
				]
			]
		]
	]
	;do-events
]
