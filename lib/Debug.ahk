m(x*) {
	for a, b in x
		text .= (IsObject(b)?pa(b):b) "`n"
	MsgBox, 0, msgbox, % text
}

pa(array, depth=5, indentLevel:="   ") {
	try {
		for k,v in Array {
			lst.= indentLevel "[" k "]"
			if (IsObject(v) && depth>1)
				lst.="`n" pa(v, depth-1, indentLevel . "    ")
			else
				lst.=" -> " v
			lst.="`n"
		} return rtrim(lst, "`r`n `t")	
	} return
}

QPC(R := 0) { ; By SKAN, http://goo.gl/nf7O4G, CD:01/Sep/2014 | MD:01/Sep/2014
	static P := 0, F := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P", F)
	return !DllCall("QueryPerformanceCounter", "Int64P" , Q) + (R ? (P := Q) / F : (Q - P) / F)
}

pas(array, depth=5) {
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