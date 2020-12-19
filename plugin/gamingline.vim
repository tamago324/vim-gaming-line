scriptencoding utf-8

let g:gaming_num_colors = get(g:, 'gaming_num_colors', 1024)

" HLS: https://ja.wikipedia.org/wiki/HLS%E8%89%B2%E7%A9%BA%E9%96%93

" 彩度: 0 ~ 100
let g:gaming_saturation = get(g:, 'gaming_saturation', 100)
" 輝度: 0 ~ 100
let g:gaming_lightness = get(g:, 'gaming_lightness', 50)

let g:gaming_interval = get(g:, 'gaming_interval', 10)

command! GamingLineEnable call gamingline#enable()
command! GamingLineDisable call gamingline#disable()
