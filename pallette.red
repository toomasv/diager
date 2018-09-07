Red []
context [
	color-word: [
		  'Red    | 'white   | 'transparent | 'black  | 'gray    | 'aqua    | 'beige  | 'blue 
		| 'brick  | 'brown   | 'coal        | 'coffee | 'crimson | 'cyan    | 'forest | 'gold 
		| 'green  | 'ivory   | 'khaki       | 'leaf   | 'linen   | 'magenta | 'maroon | 'mint 
		| 'navy   | 'oldrab  | 'olive       | 'orange | 'papaya  | 'pewter  | 'pink   | 'purple 
		| 'reblue | 'rebolor | 'sienna      | 'silver | 'sky     | 'snow    | 'tanned | 'teal 
		| 'violet | 'water   | 'wheat       | 'yello  | 'yellow  | 'glass
	]
	;system/words/transparent: 255.255.255.254 ; ????
	colors: exclude sort extract load help-string tuple! 2 [glass transparent]
	; DideC -->
	pallette: [
		title "Select color" origin 1x1 space 1x1
		style clr: base 15x15 on-down [dn?: true] on-up [
			if dn? [
				either event/shift? [
					append color-bag face/extra
				][
					color: either empty? color-bag [
						face/extra
					][
						append color-bag face/extra
					]
					unview
				]
			]
		]
	]
	x: 0
	color: none
	color-bag: copy []
	dn?: none

	make-pallette: has [j][
		clear color-bag
		foreach j colors [
			append pallette compose/deep [
				clr (j) extra (to-lit-word j)
			]
			if (x: x + 1) % 9 = 0 [append pallette 'return]
		]
	]
	; <-- DideC

	make-pallette
	color: black
	set 'select-color does [clear color-bag view/flags pallette [modal popup] color]
]
