import {
    LightningElement,
    track,
    wire
} from 'lwc';
// import My_Resource from '@salesforce/resourceUrl/LP_Design';
import {
    getRecord
} from 'lightning/uiRecordApi';
import MODPR_MessageChannel from '@salesforce/messageChannel/MODPR_MessageChannel__c';
import { subscribe, MessageContext } from 'lightning/messageService';
import USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_PROFILE_IMAGE from '@salesforce/schema/User.SmallPhotoUrl';
import basePath from "@salesforce/community/basePath";

import getAcrRecords from '@salesforce/apex/LPI_FCDashboardProfileCompletion.getAcrRecords';
import updateAcrSelectedOnParentAccount from '@salesforce/apex/LPI_FCDashboardProfileCompletion.updateAcrSelectedOnParentAccount';
import getHeaderNotifications from '@salesforce/apex/LPI_FCDashboardProfileCompletion.getHeaderNotifications';
import markHeaderNotificationsRead from '@salesforce/apex/LPI_FCDashboardProfileCompletion.markHeaderNotificationsRead';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import setLanguage from '@salesforce/apex/EMP_LanguageCtrl.setLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiHeader extends NavigationMixin(LightningElement) {
    menu = lpiResource + '/media/icons/menu.svg';
    profile = lpiResource + '/media/icons/lpiprofile.png';
    toggle = lpiResource + '/media/icons/toggleicon.svg';
    myProfile = lpiResource + '/media/icons/my-profile.svg';
    settings = lpiResource + '/media/icons/settings.svg';
    signOut = lpiResource + '/media/icons/sign-out.svg';
    logo = lpiResource + '/media/images/ibm-logo-white.svg';
    
    @track accountData = {};
    cmpHide;
    @track acrList = [];
    subscription = null;
    isBusinessAccount = true;
    isMainBusinessAccount = false;
    @track selectedLanguage = 'en_US';
    @track languageUpdating = false;
    @track labels = {
        selectedAccount: 'Selected Account',
        pleaseSelectAccount: 'Please Select Account',
        switchAccountHelp: 'Switch your account type by clicking Select Account here.',
        notifications: 'Notifications',
        noNotifications: 'No notifications available.',
        notifStatusUpdate: 'Application Status Update',
        notifMultipleUpdated: '{0} of your applications were updated.'
    };

    // Portal header notifications (CDC -> Notification__c; empApi unsupported in Experience Cloud)
    @track notifications = [];
    @track unreadCount = 0;
    @track showNotificationDropdown = false;
    notificationPollTimer;
    notificationsInitialized = false;
    markingNotificationsRead = false;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    currentPageReference;

    get languageOptions() {
        return [
            { label: 'English', value: 'en_US' },
            { label: 'French', value: 'fr' }
        ];
    }

    connectedCallback() {
        if (this.currentPageReference.attributes.name == 'Login') {
            window.open('/s/', '_self');
        }
        if (!USER_ID) {
            this.cmpHide = true;
        } else {
            this.handleSubscribe();
            this.initLanguage();
            this.initHeaderNotifications();
            try {
                getAcrRecords({})
                    .then(result => {
                        if (result.accList) {
                            this.acrList = result.accList;
                        }
                        if (result.accInfo) {
                            this.accountData = JSON.parse(JSON.stringify(result.accInfo));
                            if (this.accountData?.Name) {
                                this.selectedAccountName = this.accountData.Name;
                            }
                            if (this.accountData?.Id) {
                                this.selectedAccountId = this.accountData.Id;
                                if (this.acrList.length > 0) {
                                    this.acrList.forEach((item) => {
                                        if (item.Id === this.selectedAccountId) {
                                            item.showIcon = true;
                                        } else {
                                            item.showIcon = false;
                                        }
                                    });
                                }
                            }
                        } else {
                            this.selectedAccountId = '';
                            this.selectedAccountName = this.labels.pleaseSelectAccount;
                        }
                        if (result.businessAccount == true) {
                            this.isBusinessAccount = true;
                        } else {
                            this.isBusinessAccount = false;
                        }
                        if (result.businessAccount == true || (this.acrList != undefined && this.acrList.length == 1)) {
                            this.isMainBusinessAccount = true;
                        } else {
                            this.isMainBusinessAccount = false;
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });

            } catch (error) {

            } finally {
                this.showSpinner = false;
            }
        }

    }

    disconnectedCallback() {
        this.stopNotificationPolling();
    }

    initHeaderNotifications() {
        this.loadHeaderNotifications();
        this.startNotificationPolling();
    }

    startNotificationPolling() {
        this.stopNotificationPolling();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.notificationPollTimer = setInterval(() => {
            this.loadHeaderNotifications(true);
        }, 15000);
    }

    stopNotificationPolling() {
        if (this.notificationPollTimer) {
            clearInterval(this.notificationPollTimer);
            this.notificationPollTimer = null;
        }
    }

    loadHeaderNotifications(fromPoll) {
        getHeaderNotifications({ language: this.selectedLanguage || 'en_US' })
            .then((result) => {
                const nextNotifications = result?.notifications || [];
                const nextUnread = result?.unreadCount || 0;
                const previousIds = new Set((this.notifications || []).map((n) => n.id));
                const newlyAdded = nextNotifications.filter((n) => n.id && !previousIds.has(n.id));

                this.notifications = nextNotifications;

                // Do not restore the badge while mark-as-read is in progress,
                // or while the dropdown is open after the user has viewed notifications.
                if (this.markingNotificationsRead || this.showNotificationDropdown) {
                    this.unreadCount = 0;
                    this.notifications = nextNotifications.map((n) => ({
                        ...n,
                        isRead: true
                    }));
                } else {
                    this.unreadCount = nextUnread;
                }

                if (this.notificationsInitialized && fromPoll && newlyAdded.length === 1) {
                    const toastTitle =
                        newlyAdded[0].title ||
                        this.labels.notifStatusUpdate ||
                        'Application Status Update';
                    this.showMessage(toastTitle, newlyAdded[0].body, 'info');
                } else if (this.notificationsInitialized && fromPoll && newlyAdded.length > 1) {
                    const multiMsg = (
                        this.labels.notifMultipleUpdated ||
                        '{0} of your applications were updated.'
                    ).replace('{0}', String(newlyAdded.length));
                    this.showMessage(
                        this.labels.notifications || 'Notifications',
                        multiMsg,
                        'info'
                    );
                }
                this.notificationsInitialized = true;
            })
            .catch(() => {
                if (!fromPoll) {
                    this.notifications = [];
                    this.unreadCount = 0;
                }
                this.notificationsInitialized = true;
            });
    }

    toggleNotificationDropdown() {
        this.showNotificationDropdown = !this.showNotificationDropdown;
        if (!this.showNotificationDropdown) {
            return;
        }

        const unreadIds = (this.notifications || [])
            .filter((n) => n && n.id && !n.isRead)
            .map((n) => n.id);

        // Clear badge immediately on open
        this.unreadCount = 0;
        this.notifications = (this.notifications || []).map((n) => ({
            ...n,
            isRead: true
        }));

        const finishReload = () => {
            this.markingNotificationsRead = false;
            this.loadHeaderNotifications(true);
        };

        if (unreadIds.length) {
            this.markingNotificationsRead = true;
            markHeaderNotificationsRead({ notificationIds: unreadIds })
                .then(finishReload)
                .catch(() => {
                    // Keep badge cleared for this view even if server update fails
                    finishReload();
                });
        } else {
            this.loadHeaderNotifications(true);
        }
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, MODPR_MessageChannel, (message) => {
            this.userProfileImage = message.profileUrl;
        });
    }

    initLanguage() {
        const stored = readStoredLanguage();
        const applyLang = (resolvedLang) => {
            this.selectedLanguage = resolvedLang === 'fr' ? 'fr' : 'en_US';
            this.loadLabels(this.selectedLanguage);
        };
        if (stored === 'fr' || stored === 'en_US') {
            applyLang(stored);
            return;
        }
        getCurrentLanguage()
            .then((serverLang) => {
                const resolved = serverLang === 'fr' ? 'fr' : 'en_US';
                writeStoredLanguage(resolved);
                applyLang(resolved);
            })
            .catch(() => {
                applyLang('en_US');
            });
    }

    loadLabels(lang) {
        getLabels({ apiNames: LABEL_API_NAMES, language: lang })
            .then((apiMap) => {
                this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
                if (!this.selectedAccountId) {
                    this.selectedAccountName = this.labels.pleaseSelectAccount;
                }
            })
            .catch(() => {
                // keep defaults
            });
    }

    handleLanguageChange(event) {
        const next = event.detail.value;
        if (!next || next === this.selectedLanguage || this.languageUpdating) {
            return;
        }
        this.languageUpdating = true;
        writeStoredLanguage(next);
        setLanguage({ languageLocaleKey: next })
            .catch(() => {
                // Still apply selection
            })
            .finally(() => {
                this.selectedLanguage = next;
                setTimeout(() => {
                    window.location.reload();
                }, 250);
            });
    }

    handleChange(event) {
        try {
            const currentUrl = window.location.href;
            const myArray = currentUrl.split(/[/?]+/);
            if (myArray.includes('renew-license-details')) {
                this.showMessage('Error', 'You cannot change the account on this page. Please navigate to the home or dashboard page to switch accounts.', 'error');
            } else {
                if (this.selectedAccountId !== event.detail.value) {
                    this.selectedAccountId = event.detail.value;
                    let obj = this.acrList.find(o => o.Id == this.selectedAccountId);
                    if (obj) {
                        this.selectedAccountName = obj.Name;
                    }
                    if (this.selectedAccountId) {
                        updateAcrSelectedOnParentAccount({
                            accountId: this.selectedAccountId
                        })
                            .then(result => {
                                window.open('/s', '_self');
                            })
                            .catch(error => {
                            });
                    }
                }
            }
        } catch (error) {

        }
    }
    @track selectedAccountName = 'Please Select Account';
    @track selectedAccountId = '';
    @track error;
    @track userName;
    @track userProfileImage;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_NAME, USER_PROFILE_IMAGE]
    }) wireuser({
        error,
        data
    }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userProfileImage = data.fields.SmallPhotoUrl.value;
        } else if (error) {
            this.error = error;
        }
    }

    toggleSidebar() {
        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('open-sidebar');
            sidebar.classList.toggle("open");
        }
        sidebar.classList.toggle("close");
    }

    toggleNotificationbar() {
        let sidebar = document.querySelector(".notification-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('notification-bar-open');
        }
        sidebar.classList.toggle("close");
    }
    handleHome() {
        window.open('/s', '_self');
    }

    handleLogout() {
        window.sessionStorage.clear();
        const sitePrefix = basePath.replace(/\/s$/i, "");
        window.open(sitePrefix + "/secur/logout.jsp", '_self');
    }
    handleAccount() {
        window.open('/s/profile-details', '_self');
    }

    createCookie(name, valuee, days) {
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            var expires = "; expires=" + date.toGMTString();
        } else var expires = "";
        document.cookie = name + "=" + valuee + expires + "; path=/ ";
    }

    handleManageAccountClick() {
        let urlToManageAccount = '/s/manage-business-account?accId=' + this.selectedAccountId;
        window.open(urlToManageAccount, '_self');
    }

    showMessage(title, message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
}