let s:first_time = 1
let s:replacement = ''
func! ReplaceIt()
    if s:first_time
        let s:first_time = 0
        return '%[['.s:replacement.':.+]]'
    else
        return '%[['.s:replacement.']]'
    endif
endfunc

let s:FUNC_TO_PREFIX = { "create_undef_task_queue": "UDTASK"
            \ , "create_buffer_view": "BUFFV"
            \ , "create_buffer": "BUFF"
            \ , "create_index_array": "SHAPE"
            \ }

func! ReplaceWord()
    let tok = expand('<cword>')
    let line = getline('.')

    let prefix = ''
    for [funcname, pre] in items(s:FUNC_TO_PREFIX)
        if line =~ funcname
            let prefix = pre
            break
        endif
    endfor
    let default = tok
    if prefix != ''
        let lhs = matchstr(getline('.'), '^\s\+%\zs\d\+\ze = .*')
        let default = prefix . '_' . lhs
    elseif tok =~ '^[0-9]\+$'
        let default = 'val' . tok
    else
        let default = tok
    endif
    let repl = input('Enter replacement for "'.tok.'": ', toupper(default))

    let s:first_time = 1
    let s:replacement = repl
    exec '% s/%\<'.tok.'\>/\=ReplaceIt()/g'
endfunc
