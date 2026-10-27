({
    loadUserInfo: function(component) {
        var action = component.get("c.getCurrentUserInfo"); // Standard Apex call for User details
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    component.set("v.userName", data.Name);
                    component.set("v.userProfileImage", data.SmallPhotoUrl);
                }
            }
        });
        $A.enqueueAction(action);
    },

    initNotifications: function(component, helper) {
        helper.loadNotifications(component, helper, false);
        helper.startNotificationPolling(component, helper);
    },

    startNotificationPolling: function(component, helper) {
        helper.stopNotificationPolling(component);
        var timer = window.setInterval(
            $A.getCallback(function() {
                helper.loadNotifications(component, helper, true);
            }), 15000
        );
        component.set("v.notificationPollTimer", timer);
    },

    stopNotificationPolling: function(component) {
        var timer = component.get("v.notificationPollTimer");
        if (timer) {
            window.clearInterval(timer);
            component.set("v.notificationPollTimer", null);
        }
    },

    loadNotifications: function(component, helper, fromPoll) {
        var action = component.get("c.getHeaderNotifications");
        action.setParams({ language: component.get("v.selectedLanguage") || 'en_US' });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                var nextNotifications = (result && result.notifications) ? result.notifications : [];
                var nextUnread = (result && result.unreadCount) ? result.unreadCount : 0;
                
                var currentNotifs = component.get("v.notifications") || [];
                var previousIds = new Set(currentNotifs.map(function(n) { return n.id; }));
                var newlyAdded = nextNotifications.filter(function(n) { return n.id && !previousIds.has(n.id); });

                component.set("v.notifications", nextNotifications);
                component.set("v.unreadCount", nextUnread);

                var labels = component.get("v.labels") || {};
                var initialized = component.get("v.notificationsInitialized");
                if (initialized && fromPoll && newlyAdded.length === 1) {
                    helper.showToast(
                        newlyAdded[0].title || labels.notifStatusUpdate || 'Application Status Update',
                        newlyAdded[0].body,
                        'info'
                    );
                } else if (initialized && fromPoll && newlyAdded.length > 1) {
                    var multiMsg = (labels.notifMultipleUpdated || '{0} of your applications were updated.')
                        .replace('{0}', String(newlyAdded.length));
                    helper.showToast(labels.notifications || 'Notifications', multiMsg, 'info');
                }
                component.set("v.notificationsInitialized", true);
            }
        });
        $A.enqueueAction(action);
    },

    markNotificationsRead: function(component, unreadIds) {
        var action = component.get("c.markHeaderNotificationsRead");
        action.setParams({ notificationIds: unreadIds });
        action.setCallback(this, function(response) {});
        $A.enqueueAction(action);
    },

    loadAcrRecords: function(component, helper) {
        var action = component.get("c.getAcrRecords");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {
                    if (result.accList) component.set("v.acrList", result.accList);
                    if (result.accInfo) {
                        component.set("v.accountData", result.accInfo);
                        if (result.accInfo.Name) component.set("v.selectedAccountName", result.accInfo.Name);
                        if (result.accInfo.Id) component.set("v.selectedAccountId", result.accInfo.Id);
                    }
                    component.set("v.isBusinessAccount", !!result.businessAccount);
                    component.set("v.isMainBusinessAccount", result.businessAccount || (result.accList && result.accList.length === 1));
                }
            }
        });
        $A.enqueueAction(action);
    },

    initLanguage: function(component, helper) {
        var keys = ['arp_portal_language', 'portalLanguage', 'lp_portal_language', 'ep_portal_language'];
        var selectedLang = 'en_US';
        for (var i = 0; i < keys.length; i++) {
            var stored = localStorage.getItem(keys[i]);
            if (stored === 'fr' || stored === 'en_US') {
                selectedLang = stored;
                break;
            }
        }
        helper.setStoredLanguage(selectedLang);
        component.set("v.selectedLanguage", selectedLang);
        helper.loadHeaderLabels(component, selectedLang);
    },

    loadHeaderLabels: function(component, language) {
        var action = component.get("c.getLabels");
        action.setParams({
            apiNames: [
                'EP_Language',
                'EP_English',
                'EP_French',
                'EP_Selected_Account',
                'EP_Please_Select_Account',
                'EP_My_Profile',
                'EP_Logout',
                'EP_Manage_Account',
                'LP_Notifications',
                'LP_No_Notifications',
                'LP_Notif_Status_Update',
                'LP_Notif_Multiple_Updated'
            ],
            language: language
        });
        action.setCallback(this, function(response) {
            if (response.getState() !== 'SUCCESS') {
                return;
            }
            var apiMap = response.getReturnValue() || {};
            var current = component.get("v.labels") || {};
            var next = Object.assign({}, current, {
                language: apiMap.EP_Language || current.language,
                selectedAccount: apiMap.EP_Selected_Account || current.selectedAccount,
                pleaseSelectAccount: apiMap.EP_Please_Select_Account || current.pleaseSelectAccount,
                myProfile: apiMap.EP_My_Profile || current.myProfile,
                logout: apiMap.EP_Logout || current.logout,
                manageAccount: apiMap.EP_Manage_Account || current.manageAccount,
                notifications: apiMap.LP_Notifications || current.notifications,
                noNotifications: apiMap.LP_No_Notifications || current.noNotifications,
                notifStatusUpdate: apiMap.LP_Notif_Status_Update || current.notifStatusUpdate,
                notifMultipleUpdated: apiMap.LP_Notif_Multiple_Updated || current.notifMultipleUpdated
            });
            component.set("v.labels", next);
            component.set("v.languageOptions", [
                { label: apiMap.EP_English || 'English', value: 'en_US' },
                { label: apiMap.EP_French || 'French', value: 'fr' }
            ]);
            if (!component.get("v.selectedAccountId")) {
                component.set("v.selectedAccountName", next.pleaseSelectAccount);
            }
        });
        $A.enqueueAction(action);
    },

    setStoredLanguage: function(lang) {
        var keys = ['arp_portal_language', 'portalLanguage', 'lp_portal_language', 'ep_portal_language'];
        for (var i = 0; i < keys.length; i++) {
            try {
                localStorage.setItem(keys[i], lang);
            } catch (e) {
                // ignore storage failures
            }
        }
    },

    showToast: function(title, message, variant) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": variant
            });
            toastEvent.fire();
        }
    }
})