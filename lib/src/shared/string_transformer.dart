part of logging_handlers_shared;

/**
 * Format a log record according to a string pattern
 */
class StringTransformer implements LogRecordTransformer {
  
  /// Outputs [LogRecord.level]
  static const LEVEL = "%p";  
  
  /// Outputs [LogRecord.message]
  static const MESSAGE = "%m"; 
  
  /// Outputs the [Logger.name]
  static const NAME = "%n"; 
  
  /// Outputs the timestamp according to the Date Time Format specified in
  /// [timestampFormatString]
  static const TIME = "%t"; // logger date timestamp.  Format using
  
  /// Outputs the logger sequence
  static const SEQ = "%s"; // logger sequence
  static const EXCEPTION = "%x"; // logger exception type
  static const EXCEPTION_TEXT = "%e"; // logger exception message
  static const STACK_DUMP = "%d";   //logger StackDump 
  static const TAB = "\t";
  static const NEW_LINE = "\n";
  
  /// Default format for a log message that does not contain an exception.
  static const DEFAULT_MESSAGE_FORMAT = "%t\t%n\t[%p]:\t%m";
  
  /// Default format for a log message if it contains an exception
  /// This is appended onto the message format - 
  /// first the class name of the exception, then the message, and the StackTrace (if present)
  static const DEFAULT_EXCEPTION_FORMAT = "\nException Type: ${EXCEPTION}\n${EXCEPTION_TEXT}\nStackTrace:\n${STACK_DUMP}";
  
  /// Default date time format for log messages
  static const DEFAULT_DATE_TIME_FORMAT = "yyyy.mm.dd HH:mm:ss.SSS";
  
  /// Contains the standard message format string
  final String messageFormat;
  
  /// Contains the exception format string
  final String exceptionFormatSuffix;
  
  /// Contains the timestamp format string
  final String timestampFormat;
  
  /// Contains the date format instance
  DateFormat dateFormat;
  
  /// Contains the regexp pattern
  static final _regexp = new RegExp("($LEVEL|$MESSAGE|$NAME|$TIME|$SEQ|$EXCEPTION|$EXCEPTION_TEXT|$STACK_DUMP)");
  
  StringTransformer({
      String this.messageFormat : StringTransformer.DEFAULT_MESSAGE_FORMAT,
      String this.exceptionFormatSuffix : StringTransformer.DEFAULT_EXCEPTION_FORMAT, 
      String this.timestampFormat : StringTransformer.DEFAULT_DATE_TIME_FORMAT}) { 
    dateFormat = new DateFormat(this.timestampFormat);
  }
  
  /**
   * Transform the log record into a string according to the [messageFormat], 
   * [exceptionFormatSuffix] and [timestampFormat] pattern.
   */
  String transform(LogRecord logRecord) {
    var formatString = logRecord.error == null ? 
                                  messageFormat : 
                                  messageFormat+exceptionFormatSuffix;
    
    // build the log string and return
    return formatString.replaceAllMapped(_regexp, (match) {
      if (match.groupCount == 1) {
        switch (match.group(0)) {
          case LEVEL: 
            return logRecord.level.name;
          case MESSAGE:
            return logRecord.message;
          case NAME:
            return logRecord.loggerName;
          case TIME: 
            if (logRecord.time != null) {
              try {
                return dateFormat.format(logRecord.time);
              } 
              on UnimplementedError catch (e) {
                // at time of writing, dateFormat.format seems to be unimplemented.
                // so just return the time.toString()
                return logRecord.time.toString();
              }
            }
            
            break;
          case SEQ:
            return logRecord.sequenceNumber.toString();
          case EXCEPTION:
            if (logRecord.error != null) return "${logRecord.error.runtimeType}";
            break;
          case EXCEPTION_TEXT:
            if (logRecord.error != null) return logRecord.error.toString();
            break;
          case STACK_DUMP:
            if( logRecord.stackTrace != null) return "${Trace.format( logRecord.stackTrace)}";
        }
      }

      return ""; // empty string
    });
  }
  
    
}

