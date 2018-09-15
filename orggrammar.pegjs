// org-mode grammar to parse a whole book
// ======================================

{
    const headings = {1: "section", 2: "subsection", 3: "subsubsection", 4: "paragraph"}
    var environments = []
}

File = content:(Heading / Command / Text)* eof:EOF { return content.join("") + eof }

Heading = start:$[*]+ _ title:$[^\n]+ newline { return "\\" + headings[start.length] + "{" + title + "}\n" }
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
EOF = ! . { return environments.map(env => "\\end{" + env + "}\n").join("") }
Text = _ text:$[^\n]* newline { return text + "\n" }

_ "whitespace" = [ ]*
newline "\n" = [\n]
