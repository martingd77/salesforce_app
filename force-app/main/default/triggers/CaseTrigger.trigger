trigger CaseTrigger on Case (after update) {
    CaseTriggerHandler.run(Trigger.new, Trigger.oldMap);
}