import 'dart:io';
import 'package:args/args.dart';

// output types
const String ANGULAR_COMPONENT = "ng-cp";      // default output type
const String POLYMER_ELEMENT = "p-el";

const String DEFAULT_ELEMENT_NAME = "custom-element";

ArgResults argResults;

void main(List<String> arguments) {
  // set up argument parser
  final ArgParser argParser = new ArgParser()
    ..addOption('output', abbr: 'o', defaultsTo: ANGULAR_COMPONENT, help: "Type of boilerplate to generate.")
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
      case ANGULAR_COMPONENT: generateAngularComponent(argResults['name']); break;
      case POLYMER_ELEMENT: generatePolymerElement(argResults['name']); break;
      default: error("Unrecognized output type: ${argResults['o']}"); break;
    }
  }
}

void error(String errorMsg) {
  stderr.writeln(errorMsg);
  exitCode = 2;
}

void generateAngularComponent(String elementName) {
  StringBuffer htmlFileBuffer = new StringBuffer();
  StringBuffer dartFileBuffer = new StringBuffer();

  String filename = elementName.replaceAll("-", "_");
  String className = elementName.split("-").map((String word) => "${word[0].toUpperCase()}${word.substring(1)}").join();

  htmlFileBuffer.write("""<style>

</style>
""");

  dartFileBuffer.write("""import 'package:angular2/angular2.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';

import '../../services/logger.dart';

@Component(selector: '$elementName',
    encapsulation: ViewEncapsulation.Native,
    templateUrl: '$filename.html',
    directives: const [],
    providers: const []
)
class $className {
  final Logger _log;

  $className(Logger this._log) {
    _log.info("\$runtimeType()");
  }
}""");

  outputDirectoryDartHTML(filename, htmlFileBuffer, dartFileBuffer);
}

void generatePolymerElement(String elementName) {
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

import '../../services/logger.dart';

@PolymerRegister('$elementName')
class $className extends PolymerElement {

  $className.created() : super.created();

  void ready() {
    log.info("\$runtimeType::ready()");
  }
}""");

  outputDirectoryDartHTML(filename, htmlFileBuffer, dartFileBuffer);
}

void outputDirectoryDartHTML(String filename, StringBuffer htmlFileBuffer, StringBuffer dartFileBuffer) {
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