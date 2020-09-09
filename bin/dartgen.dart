import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dartgen/src/identifier.dart';

// output types
const String cubit = "cubit";      // default output type
const String bloc = "bloc";

const defaultName = 'Unnamed';

void main(List<String> arguments) {
  // set up argument parser
  final ArgParser argParser = new ArgParser()
    ..addOption('output', abbr: 'o', defaultsTo: cubit, help: "Type of boilerplate to generate and output.")
    ..addOption('name', abbr: 'n', defaultsTo: defaultName, help: "Name of element, class, etc.")
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
      case cubit: generateCubit(argResults['name']); break;
      case bloc: generateBloc(argResults['name']); break;
      default: error("Unrecognized output type: ${argResults['o']}"); break;
    }
  }
}

void error(String errorMsg) {
  stderr.writeln(errorMsg);
  exitCode = 2;
}

void generateCubit(String name) {
  if (!isPascalCase(name)) {
    error("Error: Cubit names should be provided using Pascal case (upper camel case).");
    return;
  }

  final blocFileBuffer = new StringBuffer();
  final stateFileBuffer = new StringBuffer();
  final exportsFileBuffer = new StringBuffer();

  final filename = pascalToSnakeCase(name);
  final blocClassName = "${name}Bloc";
  final stateClassName = "${name}State";

  blocFileBuffer.write("""import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../app_config.dart' show log;
import '${filename}_state.dart';

class $blocClassName extends Cubit<$stateClassName> {
  $blocClassName() : super(const $stateClassName()) {
    log.info("\$runtimeType()");
  }
}""");

  stateFileBuffer.write("""class $stateClassName {
  final bool isLoading;

  const $stateClassName({this.isLoading = false});

  $stateClassName copyWith({bool isLoading}) {
    return $stateClassName(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}""");

  exportsFileBuffer.write("""export '${filename}_bloc.dart';
export '${filename}_state.dart';
""");

  writeFiles([
    OutputFile("${filename}_bloc", "dart", blocFileBuffer),
    OutputFile("${filename}_state", "dart", stateFileBuffer),
    OutputFile(filename, "dart", exportsFileBuffer)
  ], dir: filename);
}

void generateBloc(String name) {
  if (!isPascalCase(name)) {
    error("Error: BLoC names should be provided using Pascal case (upper camel case).");
    return;
  }

  final blocFileBuffer = new StringBuffer();
  final stateFileBuffer = new StringBuffer();
  final eventsFileBuffer = new StringBuffer();
  final exportsFileBuffer = new StringBuffer();

  final filename = pascalToSnakeCase(name);
  final blocClassName = "${name}Bloc";
  final stateClassName = "${name}State";
  final eventClassName = "${name}Event";

  blocFileBuffer.write("""import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../app_config.dart' show log;
import '${filename}_state.dart';
import '${filename}_events.dart';

class $blocClassName extends Bloc<$eventClassName, $stateClassName> {
  $blocClassName() {
    log.info("\$runtimeType()");
  }

  @override
  Stream<$stateClassName> mapEventToState($eventClassName event) async* {

  }
}""");

  stateFileBuffer.write("""class $stateClassName {
  final bool isLoading;

  const $stateClassName({this.isLoading = false});

  $stateClassName copyWith({bool isLoading}) {
    return $stateClassName(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}""");

  eventsFileBuffer.write("abstract class $eventClassName {}");

  exportsFileBuffer.write("""export '${filename}_bloc.dart';
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