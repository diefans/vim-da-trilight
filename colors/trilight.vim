hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "trilight"


if !has("gui_running") && &t_Co != 88 && &t_Co != 256
	finish
endif

" function taken from wombat256
" functions {{{
" returns an approximate grey index for the given grey level
fun <SID>grey_number(x)
	if &t_Co == 88
		if a:x < 23
			return 0
		elseif a:x < 69
			return 1
		elseif a:x < 103
			return 2
		elseif a:x < 127
			return 3
		elseif a:x < 150
			return 4
		elseif a:x < 173
			return 5
		elseif a:x < 196
			return 6
		elseif a:x < 219
			return 7
		elseif a:x < 243
			return 8
		else
			return 9
		endif
	else
		if a:x < 14
			return 0
		else
			let l:n = (a:x - 8) / 10
			let l:m = (a:x - 8) % 10
			if l:m < 5
				return l:n
			else
				return l:n + 1
			endif
		endif
	endif
endfun

" returns the actual grey level represented by the grey index
fun <SID>grey_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 46
		elseif a:n == 2
			return 92
		elseif a:n == 3
			return 115
		elseif a:n == 4
			return 139
		elseif a:n == 5
			return 162
		elseif a:n == 6
			return 185
		elseif a:n == 7
			return 208
		elseif a:n == 8
			return 231
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 8 + (a:n * 10)
		endif
	endif
endfun

" returns the palette index for the given grey index
fun <SID>grey_color(n)
	if &t_Co == 88
		if a:n == 0
			return 16
		elseif a:n == 9
			return 79
		else
			return 79 + a:n
		endif
	else
		if a:n == 0
			return 16
		elseif a:n == 25
			return 231
		else
			return 231 + a:n
		endif
	endif
endfun

" returns an approximate color index for the given color level
fun <SID>rgb_number(x)
	if &t_Co == 88
		if a:x < 69
			return 0
		elseif a:x < 172
			return 1
		elseif a:x < 230
			return 2
		else
			return 3
		endif
	else
		if a:x < 75
			return 0
		else
			let l:n = (a:x - 55) / 40
			let l:m = (a:x - 55) % 40
			if l:m < 20
				return l:n
			else
				return l:n + 1
			endif
		endif
	endif
endfun

" returns the actual color level for the given color index
fun <SID>rgb_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 139
		elseif a:n == 2
			return 205
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 55 + (a:n * 40)
		endif
	endif
endfun

" returns the palette index for the given R/G/B color indices
fun <SID>rgb_color(x, y, z)
	if &t_Co == 88
		return 16 + (a:x * 16) + (a:y * 4) + a:z
	else
		return 16 + (a:x * 36) + (a:y * 6) + a:z
	endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun <SID>color(r, g, b)
	" get the closest grey
	let l:gx = <SID>grey_number(a:r)
	let l:gy = <SID>grey_number(a:g)
	let l:gz = <SID>grey_number(a:b)

	" get the closest color
	let l:x = <SID>rgb_number(a:r)
	let l:y = <SID>rgb_number(a:g)
	let l:z = <SID>rgb_number(a:b)

	if l:gx == l:gy && l:gy == l:gz
		" there are two possibilities
		let l:dgr = <SID>grey_level(l:gx) - a:r
		let l:dgg = <SID>grey_level(l:gy) - a:g
		let l:dgb = <SID>grey_level(l:gz) - a:b
		let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
		let l:dr = <SID>rgb_level(l:gx) - a:r
		let l:dg = <SID>rgb_level(l:gy) - a:g
		let l:db = <SID>rgb_level(l:gz) - a:b
		let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
		if l:dgrey < l:drgb
			" use the grey
			return <SID>grey_color(l:gx)
		else
			" use the color
			return <SID>rgb_color(l:x, l:y, l:z)
		endif
	else
		" only one possibility
		return <SID>rgb_color(l:x, l:y, l:z)
	endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun <SID>rgb(rgb)
	let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
	let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
	let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
	return <SID>color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun <SID>X(group, fg, bg, attr)
	if a:fg != ""
		exec "hi ".a:group." guifg=#".a:fg." ctermfg=".<SID>rgb(a:fg)
	endif
	if a:bg != ""
		exec "hi ".a:group." guibg=#".a:bg." ctermbg=".<SID>rgb(a:bg)
	endif
	if a:attr != ""
        " urxvt is capable of italics - so I leave that
        "exec "hi ".a:group." gui=".a:attr." cterm=none"
        exec "hi ".a:group." gui=".a:attr." cterm=".a:attr
	endif
endfun
" }}}

let s:grey_blue         = '8a9597'
let s:light_grey_blue   = 'a0a8b0'
let s:dark_grey_blue    = '34383c'
let s:mid_grey_blue     = '64686c'
let s:beige             = 'ceb67f'
let s:light_orange      = 'ebc471'
let s:yellow            = 'e3d796'
let s:violet            = 'a999ac'
let s:green             = 'a2a96f'
let s:light_green       = 'c2c98f'
let s:red               = 'd08356'
let s:cyan              = '74dad9'
let s:darkgrey          = '1a1a1a'
let s:contrast_bg       = '120707'
let s:contrast_bg_blue  = '120727'
let s:contrast_bg_green = '122707'
let s:contrast_bg_red   = '320707'
let s:contrast_bg_yellow = '322707'
let s:grey              = '303030'
let s:light_grey        = '605958'
let s:white             = 'fffedc'
" extras
let s:blue              = '112233'

let s:cursor_column     = '1b1d1f'
let s:color_column      = '101922'
let s:cursor            = 'b0d0f0'



if version >= 700
  "Tabpages
  "hi TabLine guifg=#a09998 guibg=#202020 gui=underline
  "hi TabLineFill guifg=#a09998 guibg=#202020 gui=underline
  "hi TabLineSel guifg=#a09998 guibg=#404850 gui=underline

endif

"hi Visual guibg=#404040

"highlight ColorColumn ctermbg=112233 guibg=#112233
"highlight MarginBorder ctermbg=112233 guibg=#112233



" IDE colors
call <SID>X("Normal",           s:white,            s:contrast_bg,      "none")
call <SID>X("Cursor",           "",                 s:cursor,           "underline")
if &diff
  " Don't change the background color in diff mode
    call <SID>X("CursorLine",   "",             "none",                 "underline")
else
    call <SID>X("CursorLine",   "",             s:cursor_column,    "none")
endif
call <SID>X("CursorColumn",     "",                 s:cursor_column,    "none")
call <SID>X("ColorColumn",      "",                 s:color_column,     "none")
call <SID>X("MarginBorder",     "",                 s:color_column,     "none")
			"CursorIM
			"Question
			"IncSearch
call <SID>X("Search",		    "444444",           "af87d7",	        "bold")
call <SID>X("MatchParen",	    s:white,	        "80a090",       	"bold")
call <SID>X("SpecialKey",       s:grey,             s:contrast_bg,      "none")
call <SID>X("Visual",		    "ecee90",	        "597418",	        "none")
call <SID>X("LineNr",           s:mid_grey_blue,    s:dark_grey_blue,   "none")
call <SID>X("Folded",           s:grey_blue,        s:dark_grey_blue,   "none")
call <SID>X("FoldColumn",       s:grey_blue,        s:dark_grey_blue,   "none")
call <SID>X("Title",            s:red,              s:contrast_bg,      "bold")
call <SID>X("VertSplit",        s:grey,             s:grey,             "none")
call <SID>X("StatusLine",       s:white,            s:grey,             "italic,underline")
call <SID>X("StatusLineNC",     s:light_grey,       s:grey,             "italic,underline")
			"Scrollbar
			"Tooltip
			"Menu
			"WildMenu

" P-Menu (auto-completion)
call <SID>X("Pmenu",            "605958",           "303030",           "underline")
call <SID>X("PmenuSel",         "a09998",           "404040",           "underline")
            "PmenuSbar
            "PmenuThumb
			"ErrorMsg
			"ModeMsg
			"MoreMsg
call <SID>X("Directory",        "dad085",           "",                 "none")
call <SID>X("DiffAdd",          s:white,                 s:contrast_bg_green,                 "none")
call <SID>X("DiffChange",          s:white,                 s:contrast_bg_yellow,                 "none")
call <SID>X("DiffDelete",          s:white,                 s:contrast_bg_red,                 "none")
call <SID>X("DiffText",          s:white,                 s:contrast_bg_blue,                 "none")
"call <SID>X("DiffChange",          "",                 "",                 "")
"call <SID>X("DiffDelete",          "",                 "",                 "")
"call <SID>X("DiffText",          "",                 "",                 "")

call <SID>X("NonText",          s:light_grey,       s:grey,             "none")
call <SID>X("SignColumn",       s:grey_blue,        s:dark_grey_blue,   "none")


" Syntax
call <SID>X("Number",		    "e5786d",	        "",			        "none")
call <SID>X("Constant",         s:red,              s:contrast_bg,      "none")
call <SID>X("Label",            s:red,              s:contrast_bg,      "none")
call <SID>X("String",           s:green,            s:contrast_bg,      "none")
call <SID>X("Comment",          s:mid_grey_blue,    s:contrast_bg,      "italic")
call <SID>X("Identifier",       s:grey_blue,        s:contrast_bg,      "none")
call <SID>X("Keyword",		    "87afff",	        "",			        "none")
call <SID>X("Function",         s:violet,           s:contrast_bg,      "none")
call <SID>X("PreProc",          s:grey_blue,        s:contrast_bg,      "none")
call <SID>X("Type",             s:yellow,           s:contrast_bg,      "italic")
call <SID>X("Special",          s:light_green,      s:contrast_bg,      "none")

call <SID>X("TODO",             s:grey_blue,        s:contrast_bg,      "italic,bold")
call <SID>X("pythonSphinx",     s:grey_blue,        s:contrast_bg,      "bold")

call <SID>X("Statement",        s:beige,            s:contrast_bg,      "bold")
call <SID>X("Conditional",      s:beige,            s:contrast_bg,      "none")
call <SID>X("Repeat",           s:beige,            s:contrast_bg,      "none")
call <SID>X("Structure",        s:beige,            s:contrast_bg,      "italic")
call <SID>X("Entity",           s:beige,            s:contrast_bg,      "underline")

call <SID>X("Operator",         s:light_orange,     s:contrast_bg,      "none")
call <SID>X("Underlined",       s:white,            s:contrast_bg,      "underline")
call <SID>X("Error",            "",                 "602020",           "none")

" special needs
" markdown


"hi Identifier guifg=#7587a6
" Type d: 'class'
"hi Structure guifg=#9B859D gui=underline
"hi Function guifg=#dad085
" dylan: method, library, ... d: if, return, ...
"hi Statement guifg=#7187a1 gui=NONE
" Keywords  d: import, module...
"hi PreProc guifg=#8fbfdc
"gui=underline
"hi Operator guifg=#a07020
"hi Repeat guifg=#906040 gui=underline
"hi Type guifg=#708090

"hi Type guifg=#f9ee98 gui=NONE

"hi NonText guifg=#808080 guibg=#303030

"hi Macro guifg=#a0b0c0 gui=underline

"Tabs, trailing spaces, etc (lcs)
"hi SpecialKey guifg=#808080 guibg=#343434

"hi TooLong guibg=#ff0000 guifg=#f8f8f8




" delete functions {{{
delf <SID>X
delf <SID>rgb
delf <SID>color
delf <SID>rgb_color
delf <SID>rgb_level
delf <SID>rgb_number
delf <SID>grey_color
delf <SID>grey_level
delf <SID>grey_number
" }}}

 """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" margin
" autocmd BufWinEnter * call matchadd('MarginBorder', '\%>'.&l:textwidth.'v.\+', -1)
"

set background=dark
