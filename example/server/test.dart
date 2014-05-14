
import 'package:logging_handlers/server_logging_handlers.dart';
import 'package:logging/logging.dart';
 
main() {
   var logger = new Logger("mylogger");
   logger.onRecord.listen(new LogPrintHandler());
   logger.info("Hello World"); // should output to the console
   
   try{
     throw new FormatException( "this is a test");
   }catch( e, st){
     logger.warning( "Caught something", e, st);
   }
}