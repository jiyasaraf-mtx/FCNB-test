({
    // handleLocationChange: function(component, event, helper) {
    //     var isLwcVisible = component.get("v. isLwcVisible");
    //     if (isLwcVisible) {
    //         component.set("v. isLwcVisible", false);
    //     } else {
    //         component.set("v. isLwcVisible", true);
    //     }
    // },
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }

})