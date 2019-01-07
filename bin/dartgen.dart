import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dartgen/src/identifier.dart';

// output types
const String ANGULAR_COMPONENT = "ng-cmp";      // default output type
const String ANGULAR_DIRECTIVE = "ng-dir";
const String ANGULAR_PIPE = "ng-pipe";
const String BLOC = "bloc";

const String DEFAULT_ELEMENT_NAME = "custom-element";

void main(List<String> arguments) {
  // set up argument parser
  final ArgParser argParser = new ArgParser()
    ..addOption('output', abbr: 'o', defaultsTo: ANGULAR_COMPONENT, help: "Type of boilerplate to generate and output.")
    ..addOption('name', abbr: 'n', defaultsTo: DEFAULT_ELEMENT_NAME, help: "Name of element, class, etc.")
    ..addFlag('help', abbr: 'h', negatable: false, help: "Displays this help information.");

  // parse the command-line arguments
  ArgResults argResults = argParser.parse(arguments);

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
      case BLOC: generateBloc(argResults['name']); break;
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

  final htmlFileBuffer = new StringBuffer();
  final dartFileBuffer = new StringBuffer();
  final cssFileBuffer = new StringBuffer();

  final filename = spinalToSnakeCase(elementName);
  final className = spinalToPascalCase(elementName);

  htmlFileBuffer.write("""<div></div>""");

  dartFileBuffer.write("""import 'package:angular/angular.dart';

import 'package:client_shared/managers.dart';

@Component(selector: '$elementName',
    templateUrl: '$filename.html',
    styleUrls: ['$filename.css'],
    directives: []
)
class $className {
  final LoggerManager _log;

  $className(this._log) {
    _log.info("\$runtimeType()");
  }
}""");

  cssFileBuffer.write(""":host {
  
}""");

  writeFiles([
    OutputFile(filename, "html", htmlFileBuffer),
    OutputFile(filename, "css", cssFileBuffer),
    OutputFile(filename, "dart", dartFileBuffer)
  ], dir: filename);
}

void generateAngularDirective(String className) {
  if (!isPascalCase(className)) {
    error("Error: Directive class names should be provided using Pascal case (upper camel case).");
    return;
  }

  final dartFileBuffer = new StringBuffer();

  final filename = pascalToSnakeCase(className);
  final elementName = snakeToSpinalCase(filename);

  dartFileBuffer.write("""import 'package:angular/angular.dart';

@Directive(selector: '$elementName')
class $className {

}""");

  writeFiles([OutputFile(filename, "dart", dartFileBuffer)]);
}

void generateAngularPipe(String pipeName) {
  if (!isCamelCase(pipeName)) {
    error("Error: Pipe names should be provided using camel case.");
    return;
  }

  final dartFileBuffer = new StringBuffer();

  final filename = camelToSnakeCase(pipeName);
  final className = camelToPascalCase(filename);

  dartFileBuffer.write("""import 'package:angular/angular.dart';

@Pipe(name: '$pipeName')
class $className implements PipeTransform {
  String transform(val, [List args]) {
    return "";
  }
}""");

  writeFiles([OutputFile(filename, "dart", dartFileBuffer)]);
}

void generateBloc(String blocName) {
  if (!isPascalCase(blocName)) {
    error("Error: BLoC names should be provided using Pascal case (upper camel case).");
    return;
  }

  final blocFileBuffer = new StringBuffer();
  final stateFileBuffer = new StringBuffer();
  final eventsFileBuffer = new StringBuffer();
  final exportsFileBuffer = new StringBuffer();

  final filename = pascalToSnakeCase(blocName);
  final blocClassName = "${blocName}Bloc";
  final stateClassName = "${blocName}State";
  final eventClassName = "${blocName}Event";

  blocFileBuffer.write("""import 'package:bloc/bloc.dart';

import '${filename}_state.dart';
import '${filename}_events.dart';
import '../../managers/logger_manager.dart';

class $blocClassName extends Bloc<$eventClassName, $stateClassName> {
  @override
  $stateClassName get initialState => $stateClassName.initial();

  final LoggerManager _log;

  $blocClassName(this._log) {
    _log.info("\$runtimeType()");
  }

  @override
  Stream<$stateClassName> mapEventToState($stateClassName state, $eventClassName event) async* {

  }
}""");

  stateFileBuffer.write("""class $stateClassName {
  final bool isLoading;

  const $stateClassName({this.isLoading = false});

  factory $stateClassName.initial() => $stateClassName();
}""");

  eventsFileBuffer.write("abstract class $eventClassName {}");

  exportsFileBuffer.write("""library blocs.$filename;
  
export '${filename}_bloc.dart';
export '${filename}_events.dart';
export '${filename}_state.dart';
""");

  writeFiles([
    OutputFile("${filename}_bloc", "dart", blocFileBuffer),
    OutputFile("${filename}_state", "dart", stateFileBuffer),
    OutputFile("${filename}_events", "dart", eventsFileBuffer),
    OutputFile(filename, "dart", exportsFileBuffer)
  ], dir: filename);
}

Future<void> writeFiles(List<OutputFile> files, {String dir}) async {
  if (dir != null) {
    await Directory(dir).create();
  }

  for (OutputFile f in files) {
    final path = "${dir != null ? '$dir/' : ''}${f.name}.${f.extension}";

    try {
      await File(path).writeAsString(f.content.toString());
      stdout.writeln("$path created.");
    }
    catch (e) {
      error("Error writing .${f.extension} file.");
    }
  }
}

class OutputFile {
  final String name;
  final String extension;
  final StringBuffer content;

  const OutputFile(this.name, this.extension, this.content);
}