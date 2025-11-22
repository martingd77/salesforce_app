public with sharing class LogService {
    public static void createInfoLog(String message) {
        Log__c log = new Log__c(
            Message__c = message,
            Level__c = 'Info'
        );
        insert log;
    }
}