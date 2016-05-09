import 'package:angular2/core.dart';

@Pipe(selector: 'myPipe')
class My_pipe implements PipeTransform {
  @override String transform(val, [List args]) {
    return "";
  };
}