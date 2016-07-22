" Vim autoloaded utility functions mainly for use in my own scripts
" Last Change:	2016-07-22
" Maintainer:	Benct Philip Jonsson <bpjonsson@gmail.com>
" License:	    MIT license

" Changes:
"   2016-07-22:
"       -   Renamed #splitlist() to #str2list() 
"           and     #splitdict() to #str2dict()
"           The old names remain as 'aliases' but are deprecated.
"       -   Added #dictsplit() which emulates the builtin split()
"           but returns a dictionary of substring pairs.

"{{{1
let s:split_list = [ '\v([^01]*%(1.[^01]*)*)%([0]|$)',  
            \'\=add(list, bpj#util#cleanstr(submatch(2),''\v1(.)''))',
            \[',', '\\', '1']]

let s:split_dict = [ '\v([^012]*%(2.[^012]*)*)[1]([^012]*%(2.[^012]*)*)%([0]|$)',
            \ '\=string(extend(dict,{bpj#util#cleanstr(submatch(3),''\v(.)''): bpj#util#cleanstr(submatch(4),''\v2(.)'')}))',
            \[',', ':', '\\', '1', '2']]
"}}}

let s:dict_split = [
            \'\v6\m0\v7%(\m2\v6\m1\v7)?',
            \'\=string(extend(dict,{bpj#util#unescape(submatch(arg[4])): bpj#util#unescape(submatch(arg[5]))}))',
            \['\v%(\\@!\S|\\.)+', '', '\v\s+', 0, 1, 2, '(', ')'],
            \]

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
fun! s:do_str2list(string,arg) "{{{1
    let [pattern, expr, default] = s:split_list
    let pattern = substitute(pattern,'\d','\=get(a:arg, submatch(0), default[submatch(0)])','g')
    let expr = substitute(expr,'\d','\=get(a:arg, submatch(0), default[submatch(0)])','g')
    let list = []
    call substitute(a:string, pattern, expr, 'g')
    return list
endfun 
fun! bpj#util#str2list(string,...)
    return s:do_str2list(a:string, copy(a:000))
endfun
fun! bpj#util#splitlist(string,...)
    return s:do_str2list(a:string, copy(a:000))
endfun " 1}}}

" bpj#util#str2dict
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
fun! s:do_str2dict(string,arg) "{{{1
    let [pattern, expr, default] = s:split_dict
    let pattern = substitute(pattern,'\d','\=get(a:arg, submatch(0), default[submatch(0)])','g')
    let expr = substitute(expr,'\d','\=get(a:arg, submatch(0), default[submatch(0)])','g')
    let dict = {}
    call substitute(a:string, pattern, expr, 'g')
    return dict
endfun
fun! bpj#util#str2dict(string,...)
    return s:do_str2dict(a:string, copy(a:000))
endfun
fun! bpj#util#splitdict(string,...)
    return s:do_str2dict(a:string, copy(a:000))
endfun " 1}}}


" bpj#util#dictsplit({stringish}[,{key_pat}[,{val_pat}[,{sep_pat}[,{no_parens}[,{k}[,{v}]]]]]])
"       
" More or less like the builtin split(), although it uses a
" match against a pattern equivalent to
"
"   '\({key_pat}\){sep_pat}\({val_pat}\)'
"
" and returns a dict of submatch(1): submatch(2) pairs,
" with the submatches run through #unescape().
" There is as yet no support for a custom escape character!
"
" The optional arguments are:
"
"   1.  {key_pat} 
"           Type:       pattern
"           Default:    '\%([\\]\@!\S\|\\.\)\+'
"   2.  {val_pat}
"           Type:       pattern
"           Default:    same as {key_pat}.
"   3.  {sep_pat}
"           Type:       pattern
"           Default:    '\s\+'
"   4.  {no_parens}
"           Type:       (boolean)
"           Default:    0 (false)
"           A boolean indicating whether the automatic capturing 
"           parentheses around {key_pat} and {val_pat}) should be
"           omitted from the assembled pattern. If true it is up 
"           to you to include captures in your patterns!
"   5.  {k}
"           Type:       integer
"           Default:    1
"           The number of the submatch() *of the assembled pattern*
"           which should be used as the dict key.
"           You pretty much always want to set {no_parens} to true
"           if you set this!
"   6.  {v}
"           Type:       integer
"           Default:    1
"           The number of the submatch() *of the assembled pattern*
"           which should be used as the dict value.
"           You pretty much always want to set {no_parens} to true
"           if you set this!
"
" The patterns are considered unset if len({pat}) returns false.
" The others are considered unset only if omitted.
"
" A leading \m is assumed for the patterns. You can use any of
" \v \m \M \V inside them, though \m would be redundant.
"
fun! bpj#util#dictsplit(string, ...)
    let arg = range(0,7)
    let [ pattern, expr, default ] = s:dict_split
    for n in range(0,2)
        let val = get(a:000, n, '')
        let arg[n] = len(val) ? val : default[n]
    endfor
    let arg[1] = len(arg[1]) ? arg[1] : arg[0]
    for n in range(3,5)
        let arg[n] = get(a:000, n, default[n])
    endfor
    for n in range(6,7)
        let arg[n] = arg[3] ? "" : default[n]
    endfor
    let pattern = substitute(pattern, '\d', '\=arg[submatch(0)]', 'g')
    " let [b:arg, b:pattern ] = [ arg, pattern ]
    let dict={}
    call substitute(a:string, pattern, expr, 'g')
    return dict
endfun


" vim: set fdm=marker et sts=4:
