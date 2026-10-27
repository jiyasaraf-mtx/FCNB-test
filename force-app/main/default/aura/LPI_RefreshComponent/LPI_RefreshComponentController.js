({
    handleInit : function(component, event, helper) {
        setTimeout(function(){ 
            $A.get('e.force:refreshView').fire();
        }, 1);


    }
})