import 'dart:io';

void main() {
  final file = File('lib/view/screens/provider/services/provider_services_screen.dart');
  var content = file.readAsStringSync();
  
  // Add auth cubit import if not there
  if (!content.contains('cubits/auth/auth_cubit.dart')) {
    content = content.replaceFirst(
      'import \'../../../../cubits/provider_services/provider_services_cubit.dart\';',
      'import \'../../../../cubits/provider_services/provider_services_cubit.dart\';\nimport \'../../../../cubits/auth/auth_cubit.dart\';'
    );
  }
  
  // Update _buildCoverAndProfile method to take user data
  content = content.replaceAll(
    'Widget _buildCoverAndProfile(ThemeData theme, Color primary) {',
    'Widget _buildCoverAndProfile(ThemeData theme, Color primary, BuildContext context) {\n    final authState = context.read<AuthCubit>().state;\n    final userName = authState is AuthSuccess ? authState.user.name : \'اسم المتجر\';\n    final userRegion = authState is AuthSuccess ? authState.user.region : \'فلسطين\';\n'
  );
  
  // Replace the strings
  content = content.replaceAll(
    '\'اسم المتجر\', // Fallback',
    'userName,'
  );
  content = content.replaceAll(
    '\'تصنيف المتجر\', // Fallback',
    'userRegion,'
  );
  
  // Update the call to _buildCoverAndProfile
  content = content.replaceAll(
    '_buildCoverAndProfile(theme, primary),',
    '_buildCoverAndProfile(theme, primary, context),'
  );
  
  file.writeAsStringSync(content);
}
