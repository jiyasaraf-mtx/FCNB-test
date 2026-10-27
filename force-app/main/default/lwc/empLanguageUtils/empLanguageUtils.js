/**
 * Shared Employer Portal language helpers for LWC.
 */
const STORAGE_KEY = 'ep_portal_language';

const LABEL_API_NAMES = [
    'EP_Language', 'EP_English', 'EP_French', 'EP_Language_Updated',
    'EP_Selected_Account', 'EP_My_Profile', 'EP_Logout', 'EP_Manage_Account',
    'EP_Please_Select_Account', 'EP_Menu', 'EP_Help', 'EP_Dashboard',
    'EP_Financial_Filings', 'EP_Cancel', 'EP_Close', 'EP_Expand', 'EP_Collapse',
    'EP_All_Annual_Financial_Filings', 'EP_Showing_All_Filings', 'EP_Draft',
    'EP_Submitted', 'EP_Accepted', 'EP_Rejected', 'EP_Financial_Filing_Requirements',
    'EP_Annual_Financial_Filing_Requirements_For', 'EP_Portal_Home', 'EP_Filings',
    'EP_Open_Filing', 'EP_Add_Annual_Filing', 'EP_Parent_Licence', 'EP_Filing_Type',
    'EP_Reporting_Year', 'EP_Due', 'EP_Current_Filing', 'EP_In_Progress',
    'EP_Under_Review', 'EP_Completed', 'EP_Action_Required', 'EP_Clear_Filter',
    'EP_Show_All', 'EP_Filing_Transactions', 'EP_Filer', 'EP_Due_Date',
    'EP_Premiums_NB', 'EP_Edit_Draft', 'EP_View_Details', 'EP_No_Filings_Under_Status',
    'EP_What_Must_Be_Submitted', 'EP_Filing_Requirements_Checklist', 'EP_Required',
    'EP_Optional', 'EP_Reporting_Period', 'EP_Checklist_Reporting_Period_Desc',
    'EP_Filer_Contact', 'EP_Checklist_Filer_Contact_Desc', 'EP_Checklist_Financial_Amounts',
    'EP_Checklist_Financial_Amounts_Desc', 'EP_Annual_Statements',
    'EP_Checklist_Annual_Statements_Desc', 'EP_Attestation', 'EP_Checklist_Attestation_Desc',
    'EP_Checklist_Certification', 'EP_Checklist_Certification_Desc', 'EP_Requirement_Profile',
    'EP_Filing_Setup', 'EP_Edit_Filing_Setup', 'EP_Filing_ID', 'EP_Status',
    'EP_Licence_Type', 'EP_Required_Financial_Values', 'EP_Field', 'EP_Value',
    'EP_Total_Assets', 'EP_Total_Liabilities', 'EP_Written_Premiums_NB',
    'EP_Other_NB_Amounts', 'EP_Yes', 'EP_No', 'EP_As_Configured', 'EP_Documents_Evidence',
    'EP_Upload_Document', 'EP_Upload_Annual_Statements_Desc', 'EP_Create_Filing_First',
    'EP_Accepted_File_Types', 'EP_Uploaded_To_Files', 'EP_Preview', 'EP_Remove',
    'EP_Annual_Statements_Required', 'EP_Upload_Evidence', 'EP_Submission_Rule',
    'EP_Staff_Ready_View', 'EP_Financial_Analysis', 'EP_Open_Staff_Analysis',
    'EP_NB_Written_Premiums', 'EP_Review_Requirement', 'EP_Hero_Sub',
    'EP_Annual_Financial_Filing', 'EP_Add_Annual_Filing_Help', 'EP_Create_Draft',
    'EP_Period_Start', 'EP_Period_End', 'EP_Search_License_Placeholder',
    'EP_Search_By_License_Hint', 'EP_No_Matching_Licenses', 'EP_Select_Parent_Licence',
    'EP_Edit_Filing_Setup_Help', 'EP_Filer_Account', 'EP_Filer_First_Name',
    'EP_Filer_Last_Name', 'EP_Filer_Email', 'EP_Filer_Phone', 'EP_Save_Changes',
    'EP_Filing_Header', 'EP_Financials', 'EP_Documents', 'EP_Validation_Attestation',
    'EP_Submit', 'EP_Open_Filing_Wizard', 'EP_Continue_To_Submit', 'EP_Edit',
    'EP_Evidence', 'EP_Workflow', 'EP_Description', 'EP_Statements', 'EP_Assets',
    'EP_Liabilities', 'EP_Editable_Draft', 'EP_Complete', 'EP_Not_Complete',
    'EP_Save_Draft', 'EP_Save_And_Submit', 'EP_Draft_Created', 'EP_Setup_Updated',
    'EP_No_Filing_Available', 'EP_Staff_Analysis_Opened', 'EP_Something_Went_Wrong',
    'EP_Upload_Before_Save', 'EP_Complete_Attestation', 'EP_Upload_Before_Submit',
    'EP_No_Document_Attached', 'EP_Statements_Removed', 'EP_Statements_Removed_Draft',
    'EP_No_Document_To_Remove', 'EP_Opening_Next_Step', 'EP_No_Filing_To_Edit',
    'EP_Filing_Details', 'EP_No_Document_Name', 'EP_Workflow_Draft',
    'EP_Workflow_Submitted', 'EP_Workflow_Accepted', 'EP_Workflow_Rejected',
    'EP_Record_Singular', 'EP_Record_Plural', 'EP_Annual_Statements_Doc',
    'EP_Upload_Or_Replace', 'EP_Current_Filing_Evidence', 'EP_Required_Star',
    'EP_Period', 'EP_Header', 'EP_Validation', 'EP_Attest_Confirm',
    'EP_NB_Premiums_Short', 'EP_Email', 'EP_Phone', 'EP_Save',
    // Financial Filing – Missing Schedule
    'EP_Request_Missing_Schedule', 'EP_Missing_Schedule_Submitted',
    'EP_Missing_Schedule_Caption', 'EP_Previously_Uploaded', 'EP_Download',
    'EP_Save_Updated_Filing', 'EP_Edit_Missing_Schedule',
    'EP_Workflow_Request_Missing_Schedule', 'EP_Workflow_Missing_Schedule_Submitted',
    'EP_FF_Email_Subject', 'EP_FF_Email_Greeting', 'EP_FF_Email_Received',
    'EP_FF_Email_Filing_Number', 'EP_FF_Email_Filing_Status', 'EP_FF_Email_Body_Review',
    'EP_FF_Email_Thank_You', 'EP_FF_Email_Signature', 'EP_FF_Notif_Title',
    'EP_FF_Notif_Subject_Missing_Schedule', 'EP_FF_Notif_Body_Missing_Schedule',
    // Sponsoring Insurer Review
    'EP_SIR_Title', 'EP_SIR_Subtitle', 'EP_SIR_Open_Queue', 'EP_SIR_Confirm_Class',
    'EP_SIR_Return_Applicant', 'EP_SIR_Approve_Online', 'EP_SIR_Reject_Sponsorship',
    'EP_SIR_Status_Prefix', 'EP_SIR_Life_Check', 'EP_SIR_Submitted_FCNB',
    'EP_SIR_Remains_On_File', 'EP_SIR_Queue_Title', 'EP_SIR_Refresh', 'EP_SIR_Filters',
    'EP_SIR_All', 'EP_SIR_RMI', 'EP_SIR_Approved', 'EP_SIR_Search_Placeholder',
    'EP_SIR_Applicant', 'EP_SIR_Agency', 'EP_SIR_Submitted', 'EP_SIR_Action',
    'EP_SIR_Empty', 'EP_SIR_Detail_Title', 'EP_SIR_Return_RMI', 'EP_SIR_Approve_Sponsorship',
    'EP_SIR_Reject', 'EP_SIR_Applicant_Info', 'EP_SIR_Applicant_Name', 'EP_SIR_DOB',
    'EP_SIR_CIPR', 'EP_SIR_Sponsorship_Review', 'EP_SIR_Class_Applied',
    'EP_SIR_Insurer_Licensed', 'EP_SIR_Class_Match', 'EP_SIR_Documents_Received',
    'EP_SIR_Insurer_Decision', 'EP_SIR_Comments', 'EP_SIR_App_Info', 'EP_SIR_Term',
    'EP_SIR_Agency_Firm', 'EP_SIR_Supervisor', 'EP_SIR_Submitted_On',
    'EP_SIR_Transaction_Id', 'EP_SIR_Current_Status', 'EP_SIR_Select_App',
    'EP_SIR_Confirm', 'EP_SIR_Flow_Note', 'EP_SIR_All_Agencies', 'EP_SIR_Select_Decision',
    'EP_SIR_Submitted_To_Insurer', 'EP_SIR_More_Info_Require', 'EP_SIR_Approved_By_Insurer',
    'EP_SIR_Denied_By_Insurer'
];

function toCamel(apiName) {
    const parts = apiName.replace(/^EP_/, '').split('_');
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
            STORAGE_KEY,
            'portalLanguage',
            'lp_portal_language',
            'arp_portal_language'
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
        [
            STORAGE_KEY,
            'portalLanguage',
            'lp_portal_language',
            'arp_portal_language'
        ].forEach((key) => {
            window.localStorage.setItem(key, lang);
        });
    } catch (e) {
        // ignore
    }
}

export {
    STORAGE_KEY,
    LABEL_API_NAMES,
    toCamel,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
};