/**
 * Shared success-page resolver for non-Licensing portals
 * (Employer, Agency Review, AVR Pension).
 * Licensing Portal success page is intentionally out of scope.
 */
public with sharing class LPI_PortalSuccessCtrl {
    public static final String FLOW_PREMIUM_TAX = 'PremiumTax';
    public static final String FLOW_FIRE_MARSHAL = 'FireMarshalLevy';
    public static final String FLOW_VEHICLE_LEVY = 'VehicleLevy';
    public static final String FLOW_AVR_FILING = 'AvrFiling';
    public static final String FLOW_AGENT_REVIEW = 'AgentReview';
    public static final String FLOW_FINANCIAL = 'FinancialFiling';
    public static final String FLOW_GENERIC = 'Generic';

    @AuraEnabled(cacheable=true)
    public static SuccessDTO getSuccessDetails(String flowKey, Id contextId) {
        String resolvedFlow = resolveFlow(flowKey, contextId);
        SuccessDTO dto = baseContent(resolvedFlow);

        if (contextId != null) {
            populateFromRecord(dto, resolvedFlow, contextId);
        }

        if (String.isBlank(dto.recordNumber) && contextId != null) {
            dto.recordNumber = String.valueOf(contextId);
        }
        if (String.isBlank(dto.status)) {
            dto.status = 'Submitted';
        }
        return dto;
    }

    private static String resolveFlow(String flowKey, Id contextId) {
        if (String.isNotBlank(flowKey)) {
            return flowKey.trim();
        }
        if (contextId == null) {
            return FLOW_GENERIC;
        }
        Schema.SObjectType sot = contextId.getSObjectType();
        if (sot == Tax_Return_Applications__c.SObjectType) {
            return FLOW_PREMIUM_TAX;
        }
        if (sot == Fire_Marshal_Levy__c.SObjectType) {
            return FLOW_FIRE_MARSHAL;
        }
        if (sot == Vehicle_Levy__c.SObjectType) {
            return FLOW_VEHICLE_LEVY;
        }
        if (sot == AVR_Filing__c.SObjectType) {
            return FLOW_AVR_FILING;
        }
        return FLOW_GENERIC;
    }

    private static SuccessDTO baseContent(String flowKey) {
        SuccessDTO dto = new SuccessDTO();
        dto.flowKey = flowKey;
        dto.navigatePage = 'Home';

        if (flowKey == FLOW_PREMIUM_TAX || flowKey == FLOW_FIRE_MARSHAL || flowKey == FLOW_VEHICLE_LEVY) {
            dto.title = 'Submission successful';
            dto.body = 'Your submission was received successfully.';
            dto.idLabel = 'Reference ID';
            dto.ctaLabel = 'Back to Home';
            dto.nextSteps = new List<String>{
                'Please keep this reference for your records.',
                'You will be notified if more information is required.',
                'You can return to the portal home anytime.'
            };
        } else if (flowKey == FLOW_AVR_FILING) {
            dto.title = 'AVR filing submitted';
            dto.body = 'Your AVR filing was received and is in the specialist queue.';
            dto.idLabel = 'Filing ID';
            dto.ctaLabel = 'Back to Pension Filings';
            dto.nextSteps = new List<String>{
                'Please keep this Filing ID for your records. It will be used for any future correspondence about this filing.',
                'Our team will review your AVR filing. You will be notified when the review is complete or if more information is required.',
                'You can track status anytime from Pension Filings on the portal home.'
            };
        } else if (flowKey == FLOW_AGENT_REVIEW) {
            dto.title = 'Review submitted';
            dto.body = 'Your review action was recorded successfully.';
            dto.idLabel = 'Reference ID';
            dto.ctaLabel = 'Back to Home';
            dto.nextSteps = new List<String>{
                'Please keep this reference for your records.',
                'You can return to the Agent Review Queue to continue reviewing applications.',
                'Applicants will be notified when further action is required.'
            };
        } else if (flowKey == FLOW_FINANCIAL) {
            dto.title = 'Financial filing submitted';
            dto.body = 'We have received your financial filing.';
            dto.idLabel = 'Filing ID';
            dto.ctaLabel = 'Back to Home';
            dto.nextSteps = new List<String>{
                'Please keep this Filing ID for your records.',
                'Our team will review your filing and contact you if more information is required.',
                'You can return to Financial Filings from the Employer Portal home.'
            };
        } else {
            dto.title = 'Submission successful';
            dto.body = 'Your submission was received successfully.';
            dto.idLabel = 'Reference ID';
            dto.ctaLabel = 'Back to Home';
            dto.nextSteps = new List<String>{
                'Please keep this reference for your records.',
                'You will be notified if more information is required.',
                'You can return to the portal home anytime.'
            };
        }
        return dto;
    }

    private static void populateFromRecord(SuccessDTO dto, String flowKey, Id contextId) {
        try {
            if (flowKey == FLOW_PREMIUM_TAX || contextId.getSObjectType() == Tax_Return_Applications__c.SObjectType) {
                List<Tax_Return_Applications__c> rows = [
                    SELECT Id, Name
                    FROM Tax_Return_Applications__c
                    WHERE Id = :contextId
                    LIMIT 1
                ];
                if (!rows.isEmpty()) {
                    dto.recordId = rows[0].Id;
                    dto.recordNumber = rows[0].Name;
                    dto.status = 'Submitted';
                }
                return;
            }
            if (flowKey == FLOW_FIRE_MARSHAL || contextId.getSObjectType() == Fire_Marshal_Levy__c.SObjectType) {
                List<Fire_Marshal_Levy__c> rows = [
                    SELECT Id, Name, Filing_Status__c
                    FROM Fire_Marshal_Levy__c
                    WHERE Id = :contextId
                    LIMIT 1
                ];
                if (!rows.isEmpty()) {
                    dto.recordId = rows[0].Id;
                    dto.recordNumber = rows[0].Name;
                    dto.status = String.isNotBlank(rows[0].Filing_Status__c)
                        ? rows[0].Filing_Status__c
                        : 'Submitted';
                }
                return;
            }
            if (flowKey == FLOW_VEHICLE_LEVY || contextId.getSObjectType() == Vehicle_Levy__c.SObjectType) {
                List<Vehicle_Levy__c> rows = [
                    SELECT Id, Name, Filing_Status__c
                    FROM Vehicle_Levy__c
                    WHERE Id = :contextId
                    LIMIT 1
                ];
                if (!rows.isEmpty()) {
                    dto.recordId = rows[0].Id;
                    dto.recordNumber = rows[0].Name;
                    dto.status = String.isNotBlank(rows[0].Filing_Status__c)
                        ? rows[0].Filing_Status__c
                        : 'Submitted';
                }
                return;
            }
            if (flowKey == FLOW_AVR_FILING || contextId.getSObjectType() == AVR_Filing__c.SObjectType) {
                List<AVR_Filing__c> rows = [
                    SELECT Id, Name, Status__c
                    FROM AVR_Filing__c
                    WHERE Id = :contextId
                    LIMIT 1
                ];
                if (!rows.isEmpty()) {
                    dto.recordId = rows[0].Id;
                    dto.recordNumber = rows[0].Name;
                    dto.status = String.isNotBlank(rows[0].Status__c) ? rows[0].Status__c : 'Submitted';
                }
            }
        } catch (Exception e) {
            // URL params remain as fallback in the LWC
        }
    }

    public class SuccessDTO {
        @AuraEnabled
        public String flowKey;
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String recordNumber;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String body;
        @AuraEnabled
        public String idLabel;
        @AuraEnabled
        public String ctaLabel;
        @AuraEnabled
        public String navigatePage;
        @AuraEnabled
        public List<String> nextSteps;
    }
}