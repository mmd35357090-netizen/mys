import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import 'package:foap/model/job_model.dart';
import '../../api_handler/apis/job_api.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../model/category_model.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class JobController extends GetxController {
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<JobModel> jobs = <JobModel>[].obs;
  RxList<JobModel> appliedJobs = <JobModel>[].obs;

  JobSearchModel searchModel = JobSearchModel();
  RxBool isLoadingCategories = false.obs;
  Rx<JobModel?> currentJob = Rx<JobModel?>(null);
  DataWrapper jobsDataWrapper = DataWrapper();
  DataWrapper appliedJobsDataWrapper = DataWrapper();

  RxInt currentIndex = 0.obs;
  RxInt experience = 1.obs;

  File? selectedResume;
  RxString selectedResumeFileName = ''.obs;

  clear() {
    categories.clear();
    isLoadingCategories.value = false;
    appliedJobsDataWrapper = DataWrapper();
    clearJobs();
  }

  clearJobs() {
    jobs.clear();
    jobsDataWrapper = DataWrapper();
  }

  selectExperience(int experience) {
    this.experience.value = experience;
  }

  setCurrentJob(JobModel job) {
    currentJob.value = job;
  }

  setCategoryId(int? categoryId) {
    clearJobs();
    searchModel.categoryId = categoryId;
    getJobs(() {});
  }

  setTitle(String? title) {
    clearJobs();
    searchModel.title = title;
    getJobs(() {});
  }

  getCategories() {
    isLoadingCategories.value = true;
    JobApi.getCategories(resultCallback: (result) {
      categories.value = result;
      isLoadingCategories.value = false;

      update();
    });
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
  }

  refreshJobs(VoidCallback callback) {
    clearJobs();
    getJobs(callback);
  }

  loadMoreJobs(VoidCallback callback) {
    if (jobsDataWrapper.haveMoreData.value) {
      getJobs(callback);
    } else {
      callback();
    }
  }

  getJobs(VoidCallback callback) {
    JobApi.getJobs(
        searchModel: searchModel,
        page: jobsDataWrapper.page,
        resultCallback: (result, metadata) {
          jobs.addAll(result);
          jobs.unique((e) => e.id);
          jobsDataWrapper.processCompletedWithData(metadata);

          update();
          callback();
        });
  }

  refreshAppliedJobs(VoidCallback callback) {
    clear();
    getAppliedJobs(callback);
  }

  loadMoreAppliedJobs(VoidCallback callback) {
    if (appliedJobsDataWrapper.haveMoreData.value) {
      getAppliedJobs(callback);
    } else {
      callback();
    }
  }

  getAppliedJobs(VoidCallback callback) {
    JobApi.getAppliedJobs(
        page: appliedJobsDataWrapper.page,
        resultCallback: (result, metadata) {
          appliedJobs.addAll(result);
          appliedJobs.unique((e) => e.id);

          appliedJobsDataWrapper.processCompletedWithData(metadata);

          update();
          callback();
        });
  }

  applyJob(
      {required String jobId,
      required String experience,
      required String education,
      required String coverLetter}) async {
    String uploadedResumeFileName = '';
    // Loader.show();
    await MiscApi.uploadFile(selectedResume!.path,
        mediaType: GalleryMediaType.photo, type: UploadMediaType.uploadResume,
        resultCallback: (fileName, filePath) {
      uploadedResumeFileName = fileName;
    });
    JobApi.applyJob(
        jobId: jobId,
        experience: experience,
        education: education,
        coverLetter: coverLetter,
        resume: uploadedResumeFileName,
        successHandler: () {
          AppUtil.showToast(message: appliedSuccessfully, isSuccess: true);
          Get.close(2);
          refreshJobs(() {});
        });
  }

  void openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
      ],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      selectedResume = file;
      selectedResumeFileName.value = result.files.first.name;
    } else {
      // User canceled the picker
    }
  }
}
