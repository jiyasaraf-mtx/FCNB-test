({
    doInit: function (component, event, helper) {
        var action = component.get("c.populateCaseOnCompanionComplaintRecords");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var responseValue = response.getReturnValue();
            console.log('RESPONSE VALUE >> ' + JSON.stringify(response));

            if(responseValue == 'CaseExist'){
                helper.showToast('', 'Case(s) already created for all the respondents added on the Complaint.', 'warning');
            }
            else if(responseValue == 'NoRecordFound'){
                helper.showToast('', 'Public complaint not found.', 'warning');
            }
            else if(responseValue == 'NoRespondent'){
                helper.showToast('', 'Complaint has no respondent attached to it.', 'warning');
            }
            else if(responseValue == 'NoJunctionRecord') {
                helper.showToast('','Cannot find proper Junction Record for this Complaint','warning');
            } else if(responseValue == 'CaseExistsOrNoJunctionFound') {
                helper.showToast('','Case Already Exists or Could not Fetch Proper Companion Complaint Case Records.');
            }
            else {
                helper.showToast('', 'Case Created Successfully : '+ responseValue, 'success');
            }
        });
        $A.enqueueAction(action);
    },
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    }
    
})