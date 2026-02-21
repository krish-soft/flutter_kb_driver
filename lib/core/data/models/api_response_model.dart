class ApiResponseModel<T> {
  final bool? isSuccess;
  final dynamic message;
  final int? statusCode;
  final int? actionCode;
  final T? data;

  ApiResponseModel({this.isSuccess, this.message, this.statusCode, this.actionCode, this.data});

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      isSuccess: json["isSuccess"],
      message: json["message"],
      statusCode: json["statusCode"],
      actionCode: json["actionCode"],
      data: fromJsonT != null ? fromJsonT(json["data"]) : json["data"],
    );
  }
}
