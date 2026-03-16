import 'package:get/get.dart';
import '../../services/api_service.dart';

class SearchPackageController extends GetxController {

  var packages = [].obs;
  var keyword = ''.obs;
  var isLoading = false.obs;


  Future<void> search(String value) async {

    keyword.value = value;

    try {

      isLoading.value = true;

      final res = await searchPackages(value);
      
      if (res.success) {
        packages.value = res.data["data"];
      }

    } catch (e) {

      print(e);

    } finally {

      isLoading.value = false;

    }

  }

}