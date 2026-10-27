/**
 * @description       : Controller class to create Incicent records while Complaint Investigation.
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 02-19-2024
 * @last modified by  : Mohit Karani
 **/
public with sharing class LPI_IncidentController {
    public static final String MEDIUM_TEXT = 'Medium';
    public static final String MODERATE_TEXT = 'Moderate';
    public static final String INCIDENT_TEXT = 'Incident';

    /**
     * @description : Method to fetch incident detail record.
     * @author Mohit Karani | 05-22-2023
     * @param recordId
     * @return LPI_Wrapper.IncidentWrapper
     **/
    @AuraEnabled
    public static LPI_Wrapper.IncidentWrapper getIncidentDetails(
        Id recordId
    ) {
        try {
            // return null if no record id or record id not for incident object.
            if (
                String.isBlank(recordId) ||
                String.valueOf(recordId.getsobjecttype()) != INCIDENT_TEXT
            ) {
                return null;
            }
            String fieldsToQuery = 'Id,Complaint_Number__r.OwnerId,Complaint_Number__c,Affected_Person__c,StartDateTime,EndDateTime,Affected_Person_DOB__c,Money_Paid__c,Injury_Severity__c,Location_Category__c,Location__c,Impact,Urgency,Subject,Priority';
            String whereClause =
                ' ID = \'' +
                String.escapeSingleQuotes(recordId) +
                '\'';
            List<Incident> incidentList = LPI_IncidentDao.fetchIncidents(
                fieldsToQuery,
                whereClause,
                null,
                null,
                null
            );
            // retrun if no incident found.
            if (incidentList.isEmpty()) {
                throw new LPI_Exception('No record found.');
            }

            if(UserInfo.getUserId() != incidentList[0].Complaint_Number__r.OwnerId){
                throw new LPI_Exception('You need to assign the Public Complaint record to yourself before updating the incident records.');
            }
            // prepare wrapper from the record.
            Incident incidentRec = incidentList[0];
            LPI_Wrapper.IncidentWrapper wrapper = new LPI_Wrapper.IncidentWrapper();
            wrapper.incidentId = incidentRec.Id;
            wrapper.affectedPerson = incidentRec.Affected_Person__c;
            wrapper.beginDate = Date.newInstance(
                incidentRec.StartDateTime.year(),
                incidentRec.StartDateTime.month(),
                incidentRec.StartDateTime.day()
            );
            wrapper.endDate = wrapper.endDate == NULL ? NULL : Date.newInstance(
                incidentRec.EndDateTime.year(),
                incidentRec.EndDateTime.month(),
                incidentRec.EndDateTime.day()
            );
            wrapper.affectedPersonDob = incidentRec.Affected_Person_DOB__c;
            wrapper.moneyPaid = incidentRec.Money_Paid__c;
            wrapper.injurySeverity = incidentRec.Injury_Severity__c;
            wrapper.locationCategory = incidentRec.Location_Category__c;
            wrapper.publicComplaintId = incidentRec.Complaint_Number__c;
            wrapper.urgency = incidentRec.Urgency;
            wrapper.priority = incidentRec.Priority;
            wrapper.subject = incidentRec.Subject;
            wrapper.impact = incidentRec.Impact;
            wrapper.locationId = incidentRec.Location__c;
            fieldsToQuery = 'Id';
            whereClause = 'ParentId = \'' + incidentRec.Location__c + '\'';
            List<Schema.Address> addressList = LPI_AddressDAO.getAddressByDymanicQuery(
                fieldsToQuery,
                whereClause,
                null,
                null,
                null
            );
            // return if no address found.
            if (addressList.isEmpty()) {
                return wrapper;
            }
            wrapper.addressId = addressList[0].Id;
            return wrapper;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_IncidentController',
                'getIncidentDetails',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @description : Save incident data related to a PublicComplaint.
     * @author Mohit Karani | 05-22-2023
     * @param jsonData
     **/
    @AuraEnabled
    public static void saveIncidentData(String jsonData) {
        try {
            if (String.isBlank(jsonData)) {
                throw new LPI_Exception('Invalid Data.');
            }
            LPI_Wrapper.IncidentWrapper wrapper = (LPI_Wrapper.IncidentWrapper) JSON.deserialize(
                jsonData,
                LPI_Wrapper.IncidentWrapper.class
            );
            String fields = 'Name';
            String whereClause =
                ' ID = \'' +
                String.escapeSingleQuotes(wrapper.publicComplaintId) +
                '\'';
            List<PublicComplaint> pcList = LPI_PublicComplaintDao.fetchPublicComplaintRecords(
                fields,
                whereClause,
                null,
                null
            );
            if (pcList.isEmpty()) {
                throw new LPI_Exception('Public Complaint not found.');
            }
            Incident incidentRec = new Incident();
            incidentRec.Id = String.isNotBlank(wrapper.incidentId)
                ? wrapper.incidentId
                : null;
            incidentRec.Affected_Person__c = wrapper.affectedPerson;
            incidentRec.StartDateTime = Datetime.newInstance(
                wrapper.beginDate.year(),
                wrapper.beginDate.month(),
                wrapper.beginDate.day(),
                0,
                0,
                0
            );
            incidentRec.EndDateTime = Datetime.newInstance(
                wrapper.endDate.year(),
                wrapper.endDate.month(),
                wrapper.endDate.day(),
                0,
                0,
                0
            );
            incidentRec.Affected_Person_DOB__c = wrapper.affectedPersonDob;
            incidentRec.Money_Paid__c = wrapper.moneyPaid;
            incidentRec.Injury_Severity__c = wrapper.injurySeverity;
            incidentRec.Location_Category__c = wrapper.locationCategory;
            incidentRec.Complaint_Number__c = wrapper.publicComplaintId;
            incidentRec.Location__c = wrapper.locationId;
            incidentRec.Urgency = String.isNotBlank(wrapper.incidentId)
                ? wrapper.urgency
                : MEDIUM_TEXT;
            incidentRec.Impact = String.isNotBlank(wrapper.incidentId)
                ? wrapper.impact
                : MEDIUM_TEXT;
            incidentRec.Priority = String.isNotBlank(wrapper.incidentId)
                ? wrapper.priority
                : MODERATE_TEXT;
            incidentRec.Subject = String.isNotBlank(wrapper.incidentId)
                ? wrapper.subject
                : 'Incident Details for Complaint - ' +
                  pcList[0].Name +
                  ',' +
                  'Incident Date - ' +
                  incidentRec.StartDateTime.format('MM/dd/yyyy');
            LPI_DML.doUpsert(new List<Incident>{ incidentRec });
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_IncidentController',
                'saveIncidentData',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }
    /**
     * @description : Method to get Address records of the ComplaintParticipant added on the PublicComplaint.
     * @author Mohit Karani | 05-24-2023
     * @param jsonData
     * @return List<LookupWrapper>
     **/
    @AuraEnabled(cacheable=true)
    public static List<LPI_CustomLookup.LookupWrapper> geAddressRecordsForComplaintParticipants(
        String jsonData
    ) {
        try {
            if (String.isBlank(jsonData)) {
                return null;
            }
            LPI_Wrapper.IncidentWrapper wrapper = (LPI_Wrapper.IncidentWrapper) JSON.deserialize(
                jsonData,
                LPI_Wrapper.IncidentWrapper.class
            );
            if (
                String.isBlank(wrapper.publicComplaintId) ||
                String.isBlank(wrapper.searchKey)
            ) {
                return null;
            }
            wrapper.publicComplaintId = String.escapeSingleQuotes(
                wrapper.publicComplaintId
            );
            String fields = 'ParticipantId';
            String whereClause =
                'ParticipantId != NULL AND PublicComplaintId = \'' +
                wrapper.publicComplaintId +
                '\'';
            List<ComplaintParticipant> cmpParticipantList = LPI_ComplaintParticipantDAO.getComplaintParticipantByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            );
            
            if (cmpParticipantList.isEmpty()) {
                return null;
            }
            Set<String> participantIdSet = new Set<String>();
            for (ComplaintParticipant cp : cmpParticipantList) {
                participantIdSet.add(cp.ParticipantId);
            }
            fields = 'Id,LocationId';
            whereClause =
                ' LocationId != NULL AND ParentRecordId IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(
                    participantIdSet
                );
            List<AssociatedLocation> accociatedLocationList = LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
                fields.split(','),
                whereClause,
                1000,
                null,
                null
            );
            
            if (accociatedLocationList.isEmpty()) {
                return null;
            }
            Set<String> locationIdSet = new Set<String>();
            for (AssociatedLocation accLoc : accociatedLocationList) {
                locationIdSet.add(accLoc.LocationId);
            }
            wrapper.searchKey =
                '%' +
                String.escapeSingleQuotes(wrapper.searchKey) +
                '%';
            fields = 'Id,Street,State,City,PostalCode';
            whereClause =
                '(State LIKE \'' +
                wrapper.searchKey +
                '\' OR City LIKE \'' +
                wrapper.searchKey +
                '\' OR Street LIKE \'' +
                wrapper.searchKey +
                '\' OR PostalCode LIKE \'' +
                wrapper.searchKey +
                '\') AND ParentId IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(locationIdSet);
            List<Schema.Address> addressList = LPI_AddressDAO.getAddressByDymanicQuery(
                fields,
                whereClause,
                '5',
                'CreatedDate',
                'DESC'
            );
            //System.assert(false, addressList.size());
            if (addressList.isEmpty()) {
                return null;
            }
            String add;
            List<LPI_CustomLookup.LookupWrapper> returnList = new List<LPI_CustomLookup.LookupWrapper>();

            for (Schema.Address addressRec : addressList) {
                add = concatenateAddressFields(addressRec);
                returnList.add(
                    new LPI_CustomLookup.LookupWrapper(
                        (String) addressRec.get('Id'),
                        add
                    )
                );
            }

            return returnList;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_IncidentController',
                'geAddressRecordsForComplaintParticipants',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @description : Method to concatenate address fields.
     * @author Mohit Karani | 05-24-2023
     * @param addressRec
     * @return String
     **/
    public static String concatenateAddressFields(Schema.Address addressRec) {
        return ((String) addressRec.get('Street') != null
                ? (String) addressRec.get('Street')
                : '') +
            ((String) addressRec.get('City') != null
                ? ' , ' + (String) addressRec.get('City')
                : '') +
            ((String) addressRec.get('State') != null
                ? ' , ' + (String) addressRec.get('State')
                : '') +
            ((String) addressRec.get('PostalCode') != null
                ? ' , ' + (String) addressRec.get('PostalCode')
                : '');
    }
}