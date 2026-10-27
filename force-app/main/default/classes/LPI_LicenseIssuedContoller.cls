/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_LicenseIssuedContoller {
    public IndividualApplication ia { get; set; }
    public BusinessLicenseApplication bla { get; set; }
    public LPI_LicenseIssuedContoller() {
        String targetId = ApexPages.currentPage().getParameters().get('targetId');
        System.debug('Target Id >>>> ' + targetId);
        if (targetId != null) {
            // Check the prefix to determine the type of record
            String prefix = targetId.substring(0, 3);
            if (prefix == IndividualApplication.SObjectType.getDescribe().getKeyPrefix()) {
                ia = [SELECT Id, Name, LicensePermitName.Name, LicensePermitName.Status, LicenseType.Name 
                      FROM IndividualApplication 
                      WHERE Id = :targetId LIMIT 1];
            } else if (prefix == BusinessLicenseApplication.SObjectType.getDescribe().getKeyPrefix()) {
                bla = [SELECT Id, Name, LicensePermitName.Name, LicensePermitName.Status, LicenseType.Name 
                       FROM BusinessLicenseApplication 
                       WHERE Id = :targetId LIMIT 1];
            }
        }
    }
    public IndividualApplication getia() {
        return ia;
    }
    public BusinessLicenseApplication getBla() {
        return bla;
    }
}