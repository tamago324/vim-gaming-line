scriptencoding utf-8

let s:Color = vital#gamingline#import('Color')

let s:counter = 0
let s:colors = []
" complementary color
let s:comp_colors = []

let s:timer = v:null

function! s:get(name) abort
  return get(g:, 'gaming_'..a:name)
endfunction

function! s:countup() abort
  let s:counter = (s:counter + 1) % (s:get('num_colors') * 2)
endfunction

function! s:complementary_color(color) abort
  let l:colors = map(a:color.as_hsl(), {_,x -> float2nr(ceil(x))})
  let [H, S, L] = l:colors
  if H < 180
    let l:hue = H + 180
  else
    let l:hue = H - 180
  endif
  return s:Color.hsl(l:hue, S, L)
endfunction

function! s:set_color(_) abort
  call s:countup()
  let l:cnt = s:counter - 1

  let l:fg = printf('guifg=%s', s:colors[l:cnt])
  let l:bg = printf('guibg=%s', s:comp_colors[l:cnt])

  exec printf('hi! StatusLine %s %s', l:fg, l:bg)
endfunction

function! s:next() abort
  " When the limit is reached, reset it.
  let l:color_number = s:counter > s:get('num_colors') ? s:counter - s:get('num_colors') : s:counter
  let l:hue = (l:color_number / floor(s:get('num_colors'))) * 360.0
  let l:color = s:Color.hsl(l:hue, s:get('saturation'), s:get('lightness'))
  call s:countup()
  return l:color
endfunction

function! s:reset() abort
  let s:colors = []
  let s:comp_colors = []
  let s:counter = 0
endfunction

function! s:setup() abort
  call s:reset()
  let l:color = s:next()
  for i in range((s:get('num_colors') * 2) - 1)
    call add(s:colors, l:color.as_rgb_hex())
    call add(s:comp_colors, s:complementary_color(l:color).as_rgb_hex())
    let l:color = s:next()
  endfor
endfunction

function! gamingline#enable() abort
  if !(has('termguicolors') && &termguicolors) && !has('gui_running') && &t_Co != 256
    return
  endif

  call s:setup()
  call gamingline#disable()

  let s:save_color = {}
  let s:save_color.guifg = synIDattr(synIDtrans(hlID('StatusLine')), 'fg#') 
  let s:save_color.guibg = synIDattr(synIDtrans(hlID('StatusLine')), 'bg#') 
  let s:timer = timer_start(s:get('interval'), function('s:set_color'), {'repeat': -1})
endfunction

function! gamingline#disable() abort
  if !s:timer
    return
  endif

  let l:guifg = printf('guifg=%s', empty(s:save_color.guifg) ? 'NONE' : s:save_color.guifg)
  let l:guibg = printf('guibg=%s', empty(s:save_color.guibg) ? 'NONE' : s:save_color.guibg)
  exec printf('hi! StatusLine %s %s', l:guifg, l:guibg)
  unlet s:save_color

  call timer_stop(s:timer)
  let s:timer = v:null
endfunction
