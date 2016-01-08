import 'dart:io';
import 'package:args/args.dart';

// output types
const String ELEMENT = "el";      // default output type

const String DEFAULT_ELEMENT_NAME = "custom-element";

ArgResults argResults;

void main(List<String> arguments) {
  // set up argument parser
  final ArgParser argParser = new ArgParser()
    ..addOption('output', abbr: 'o', defaultsTo: ELEMENT, help: "Type of boilerplate to generate.")
    ..addOption('name', abbr: 'n', defaultsTo: DEFAULT_ELEMENT_NAME, help: "Name of element, class, etc.")
    ..addFlag('help', abbr: 'h', negatable: false, help: "Displays this help information.");

  // parse the command-line arguments
  argResults = argParser.parse(arguments);

  if (argResults['help']) {
    stdout.writeln("""

** dartgen help **
${argParser.usage}
    """);
  }
  else {
    switch (argResults['output']) {
      case ELEMENT: generateElement(argResults['name']); break;
      default: error("Unrecognized output type: ${argResults['o']}"); break;
    }
  }
}

void error(String errorMsg) {
  stderr.writeln(errorMsg);
  exitCode = 2;
}

void generateElement(String elementName) {
  StringBuffer htmlFileBuffer = new StringBuffer();
  StringBuffer dartFileBuffer = new StringBuffer();

  String filename = elementName.replaceAll("-", "_");
  String className = elementName.split("-").map((String word) => "${word[0].toUpperCase()}${word.substring(1)}").join();

  htmlFileBuffer.write("""<dom-module id="$elementName">
  <template>
    <style>
      :host {
        display: block;
      }
    </style>

  </template>
</dom-module>""");

  dartFileBuffer.write("""@HtmlImport('$filename.html')
library my_project.lib.$filename;

import 'dart:html';

import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

import '../../services/logging.dart';

@PolymerRegister('$elementName')
class $className extends PolymerElement {

  $className.created() : super.created();

  void ready() {
    log.info("\$runtimeType::ready()");
  }
}""");

  String htmlFilename = "$filename.html";
  String dartFilename = "$filename.dart";

  new Directory("$filename").create().then((Directory directory) {
    new File("${filename}/$htmlFilename").writeAsString(htmlFileBuffer.toString())
        .then((_) => stdout.writeln("$htmlFilename created."))
        .catchError(() {
      error("Error writing HTML file.");
    });

    new File("${filename}/$dartFilename").writeAsString(dartFileBuffer.toString())
        .then((_) => stdout.writeln("$dartFilename created."))
        .catchError(() {
      error("Error writing Dart file.");
    });
  });
}