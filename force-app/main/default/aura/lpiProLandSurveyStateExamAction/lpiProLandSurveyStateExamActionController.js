({
    handleClose: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },


    callBackendFunction: function (component, event, helper) {
        var action = component.get('c.isPlsExamNotificatoAlreadySent');
        action.setParams({
            "iaId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.hideModal', !response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }



})