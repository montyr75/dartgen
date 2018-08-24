# dartgen
A command-line application to generate Dart code files.

## Install
Use the [pub global](https://www.dartlang.org/tools/pub/cmd/pub-global.html) command to install this into your system. You must already have the [Dart SDK](https://www.dartlang.org/downloads/) downloaded and included in your system path.

    pub global activate --source git https://github.com/montyr75/dartgen/

>**Warning!**
>If you haven't gone through these steps before, you might see a warning telling you that Pub's cache directory is not in your system path. Make things easy on yourself and add the path revealed in the warning to your system path.

## Use
For Angular component (default) boilerplate, creates a directory and inserts HTML, CSS, and Dart files. Other types do not create a directory.

    dartgen -n my-angular-component
    dartgen -o ng2-cmp -n my-angular-component
    dartgen -o ng2-dir -n MyAngularDirective
    dartgen -o ng2-pipe -n myAngularPipe

## Help

    dartgen -h
    
