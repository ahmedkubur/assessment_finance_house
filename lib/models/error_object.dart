
enum ErrorType { 
    NETWORK, 
    SERVER, 
    UNKNOWN
}  
  class ErrorObject {
    String errorMessage;
    ErrorType errorType;

    ErrorObject({required this.errorMessage, required this.errorType});
  }


