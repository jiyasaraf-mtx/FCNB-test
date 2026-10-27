import { LightningElement,api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const actions = [
    { label: 'Resume', name: 'resume' }
];

const columns = [
    { label: 'Application Number', fieldName: 'parUrl', type:'url',typeAttributes: {label: { fieldName: 'name' }, 
    target: '_blank'}, wrapText: true},
    { label: 'License Type', fieldName: 'licenseType' },
    { label: 'Application Type', fieldName: 'applicationType' },
    { label: 'Submitted Date', fieldName: 'submittedDate' },
    { label: 'Status', fieldName: 'status' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
import {
    NavigationMixin
} from 'lightning/navigation';
import fetchDraftApplication from '@salesforce/apex/LPI_DraftApplicationViewController.fetchDraftApplication'
import getIsPortalUser from '@salesforce/apex/LPI_InternalRegistration.getIsPortalUser';

export default class LpiDraftApplicationView extends NavigationMixin(LightningElement) {
    @api recordId;
    data = [];
    columns = columns;
    record = {};
    isPortalUser;
    fetchDraftApplication(){
        fetchDraftApplication({recordId : this.recordId})
        .then((result)=>{
            let draftArray = [];
            result.forEach(parDetail => {
                parDetail.parUrl = '/' + parDetail.id;
                draftArray.push(parDetail);
            });
            this.data = draftArray;
        })
        .catch((error)=>{
            console.log(JSON.stringify(error));
        })
    }
    connectedCallback(){
        this.fetchDraftApplication();
        getIsPortalUser()
            .then(result => {
                this.isPortalUser = result;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'resume':
                this.resumeApplication(row);
                break;
            default:
        }
    }
    resumeApplication(row){
        const { id,savedApplicationUrl,type,isSupportStaffCreated, instanceId } = row;
        if(!isSupportStaffCreated){
            this.showMessage('Error','You are not allowed to resume this application.', 'error');
        }else{
            let newUrl =savedApplicationUrl;
            newUrl = newUrl + '&c__parid='+id+'&type='+type.toLowerCase();
            const myUrlSplit = newUrl.split("&");
            var target = '';
            var c__ContextId = '';
            var c__parid = '';
            var lateRenewal = '';
            var c__type = '';
            let portalUser = this.isPortalUser.toString();
            myUrlSplit.forEach(element => {
                var paramSplit = element.split("=");
                if (paramSplit[0] == 'c__target') {
                    target = paramSplit[1];
                } else if (paramSplit[0] == 'ContextId') {
                    c__ContextId = paramSplit[1];
                } else if (paramSplit[0] == 'c__parid') {
                    c__parid = paramSplit[1];
                }else if (paramSplit[0] == 'lateRenewal') {
                    lateRenewal = paramSplit[1];
                }else if (paramSplit[0] == 'type') {
                    c__type = paramSplit[1];
                }
            });
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'omnistudio__vlocityLWCOmniWrapper'
                },
                state: {
                    c__target: target,
                    c__layout: 'lightning',
                    c__tabIcon: 'custom:custom18',
                    c__tabLabel: 'Apply for license',
                    c__ContextId: c__ContextId,
                    c__parid: c__parid,
                    c__type : c__type,
                    c__portalUser: portalUser,
                    c__lateRenewal : lateRenewal,
                    c__accountId: this.recordId,
                    c__instanceId: instanceId
                }
            })
        }
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
}