// org-mode grammar to parse a whole book
// ======================================

{
    const headings = {1: "section", 2: "subsection", 3: "subsubsection", 4: "paragraph"}
    var environments = []
}

File = content:(Heading / Command / Ruler / InterpretedText)* eof:EOF { return content.join("") + eof }

Heading = start:$[*]+ _ title:SingleLineInterpretedText* newline { return "\\" + headings[start.length] + "{" + title.join("") + "}\n" }
Command = "#+" command:$[^\:\n]+ separator:":"? _ optargument:$("[" [^\]]* "]")? _ argument:$[^\n]* newline {
    if (command.toLowerCase() == "begin")
	environments.push(argument)
    if (command.toLowerCase() == "end") {
	let theenv = environments.pop()
	if (theenv != argument)
	    error("end command for environment " + argument + " not matching begin environment of type " + theenv)
    }
    return "\\" + command.toLowerCase() + (separator == null ? "" : optargument + "{" + argument + "}") + "\n"
}
Ruler = "-----" $[-]* newline { return "\\vskip 1.0em\\hrule\\vskip 1.0em\n" }
SingleLineInterpretedText = content:(MathText / BoldText / ItalicText / UnderlinedText / VerbatimText / CodeText / StrikeTroughText / [^*/_=~+\n]) { return content }
InterpretedText = content:(MathText / BoldText / ItalicText / UnderlinedText / VerbatimText / CodeText / StrikeTroughText / [^*/_=~+]) { return content }
MathText = text:$("$" ("$" text:$[^$]+ "$" / text:$[^$]+) "$") { return text }
BoldText = "*" text:$[^*]+ "*" { return "\\textbf{" + text + "}" }
ItalicText = "/" text:$[^/]+ "/" { return "\\textit{" + text + "}" }
UnderlinedText = "_" text:$[^_]+ "_" { return "\\underline{" + text + "}" }
VerbatimText = "=" text:$[^=]+ "=" { return "\\verb{" + text + "}" }
CodeText = "~" text:$[^~]+ "~" { return "\\code{" + text + "}" }
StrikeTroughText = "+" text:$[^+]+ "+" { return "\\cancel{" + text + "}" }
EOF = ! . { return environments.map(env => "\\end{" + env + "}\n").join("") }
LineText = _ text:$[^\n]* newline { return text + "\n" }

_ "whitespace" = [ ]*
newline "\n" = [\n]
