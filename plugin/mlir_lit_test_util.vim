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
    if prefix != ''
        let lhs = matchstr(getline('.'), '^\s\+%\zs\d\+\ze = .*')
        let repl = prefix . '_' . lhs
    else
        let repl = input('Enter replacement for "'.tok.'": ', toupper(tok))
    endif

    let s:first_time = 1
    let s:replacement = repl
    exec '% s/%\<'.tok.'\>/\=ReplaceIt()/g'
endfunc
