part of shared_test;



runTransformerTests() {
  group("transformers", () {
    test("BaseLogRecordTransformer", () {
      var impl = new TestFormatterImpl();
      var message = "I am a message";
      var loggerName = "my.logger";
      var logRecord = new LogRecord(Level.INFO, message, loggerName);

      // tests the base transformer.  Expect the same log record to be returned
      expect(impl.transform(logRecord), equals(logRecord)); // expect to get the same output as input
      
    });
    
    group("StringTransformer", () {
      runStringTransformerTests();
    });
    
    group("MapTransformer", () {
      runMapTransformerTests();
    });

  });
}




class TestFormatterImpl extends LogRecordTransformer { }
/**
 *  Changed from a Mock, which didnt work...
 */
StackTrace createStackTrace(){
  StackTrace st;
  try{
    throw new Exception( );
  }catch( e, s){
    return s;
  }
}

class MockStackTrace extends StackTrace {
  String _stackText;
  MockStackTrace(this._stackText);
  toString() => _stackText;
}
var dateFormat = new DateFormat(StringTransformer.DEFAULT_DATE_TIME_FORMAT);

runStringTransformerTests() {
  test("defaults", () {
    var message = "I am a message";
    var loggerName = "my.logger";
    var logRecord = new LogRecord(Level.INFO, message, loggerName);
    
    var impl = new StringTransformer();
    expect(impl.transform(logRecord),
        equals("${dateFormat.format(logRecord.time)}\tmy.logger\t[INFO]:\tI am a message"));
  });
  

  test("defaults with exception and stackTrace", () {

  
    var message = "I am a message";
    var loggerName = "my.logger";
    var exception = new Exception("I am an exception");
    var stackTrace = createStackTrace();
    
    var logRecord = new LogRecord(Level.INFO, 
        message, 
        loggerName, 
        exception,
        stackTrace);
            
    var impl = new StringTransformer();
    expect(impl.transform(logRecord),
        equals("""${dateFormat.format(logRecord.time)}\tmy.logger\t[INFO]:\tI am a message
Exception Type: ${exception.runtimeType}
Exception: I am an exception\nStackTrace:
${Trace.format(stackTrace)}"""));
  });  
  
  test("custom formats", () {
    
    
    var message = "I am a message";
    var loggerName = "my.logger";
    var exception = new Exception("I am an exception");
    var logRecordNoException = new LogRecord(Level.FINEST, 
        message, 
        loggerName);
    var logRecordWithException = new LogRecord(Level.FINEST, 
        message, 
        loggerName, 
        exception,
        null);
    
    var impl = new StringTransformer(messageFormat: "%s %t %n[%p]: %m", exceptionFormatSuffix: " %e %x", timestampFormat: "dd-MM-yyyy");
    // Note - this prints the exception message with a sequence number.
    // The sequence number is unique, and depends where about this test falls in 
    // relation to other tests.  For that reason, we'll check that the logged
    // output "contains" the expected string without the sequence number prefix 
    expect(impl.transform(logRecordNoException),
        contains(" my.logger[FINEST]: I am a message"));
    
    
    expect(impl.transform(logRecordWithException),
        contains(" my.logger[FINEST]: I am a message Exception: I am an exception _ExceptionImplementation"));
    
  });
  
}

runMapTransformerTests() {
  test("defaults", () {
    var message = "I am a message";
    var loggerName = "my.logger";
    var logRecord = new LogRecord(Level.INFO, message, loggerName);
    
    var impl = new MapTransformer();
    var map = impl.transform(logRecord); // convert the logRecord to a map    
    String json = JSON.encode(map); // convert the map to json with dart:json
    Map map2 = JSON.decode(json); // convert the json back to a map
    
    expect(map2["message"], equals(logRecord.message));
    expect(map2["loggerName"], equals(logRecord.loggerName));
    expect(map2["level"], equals(logRecord.level.name));
    expect(map2["sequenceNumber"], equals(logRecord.sequenceNumber));
    expect(map2["exceptionText"], isNull);
    expect(map2["exception"], isNull);
    expect(map2["time"], equals(logRecord.time.toString()));
    
  });
  
  test("defaults with exception", () {
    var message = "I am a message";
    var loggerName = "my.logger";
    var exception = new Exception("I am an exception");
    var logRecord = new LogRecord(Level.INFO, 
        message, 
        loggerName, 
        exception,
        createStackTrace());
        //new MockStackTrace("Exception text"));
    
    var impl = new MapTransformer();
    var map = impl.transform(logRecord); // convert the logRecord to a map    
    String json = JSON.encode(map); // convert the map to json with dart:json
    Map map2 = JSON.decode(json); // convert the json back to a map
    
    expect(map2["message"], equals(logRecord.message));
    expect(map2["loggerName"], equals(logRecord.loggerName));
    expect(map2["level"], equals(logRecord.level.name));
    expect(map2["sequenceNumber"], equals(logRecord.sequenceNumber));
    expect(map2["exception"], equals(logRecord.error.toString()));
    expect(map2["time"], equals(logRecord.time.toString()));
  });  
}