" Vim autoloaded utility functions mainly for use in my own scripts
" Last Change:	2016-02-15
" Maintainer:	Benct Philip Jonsson <bpjonsson@gmail.com>
" License:	    MIT license

"{{{1
let s:list = [ '\v([^01]*%(1.[^01]*)*)%([0]|$)',  
            \'\=add(list, bpj#util#cleanstr(submatch(2),''\v1(.)''))',
            \[',', '\\', '1']]
let s:dict = [ '\v([^012]*%(2.[^012]*)*)[1]([^012]*%(2.[^012]*)*)%([0]|$)',
            \ '\=string(extend(dict,{bpj#util#cleanstr(submatch(3),''\v(.)''): bpj#util#cleanstr(submatch(4),''\v2(.)'')}))',
            \[',', ':', '\\', '1', '2']]
"}}}

" remove leading and trailing whitespace from string
fun! bpj#util#trim(string) "{{{1
    return substitute(a:string,'\v^\s+|\s+$','','g')
endfun " 1}}}

" remove leading whitespace from string
fun! bpj#util#ltrim(string) "{{{1
    return substitute(a:string,'\v^\s+','','')
endfun " 1}}}

" remove trailing whitespace from string
fun! bpj#util#rtrim(string) "{{{1
    return substitute(a:string,'\v\s+$','','')
endfun " 1}}}

" bpj#util#unescape({string}, [{pattern}]
" replace all instances of {pattern} with \1
" {pattern} defaults to '\v\\(.)'
fun! bpj#util#unescape(string, ...) "{{{1
    let pattern = a:0 ? a:1 : '\v\\(.)'
    return substitute(a:string,pattern,'\1','g')
endfun " 1}}}

" call #unescape() on the result of #trim(string)
" arguments as for #unescape()
fun! bpj#util#cleanstr(string, ...) "{{{1
    let pattern = a:0 ? a:1 : '\v\\(.)'
    return bpj#util#unescape(bpj#util#trim(a:string),pattern)
endfun " 1}}}


" return a List with all matches of pattern in string
fun! bpj#util#findall(string,pattern) "{{{1
    let ret = []
    call substitute(a:string, a:pattern, '\=add(ret, submatch(0))', 'g')
    return ret
endfun " 1}}}

" like #findall but call matchlist(v:val, pattern) on the items in the list
" thus returns a list of list with matches and submatches
fun! bpj#util#matchall(string,pattern) "{{{1
    let ret = []
    call substitute(a:string, a:pattern, '\=add(ret, matchlist(submatch(0), a:pattern))', 'g')
    " let ret = bpj#util#findall(a:string, a:pattern)
    " let mapfunc = 'matchlist(v:val,a:pattern)'
    " call map(ret, mapfunc)
    return ret
endfun " 1}}}

" return a list with the unique values in list
fun! bpj#util#uniq(list) "{{{1
    return filter(copy(a:list), 'index(a:list, v:val, v:key+1)==-1')
endfun " 1}}}

" return a list with comma-separated substrings in string
" commas in items may be escaped with backslashes
" because #cleanstr is called on each item
" and hence any backslash not escaped by another backslash will disappear!
" If there are more than 1 argument:
"   the second argument is used as separator instead of comma
"   the third argument is used as escape char instead of backslash
"   so #splitlist(s, ';', '!') would split a semicolon-separated, bang-escaped list
"   Note that the extra arguments must be single characters
"   (but [, ] and \ must be backslash-escaped)!
"   Don't pass any more arguments than these!
fun! bpj#util#splitlist(string,...) "{{{1
    let [pattern, expr, default] = s:list
    let pattern = substitute(pattern,'\d','\=get(a:000, submatch(0), default[submatch(0)])','g')
    let expr = substitute(expr,'\d','\=get(a:000, submatch(0), default[submatch(0)])','g')
    let list = []
    call substitute(a:string, pattern, expr, 'g')
    return list
endfun " 1}}}

" like #splitlist but returns a dict with pairs separated by colons
" If there are more than 1 argument:
"   the second argument is used as item separator instead of comma
"   the third argument is used as key--value separator instead of comma
"   the fourth argument is used as escape char instead of backslash
"   so #splitlist(s, ';', '.', '!') would 
"   split a semicolon-separated, bang-escaped list,
"   with keys and values separated by periods
"   Note that the extra arguments must be single characters
"   (but [, ] and \ must be backslash-escaped)!
"   Don't pass any more arguments than these!
fun! bpj#util#splitdict(string,...) "{{{1
    let [pattern, expr, default] = s:dict
    let pattern = substitute(pattern,'\d','\=get(a:000, submatch(0), default[submatch(0)])','g')
    let expr = substitute(expr,'\d','\=get(a:000, submatch(0), default[submatch(0)])','g')
    let dict = {}
    call substitute(a:string, pattern, expr, 'g')
    return dict
endfun " 1}}}

" vim: set fdm=marker et sts=4:
