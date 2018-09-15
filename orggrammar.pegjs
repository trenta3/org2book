// org-mode grammar to parse a whole book
// ======================================

{
    const headings = {1: "section", 2: "subsection", 3: "subsubsection", 4: "paragraph"}
}

File = content:(Heading / Command / Text)* { return content.join("") }

Heading = start:$[*]+ _ title:$[^\n]+ newline { return "\\" + headings[start.length] + "{" + title + "}\n" }
Command = "#+" command:$[^\:\n]+ separator:":"? _ optargument:$("[" [^\]]* "]")? _ argument:$[^\n]* newline {
    return "\\" + command.toLowerCase() + (separator == null ? "" : optargument + "{" + argument + "}") + "\n"
}
Text = _ text:$[^\n]* newline { return text + "\n" }

_ "whitespace" = [ ]*
newline "\n" = [\n]
