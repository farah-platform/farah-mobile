import 'dart:io';

void main() {
  final files = ['lib/view/screens/auth/sginup.dart', 'lib/view/screens/auth/login.dart'];
  for (final path in files) {
    final file = File(path);
    var lines = file.readAsLinesSync();
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('Image.asset("assets/image/google1.png", width: 24),')) {
        // The next line is const SizedBox(width: 12),
        // The line after that is Text(
        if (lines[i+2].trim().startsWith('Text(')) {
          lines[i+2] = lines[i+2].replaceFirst('Text(', 'Flexible(child: Text(');
          
          // find the matching closing bracket for Text
          int j = i + 2;
          while (j < lines.length && !lines[j].trim().startsWith('),')) {
             if (lines[j].contains('style:')) {
                // insert overflow before style or after it
             }
             j++;
          }
          // lines[j] is the closing bracket for Text
          lines[j] = lines[j].replaceFirst('),', '), overflow: TextOverflow.ellipsis,),');
        }
      }
    }
    
    file.writeAsStringSync(lines.join('\n'));
  }
}
