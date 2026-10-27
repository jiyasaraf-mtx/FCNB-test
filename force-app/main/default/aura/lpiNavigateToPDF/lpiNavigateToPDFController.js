({
    navigate : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        window.open('/apex/LPI_PaymentReceiptPDFPage?targetId='+recordId,"_blank");
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
     doneRendering: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
   
})