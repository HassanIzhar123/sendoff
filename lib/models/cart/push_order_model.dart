class PushOrderModel {
  bool? isSignedIn = false;
  bool isUploaded;
  bool isError;
  String? errorMessage;

  @override
  String toString() {
    return 'pushOrderModel{isUploaded: $isUploaded, isError: $isError, errorMessage: $errorMessage, isSignedIn: $isSignedIn}';
  }

  PushOrderModel(this.isUploaded, this.isError, this.errorMessage, this.isSignedIn);
}
