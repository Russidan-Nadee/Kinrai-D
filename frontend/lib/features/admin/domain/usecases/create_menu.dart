import '../repositories/admin_repository.dart';

class CreateMenuUseCase {
  final AdminRepository repository;

  const CreateMenuUseCase({required this.repository});

  Future<bool> call(Map<String, dynamic> menuData) async {
    return await repository.createMenu(menuData);
  }
}