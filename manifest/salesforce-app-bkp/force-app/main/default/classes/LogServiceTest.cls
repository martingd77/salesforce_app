@isTest
private class LogServiceTest {

    @isTest
    static void testCreateInfoLog() {
        Test.startTest();
        String message = 'Test message';
        LogService.createInfoLog(message);

        List<Log__c> logs = [SELECT Id, Message__c, Level__c FROM Log__c];
        Assert.areEqual(1, logs.size());
        Assert.areEqual(message, logs[0].Message__c);
        Assert.areEqual('INFO', logs[0].Level__c);
        Test.stopTest();
        
    }
}