" Vim autoloaded utility functions mainly for use in my own scripts
" Last Change:	2016-02-15
" Maintainer:	Benct Philip Jonsson <bpjonsson@gmail.com>
" License:	    MIT license

"{{{1
let s:list = [ '\v([^,\\]*%(\\.[^,\\]*)*)%(\,|$)',  '\=add(list, bpj#util#cleanstr(submatch(1)))' ]
let s:dict = [ '\v([^:,\\]*%(\\.[^:,\\]*)*)\:([^:,\\]*%(\\.[^:,\\]*)*)%(\,|$)',
            \ '\=extend(dict,{bpj#util#cleanstr(submatch(1)),bpj#util#cleanstr(submatch(2))})' ]
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
    return filter(copy(a:list), 'index(list, v:val, v:key+1)==-1')
endfun " 1}}}

" return a list with comma-separated substrings in string
" commas in items may be escaped with backslashes
" because #cleanstr is called on each item
" and hence any backslash not escaped by another backslash will disappear!
fun! bpj#util#splitlist(string) "{{{1
    let list = []
    call substitute(a:string, s:list[0], s:list[1], 'g')
    return list
endfun " 1}}}

" like #splitlist but returns a dict with pairs separated by :
fun! bpj#util#splitdict(string) "{{{1
    let dict = {}
    call substitute(a:string, s:dict[0], s:dict[1], 'g')
    return dict
endfun " 1}}}

" vim: set fdm=marker et sts=4:
