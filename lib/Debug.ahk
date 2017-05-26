m(x*) {
	for a, b in x
		text .= (IsObject(b)?pa(b):b) "`n"
	MsgBox, 0, msgbox, % text
}

pa(array, depth=5, indentLevel:="   ") { ; tidbit, this has saved my life
	try {
		for k,v in Array {
			lst.= indentLevel "[" k "]"
			if (IsObject(v) && depth>1)
				lst.="`n" pa(v, depth-1, indentLevel . "    ")
			else
				lst.=" => " v
			lst.="`n"
		} return rtrim(lst, "`r`n `t")	
	} return
}

pas(array, depth=5) { ; tidbit, this has saved my life
	try {
		lst := "{"
		for k,v in Array {
			lst.= k ": "
			if (IsObject(v) && depth>1)
				lst.= A_ThisFunc.(v, depth-1)
			else
				lst.=v
			lst.=", "
		} return rtrim(lst, ", ") "}"	
	} return
}