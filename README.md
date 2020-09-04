# dartgen
A command-line application to generate Dart code files.

## Install
Use the [pub global](https://www.dartlang.org/tools/pub/cmd/pub-global.html) command to install this into your system. You must already have the [Dart SDK](https://dart.dev/get-dart) downloaded and included in your system path.

    pub global activate --source git https://github.com/montyr75/dartgen/

>**Warning!**
>If you haven't gone through these steps before, you might see a warning telling you that Pub's cache directory is not in your system path. Make things easy on yourself and add the path revealed in the warning to your system path.

## Use

### Cubit

For Cubit (default) boilerplate, creates a directory and inserts files for the Cubit itself, state, and an exports file.

    dartgen -n MyAuth

### BLoC
Creates a directory and inserts files for the BLoC itself, events, state, and an exports file.

    dartgen -o bloc -n MyAuth

## Help

    dartgen -h
    
