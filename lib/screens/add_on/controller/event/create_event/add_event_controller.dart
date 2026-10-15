import 'package:camera/camera.dart';
import 'package:foap/api_handler/apis/misc_api.dart';
import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/add_on/model/create_event_model.dart';
import 'package:foap/screens/add_on/model/event_category_model.dart';
import '../../../../../api_handler/apis/events_api.dart';
import '../../../../../model/category_model.dart';
import 'my_events_controller.dart';

class AddEventController extends GetxController {
  Rx<CreateEventModel> creatingEvent =
      CreateEventModel(gallery: [], galleryImageName: []).obs;
  RxList<EventCategoryModel> categories = <EventCategoryModel>[].obs;
  final MyEventsController _eventsController = Get.find();

  getCategories() {
    EventApi.getEventCategories(resultCallback: (result) {
      categories.value = result;
    });
  }

  clear() {
    creatingEvent.value =
        CreateEventModel(gallery: [], galleryImageName: []);
  }

  setEditableEvent(CreateEventModel ad) {
    creatingEvent.value = ad;
  }

  setCategory(CategoryModel category) {
    creatingEvent.value.category = category;
  }

  setSubCategory(CategoryModel category) {
    creatingEvent.value.subCategory = category;
  }

  setStartDate(DateTime date) {
    creatingEvent.value.startDateInMillisecond =
        date.millisecondsSinceEpoch;
    if (creatingEvent.value.endDate != null) {
      if (creatingEvent.value.endDate!
          .isEarlierThan(creatingEvent.value.startDate!)) {
        creatingEvent.value.endDateInMillisecond =
            creatingEvent.value.startDateInMillisecond!.addDays(1);
      }
    } else {
      creatingEvent.value.endDateInMillisecond =
          creatingEvent.value.startDateInMillisecond!.addDays(1);
    }
    creatingEvent.refresh();
  }

  setEndDate(DateTime date) {
    creatingEvent.value.endDateInMillisecond = date.millisecondsSinceEpoch;
    creatingEvent.refresh();
  }

  setIsFreeFlag(bool isFree) {
    creatingEvent.value.isFree = isFree;
    creatingEvent.refresh();
  }

  submitEvent() {
    if (creatingEvent.value.id == null) {
      EventApi.createEvent(
          event: creatingEvent.value,
          successCallback: (id) {
            Get.close(3);
            clear();
            _eventsController.refreshEvents(() {});
          },
          errorCallback: () {});
    } else {
      EventApi.updateEvent(
          event: creatingEvent.value,
          successCallback: (id) {
            Get.close(3);
            clear();
            _eventsController.refreshEvents(() {});
          },
          errorCallback: () {});
    }
  }

  Future uploadCoverImage(
      {required XFile pickedFile,
      required Function(String) successCallback}) async {
    await MiscApi.uploadFile(pickedFile.path,
        mediaType: GalleryMediaType.photo,
        type: UploadMediaType.event, resultCallback: (fileName, filePath) {
      successCallback(filePath);
      creatingEvent.value.image = filePath;
      creatingEvent.value.imageName = fileName;

      creatingEvent.refresh();
    });
  }

  Future uploadGalleryImage(
      {required XFile pickedFile,
      required Function(String) successCallback}) async {
    await MiscApi.uploadFile(pickedFile.path,
        mediaType: GalleryMediaType.photo,
        type: UploadMediaType.event, resultCallback: (fileName, filePath) {
      successCallback(filePath);
      (creatingEvent.value.gallery).add(filePath);
      (creatingEvent.value.galleryImageName).add(fileName);

      creatingEvent.refresh();
    });
  }

  removeImageAt(int index) {
    creatingEvent.value.gallery.removeAt(index);
    creatingEvent.value.galleryImageName.removeAt(index);

    creatingEvent.refresh();
  }
}
