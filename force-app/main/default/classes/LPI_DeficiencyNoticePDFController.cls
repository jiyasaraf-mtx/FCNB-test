/**
 * @author          : MTX Group Product Team
 * @Description     : Controller class for Document Deficiency Notice PDF
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         20 Oct, 2023      MTX Group Product Team                   Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_DeficiencyNoticePDFController {
    // -------------------------------------------------- CONSTANTS ---------------------------------------------------------
    private static final String CLASS_NAME = 'LPI_DeficiencyNoticePDFController';
    private static final String MISSING = 'Missing';
    public DeficiencyNoticeWrapper documentData { get; private set; }
    private String applicationNumber;
    private static final String BUSINESS_ADDRESS = 'Business Address';
    private static final String RESIDENCE_ADDRESS = 'Residence';
    private static final String OPEN = 'Open';
    private static final String LOCATION = 'Location';
    // -----------------------------------------------------------------------------------------------------------------------

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Oct 2023
     * @description                 : Constructor
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_DeficiencyNoticePDFController() {
        try {
            Id targetId = ApexPages.currentPage().getParameters().get('targetId');

            if (
                String.isNotBlank(targetId) &&
                (targetId.getSObjectType() == Schema.BusinessLicenseApplication.getSObjectType() ||
                targetId.getSObjectType() == Schema.IndividualApplication.getSObjectType())
            ) {
                this.fetchDataForDocument(targetId);
                if (this.documentData != null) {
                    string fileName = 'Deficiency Notice_' + this.applicationNumber;
                    Apexpages.currentPage()
                        .getHeaders()
                        .put('content-disposition', 'attachment; filename=' + fileName + '.pdf');
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'LPI_DeficiencyNoticePDFController', e);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Oct 2023
     * @description                 : This Method fetch all details for PDF
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private void fetchDataForDocument(Id targetId) {
        DeficiencyNoticeWrapper dfNoticeWrapper = new DeficiencyNoticeWrapper();
        Id licensePermitId;
        String whereClause,address;
        if (targetId.getSObjectType() == Schema.BusinessLicenseApplication.getSObjectType()) {
            List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                'Id,Name,LicenseType.Name,LicensePermitName.Name,Board_Name__c,LicensePermitNameId',
                'Id =\'' + targetId + '\'',
                null,
                null,
                null
            );
            // Fetching all Dynamic varibales
            if (!blaList.isEmpty()) {
                dfNoticeWrapper.applicationNumber = blaList[0].Name;
                dfNoticeWrapper.licenseType = blaList[0].LicenseType.Name;
                dfNoticeWrapper.licenseNumber = blaList[0].LicensePermitName.Name;
                dfNoticeWrapper.boardName = blaList[0].Board_Name__c;
                this.applicationNumber = blaList[0].Name;
                licensePermitId = blaList[0].LicensePermitNameId;
                whereClause = 'Application__c =\'' + targetId + '\'' + ' AND Status__c = \'' + MISSING + '\'';
                address = BUSINESS_ADDRESS ;
            }
        } else if (targetId.getSObjectType() == Schema.IndividualApplication.getSObjectType()) {
            List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                'Id,Name,LicenseType.Name,LicensePermitName.Name,Board_Name__c,LicensePermitNameId',
                'Id =\'' + targetId + '\'',
                null,
                null,
                null
            );
            // Fetching all Dynamic varibales
            if (!iaList.isEmpty()) {
                dfNoticeWrapper.applicationNumber = iaList[0].Name;
                dfNoticeWrapper.licenseType = iaList[0].LicenseType.Name;
                dfNoticeWrapper.licenseNumber = iaList[0].LicensePermitName.Name;
                dfNoticeWrapper.boardName = iaList[0].Board_Name__c;
                this.applicationNumber = iaList[0].Name;
                licensePermitId = iaList[0].LicensePermitNameId;
                whereClause = 'Individual_Application__c =\'' + targetId + '\'' + ' AND Status__c = \'' + MISSING + '\'';
                address = RESIDENCE_ADDRESS;
            }
        }

        // Fetching all due dilligence with Missing Status
        List<Due_Diligence__c> iaDueDiligenceList = LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
            'Id,Comment__c,Checklist_Name__c,Sequence__c',
            whereClause,
            null,
            'Sequence__c',
            null
        );
        if (!iaDueDiligenceList.isEmpty()) {
            dfNoticeWrapper.dueDiligenceList = new List<CommentWrapper>();
            for (Due_Diligence__c dueDiligence : iaDueDiligenceList) {
                CommentWrapper cw = new CommentWrapper();
                cw.commentText = dueDiligence.Comment__c;
                cw.isCommentAdded = String.isNotBlank(dueDiligence.Comment__c);
                cw.checkListItemName = dueDiligence.Checklist_Name__c;
                dfNoticeWrapper.dueDiligenceList.add(cw);
            }
            this.documentData = dfNoticeWrapper;
        }


        // Fetching Address from Business License
        Set<Id> locationIdSet = new Set<Id>();
        if (licensePermitId != null) {
            for (
                AuthApplicationPlace aap : new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO()
                    .getAuthAppPlaceByDymQueryWithoutSecurity(
                        'Id,PlaceId,TYPEOF Place WHEN Location Then Id,LocationType,Status__c END',
                        'AuthorizationId =\'' + licensePermitId + '\'' + ' AND Place.Type =\'' + LOCATION + '\'',
                        null,
                        null,
                        null
                    )
            ) {
                if (aap.Place instanceof Schema.Location) {
                    locationIdSet.add(aap.PlaceId);
                }
            }
            if (!locationIdSet.isEmpty()) {
                for (
                    Schema.Address add : new LPI_AddressDAO.LPI_AddressDAOWithoutSharing()
                        .getAddressByDymanicQuery(
                            'Id,Street,City,State,Country,PostalCode,Business_State__c',
                            'ParentId IN' +
                                LPI_ServiceUtility.getStringValuesBySet(locationIdSet) +
                                ' AND Parent.locationType =\'' +
                                address +
                                '\'' +
                                ' AND Parent.Status__c =\'' +
                                OPEN +
                                '\'',
                            '1',
                            'CreatedDate',
                            'DESC'
                        )
                ) {
                    dfNoticeWrapper.street = add.street;
                    dfNoticeWrapper.city = add.City;
                    if (add.State == null) {
                        dfNoticeWrapper.state = add.Business_State__c;
                    } else {
                        dfNoticeWrapper.state = add.State;
                    }
                    dfNoticeWrapper.country = add.Country;
                    dfNoticeWrapper.postalCode = add.PostalCode;
                }
                this.documentData = dfNoticeWrapper;
            }
        }
    }

    public class DeficiencyNoticeWrapper {
        public string applicationNumber { get; private set; }
        public string licenseType { get; private set; }
        public string licenseNumber { get; private set; }
        public string boardName { get; private set; }
        public List<CommentWrapper> dueDiligenceList { get; private set; }
        public string street { get; private set; }
        public string city { get; private set; }
        public string state { get; private set; }
        public string country { get; private set; }
        public string postalCode { get; private set; }
    }
    
    public class CommentWrapper{
        public string commentText {get;private set;}
        public Boolean isCommentAdded {get;private set;}
        public String checkListItemName {get;private set;}  
    }
}