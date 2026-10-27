/**
 * @author      : Piyush Aneja
 * @since       : 01 March 2023
 * @description : This is a utility class designed to support and enhance the functionality of the MODPR_DocumentConfigGenerator. 
 *  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         01 March 2023       Piyush Aneja            Initial Developement for Renewal Template data
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_DocumentConfigGeneratorUtil{
	// *************************************** ALL CONSTANTS ************************************************
	public final static Set<String> EMPLOYEE_ROLES_SET = new Set<String>{ 'Employee' };
	public final static String RECORDS_ADDRESS = 'Records Address';
	public static final String CLASS_NAME = 'LPI_DocumentConfigGeneratorUtil';
	public final static Set<String> OWNER_PIC_ROLES_SET = new Set<String>{ 'Authorised Sellers/Dealers', 'Owner', 'Primary Supervisor', 'Employee' };
	public final static String LOCATION_TYPE_RESIDENCE = 'Residence';
	public final static Set<String> LICENSE_ROLES_SET = new Set<String>{ 'Authorised Sellers/Dealers', 'Designation of Custodial', 'Owner', 'Designated Incharge', 'Primary Supervisor' };
	public final static Set<String> BUSINESS_ROLES_SET = new Set<String>{ 'Designated Incharge', 'Owner' };
	public final static String PIC_ADDRESS = 'Person In Charge Address';
	private static final Set<Integer> FEB_END_DAYS_SET = new Set<Integer>{ 28, 29 };
	public static final Set<String> LICENSE_TYPE_SET = new Set<String>{ 'Funeral Establishment', 'Funeral Director Limited', 'Funeral Director', 'Embalmer' };
	public static Set<String> TWO_YEARS_EXPIRY_CYCLES = new Set<String>{ LPI_LiteralConstant.Expiration_Cycle_EVEN, LPI_LiteralConstant.Expiration_Cycle_ODD, LPI_LiteralConstant.Expiration_Cycle_BIENNIAL, LPI_LiteralConstant.EXPIRATION_CYCLE_TWO_YEARS };
	// ******************************************************************************************************
	/**
	 * @author                      : Piyush Aneja
	 * @since                       : Oct 2023
	 * @description                 : This method retrieves BR realationship details
	 * @param blIdSet               : Set of business liocemse IDs for which  BR realationship details need to be retrieved.
	 * @return                      : Map<Id, Map<String, List<Map<String, Object>>>>
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	/*public static Map<Id, Map<String, List<Map<String, Object>>>> geFQHCEmployeeDetails(Set<Id> blIdSet){
		try{
			if (!blIdSet.isEmpty()){
				Map<Id, Map<String, List<Map<String, Object>>>> resultMap = new Map<Id, Map<String, List<Map<String, Object>>>>();
				List<Map<String, Object>> employerAddrDetailsList = new List<Map<String, Object>>();
				Map<String, Object> employeeDetailsList = new Map<String, Object>();
				Map<String, Object> employerAddrMap = new Map<String, Object>();
				Map<String, List<Map<String, Object>>> employeeMap = new Map<String, List<Map<String, Object>>>();

				String fields = '  Id,Title__c,Related_From__c ,Related_From__r.Name, Related_From_License_Number__c,Related_From_License_Number__r.Name, Related_From__r.Phone,Related_From__r.BillingAddress,Related_From__r.BillingStreet, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From_License_Number__r.Account.Name, Related_To__c,Related_To__r.Name,Related_To__r.PersonEmail, Related_To__r.Phone, License_Number__c, Related_To_License_Number__c,Related_To_License_Number__r.Name,Entity_License_Number__c,Roles__c,Start_Date__c, EndDate__c, Supervisor_License_Number__c, License_Type__c, Related_From_License_Number__r.Status, IsActive__c';
				String whereClause = 
					'Related_From_License_Number__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet) + 
					'AND IsActive__c = true' + 
					' AND Roles__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(EMPLOYEE_ROLES_SET);

				for (Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(fields, whereClause, null, null, null)){
					if (br.Roles__c == 'Employee'){
						if (!resultMap.containsKey(br.Related_From_License_Number__c)){
							resultMap.put(br.Related_From_License_Number__c, new Map<String, List<Map<String, Object>>>());
						}
						employerAddrMap.put('EmployerName', br.Related_From__r.Name);
						employerAddrMap.put('EmployerLicenseName', br.Related_From_License_Number__r.Name);
						if (br.Related_From__r.BillingAddress != null){
							Address billingAddress = br.Related_From__r.BillingAddress;
							employerAddrMap.put('Street', billingAddress.street);
							employerAddrMap.put('City', billingAddress.city);
							employerAddrMap.put('State', billingAddress.state);
							employerAddrMap.put('PostalCode', billingAddress.postalCode);
							employerAddrMap.put('Country', billingAddress.country);
						}
						employerAddrMap.put('Phone', br.Related_From__r.Phone);
						employeeDetailsList.put('EmployeeInformation', employerAddrMap);
						employerAddrDetailsList.add(employeeDetailsList);
						resultMap.get(br.Related_From_License_Number__c).put('EmployeeInformation', employerAddrDetailsList);
						if (!employeeMap.containsKey(br.Related_From_License_Number__c)){
							employeeMap.put(br.Related_From_License_Number__c, new List<Map<String, Object>>());
						}
						Map<String, Object> employeeMapDetails = new Map<String, Object>();
						employeeMapDetails.put('LicenseNumber', br.Related_To_License_Number__r.Name);
						employeeMapDetails.put('EmployeeName', br.Related_To__r.Name);
						employeeMapDetails.put('Position', br.Title__c);
						employeeMap.get(br.Related_From_License_Number__c).add(employeeMapDetails);
						resultMap.get(br.Related_From_License_Number__c).put('Employee', employeeMap.get(br.Related_From_License_Number__c));
					}
				}
				return resultMap;
			}
			return null;
		} catch (Exception ex){
			LPI_ExceptionManager.logException(CLASS_NAME, 'geFQHCEmployeeDetails', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}*/

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 13 Oct 2023
	 * @description                 : This method retrieves name of the School from Contact Id
	 * @param conIdsSet             : Set of Contact IDs for which name of the School need to be retrieved.
	 * @return                      : A Map Map<Id, Map<String, String>>
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	/*public static Map<Id, Map<String, String>> getEducationHistory(Set<Id> conIdsSet){
		try{
			if (!conIdsSet.isEmpty()){
				Map<Id, Map<String, String>> educationMap = new Map<Id, Map<String, String>>();
				List<PersonEducation> educationList = LPI_PersonEducationDAO.getPersonEducationByDymanicQuery('Id,IdentifierIssuer,ContactId', 'ContactId IN ' + LPI_ServiceUtility.getStringValuesBySet(conIdsSet), null, null, null);
				for (PersonEducation education : educationList){
					Map<String, String> educationDetails = new Map<String, String>();
					educationDetails.put('PharmacySchool', education.IdentifierIssuer);
					educationMap.put(education.ContactId, educationDetails);
				}
				return educationMap;
			}
			return null;
		} catch (Exception ex){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getEducationHistory', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}*/

	/**
	 * @author                       : Chetan
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get Alias Details
	 * @param blIdToAccountIdMap     : Map<Id, Id>
	 * @return                       : Map<Id, Map<String, Object>>
	 * @last modified by             : Uzma Md
	 * @last modified date           :
	 * @last modified details        :
	 */
	/*public static Map<Id, Map<String, Object>> getAliasDetails(Map<Id, Id> blIdToAccountIdMap){
		try{
			if (!blIdToAccountIdMap.isEmpty()){
				Map<Id, Map<String, Object>> aliasDetailMap = new Map<Id, Map<String, Object>>();
				Map<Id, Map<String, Object>> blIdToAliasDetailMap = new Map<Id, Map<String, Object>>();

				String whereClause = 
					'Account__c IN ' + LPI_ServiceUtility.getStringValuesByList(blIdToAccountIdMap.values()) + 
					' AND Alias_Type__c = \'Ring\' AND Status__c = \'Active\'';

				for (Alias__c alias : LPI_AliasDAO.getAliasByDymanicQuery('Id, Name, Account__c, Alias_From_Date__c, Alias_Thru_Date__c, Alias_Type__c', whereClause, null, null, null)){
					aliasDetailMap.put(alias.Account__c, new Map<String, Object>{ 'RingName' => alias.Name });
				}
				for (Id blId : blIdToAccountIdMap.keySet()){
					blIdToAliasDetailMap.put(blId, aliasDetailMap.get(blIdToAccountIdMap.get(blId)));
				}
				return blIdToAliasDetailMap;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getDocActionConfig', e);
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	/**
	 * @author                       : Chetan
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get Continuing Education Records Information.
	 * @param conIdsSet              : Set<Id>
	 * @return                       : Map<Id, List<Map<String, Object>>>
	 * @last modified by             : Uzma Md
	 * @last modified date           :
	 * @last modified details        :
	 */
	/*public static Map<Id, Map<String, Object>> getContinuingEducationRecords(List<BusinessLicense> blRecordList){
		try{
			if (!blRecordList.isEmpty()){
				Map<Id, Map<String, Object>> blIdToContinuingEduMap = new Map<Id, Map<String, Object>>();
				Set<Id> blIdSet = new Set<Id>();
				Map<Id, String> blIdToYearMap = new Map<Id, String>();
				for (BusinessLicense bl : blRecordList){
					blIdSet.add(bl.Id);
					blIdToYearMap.put(bl.Id, String.valueOf(bl.PeriodEnd.year()));
				}
				String whereClause = 'Business_License__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet) + 
									' AND RecordType.DeveloperName = \'CE_Audit\' AND Current_Reporting_End_Year__c IN ' + LPI_ServiceUtility.getStringValuesByList(blIdToYearMap.values());
				List<Audit_Detail__c> auditDetails = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery('Id, Business_License__c, Approved_CE_Hours__c, Approved_NABP_CE_Hours__c, CE_Completion_Status__c', whereClause, null, null, null);

				if (!auditDetails.isEmpty()){
					Set<Id> auditIds = new Set<Id>();
					for (Audit_Detail__c audit : auditDetails){
						auditIds.add(audit.Id);
					}
					String tcpWhereClause = 'Audit_Detail__c IN ' + LPI_ServiceUtility.getStringValuesBySet(auditIds);
					String tcpFields = 'Business_License__c,Approved_Hours__c, Title__c, Course_Number__c, TotalHours, VerificationStatus, Delivery_Method__c, CourseOfferingId, CourseOffering.CourseNameId, ContactId, CourseOffering.CourseName.Course_ID__c, CourseOffering.CourseName.Name';
					List<TrainingCourseParticipant> trainingCourseParticipants = LPI_TrainingCourseParticipantDAO.getTrainingCourseParticipantByDymanicQuery(tcpFields, tcpWhereClause, null, null, null);
					for (TrainingCourseParticipant tcp : trainingCourseParticipants){
						if (!blIdToContinuingEduMap.containsKey(tcp.Business_License__c)){
							blIdToContinuingEduMap.put(tcp.Business_License__c, new Map<String, Object>());
							blIdToContinuingEduMap.get(tcp.Business_License__c).put('Course', new List<Map<String, Object>>());
						}

						Map<String, Object> continuingEduMap = new Map<String, Object>();
						if (tcp.CourseOfferingId != null && tcp.CourseOffering.CourseNameId != null){
							continuingEduMap.put('CourseNumber', tcp.CourseOffering.CourseName.Course_ID__c);
							continuingEduMap.put('CourseTitle', tcp.CourseOffering.CourseName.Name);
						} else{
							continuingEduMap.put('CourseNumber', tcp.Course_Number__c);
							continuingEduMap.put('CourseTitle', tcp.Title__c);
						}
						continuingEduMap.put('Hours', tcp.Approved_Hours__c);
						((List<Map<String, Object>>)blIdToContinuingEduMap.get(tcp.Business_License__c).get('Course')).add(new Map<String, Object>(continuingEduMap));
					}
				}
				return blIdToContinuingEduMap;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getContinuingEducationRecords', e);
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	/**
	 * @author                      : Chetan
	 * @since                       : Oct 2023
	 * @description                 : This method retrieves based on license type if it is a individual call this method if it is an entity call the above
	 method getBusinessRelationshipInformation. New method for individual license types to get the details from related to fields of BR object.
	 * @param blIdSet               : Set of business liocemse IDs for which  BR realationship details need to be retrieved.
	 * @return                      : Map<Id, Map<String, List<Map<String, Object>>>>
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	/*public static Map<Id, Map<String, List<Map<String, Object>>>> getOwnerPicSupervisorDetails(Set<Id> blIdSet){
		try{
			if (!blIdSet.isEmpty()){
				Map<Id, Map<String, List<Map<String, Object>>>> resultMap = new Map<Id, Map<String, List<Map<String, Object>>>>();
				Map<String, Object> picAddressMap = new Map<String, Object>();
				List<Map<String, Object>> controllingPersonDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> preneedSellerDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> personInchargeDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> supervisorDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> employerAddrDetailsList = new List<Map<String, Object>>();
				Set<Id> picIdSet = new Set<Id>();

				String fields = ' Id,Related_From__c,Related_From_License_Number__r.Regulatory_Authorization_Type_Name__c,Related_From__r.Name, Related_From_License_Number__c,Related_From_License_Number__r.Name, Related_From__r.Phone,Related_From__r.BillingAddress,Related_From__r.BillingStreet, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From_License_Number__r.Account.Name, Related_To__c,Related_To__r.Name,Related_To__r.PersonEmail, Related_To__r.Phone, License_Number__c, Related_To_License_Number__c,Related_To_License_Number__r.Name,Entity_License_Number__c,Roles__c, Related_From_License_Number__r.Account.BillingAddress,Start_Date__c, EndDate__c, Supervisor_License_Number__c, License_Type__c, Related_From_License_Number__r.Status, IsActive__c';
				String whereClause = 
					'Related_To_License_Number__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet) + 
					'AND IsActive__c = true' + 
					' AND Roles__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(OWNER_PIC_ROLES_SET);
				Set<Id> pdIdSet = new Set<Id>();

				for (Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(fields, whereClause, null, null, null)){
					Map<String, Object> controllingPersonDetails = new Map<String, Object>();
					Map<String, Object> preneedSellerDetails = new Map<String, Object>();
					Map<String, Object> primSupervisorMap = new Map<String, Object>();
					Map<String, Object> supervisorDetails = new Map<String, Object>();

					if (br.Roles__c == 'Owner'){
						if (!resultMap.containsKey(br.Related_To_License_Number__c)){
							resultMap.put(br.Related_To_License_Number__c, new Map<String, List<Map<String, Object>>>());
						}
						controllingPersonDetails.put('OwnerName', br.Related_From__r.Name);
						controllingPersonDetailsList.add(controllingPersonDetails);
						resultMap.get(br.Related_To_License_Number__c).put('ControllingPersonDetail', controllingPersonDetailsList);
					} else if (br.Roles__c == 'Primary Supervisor' || br.Roles__c == 'Employee'){
						if (!resultMap.containsKey(br.Related_To_License_Number__c)){
							resultMap.put(br.Related_To_License_Number__c, new Map<String, List<Map<String, Object>>>());
						}
						Map<String, Object> employerAddrMap = new Map<String, Object>();
						if (br.Roles__c == 'Employee'){
							employerAddrMap.put('EmployerName', br.Related_From__r.Name);
							employerAddrMap.put('EmployerLicenseName', br.Related_From_License_Number__r.Name);
							employerAddrMap.put('EmployerLicenseNumber', br.Related_From_License_Number__r.Name);
							if (br.Related_From__r.BillingAddress != null){
								Address billingAddress = br.Related_From__r.BillingAddress;
								employerAddrMap.put('Street', billingAddress.street);
								employerAddrMap.put('City', billingAddress.city);
								employerAddrMap.put('State', billingAddress.state);
								employerAddrMap.put('PostalCode', billingAddress.postalCode);
								employerAddrMap.put('Country', billingAddress.country);
							}
							employerAddrMap.put('Phone', br.Related_From__r.Phone);

							supervisorDetails.put('CurrentEmployeeBusinessAddress', employerAddrMap);
							employerAddrDetailsList.add(supervisorDetails);
							resultMap.get(br.Related_To_License_Number__c).put('SupervisorInformation', employerAddrDetailsList);
						} else{
							supervisorDetails.put('SupervisorFullName', br.Related_From__r.Name);
							supervisorDetails.put('AgencyName', br.Related_From_License_Number__r.Account.Name);
							Map<String, Object> agencyAddrMap = new Map<String, Object>();
							Address billingAddress = br.Related_From_License_Number__r?.Account?.BillingAddress;
							if (billingAddress != null){
								agencyAddrMap.put('AgencyStreet', billingAddress?.street);
								agencyAddrMap.put('AgencyCity', billingAddress?.city);
								agencyAddrMap.put('AgencyState', billingAddress?.state);
								agencyAddrMap.put('AgencyPostalCode', billingAddress?.postalCode);
								agencyAddrMap.put('AgencyCountry', billingAddress?.country);
							}
							supervisorDetails.put('AgencyAddress', agencyAddrMap);
							supervisorDetails.put('PersonInChargeName', br.Related_From__r.Name);
							primSupervisorMap.put('RelSchoolInformationDetailsationshipStartDate', br.Start_Date__c);
							primSupervisorMap.put('RelationshipEndDate', br.EndDate__c);
							primSupervisorMap.put('LicenseNumber', br.Supervisor_License_Number__c);
							primSupervisorMap.put('LicenseType', br.License_Type__c);
							primSupervisorMap.put('LicenseStatus', br.Related_From_License_Number__r.Status);
							primSupervisorMap.put('RelationshipProfession', br.Related_From_License_Number__r.Regulatory_Authorization_Type_Name__c);
							if (br.IsActive__c){
								primSupervisorMap.put('RelationshipStatus', 'Active');
							} else{
								primSupervisorMap.put('RelationshipStatus', 'Inactive');
							}
							if (br.Related_From_License_Number__r.Id != null){
								pdIdSet.add(br.Related_From_License_Number__r.Id);
							}
							supervisorDetails.put('SupervisorRelationDetails', primSupervisorMap);
							supervisorDetails.put('Id', br.Related_From_License_Number__r.Id);
							supervisorDetailsList.add(supervisorDetails);
							resultMap.get(br.Related_To_License_Number__c).put('SupervisorInformation', supervisorDetailsList);
						}
					} else if (br.Roles__c == 'Authorised Sellers/Dealers'){
						if (!resultMap.containsKey(br.Related_To_License_Number__c)){
							resultMap.put(br.Related_To_License_Number__c, new Map<String, List<Map<String, Object>>>());
						}
						preneedSellerDetails.put('Name', br.Related_From__r.Name);
						preneedSellerDetails.put('LicenseNumber', br.Entity_License_Number__c);
						preneedSellerDetails.put('StreetAddress', br.Related_From__r.BillingStreet);
						preneedSellerDetails.put('City', br.Related_From__r.BillingCity);
						preneedSellerDetails.put('State', br.Related_From__r.BillingState);
						preneedSellerDetails.put('ZipCode', br.Related_From__r.BillingPostalCode);
						preneedSellerDetails.put('StartDate', br.Start_Date__c);
						preneedSellerDetailsList.add(preneedSellerDetails);
						resultMap.get(br.Related_To_License_Number__c).put('PreneedSellerInformation', preneedSellerDetailsList);
					}
				}
				return resultMap;
			}

			return null;
		} catch (Exception ex){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getOwnerPicSupervisorDetails', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}*/

	/**
	 * @author                       : Chetan
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get License Association Details Information
	 * @param blIdToAccountIdMap     :  Map<Id, Id>
	 * @param AccountIdToblIdMap     :  Map<Id, Id>
	 * @return                       : Map<Id, Map<String, List<Map<String, Object>>>>
	 * @last modified by             : Uzma Md
	 * @last modified date           :
	 * @last modified details        :
	 */
	/*public static Map<Id, Map<String, List<Map<String, Object>>>> getLicenseAssociationDetails(Map<Id, Id> blIdToAccountIdMap, Map<Id, Id> AccountIdToblIdMap){
		try{
			if (!blIdToAccountIdMap.isEmpty() && !AccountIdToblIdMap.isEmpty()){
				Map<Id, Map<String, List<Map<String, Object>>>> resultMap = new Map<Id, Map<String, List<Map<String, Object>>>>();
				Map<Id, List<Map<String, Object>>> licenseAssociationDetailMap = new Map<Id, List<Map<String, Object>>>();
				List<Map<String, Object>> controllingPersonDetailsList = new List<Map<String, Object>>();
				Map<String, Object> controllingPersonDetails = new Map<String, Object>();
				List<Map<String, Object>> personInchargeDetailsList = new List<Map<String, Object>>();
				Map<String, Object> personInchargeDetails = new Map<String, Object>();
				Map<String, Object> adminHomeAddressDetails = new Map<String, Object>();
				Map<String, Object> adminMainAddressDetails = new Map<String, Object>();
				Map<String, Object> adminAddressDetails = new Map<String, Object>();
				Map<String, Object> ownerAddressDetails = new Map<String, Object>();
				Set<Id> dcIdSet = new Set<Id>();
				Set<Id> pdIdSet = new Set<Id>();
				Set<Id> schoolAccountIdSet = new Set<Id>();
				Set<Id> ownerAccountIdSet = new Set<Id>();

				String fields = ' Id,Related_From__r.BillingAddress,Related_From_License_Number__r.Regulatory_Authorization_Type_Name__c, Supervisor_License_Number__c,Related_From__c, Related_From__r.Name,Related_To__c,Related_To__r.Name, Related_To_License_Number__c,Related_To_License_Number__r.Name, Related_From_License_Number__c, Related_From_License_Number__r.Name, Roles__c,Related_To__r.Website,Related_To__r.Phone,  Related_To__r.Fax, Related_To__r.Buisness_Email__c , Related_To__r.PersonEmail,Related_To__r.PersonHomePhone,Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherState,Related_To__r.PersonOtherCity,Related_To__r.PersonOtherPostalCode,Related_From__r.BillingStreet,Related_From__r.BillingState,Related_From__r.BillingCity,Related_From__r.BillingPostalCode';
				String whereClause = 'Roles__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(LICENSE_ROLES_SET);
				whereClause += 
					' AND (Related_From__c IN ' + LPI_ServiceUtility.getStringValuesByList(blIdToAccountIdMap.values()) + 
					' OR Related_To__c IN ' + LPI_ServiceUtility.getStringValuesByList(blIdToAccountIdMap.values()) + 
					') AND IsActive__c = true';
				Integer count = 0;
				for (Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(fields, whereClause, null, null, null)){
					Map<String, Object> relationMap = new Map<String, Object>();
					Map<String, Object> funeralRelationMap = new Map<String, Object>();
					Map<String, Object> primarySupervisorDetails = new Map<String, Object>();
					List<Map<String, Object>> temporaryList = new List<Map<String, Object>>();
					List<Map<String, Object>> funeraltemporaryList = new List<Map<String, Object>>();
					if (br.Roles__c == 'Authorised Sellers/Dealers'){
						if (blIdToAccountIdMap.values().contains(br.Related_To__c)){
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_To__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_To__c), new Map<String, List<Map<String, Object>>>());
							}
							relationMap.put('LicenseeName', br.Related_From__r.Name);
							relationMap.put('LicenseNumber', br.Related_From_License_Number__r.Name);
							relationMap.put('Profession', br.Roles__c);
							Map<String, Object> AddressMap = new Map<String, Object>();
							Address billingAddress = br.Related_From__r?.BillingAddress;
							if (billingAddress != null){
								AddressMap.put('Street', billingAddress?.street);
								AddressMap.put('City', billingAddress?.city);
								AddressMap.put('State', billingAddress?.state);
								AddressMap.put('PostalCode', billingAddress?.postalCode);
								AddressMap.put('Country', billingAddress?.country);
							}
							relationMap.put('Address', AddressMap);
							String licenseNumber = br.Related_From_License_Number__c;
							String accountId = AccountIdToblIdMap.get(br.Related_To__c);
							if (!resultMap.get(accountId).containsKey('LicenseAssociationDetail')){
								resultMap.get(accountId).put('LicenseAssociationDetail', new List<Map<String, Object>>{ relationMap });
							} else{
								if (resultMap.get(accountId).get('LicenseAssociationDetail') == null){
									resultMap.get(accountId).put('LicenseAssociationDetail', new List<Map<String, Object>>{ relationMap });
								} else{
									resultMap.get(accountId).get('LicenseAssociationDetail').add(relationMap);
								}
							}
						}
					} else if (br.Roles__c == 'Designation of Custodial'){
						if (blIdToAccountIdMap.values().contains(br.Related_From__c)){
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_From__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_From__c), new Map<String, List<Map<String, Object>>>());
							}
							relationMap.put('DesignationCustodialName', br.Related_To__r.Name);
							relationMap.put('Id', br.Related_From__c);
							dcIdSet.add(br.Related_From__c);
							if (!resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).containsKey('DesignationOfCustodial')){
								temporaryList.add(relationMap);
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).put('DesignationOfCustodial', temporaryList);
							} else{
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).get('DesignationOfCustodial').add(relationMap);
							}
						}
					}
					else if (br.Roles__c == 'Owner'){
						if (blIdToAccountIdMap.values().contains(br.Related_To__c)){
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_To__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_To__c), new Map<String, List<Map<String, Object>>>());
							}
							controllingPersonDetails.put('OwnerName', br.Related_From__r.Name);
							schoolAccountIdSet.add(br.Related_To__c);
							controllingPersonDetails.put('OwnerStreet', br.Related_From__r.BillingStreet);

							controllingPersonDetails.put('OwnerState', br.Related_From__r.BillingState);
							controllingPersonDetails.put('OwnerCity', br.Related_From__r.BillingCity);
							controllingPersonDetails.put('OwnerZipCode', br.Related_From__r.BillingPostalCode);
							if (!resultMap.get(AccountIdToblIdMap.get(br.Related_To__c)).containsKey('OwnershipInformationDetails')){
								temporaryList.add(controllingPersonDetails);
								resultMap.get(AccountIdToblIdMap.get(br.Related_To__c)).put('OwnerInfo', temporaryList);
							} else{
								resultMap.get(AccountIdToblIdMap.get(br.Related_To__c)).get('OwnershipInformationDetails').add(controllingPersonDetails);
							}
						} else if (blIdToAccountIdMap.values().contains(br.Related_From__c)){
							Map<String, Object> ownerDetails = new Map<String, Object>();
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_From__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_From__c), new Map<String, List<Map<String, Object>>>());
							}
							ownerDetails.put('OwnerName', br.Related_To__r.Name);
							if (!resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).containsKey('OwnerInfo')){
								temporaryList = new List<Map<String, Object>>(); // Create a new list for each 'OwnerInfo'
								temporaryList.add(ownerDetails);
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).put('OwnerInfo', temporaryList);
							} else{
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).get('OwnerInfo').add(ownerDetails);
							}
						}
					}
					else if (br.Roles__c == 'Designated Incharge'){
						if (blIdToAccountIdMap.values().contains(br.Related_From__c)){
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_From__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_From__c), new Map<String, List<Map<String, Object>>>());
							}
							personInchargeDetails.put('AdminName', br.Related_To__r.Name);
							personInchargeDetails.put('AdminEmail', br.Related_To__r.PersonEmail);
							personInchargeDetails.put('AdminOfficePhone', br.Related_To__r.PersonHomePhone);
							personInchargeDetails.put('AdminHomePhone', br.Related_To__r.Phone);
							personInchargeDetails.put('AdminName', br.Related_To__r.Name);
							personInchargeDetails.put('AdminStreet', br.Related_To__r.PersonOtherStreet);
							personInchargeDetails.put('AdminState', br.Related_To__r.PersonOtherState);
							personInchargeDetails.put('AdminCity', br.Related_To__r.PersonOtherCity);
							personInchargeDetails.put('AdminZipCode', br.Related_To__r.PersonOtherPostalCode);
							personInchargeDetails.put('AdminState', br.Related_To__r.PersonOtherState);
							personInchargeDetails.put('AdminCity', br.Related_To__r.PersonOtherCity);
							personInchargeDetails.put('AdminZipCode', br.Related_To__r.PersonOtherPostalCode);
							if (!resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).containsKey('AdminInformationDetails')){
								temporaryList.add(personInchargeDetails);
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).put('AdminInformationDetails', temporaryList);
							} else{
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).get('AdminInformationDetails').add(personInchargeDetails);
							}
							if (br.Related_From_License_Number__r.Regulatory_Authorization_Type_Name__c == 'Funeral Establishment'){
								if (br.Related_From__c != null && br.Related_From_License_Number__c != null && br.Roles__c != null){
									funeralRelationMap.put('LicenseeName', br.Related_From__r.Name);
									funeralRelationMap.put('LicenseNumber', br.Related_From_License_Number__r.Name);
									String professionValue;
									if (br.Roles__c == 'Designated Incharge'){
										professionValue = 'Person In Charge';
									} else{
										professionValue = '';
									}
									funeralRelationMap.put('Profession', professionValue);
									if (!resultMap.get(br.Related_From_License_Number__c).containsKey('LicenseAssociationDetail')){
										funeraltemporaryList.add(funeralRelationMap);
										resultMap.get(br.Related_From_License_Number__c).put('LicenseAssociationDetail', funeraltemporaryList);
									} else{
										resultMap.get(br.Related_From_License_Number__c).get('LicenseAssociationDetail').add(funeralRelationMap);
									}
								}
							}
						}
					} else if (br.Roles__c == 'Primary Supervisor'){
						if (blIdToAccountIdMap.values().contains(br.Related_To__c)){
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_To__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_To__c), new Map<String, List<Map<String, Object>>>());
							}
							primarySupervisorDetails.put('CollabName', br.Related_From__r.Name);
							primarySupervisorDetails.put('CollabLicense', br.Related_From_License_Number__r.Name);
							primarySupervisorDetails.put('Id', br.Related_From_License_Number__r.Id);
							if (br.Related_From_License_Number__r.Id != null){
								pdIdSet.add(br.Related_From_License_Number__r.Id);
							}
							if (!resultMap.get(AccountIdToblIdMap.get(br.Related_To__c)).containsKey('Collaborations')){
								temporaryList.add(primarySupervisorDetails);
								resultMap.get(AccountIdToblIdMap.get(br.Related_To__c)).put('Collaborations', temporaryList);
							} else{
								resultMap.get(AccountIdToblIdMap.get(br.Related_To__c)).get('Collaborations').add(primarySupervisorDetails);
							}
						}
					}
				}
				if (!dcIdSet.isEmpty()){
					Map<Id, Map<String, Object>> addrMap = getAddressByLocationType(dcIdSet, RECORDS_ADDRESS);
					if (addrMap != null){
						for (Id blId : resultMap.keySet()){
							if (resultMap.get(blId).containsKey('DesignationOfCustodial')){
								for (Map<String, Object> dc : resultMap.get(blId).get('DesignationOfCustodial')){
									if (addrMap.containsKey((Id) dc.get('Id'))){
										dc.put('Address', addrMap.get((Id) dc.get('Id')));
									} else{
										dc.put('Address', '');
									}
								}
							}
						}
					}
				}
				return resultMap;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getLicenseAssociationDetails', e);
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	/**
	 * @author                       : Chetan
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get Business Relationship Information
	 Combined 4 methods into 1: getSupervisorInformationAndBusinessAddress , getPersonInChargeInformation, getPreneedSellerInformation, getControllingPersonList
	 * @param blIdSet                : Set<Id>
	 * @param placeIdToBlId          : Map<Id, Id>
	 * @return                       : DateTime
	 * @last modified by             : Uzma Md
	 * @last modified date           :
	 * @last modified details        :
	 */
	/*public static Map<Id, Map<String, List<Map<String, Object>>>> getBusinessRelationshipInformation(Set<Id> blIdSet, Map<Id, Id> placeIdToBlId){
		try{
			if (!blIdSet.isEmpty() && !placeIdToBlId.isEmpty()){
				Map<Id, Map<String, List<Map<String, Object>>>> resultMap = new Map<Id, Map<String, List<Map<String, Object>>>>();
				Map<String, Object> picAddressMap = new Map<String, Object>();
				List<Map<String, Object>> controllingPersonDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> preneedSellerDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> personInchargeDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> supervisorDetailsList = new List<Map<String, Object>>();
				List<Map<String, Object>> employerAddrDetailsList = new List<Map<String, Object>>();
				Set<Id> picIdSet = new Set<Id>();

				String fields = ' Id,Related_From__c ,Related_From__r.Name, Related_From_License_Number__c,Related_From_License_Number__r.Name, Related_From__r.Phone,Related_From__r.BillingAddress,Related_From__r.BillingStreet, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From_License_Number__r.Account.Name,Related_To__c,Related_To__r.Name,Related_To__r.PersonEmail, Related_To__r.Phone, License_Number__c, Related_To_License_Number__c,Related_To_License_Number__r.Name,Entity_License_Number__c,Roles__c,Start_Date__c, EndDate__c, Supervisor_License_Number__c, License_Type__c, Related_From_License_Number__r.Status, IsActive__c';

				String whereClause = 
					'Related_From_License_Number__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet) + 
					'AND IsActive__c = true' + 
					' AND Roles__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BUSINESS_ROLES_SET);

				for (Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(fields, whereClause, null, null, null)){
					Map<String, Object> controllingPersonDetails = new Map<String, Object>();
					Map<String, Object> preneedSellerDetails = new Map<String, Object>();
					Map<String, Object> personInchargeDetails = new Map<String, Object>();
					Map<String, Object> supervisorDetails = new Map<String, Object>();
					if (br.Roles__c == 'Owner'){
						if (!resultMap.containsKey(br.Related_From_License_Number__c)){
							resultMap.put(br.Related_From_License_Number__c, new Map<String, List<Map<String, Object>>>());
						}
						controllingPersonDetails.put('OwnerName', br.Related_To__r.Name);
						controllingPersonDetailsList.add(controllingPersonDetails);
						resultMap.get(br.Related_From_License_Number__c).put('ControllingPersonDetail', controllingPersonDetailsList);
					} else{
						if (!resultMap.containsKey(br.Related_From_License_Number__c)){
							resultMap.put(br.Related_From_License_Number__c, new Map<String, List<Map<String, Object>>>());
						}
						personInchargeDetails.put('AgencyName', br.Related_From__r.Name);
						personInchargeDetails.put('PersonInChargeName', br.Related_To__r.Name);
						personInchargeDetails.put('SupervisingPharmacist', br.Related_To__r.Name);
						personInchargeDetails.put('PharmacistInCharge', br.Related_To__r.Name);
						personInchargeDetails.put('ManagerInChargeName', br.Related_To__r.Name);
						personInchargeDetails.put('FuneralDirectorInchargename', br.Related_To__r.Name);
						personInchargeDetails.put('NameofDesignatedControllingPerson', br.Related_To__r.Name);
						personInchargeDetails.put('FuneralDirectorInchargeLicensenumber', br.License_Number__c);
						personInchargeDetails.put('PersonInChargeLicenseNumber', br.License_Number__c);
						personInchargeDetails.put('Email', br.Related_To__r.PersonEmail);
						personInchargeDetails.put('PhoneNumber', br.Related_To__r.Phone);
						personInchargeDetails.put('Id', br.Related_To__c);
						personInchargeDetailsList.add(personInchargeDetails);
						resultMap.get(br.Related_From_License_Number__c).put('PersonInChargeInformation', personInchargeDetailsList);
						picIdSet.add(br.Related_To__c);
					}
				}
				if (!picIdSet.isEmpty()){
					Map<Id, Map<String, Object>> addrMap = getAddressByLocationType(picIdSet, PIC_ADDRESS);
					for (Id blId : resultMap.keySet()){
						for (Map<String, Object> pic : resultMap.get(blId).get('PersonInChargeInformation')){
							if (addrMap != null && addrMap.containsKey((Id) pic?.get('Id'))){
								pic.put('Address', addrMap.get((Id) pic.get('Id')));
							} else{
								pic.put('Address', '');
							}
						}
					}
				}
				return resultMap;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getBusinessRelationshipInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 11 Oct 2023
	 * @description                 : This method retrieves Records addresses for given account IDs.
	 * @param accountIdset          : Set of account IDs for which Records addresses need to be retrieved.
	 * @param LocationType          : String , Parent.LocationType Value
	 * @return                      : A Map<Id,Map<String,Object>> containing the addresses (Address) associated with the Account IDs (Id).
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	/*public static Map<Id, Map<String, Object>> getAddressByLocationType(Set<Id> accountIdset, String LocationType){
		try{
			// Account Id and LocationType null check
			if (accountIdset != null && LocationType != null){
				Map<Id, Id> locationIdToAccIdMap = new Map<Id, Id>();
				Map<Id, Map<String, Object>> dcIdtoDCAddrMap = new Map<Id, Map<String, Object>>();

				String whereClause = 
					'ParentRecordId IN' + LPI_ServiceUtility.getStringValuesBySet(accountIdset) + 
					' AND Location.LocationType = \'' + LocationType + 
					'\'';

				for (AssociatedLocation assLoc : new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO().getAssociatedLocationByDymanicQuery('LocationId, Location.LocationType , Location.Status__c,ParentRecordId', whereClause, null, null, null)){
					locationIdToAccIdMap.put(assLoc.locationId, assLoc.ParentRecordId);
				}
				if (!locationIdToAccIdMap.isEmpty()){
					for (Schema.Address dcAddress : new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressByDymanicQuery('Street, City, State, PostalCode, ParentId, CountryCode, Business_State__c', 'Parent.Status__c = \'' + String.escapeSingleQuotes(LPI_LiteralConstant.LOCATION_STATUS_OPEN) + 
																																								'\'' + 
																																								'AND Parent.LocationType =\'' + LocationType + 
																																								'\'' + 
																																								' AND ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIdToAccIdMap.keySet()), null, null, null)){
						Map<String, Object> dcAddressMap = new Map<String, Object>();
						dcAddressMap.put('StreetAddress', dcAddress.Street);
						dcAddressMap.put('City', dcAddress.City);
						if (dcAddress.CountryCode == 'US'){
							dcAddressMap.put('State', dcAddress.State);
						} else{
							dcAddressMap.put('State', dcAddress.Business_State__c);
						}
						dcAddressMap.put('ZipCode', dcAddress.PostalCode);
						dcIdtoDCAddrMap.put(locationIdToAccIdMap.get(dcAddress.ParentId), dcAddressMap);
					}
					return dcIdtoDCAddrMap;
				}
			}
			return null;
		} catch (Exception ex){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAddressByLocationType', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}*/

	/**
	 * @author                      : Chetan
	 * @since                       : Oct 2023
	 * @description                 : Retrieves owner In charge tag details
	 * @param blIdToAccountIdMap    : Map of business license to Account
	 * @param AccountIdToblIdMap    : Map of account to business license
	 * @return                      : Map<Id, Map<String, String>>
	 * @throws AuraHandledException : if an error occurs during execution.
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	/*public static Map<Id, Map<String, String>> getOwnerInChargeTagDetails(Map<Id, Id> blIdToAccountIdMap, Map<Id, Id> AccountIdToblIdMap){
		try{
			if (!blIdToAccountIdMap.isEmpty() && !AccountIdToblIdMap.isEmpty()){
				Map<Id, Map<String, String>> resultMap = new Map<Id, Map<String, String>>();
				String fields = 'Id,Related_From__r.BillingAddress,Related_From_License_Number__r.Regulatory_Authorization_Type_Name__c, Supervisor_License_Number__c,Related_From__c, Related_From__r.Name,Related_To__c,Related_To__r.Name, Related_To_License_Number__c,Related_To_License_Number__r.Name, Related_From_License_Number__c, Related_From_License_Number__r.Name, Roles__c,Related_To__r.Website,Related_To__r.Phone,  Related_To__r.Fax, Related_To__r.Buisness_Email__c , Related_To__r.PersonEmail,Related_To__r.PersonHomePhone,Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherState,Related_To__r.PersonOtherCity,Related_To__r.PersonOtherPostalCode,Related_From__r.BillingStreet,Related_From__r.BillingState,Related_From__r.BillingCity,Related_From__r.BillingPostalCode';
				String whereClause = 'Roles__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(LICENSE_ROLES_SET);
				whereClause += 
					' AND (Related_From__c IN ' + LPI_ServiceUtility.getStringValuesByList(blIdToAccountIdMap.values()) + 
					' OR Related_To__c IN ' + LPI_ServiceUtility.getStringValuesByList(blIdToAccountIdMap.values()) + 
					') AND IsActive__c = true';

				for (Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(fields, whereClause, null, null, null)){
					if (br.Roles__c == 'Designated Incharge'){
						if (blIdToAccountIdMap.values().contains(br.Related_From__c)){
							if (!resultMap.containsKey(AccountIdToblIdMap.get(br.Related_From__c))){
								resultMap.put(AccountIdToblIdMap.get(br.Related_From__c), new Map<String, String>());
							}
							if (!resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).containsKey('OwnerInCharge')){
								resultMap.get(AccountIdToblIdMap.get(br.Related_From__c)).put('OwnerInCharge', br.Related_To__r.Name);
							}
						}
					}
				}

				return resultMap;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getOwnerInChargeTagDetails', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                       : Chetan
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get Business Information
	 * @param blRecordList           : List<BusinessLicense>
	 * @return                       : Map<Id, Map<String, Object>>
	 * @last modified by             : Uzma Md
	 * @last modified date           :
	 * @last modified details        :
	 */
	/*public static Map<Id, Map<String, Object>> getBusinessInformation(List<BusinessLicense> blRecordList){
		try{
			if (!blRecordList.isEmpty()){
				Set<Id> schoolAccountIdSet = new Set<Id>();
				Map<Id, Map<String, Object>> blIdToBusinessInfoMap = new Map<Id, Map<String, Object>>();
				for (BusinessLicense blRec : blRecordList){
					if (!blIdToBusinessInfoMap.containsKey(blRec.Id)){
						blIdToBusinessInfoMap.put(blRec.Id, new Map<String, Object>());
					}
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessName', blRec.Business_Entity_Name__c);
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessEmail', blRec.Account.Buisness_Email__c);
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessPhone', blRec.Account.Phone);
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessFaxNumber', blRec.Account.Fax);
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessDBAName', blRec.Account.Doing_Business_As_DBA_or_Trade_Name__c);
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessOwnershipType', blRec.Account.Entity_type__c);
					blIdToBusinessInfoMap.get(blRec.Id).put('BusinessWebsite', blRec.Account.Website);
					schoolAccountIdSet.add(blRec.Account.Id);
				}
				return blIdToBusinessInfoMap;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getBusinessInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : Nitish Gundedi
	 * @since                       : 21st Aug 2023
	 * @description                 : This method is to calculate Expiry Related Dates based on PeriodEnd, RegAuth
	 * @return                      : Map<String, Object>
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Map<String, Object> calculateExpiryRelatedDates(BusinessLicense blRecord){
		Map<String, Object> expiryRelatedDates = new Map<String, Object>();
		try{
			if (blRecord.PeriodEnd != null){
				Date expiryDate = Date.newInstance(blrecord.PeriodEnd.year(), blrecord.PeriodEnd.month(), blrecord.PeriodEnd.day());
				Date nextCycleStartDate;
				Date nextCycleExpiryDate;
				Date currentRenewalStartDate;
				Date currentRenewalEndDate;
				Date currentLateRenewalStartDate;
				Date currentLateRenewalEndDate;
				Date currentReinstatementStartDate;
				Date currentReinstatementEndDate;
				Integer prevRenewCycleStartYear;
				Integer prevRenewCycleEndYear;
				Date currentRenewCycleStartDate;
				Date oneYearLateReinstatementStartDate;
				Date twoYearsLateReinstatementStartDate;
				Date oneYearLateReinstatementEndDate;
				Date twoYearsLateReinstatementEndDate;
				//======================== Next Cycle Start Date, Next Cycle Expiry Date =====================================
				if (blRecord.RegulatoryAuthorizationType.Renewal_Window_Period_Before_Expiry__c != null){
					//removing condition for Next Expiry cycle Months from expiry to get Next cycle start date
					nextCycleStartDate = expiryDate.addMonths(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Renewal_Window_Period_Before_Expiry__c));
					//If the expiry is end of month, then next expiry start should be start of next month (Excpet Feb, For Feb should be next month start)
					if (blRecord.PeriodEnd.month() == 2 || blRecord.PeriodEnd.day() == date.daysInMonth(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month())){
						nextCycleStartDate = nextCycleStartDate.addMonths(1).toStartOfMonth();
					} else{
						//else one day after removing next expiry cycle months from expiry
						nextCycleStartDate = nextCycleStartDate.addDays(1);
					}
				} else{
					nextCycleStartDate = expiryDate.addDays(1);
				}
				prevRenewCycleEndYear = expiryDate.year();
				if (blRecord.RegulatoryAuthorizationType.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE){
					if (TWO_YEARS_EXPIRY_CYCLES.contains(blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c)){
						nextCycleExpiryDate = expiryDate.addYears(2);
						prevRenewCycleStartYear = expiryDate.addYears(-2).year();
						currentRenewCycleStartDate = expiryDate.addYears(-2);
					} else if (blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_ANNUAL){
						nextCycleExpiryDate = expiryDate.addYears(1);
						prevRenewCycleStartYear = expiryDate.addYears(-1).year();
						currentRenewCycleStartDate = expiryDate.addYears(-1);
					} else if (blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_FIXED_CYCLE){
						nextCycleExpiryDate = expiryDate.addYears((Integer) blRecord.RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c);
						prevRenewCycleStartYear = expiryDate.addYears(-(Integer) blRecord.RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c).year();
						currentRenewCycleStartDate = expiryDate.addYears(-(Integer) blRecord.RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c);
					} else if (blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_FIVE_YEARS){
						nextCycleExpiryDate = expiryDate.addYears(5);
						prevRenewCycleStartYear = expiryDate.addYears(-5).year();
						currentRenewCycleStartDate = expiryDate.addYears(-5);
					}
				} else if (blRecord.RegulatoryAuthorizationType.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_PERIOD){
					if (blRecord.RegulatoryAuthorizationType.Expiration_Period__c.contains(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)){
						nextCycleExpiryDate = expiryDate.addDays(Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c.remove(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)));
						prevRenewCycleStartYear = expiryDate.addDays(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c.remove(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS))).year();
						currentRenewCycleStartDate = expiryDate.addDays(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c.remove(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)));
					} else{
						nextCycleExpiryDate = expiryDate.addMonths(Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c));
						prevRenewCycleStartYear = expiryDate.addMonths(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c)).year();
						currentRenewCycleStartDate = expiryDate.addMonths(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c));
					}
					if (blRecord.RegulatoryAuthorizationType.Expiration_Day__c != null && blRecord.RegulatoryAuthorizationType.Expiration_Day__c == LPI_LiteralConstant.EXPIRATION_DAY_DAY_OF_ISSUANCE_MINUS_1 && blRecord.RegulatoryAuthorizationType.Expiration_Month__c != null && blRecord.RegulatoryAuthorizationType.Expiration_Month__c == LPI_LiteralConstant.EXPIRATION_MONTH_MONTH_OF_ISSUANCE){
						nextCycleExpiryDate = nextCycleExpiryDate.addDays(-1);
					}
				} else if (blRecord.RegulatoryAuthorizationType.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_NO_EXPIRY){
					nextCycleExpiryDate = null;
				}
				//======================== Next Cycle Start Date, Next Cycle Expiry Date =====================================

				//======================== Renewal Dates =====================================
				if (blRecord.RegulatoryAuthorizationType.Open_for_Renewal__c != null){
					currentRenewalStartDate = expiryDate.addMonths(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Open_for_Renewal__c));
					currentRenewalEndDate = expiryDate;
				}
				if (blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null){
					currentLateRenewalStartDate = expiryDate.addDays(1);
					currentLateRenewalEndDate = expiryDate.addMonths(Integer.valueOf(blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c));
				}
				//Checks if the expiry date is end of the month, then start will be first of next month after removing open for renewal months
				//Exception case: In Feb we only have 28 in Expiry Rules which we need to consider as end of the month. (So not adding any day check for feb)
				if (blRecord.PeriodEnd.month() == 2 || blRecord.PeriodEnd.day() == date.daysInMonth(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month())){
					currentRenewalStartDate = currentRenewalStartDate != null ? currentRenewalStartDate.addMonths(1).toStartOfMonth() : null;
					currentLateRenewalEndDate = currentLateRenewalEndDate != null ? currentLateRenewalEndDate.addMonths(1).toStartOfMonth().addDays(-1) : null;
				} else{
					//if not end of the month, just start from next day after removing open for renewal months till adding late renewal/periodEnd
					currentRenewalStartDate = currentRenewalStartDate != null ? currentRenewalStartDate.addDays(1) : null;
				}
				//======================== Renewal Dates =====================================

				//======================== Reinstatement Dates =====================================
				if (blrecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c != null){
					if (blrecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null){
						currentReinstatementStartDate = expiryDate.addMonths(Integer.valueOf(blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c));
					} else{
						currentReinstatementStartDate = expiryDate;
					}

					//checking To start from next month starting or not
					if ((blRecord.PeriodEnd.month() == 2 && FEB_END_DAYS_SET.contains(blRecord.PeriodEnd.day())) || blRecord.PeriodEnd.day() == date.daysInMonth(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month())){
						currentReinstatementStartDate = currentReinstatementStartDate.addMonths(1).toStartOfMonth();
						//Added by ritu for FD/FDL/EMB reinstatement periods for 2 years
						if (LICENSE_TYPE_SET.contains(blRecord.RegulatoryAuthorizationType.Name)){
							oneYearLateReinstatementStartDate = currentReinstatementStartDate;
							twoYearsLateReinstatementStartDate = currentReinstatementStartDate.addYears(1);
						}
					} else{
						//else start next day after adding late renewal months to periodEnd
						currentReinstatementStartDate = currentReinstatementStartDate.addDays(1);
						if (LICENSE_TYPE_SET.contains(blRecord.RegulatoryAuthorizationType.Name)){
							oneYearLateReinstatementStartDate = currentReinstatementStartDate;
							twoYearsLateReinstatementStartDate = currentReinstatementStartDate.addYears(1);
						}
					}

					if (blrecord.Reinstatement_Count__c != null && blrecord.Reinstatement_Count__c >= 1 && blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c != null && blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c != 0){
						currentReinstatementEndDate = currentReinstatementStartDate.addMonths(Integer.valueof(blRecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c));
					} else if (blrecord.Reinstatement_Count__c == null || blrecord.Reinstatement_Count__c < 1 || (blrecord.Reinstatement_Count__c >= 1 && (blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c == null || blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c == 0))){
						currentReinstatementEndDate = currentReinstatementStartDate.addMonths(Integer.valueof(blRecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c));
						if (LICENSE_TYPE_SET.contains(blRecord.RegulatoryAuthorizationType.Name)){
							oneYearLateReinstatementEndDate = currentReinstatementEndDate.addDays(-1).addYears(-1);
							twoYearsLateReinstatementEndDate = currentReinstatementEndDate.addDays(-1);
						}
					}
				}
				//======================== Reinstatement Dates =====================================
				// condn basis if renewd before/ after  certain period . (Next exp date - condn for next expiry)

				Integer nextYearOfNextCycleStartYear = nextCycleStartDate != null ? nextCycleStartDate.year() : null;
				expiryRelatedDates.put('NextYearOfNextCycleStartYear', nextYearOfNextCycleStartYear != null ? nextYearOfNextCycleStartYear : null);
				expiryRelatedDates.put('NextCycleStartDate', nextCycleStartDate != null ? convertDateIntoMonth(nextCycleStartDate) : null);
				// time limit for which license will be active once it renews the license
				expiryRelatedDates.put('NextCycleExpiryDate', nextCycleExpiryDate != null ? convertDateIntoMonth(nextCycleExpiryDate) : null);
				// period end business license
				Integer expirationYear = expiryDate != null ? expiryDate.year() : null;
				Date nextDateOfExpiration = expiryDate.addDays(1);
				expiryRelatedDates.put('ExpirationDate', expiryDate != null ? convertDateIntoMonth(expiryDate) : null);
				expiryRelatedDates.put('ExpirationYear', expirationYear);
				expiryRelatedDates.put('NextDateOfExpirationDate', nextDateOfExpiration != null ? convertDateIntoMonth(nextDateOfExpiration) : null);
				// window open for renewal date

				Integer currentRenewalStartYear = currentRenewalStartDate != null ? currentRenewalStartDate.year() : null;
				expiryRelatedDates.put('CurrentRenewalStartYear', currentRenewalStartYear != null ? currentRenewalStartYear : null);

				expiryRelatedDates.put('CurrentRenewalStartDate', currentRenewalStartDate != null ? convertDateIntoMonth(currentRenewalStartDate) : null);
				expiryRelatedDates.put('CurrentRenewalEndDate', currentRenewalEndDate != null ? convertDateIntoMonth(currentRenewalEndDate) : null);
				expiryRelatedDates.put('CurrentLateRenewalStartDate', currentLateRenewalStartDate != null ? convertDateIntoMonth(currentLateRenewalStartDate) : null);
				expiryRelatedDates.put('CurrentLateRenewalEndDate', currentLateRenewalEndDate != null ? convertDateIntoMonth(currentLateRenewalEndDate) : null);
				// after late renewal if no late renewal start after expiry date
				expiryRelatedDates.put('CurrentReinstatementStartDate', currentReinstatementStartDate != null ? convertDateIntoMonth(currentReinstatementStartDate) : null);
				// after late renewal if no late renewal start after expiry date
				expiryRelatedDates.put('CurrentReinstatementEndDate', currentReinstatementStartDate != null ? convertDateIntoMonth(currentReinstatementEndDate.addDays(-1)) : null);
				expiryRelatedDates.put('PrevRenewCycleStartYear', prevRenewCycleStartYear);
				// current expiration date that year
				expiryRelatedDates.put('PrevRenewCycleEndYear', prevRenewCycleEndYear);
				// current Previous Renew Cycle Start Date

				if (prevRenewCycleStartYear != null){
					expiryRelatedDates.put('PreviousRenewCycleYear', prevRenewCycleStartYear - 1);
					expiryRelatedDates.put('NextRenewCycleYear', prevRenewCycleStartYear + 1);
				}

				expiryRelatedDates.put('CurrentRenewCycleStartDate', currentRenewCycleStartDate !=null ? currentRenewCycleStartDate.addDays(1) : null);
				if (LICENSE_TYPE_SET.contains(blRecord.RegulatoryAuthorizationType.Name)){
					expiryRelatedDates.put('OneYearLateReinstatementStartDate', oneYearLateReinstatementStartDate != null ? convertDateIntoMonth(oneYearLateReinstatementStartDate) : null);
					expiryRelatedDates.put('TwoYearsLateReinstatementStartDate', twoYearsLateReinstatementStartDate != null ? convertDateIntoMonth(twoYearsLateReinstatementStartDate) : null);
					expiryRelatedDates.put('OneYearLateReinstatementEndDate', oneYearLateReinstatementEndDate != null ? convertDateIntoMonth(oneYearLateReinstatementEndDate) : null);
					expiryRelatedDates.put('TwoYearsLateReinstatementEndDate', twoYearsLateReinstatementEndDate != null ? convertDateIntoMonth(twoYearsLateReinstatementEndDate) : null);
				}
			}
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'calculateExpiryRelatedDates', e);
		}
		return expiryRelatedDates;
	}

	/**
	 * @author                       : Chetan
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to convert Date Into Month
	 * @param inputDate              : Date
	 * @return                       : String
	 * @last modified by             : Uzma Md
	 * @last modified date           :
	 * @last modified details        :
	 */
	public static String convertDateIntoMonth(Date inputDate){
		try{
			Datetime dt = Datetime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
			String formattedDate = dt.format('MMMM d, yyyy');
			return formattedDate;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'convertDateIntoMonth', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 17 Jan 2024
	 * @description                 : This method is used to get HSP Eligible Tag Value
	 * @param blIdSet               : Set<Id>
	 * @return                      : Map<Id, Boolean>
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static Map<Id, Boolean> getHSPEligibleTagValue(Set<Id> blIdSet){
		Map<Id, Boolean> hspTagMap = new Map<Id, Boolean>();

		try{
			if (!blIdSet.isEmpty()){
				String fields = 'Id, Title__c, Business_License__c';
				String whereClause = 'Status = \'Active\' AND Business_License__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet);
				List<BoardCertification> certificationDetailsList = LPI_CertificationDAO.getCertificationByDymanicQuery(fields, whereClause, null, null, null);
				for (Id blId : blIdSet){
					hspTagMap.put(blId, false);
				}
				for (BoardCertification certificate : certificationDetailsList){
					if (certificate.Title__c != null && certificate.Title__c == 'Health Service Provider (HSP)'){
						hspTagMap.put(certificate.Business_License__c, true);
					}
				}
			}
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getHSPEligibleTagValue', e);
			throw new AuraHandledException(e.getMessage());
		}
		return hspTagMap;
	}

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Novemeber 2023
	 * @description                 : Retrieves certification details for given Business License IDs.
	 * @param blIdSet               : Set of Business License IDs to fetch certification details.
	 * @return                      : Map of Business License ID to Certification details.
	 * @throws AuraHandledException : if an error occurs during execution.
	 * @last modified by            : Uzma Md
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static Map<Id, Map<String, Object>> getCertificationDetails(Set<Id> blIdSet){
		Map<Id, Map<String, Object>> certificateMap = new Map<Id, Map<String, Object>>();

		try{
			if (!blIdSet.isEmpty()){
				String fields = 'Id, Title__c, Business_License__c';
				String whereClause = 
					'Status = \'Active\' AND Business_License__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet);

				List<BoardCertification> certificationDetailsList = LPI_CertificationDAO.getCertificationByDymanicQuery(fields, whereClause, null, null, null);
				for (BoardCertification certificate : certificationDetailsList){
					if (!certificateMap.containsKey(certificate.Business_License__c)){
						certificateMap.put(certificate.Business_License__c, new Map<String, Object>());
						certificateMap.get(certificate.Business_License__c).put('Certifications', new List<Map<String, String>>());
					}

					Map<String, String> certDetails = new Map<String, String>();
					certDetails.put('CertTitle', certificate.Title__c);
					((List<Map<String, String>>)certificateMap.get(certificate.Business_License__c).get('Certifications')).add(certDetails);
				}
			}
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getCertificationDetails', e);
			throw new AuraHandledException(e.getMessage());
		}
		return certificateMap;
	}

}