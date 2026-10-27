trigger SharingLedger_Trigger on Sharing_Ledger__c (before insert, before update, before delete, after undelete)
{
    if (trigger.isBefore)
    {
        if (trigger.isInsert)
            SharingLedger_TriggerHandler.beforeInsert(trigger.new);
        else if (trigger.isUpdate)
            SharingLedger_TriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        else if (trigger.isDelete)
            SharingLedger_TriggerHandler.beforeDelete(trigger.old);
    }
    else if (trigger.isAfter)
    {
        if (trigger.isUndelete)
            throw new GenericException('Undelete is not supported for this object.  Please insert a new record instead.');
    }
}