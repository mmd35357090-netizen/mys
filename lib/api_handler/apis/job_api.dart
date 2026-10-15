import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/job_model.dart';

import '../../model/api_meta_data.dart';
import '../../model/category_model.dart';
import '../api_wrapper.dart';

class JobApi {
  static getCategories(
      {required Function(List<CategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.jobCategories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<CategoryModel>.from(
            items.map((x) => CategoryModel.fromJson(x))));
      }
    });
  }

  static getJobs(
      {required JobSearchModel searchModel,
      required int page,
      required Function(List<JobModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.jobsList;

    if (searchModel.title != null) {
      url = '$url&title=${searchModel.title}';
    }
    if (searchModel.title != null) {
      url = '$url&description=${searchModel.title}';
    }
    if (searchModel.categoryId != null) {
      url = '$url&category_id=${searchModel.categoryId}';
    }
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['jobs']['items'];

        resultCallback(
            List<JobModel>.from(items.map((x) => JobModel.fromJson(x))),
            APIMetaData.fromJson(result.data['jobs']['_meta']));
      }
    });
  }

  static getAppliedJobs(
      {required int page,
      required Function(List<JobModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.appliedJobs;

    url = '$url?page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['jobApplications']['items'];

        resultCallback(
            List<JobModel>.from(items.map((x) => JobModel.fromJson(x['job']))),
            APIMetaData.fromJson(result.data['jobApplications']['_meta']));
      }
    });
  }

  static applyJob({
    required String jobId,
    required String experience,
    required String education,
    required String coverLetter,
    required String resume,
    required VoidCallback successHandler,
  }) async {
    var url = NetworkConstantsUtil.applyJob;
    Loader.show();
    await ApiWrapper().postApi(url: url, param: {
      'job_id': jobId,
      'total_experience': experience,
      "education": education,
      "cover_letter": coverLetter,
      "resume": resume
    }).then((result) {
      Loader.dismiss();
      if (result?.success == true) {
        successHandler();
      }
    });
  }
}
