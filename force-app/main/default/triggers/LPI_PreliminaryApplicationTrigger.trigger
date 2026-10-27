/**
 * @author   : MTX.Inc
 * @since    : 3rd nov, 2022
 * @description   : Trigger on PreliminaryApplicationTrigger object
 */
trigger LPI_PreliminaryApplicationTrigger on PreliminaryApplicationRef(before insert, before update, after insert, after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if (tcmdt.PreliminaryApplicationRef__c) {
        new LPI_PreliminaryApplicationTriggerHandler().run();
    }
}