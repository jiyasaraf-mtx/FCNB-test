({
    render : function(cmp, helper) {

        var ret = this.superRender();
        // cmp.set("v.showSidebar",true);
        // console.log('true',window.location.pathname);

        // Added this code to check the login user type based on which we show the home page.
        var action = cmp.get("c.getUserName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != 'Guest'){
                    cmp.set("v.userVar",false);
                    // if(window.location.pathname == '/license/s/' || window.location.pathname.includes('licensing-information')){
                        cmp.set("v.showSidebar",true);
                        cmp.set("v.headerHide",true);
                        cmp.set("v.landingHeader",false);
                        cmp.set("v.guestClass",true);
                    // }
                }
                else{
                    cmp.set("v.userVar",true);
                    cmp.set("v.headerHide",false);
                    cmp.set("v.showSidebar",false);
                    if(window.location.pathname ==  '/s/login/' || window.location.pathname == '/employerportal/s/login/' || window.location.pathname == '/agentreviewportal/s/login/' || window.location.pathname == '/pensionportal/s/login/'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/login/SelfRegister'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/login/ForgotPassword'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/login/CheckPasswordResetEmail'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/reset-password'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/reset-password-success'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/forgot-username'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/registration'){
                        cmp.set("v.userVar",false);
                    }
                    if(window.location.pathname == '/s/business-registration'){
                        cmp.set("v.userVar",false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
        // end

        if(window.location.pathname ==  '/s/login/' || window.location.pathname == '/employerportal/s/login/' || window.location.pathname == '/agentreviewportal/s/login/' || window.location.pathname == '/pensionportal/s/login/'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
            // showSidebar = false;
        }
        if(window.location.pathname.includes('licensing')){
            cmp.set("v.showSidebar",true);
            cmp.set("v.headerHide",true);
            cmp.set("v.landingHeader",false);
            cmp.set("v.guestClass",true);
        }
        // if(window.location.pathname.includes('dashboard')){
        //     cmp.set("v.showSidebar",true);
        //     cmp.set("v.headerHide",true);
        //     cmp.set("v.landingHeader",false);
        //     cmp.set("v.test",true);
        // }

        // if(window.location.pathname.includes('recommended-licenses')){
        //     cmp.set("v.showSidebar",true);
        //     cmp.set("v.headerHide",true);
        //     cmp.set("v.landingHeader",false);
        //     cmp.set("v.test",true);
        // }

        // if(window.location.pathname == '/license/s/' || window.location.pathname.includes('licensing-information')){
        //     cmp.set("v.showSidebar",false);
        //     cmp.set("v.headerHide",false);
        //     cmp.set("v.landingHeader",true);
        //     cmp.set("v.test",false);
        // }
        
        if(window.location.pathname == '/s/registration'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
            cmp.set("v.landingHeader",false);
        }
        if(window.location.pathname == '/s/login/ForgotPassword' || window.location.pathname == '/s/forgot-username'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
            cmp.set("v.landingHeader",false);
        }
        if(window.location.pathname == '/s/login/CheckPasswordResetEmail'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
        }
        if(window.location.pathname == '/s/reset-password'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
        }
        if(window.location.pathname == '/s/reset-password-success'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
        }
        if(window.location.pathname == '/s/license-downloads'){
            cmp.set("v.showSidebar",false);
        }
        if(window.location.pathname == '/s/business-registration'){
            cmp.set("v.showSidebar",false);
            cmp.set("v.headerHide",false);
            cmp.set("v.landingHeader",false);
        }
        return ret;
    },
// Your renderer method overrides go here
   
})