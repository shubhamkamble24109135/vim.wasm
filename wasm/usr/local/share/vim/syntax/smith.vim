if exists("b:current_syntax")
finish
endif
syn case ignore
syn match smithComment ";.*$"
syn match smithNumber		"\<[+-]*[0-9]\d*\>"
syn match smithRegister		"R[\[]*[0-9]*[\]]*"
syn match smithKeyword	"COR\|MOV\|MUL\|NOT\|STOP\|SUB\|NOP\|BLA\|REP"
syn region smithString		start=+"+  skip=+\\\\\|\\"+  end=+"+
syn case match
hi def link smithRegister	Identifier
hi def link smithKeyword	Keyword
hi def link smithComment Comment
hi def link smithString String
hi def link smithNumber	Number
let b:current_syntax = "smith"
