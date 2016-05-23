import 'dart:io';
import 'package:args/args.dart';
import 'package:dogma_codegen/identifier.dart';

// output types
const String ANGULAR_COMPONENT = "ng2-cmp";      // default output type
const String ANGULAR_DIRECTIVE = "ng2-dir";
const String ANGULAR_PIPE = "ng2-pipe";
const String POLYMER_ELEMENT = "p-el";

const String DEFAULT_ELEMENT_NAME = "custom-element";

ArgResults argResults;

void main(List<String> arguments) {
  // set up argument parser
  final ArgParser argParser = new ArgParser()
    ..addOption('output', abbr: 'o', defaultsTo: ANGULAR_COMPONENT, help: "Type of boilerplate to generate and output.")
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
      case ANGULAR_DIRECTIVE: generateAngularDirective(argResults['name']); break;
      case ANGULAR_PIPE: generateAngularPipe(argResults['name']); break;
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
  if (!isSpinalCase(elementName)) {
    error("Error: Component names should be provided using spinal case (dash separators).");
    return;
  }

  StringBuffer htmlFileBuffer = new StringBuffer();
  StringBuffer dartFileBuffer = new StringBuffer();

  String filename = spinalToSnakeCase(elementName);
  String className = spinalToPascalCase(elementName);

  htmlFileBuffer.write("""<style>

</style>
""");

  dartFileBuffer.write("""import 'package:angular2/angular2.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';

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

void generateAngularDirective(String className) {
  if (!isPascalCase(className)) {
    error("Error: Directive class names should be provided using Pascal case (upper camel case).");
    return;
  }

  StringBuffer dartFileBuffer = new StringBuffer();

  String filename = pascalToSnakeCase(className);
  String elementName = snakeToSpinalCase(filename);

  // NOTE: Use replaceAll() to insert core.dart to avoid transformer errros
  dartFileBuffer.write("""import 'package:angular2/angular2.dart';

@Directive(selector: '$elementName')
class $className {

}""".replaceAll('angular2.dart', 'core.dart'));

  outputFile(filename, "dart", dartFileBuffer);
}

void generateAngularPipe(String pipeName) {
  if (!isCamelCase(pipeName)) {
    error("Error: Pipe names should be provided using camel case.");
    return;
  }

  StringBuffer dartFileBuffer = new StringBuffer();

  String filename = camelToSnakeCase(pipeName);
  String className = camelToPascalCase(filename);

  // NOTE: Use replaceAll() to insert core.dart to avoid transformer errros
  dartFileBuffer.write("""import 'package:angular2/angular2.dart';

@Pipe(name: '$pipeName')
class $className implements PipeTransform {
  @override String transform(val, [List args]) {
    return "";
  }
}""".replaceAll('angular2.dart', 'core.dart'));

  outputFile(filename, "dart", dartFileBuffer);
}

void generatePolymerElement(String elementName) {
  if (!isSpinalCase(elementName)) {
    error("Error: Element names should be provided using spinal case (dash separators).");
    return;
  }

  StringBuffer htmlFileBuffer = new StringBuffer();
  StringBuffer dartFileBuffer = new StringBuffer();

  String filename = spinalToSnakeCase(elementName);
  String className = spinalToPascalCase(elementName);

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
  new Directory("$filename").create().then((Directory directory) {
    outputFile(filename, "html", htmlFileBuffer, inDir: filename);
    outputFile(filename, "dart", dartFileBuffer, inDir: filename);
  });
}

void outputFile(String filename, String extension, StringBuffer content, {String inDir}) {
  String filePath = "${inDir != null ? '$inDir/' : ''}$filename.$extension";

  new File("$filePath").writeAsString(content.toString())
      .then((_) => stdout.writeln("$filePath created."))
      .catchError(() {
    error("Error writing .$extension file.");
  });
}