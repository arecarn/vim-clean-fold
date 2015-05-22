""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Original Author: Ryan Carney
" License: WTFPL
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{1
let s:save_cpo = &cpo
set cpo&vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}1

" VISUALS {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PUBLIC FUNCTIONS {{{2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! clean_fold#fold_text(foldchar) "{{{3
    "TODO handle wide chars with visual col
    let line = getline(v:foldstart)

    if &foldmethod == 'marker'
        let foldmarker = substitute(&foldmarker, '\zs,.*', '', '')
        let cmt = substitute(&commentstring, '\zs%s.*', '', '')
        let line = substitute(line, '\s*'. '\('.cmt.'\)\?'. '\s*'.foldmarker.'\d*\s*', '', 'g')
    endif

    let lines_count = v:foldend - v:foldstart + 1
    let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
    let foldtextstart = strpart(line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(a:foldchar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn

    return foldtextstart . repeat(a:foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction "}}}3

function! clean_fold#fold_text_minimal() "{{{3
    "TODO handle wide chars with visual col
    let line = getline(v:foldstart)

    " don't include fold markers in fold text it's ugly :)
    if &foldmethod == 'marker'
        let foldmarker = substitute(&foldmarker, '\zs,.*', '', '')
        let cmt = substitute(&commentstring, '\zs%s.*', '', '')
        let line = substitute(line, '\s*'. '\('.cmt.'\)\?'. '\s*'.foldmarker.'\d*\s*', '', 'g')
    endif

    " Foldtext ignores tabstop and shows tabs as one space,
    " so convert tabs to 'tabstop' spaces so text lines up
    let ts = repeat(' ',&tabstop)
    let line = substitute(line, '\t', ts, 'g')

    return line . repeat(' ', winwidth(0)-len(line))
endfunction "}}}3

function! clean_fold#fold_expr(lnum) "{{{3
    if getline(a:lnum) =~? '\v^\s*$'
        return '-1'
    endif

    let this_indent = s:indent_level(a:lnum)
    let next_indent = s:indent_level(s:next_non_blank_line(a:lnum))

    if next_indent == this_indent
        return this_indent
    elseif next_indent < this_indent
        return this_indent
    elseif next_indent > this_indent
        return '>' . next_indent
    endif
endfunction "}}}3
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}2

" PRIVATE FUNCTIONS {{{2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:indent_level(lnum) "{{{3
    return indent(a:lnum) / &shiftwidth
endfunction "}}}3

function! s:next_non_blank_line(lnum) "{{{3
    let numlines = line('$')
    let current = a:lnum + 1

    while current <= numlines
        if getline(current) =~? '\v\S'
            return current
        endif

        let current += 1
    endwhile

    return -2
endfunction "}}}3
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{1
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:foldmethod=marker
" vim:textwidth=78
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}1
