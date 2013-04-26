part of logging_handlers_shared;

/**
 * Transforms a Log Record into a Map that can be stringified by JSON.stringify()  
 */
class MapTransformer implements BaseLogRecordTransformer {
  
  /**
   * Convert the logRecord into a map that is parsable by the JSON library
   */
  Map transform(LogRecord logRecord) {
    var map = new Map();
    map["level"] = logRecord.level != null ? logRecord.level.name : null; 
    map["message"] = logRecord.message;
    map["time"] = logRecord.time != null ? logRecord.time.toString() : null;
    map["sequenceNumber"] = logRecord.sequenceNumber;
    map["loggerName"] = logRecord.loggerName;
    map["exceptionText"] = logRecord.exceptionText;
    map["exception"] = logRecord.exception != null ? logRecord.exception.toString() : null;    
    return map;
  }
}
