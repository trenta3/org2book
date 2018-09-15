const pegjs = require("pegjs")
const fs = require("fs")
const commandLineArgs = require("command-line-args")

const cmdLineOptions = [
    { name: "src", alias: "i", type: String, defaultOption: true },
    { name: "out", alias: "o", type: String },
    { name: "grammar", alias: "g", type: String }
]

// Parse command line options
var options = commandLineArgs(cmdLineOptions)

// Load parser file
if (options.grammar == undefined)
    options.grammar = "orggrammar.pegjs"
var grammarContent = fs.readFileSync(options.grammar).toString()
var orgparser = pegjs.generate(grammarContent)

// Read source file and write out the LaTeX generated file
var sourceContent = fs.readFileSync(options.src).toString()
var outContent = orgparser.parse(sourceContent)

if (options.out == undefined)
    console.log(outContent)
else
    fs.writeFileSync(options.out, outContent)

