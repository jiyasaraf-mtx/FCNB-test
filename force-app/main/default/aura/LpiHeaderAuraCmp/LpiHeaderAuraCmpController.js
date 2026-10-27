({
    doInit: function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if (!userId) {
            component.set("v.cmpHide", true);
        } else {
            helper.loadUserInfo(component);
            helper.initLanguage(component, helper);
            helper.initNotifications(component, helper);
            helper.loadAcrRecords(component, helper);
        }
    },

    handleDestroy: function(component, event, helper) {
        helper.stopNotificationPolling(component);
    },

    toggleNotificationDropdown: function(component, event, helper) {
        var currentState = component.get("v.showNotificationDropdown");
        component.set("v.showNotificationDropdown", !currentState);
        
        if (!currentState) {
            helper.loadNotifications(component, helper, true);
            var unread = component.get("v.unreadCount");
            if (unread > 0) {
                var notifications = component.get("v.notifications") || [];
                var unreadIds = [];
                notifications.forEach(function(n) {
                    if (n && n.id && !n.isRead) {
                        unreadIds.push(n.id);
                    }
                });
                component.set("v.unreadCount", 0);
                if (unreadIds.length > 0) {
                    helper.markNotificationsRead(component, unreadIds);
                }
            }
        }
    },

    handleLanguageChange: function(component, event, helper) {
        var nextLang = event.getParam("value");
        if (!nextLang || nextLang === component.get("v.selectedLanguage") || component.get("v.languageUpdating")) {
            return;
        }
        component.set("v.languageUpdating", true);
        helper.setStoredLanguage(nextLang);
        
        var action = component.get("c.setLanguage");
        action.setParams({ languageLocaleKey: nextLang });
        action.setCallback(this, function(response) {
            component.set("v.selectedLanguage", nextLang);
            setTimeout($A.getCallback(function() {
                window.location.reload();
            }), 250);
        });
        $A.enqueueAction(action);
    },

    handleChange: function(component, event, helper) {
        var selectedId = event.getParam("value");
        var currentUrl = window.location.href;
        if (currentUrl.includes('renew-license-details')) {
            helper.showToast('Error', 'You cannot change the account on this page. Please navigate to the home or dashboard page to switch accounts.', 'error');
            return;
        }

        if (component.get("v.selectedAccountId") !== selectedId) {
            component.set("v.selectedAccountId", selectedId);
            var acrList = component.get("v.acrList");
            var selectedObj = acrList.find(function(o) { return o.Id === selectedId; });
            if (selectedObj) {
                component.set("v.selectedAccountName", selectedObj.Name);
            }
            if (selectedId) {
                var action = component.get("c.updateAcrSelectedOnParentAccount");
                action.setParams({ accountId: selectedId });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        window.open('/s', '_self');
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },

    toggleSidebar: function(component, event, helper) {
        var sidebar = document.querySelector(".nav-sidebar");
        var sidebarWrapper = document.querySelector(".main-content");
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('open-sidebar');
            if (sidebar) sidebar.classList.toggle("open");
        }
        if (sidebar) sidebar.classList.toggle("close");
    },

    handleHome: function(component, event, helper) {
        window.open('/s', '_self');
    },

    handleLogout: function(component, event, helper) {
        window.sessionStorage.clear();
        window.open("/secur/logout.jsp", '_self');
    },

    handleAccount: function(component, event, helper) {
        window.open('/s/profile-details', '_self');
    },

    handleManageAccountClick: function(component, event, helper) {
        var accId = component.get("v.selectedAccountId");
        window.open('/s/manage-business-account?accId=' + accId, '_self');
    }
})