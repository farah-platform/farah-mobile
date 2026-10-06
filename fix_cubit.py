import re

with open('lib/cubits/provider_services/provider_services_cubit.dart', 'r', encoding='utf-8') as f:
    text = f.read()

impl = """  Future<void> updateService(int id, Map<String, dynamic> data, List<dynamic> newImages) async {
    emit(ProviderServicesAdding());
    try {
      await _repository.updateProviderService(id, data, newImages);
      emit(ProviderServicesAddSuccess());
      loadServices();
    } catch (e) {
      emit(ProviderServicesAddError(message: e.toString()));
    }
  }

  Future<void> deleteService(int id) async {
    emit(ProviderServicesAdding());
    try {
      await _repository.deleteProviderService(id);
      loadServices();
    } catch (e) {
      emit(ProviderServicesAddError(message: e.toString()));
    }
  }

  Future<void> toggleVisibility(int id) async {
    emit(ProviderServicesAdding());
    try {
      await _repository.toggleServiceVisibility(id);
      loadServices();
    } catch (e) {
      emit(ProviderServicesAddError(message: e.toString()));
    }
  }
}"""

text = re.sub(r'}\s*$', '\n' + impl, text)

with open('lib/cubits/provider_services/provider_services_cubit.dart', 'w', encoding='utf-8') as f:
    f.write(text)
