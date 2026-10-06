import re

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# I will replace the build method's dummy lists with real data from the cubit
# First, add the import
text = text.replace('import \'package:flutter/material.dart\';', 'import \'package:flutter/material.dart\';\nimport \'package:flutter_bloc/flutter_bloc.dart\';\nimport \'../../../../cubits/provider_services/provider_services_cubit.dart\';\nimport \'../../../../cubits/provider_services/provider_services_state.dart\';\nimport \'../../../../core/constants/app_routes.dart\';')

# Now wrap the body content in BlocBuilder
body = '''      body: BlocBuilder<ProviderServicesCubit, ProviderServicesState>(
        builder: (context, state) {
          bool isLoading = state is ProviderServicesLoading;
          List<dynamic> services = [];
          if (state is ProviderServicesLoaded) {
            services = state.services;
          }
          
          return CustomScrollView(
            slivers: [
              _buildCoverAndProfile(theme, primary),
              if (isLoading)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())))
              else if (services.isEmpty)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لا يوجد خدمات حتى الآن.'))))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('الخدمات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)));
                        final service = services[index - 1];
                        return _buildServiceCard(context, service, primary);
                      },
                      childCount: services.length + 1,
                    ),
                  ),
                ),
            ],
          );
        }
      ),'''

text = re.sub(r'      body: CustomScrollView.*?\]\s*,\s*\)\s*,', body, text, flags=re.DOTALL)

# Now update _buildServiceCard signature and logic
card_logic = '''  Widget _buildServiceCard(BuildContext context, dynamic service, Color primary) {
    bool isActive = service['is_active'] ?? true;
    String name = service['name'] ?? service['title'] ?? 'بدون اسم';
    String price = service['price']?.toString() ?? '0';
    String image = (service['images'] is List && service['images'].isNotEmpty) 
        ? service['images'][0] 
        : (service['image'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Edit Icon
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.providerEditService, arguments: service);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: primary, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('السعر:  شيكل', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(isActive ? 'نشط' : 'مسودة', style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 10)),
                      const SizedBox(width: 4),
                      Icon(Icons.circle, color: isActive ? Colors.green : Colors.orange, size: 8),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: image.isNotEmpty ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
                color: Colors.grey.shade200,
              ),
              child: image.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
            ),
          ],
        ),
      ),
    );
  }'''

text = re.sub(r'  Widget _buildServiceCard\(.*?}.*?}\s*}', card_logic + '\n}', text, flags=re.DOTALL)

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
