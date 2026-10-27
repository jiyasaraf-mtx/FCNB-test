/**
 * Agent Reviewer Portal language helpers.
 * Reuses EMP_LanguageCtrl.getLabels; stores preference separately from Employer Portal.
 */
const STORAGE_KEY = 'arp_portal_language';

/** Shared EP_ labels reused to avoid ARP_ duplicates for common UI words. */
const SHARED_EP_LABELS = [
    'EP_Language',
    'EP_English',
    'EP_French',
    'EP_Language_Updated',
    'EP_Cancel',
    'EP_Status',
    'EP_Email',
    'EP_Phone',
    'EP_Save',
    'EP_SIR_Confirm',
    'EP_Something_Went_Wrong',
    'EP_SIR_Refresh',
    'EP_SIR_Filters',
    'EP_SIR_Applicant',
    'EP_SIR_Agency',
    'EP_SIR_Submitted',
    'EP_SIR_Applicant_Name',
    'EP_SIR_DOB',
    'EP_SIR_Transaction_Id',
    'EP_SIR_Current_Status',
    'EP_SIR_Submitted_On',
    'EP_Licence_Type',
    'EP_Dashboard',
    'EP_Close',
    'EP_Search',
    'EP_First_Name',
    'EP_Last_Name',
    'EP_Description',
    'EP_Documents',
    'EP_SIR_Action'
];

const ARP_LABEL_API_NAMES = [
    'ARP_Agent_Review',
    'ARP_Subtitle',
    'ARP_Demo_Boundary',
    'ARP_Empty_Queue',
    'ARP_Submitted_To_Agent',
    'ARP_Confirm_Employment',
    'ARP_Review_NBREA_CRC',
    'ARP_Decision',
    'ARP_Step1_Desc',
    'ARP_Step2_Desc',
    'ARP_Step3_Desc',
    'ARP_Step4_Desc',
    'ARP_Chip_Applicant_Licence',
    'ARP_Approve_Control',
    'ARP_Document_List',
    'ARP_Agency_Require_More_Info',
    'ARP_Submitted_To_FCNB',
    'ARP_Agency_Denied',
    'ARP_Branch_RMI',
    'ARP_Branch_Approve',
    'ARP_Salesperson_Licensing',
    'ARP_Queue_Title',
    'ARP_Search_Placeholder',
    'ARP_All_Statuses',
    'ARP_Licence',
    'ARP_Review',
    'ARP_View',
    'ARP_Showing',
    'ARP_Detail_Title',
    'ARP_Return_More_Info',
    'ARP_Approve',
    'ARP_Reject',
    'ARP_Applicant_Information',
    'ARP_Employment_Representation',
    'ARP_Agent_Reviewer',
    'ARP_Declaration',
    'ARP_Confirmed',
    'ARP_Employment_Check',
    'ARP_Confirm_Employment_Opt',
    'ARP_Needs_Clarification',
    'ARP_Document_Review',
    'ARP_Uploaded_Available',
    'ARP_Document_Review_Result',
    'ARP_Documents_Complete',
    'ARP_Missing_Document',
    'ARP_Application_Summary',
    'ARP_Next_Stage',
    'ARP_Next_Stage_Value',
    'ARP_Agent_Decision',
    'ARP_Reason_Requested',
    'ARP_Comments_Placeholder',
    'ARP_Approval_Hint',
    'ARP_Clear_Changes',
    'ARP_Save_Decision',
    'ARP_Select_Application',
    'ARP_Queue_Refreshed',
    'ARP_View_Only',
    'ARP_Confirm_Before_Approve',
    'ARP_Complete_Doc_Review',
    'ARP_Approve_Title',
    'ARP_Approve_Text',
    'ARP_Enter_Rmi_Reason',
    'ARP_Rmi_Title',
    'ARP_Rmi_Text',
    'ARP_Enter_Deny_Reason',
    'ARP_Reject_Title',
    'ARP_Reject_Text',
    'ARP_Enter_Missing_Items',
    'ARP_Save_Rmi_Title',
    'ARP_Save_Rmi_Text',
    'ARP_Save_Approval_Title',
    'ARP_Save_Approval_Text',
    'ARP_No_Decision_Required',
    'ARP_Changes_Cleared',
    'ARP_Select_First',
    'ARP_Returned_Msg',
    'ARP_Approved_Msg',
    'ARP_Denied_Msg',
    'ARP_Select_An_Application',
    'ARP_Loading_Queue',
    'ARP_Org_Dashboard_Title',
    'ARP_Delegate_Access',
    'ARP_Delegation_Activity',
    'ARP_Organization_Access',
    'ARP_Branches_Locations',
    'ARP_Sponsored_Agents',
    'ARP_Org_Dashboard_Subtitle',
    'ARP_Delegate_Subtitle',
    'ARP_Activity_Subtitle',
    'ARP_Organization_Subtitle',
    'ARP_Branches_Subtitle',
    'ARP_Sponsored_Subtitle',
    'ARP_Access_Overview',
    'ARP_Click_Card_Explore',
    'ARP_Admin_Access_Title',
    'ARP_Admin_Access_Desc',
    'ARP_Delegated_Access_Title',
    'ARP_Delegated_Access_Desc',
    'ARP_Sponsored_Tile_Desc',
    'ARP_Recent_Delegation',
    'ARP_Quick_Actions',
    'ARP_Delegate_Access_Hint',
    'ARP_Review_Org_Access',
    'ARP_Review_Org_Access_Hint',
    'ARP_Search_Salesperson_Placeholder',
    'ARP_Salesperson',
    'ARP_Company',
    'ARP_Access_Type',
    'ARP_Last_Activity',
    'ARP_Using_Delegated_Access',
    'ARP_Delegated_Out',
    'ARP_Own_Access',
    'ARP_Revoke_Access',
    'ARP_Unavailable',
    'ARP_Showing_Salespeople',
    'ARP_Delegate_Inactive_Hint',
    'ARP_Date_Time',
    'ARP_Delegated_From',
    'ARP_Delegated_To',
    'ARP_Reason',
    'ARP_Users_Access_Relationships',
    'ARP_Users_Admin_Summary',
    'ARP_User',
    'ARP_Role',
    'ARP_Access_Source',
    'ARP_Branch',
    'ARP_Task_Permissions',
    'ARP_Using_Access_Of',
    'ARP_Delegated_To_Person',
    'ARP_Add_Branch',
    'ARP_Add_Sponsored_Agent',
    'ARP_Users_Count',
    'ARP_Agent',
    'ARP_Sponsored_By',
    'ARP_Permissions',
    'ARP_Sponsored_Agent_Label',
    'ARP_Delegate_Reviewer_Access',
    'ARP_Current_Access_Holder',
    'ARP_Delegate_Access_To',
    'ARP_Reason_Optional',
    'ARP_Important',
    'ARP_Delegate_Important_Text',
    'ARP_Confirm_Delegation',
    'ARP_Access_Delegated_Success',
    'ARP_Access_Relationship_Updated',
    'ARP_Original_User',
    'ARP_Receiving_User',
    'ARP_Status_Inactive',
    'ARP_Status_Active_Delegated',
    'ARP_Done',
    'ARP_Delegation_Details',
    'ARP_Delegated_To_Colon',
    'ARP_Current_Status_Colon',
    'ARP_Branch_Name',
    'ARP_Address',
    'ARP_Branch_Name_Placeholder',
    'ARP_Street_Address',
    'ARP_Optional_Description',
    'ARP_Branch_Name_Required',
    'ARP_Select_Branch',
    'ARP_Names_Required',
    'ARP_Status_Updated',
    'ARP_Access_Revoked',
    'ARP_Select_Salesperson_Receive',
    'ARP_Org_User_Updated',
    'ARP_Permissions_Updated',
    'ARP_Branch_Created',
    'ARP_Sponsored_Agent_Added',
    'ARP_Active',
    'ARP_Inactive',
    'ARP_Suspended',
    'ARP_Role_Company_Administrator',
    'ARP_Role_Salesperson',
    'ARP_Role_Sponsored_Agent',
    'ARP_Role_Reviewer',
    'ARP_Role_Read_Only',
    'ARP_Perm_Review_Applications',
    'ARP_Perm_Delegate',
    'ARP_Perm_Review_Submit',
    'ARP_Perm_Review_Only',
    'ARP_Perm_View_Inspections',
    'ARP_Perm_Submit_Documents',
    'ARP_Success',
    'ARP_Error',
    'ARP_Saved',
    'ARP_Saving',
    'ARP_No_License',
    'ARP_From',
    'ARP_To',
    'ARP_Company_Administration',
    'ARP_Organization'
];

const LABEL_API_NAMES = [...SHARED_EP_LABELS, ...ARP_LABEL_API_NAMES];

function toCamel(apiName) {
    const stripped = apiName.replace(/^(ARP_|EP_SIR_|EP_)/, '');
    const parts = stripped.split('_');
    return parts
        .map((p, i) => {
            const lower = p.toLowerCase();
            return i === 0 ? lower : lower.charAt(0).toUpperCase() + lower.slice(1);
        })
        .join('');
}

function mapApiToCamel(apiMap) {
    const out = {};
    Object.keys(apiMap || {}).forEach((api) => {
        out[toCamel(api)] = apiMap[api];
    });
    return out;
}

function readStoredLanguage() {
    try {
        const keys = [
            'arp_portal_language',
            'portalLanguage',
            'lp_portal_language',
            'ep_portal_language'
        ];
        for (const key of keys) {
            const v = window.localStorage.getItem(key);
            if (v === 'fr' || v === 'en_US') {
                return v;
            }
        }
    } catch (e) {
        // ignore
    }
    return null;
}

function writeStoredLanguage(lang) {
    try {
        const keys = [
            'arp_portal_language',
            'portalLanguage',
            'lp_portal_language',
            'ep_portal_language'
        ];
        keys.forEach((key) => {
            window.localStorage.setItem(key, lang);
        });
    } catch (e) {
        // ignore
    }
}

export {
    STORAGE_KEY,
    LABEL_API_NAMES,
    ARP_LABEL_API_NAMES,
    SHARED_EP_LABELS,
    toCamel,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
};