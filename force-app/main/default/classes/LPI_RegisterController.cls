/**
 *
 * @author          : MTX Group Product Team | 19-10-2022
 * @description     : This class is used to verify captcha and registration part, create new user, create OTP ,resend OTP
 */
public with sharing class LPI_RegisterController {
	
	public final static String CLASS_NAME = 'LPI_RegisterController';
	public final static String DO_FINISH_REGISTRATION_CAPCTCHA = 'doFinishRegistrationCapctcha';
	public final static String DO_FINISH_REGISTRATION = 'doFinishRegistration';
	public final static String CREATE_OTP = 'createOTP';
	public final static String CREATE_USER = 'createUser';
	public final static String RESEND_OTP = 'resendOtp';
	public final static String EIN_ZERO_NUM = '000000000';
	public static final String ZIP_CITY_COUNTY_PRE_POPULATION ='Zip City County Pre Population';
	

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of registration page
	 * @return  `RegistrationFormWrapper`
	 */
	@AuraEnabled
	public static RegistrationFormWrapper fetchRegistrationFormWrapper() {
		RegistrationFormWrapper wr = new RegistrationFormWrapper();
		return wr;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @description                 : Here in this method we check captcha is enabled or not and after that send data in serialize form
	 * @param wrapperData           : data we are passing from portal like firstname ,lastname ,etc
	 * @param recaptchaResponse     : Passing captacha token value
	 * @param ctype                 : Passing captacha Version V2 or V3
	 * @return                      : `ResponseWrapper`
	 */
	@AuraEnabled
	public static ResponseWrapper doFinishRegistrationCapctcha(
		String wrapperData, String recaptchaResponse, String ctype
	) {
		CaptchaWrapper inputWrapperObject;
		try {
		
			inputWrapperObject = new CaptchaWrapper();
			inputWrapperObject.cflag = isRecaptchaDisabled();
			inputWrapperObject.ctype = ctype;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, DO_FINISH_REGISTRATION_CAPCTCHA, e);
			throw new LPI_Exception('Problem in Recaptcha', e);
		}
		return doFinishRegistration(wrapperData, JSON.serialize(inputWrapperObject), recaptchaResponse);
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method will verify the captcha and check user already exist or not in portal
	 * @param  wrapperJSON        : data we are passing from portal like firstname ,lastname ,etc
	 * @param  captchaWrapper     : Here we are checking captcha is disable or Enable
	 * @param  recaptchaResponse  : response we are sending back to javascript
	 * @return                    : return captcha is verified or not
	 * @exception                 : Handle the error in case Verification Failed or OTP Creation failed
	 */
	@TestVisible
	private static ResponseWrapper doFinishRegistration(
		String wrapperJSON,String captchaWrapper,String recaptchaResponse
	) {
		Savepoint sp;
		ResponseWrapper responseWrap = new ResponseWrapper();
		try {
			if (String.isNotEmpty(wrapperJSON) && String.isNotBlank(wrapperJSON)) {
				RegistrationFormWrapper wr = (RegistrationFormWrapper) JSON.deserializeStrict(
					wrapperJSON,
					RegistrationFormWrapper.class
				);
				if (!LPI_ServiceUtility.checkForSpecialCharInString(wr.firstname)) {
					throw new LPI_Exception('Special characters are not allowed');
				}
				CaptchaWrapper inputWrapperObject = (CaptchaWrapper) JSON.deserializeStrict(
					captchaWrapper,
					CaptchaWrapper.class
				);
				
				 
				if (inputWrapperObject.cflag != true) {
					Boolean captchaValid = false;
					 
					if (String.isNotBlank(recaptchaResponse)) {
						if (inputWrapperObject.ctype == 'v3') {
							RecaptchaResponseWrapper captchaWrpMap = (RecaptchaResponseWrapper) JSON.deserializeStrict(
								recaptchaResponse,
								RecaptchaResponseWrapper.class
							);
							if (captchaWrpMap.action == 'Submit') {
								Map<String, Object> txnMap = new Map<String, Object>();
								txnMap = LPI_VerifyCaptcha.makeRequest(
									captchaWrpMap.response,
									captchaWrpMap.action,
									false
								);

								captchaValid = (Boolean) txnMap.get('valid');
							}
							if (!captchaValid) {
								responseWrap.isV3Failed = true;
							}
						}
					}
					if (Test.isRunningTest()) {
						captchaValid = true;
					}
					if (!captchaValid) {
						responseWrap.isCaptchaInvalid = true;
						responseWrap.isV3Failed = true;
						return responseWrap;
					}
				}
				sp = Database.setSavepoint();

				 
				Id personAccountRecordTypeId = LPI_UtilityDescribe.getRecordTypeIdWithName(
				'Account',
				LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE
				);

				Account acc = new Account();
				acc.Combined_Name__pc = String.isNotBlank(wr.firstname) && String.isNotBlank(wr.middleName) ? wr.firstname + ' ' + wr.middleName + ' ' + wr.lastName
                : String.isNotBlank(wr.firstname) ? wr.firstname + ' ' + wr.lastName : String.isNotBlank(wr.middleName) ? wr.middleName + ' ' + wr.lastName : wr.lastName;
				
				acc.FirstName = LPI_VlocityUtility.updateStringToCamelCase(wr.firstname);
				acc.middleName = LPI_VlocityUtility.updateStringToCamelCase(wr.middleName);
				acc.LastName = LPI_VlocityUtility.updateStringToCamelCase(wr.lastName);
				acc.OwnerId = Label.UserOwnerId;
				acc.RecordTypeId = personAccountRecordTypeId;
				acc.PersonOtherStreet = wr.street1;
				acc.PersonOtherPostalCode = wr.zipcode;
				acc.PersonOtherCity = wr.city;
				if (wr.state != null) {
					acc.PersonOtherStateCode = wr.state;
				}
				if (wr.stateText != null) {
					acc.Other_State__c = wr.stateText;
				}
				acc.County__c = wr.county;
				acc.PersonOtherCountryCode = wr.country;
				acc.PersonEmail = wr.email;
				acc.Phone = wr.phone;
				// if (wr.ssn.contains('XXX')) {
				// 	acc.Social_Security_Number__c = wr.newssn;
				// } else {
				// 	acc.Social_Security_Number__c = wr.ssn;
				// }
				acc.Date_of_Birth__c = Date.valueOf(wr.birthdate);

				List<Datacloud.MatchRecord> existingAccount = new List<Datacloud.MatchRecord>();
			    existingAccount = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{acc}); 
				if(!existingAccount.isEmpty()) {
					List<User> userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery('Id,Contact.Account.Social_Security_Number__c,Contact.Account.PersonEmail','Contact.AccountId = \''+existingAccount[0].getRecord().Id+'\'',null,null,null);
					if(!userList.isEmpty())
					{
						if(userList[0].Contact.Account.Social_Security_Number__c  == acc.Social_Security_Number__c || userList[0].Contact.Account.PersonEmail == acc.PersonEmail)
						{
							throw new LPI_Exception('User already exists');    
						}
					}
				} else {
					List<Account> existingAccountWithEmail = LPI_ServiceUtility.getDuplicateRecordsByEmail(new List<Account>{acc});
					if(!existingAccountWithEmail.isEmpty()){
						List<User> userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery('Id','Contact.AccountId = \''+existingAccountWithEmail[0].Id+'\'',null,null,null);
						if(!userList.isEmpty())
						{
							throw new LPI_Exception('User already exists');
						}
					}
				}

				 
				String ssn;
				// if (wr.ssn.contains('XXX') && wr.ssn != '' && wr.newssn != '') {
				// 	ssn = wr.newssn;
				// } else {
				// 	ssn = wr.ssn;
				// }
				if (String.isNotBlank(ssn)) {
					List<User> userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery(
						'ID',
						'Contact.Account.Social_Security_Number__c = \'' + ssn + '\'',
						null,
						null,
						null
					);

					if (!userList.isEmpty()) {
						throw new LPI_Exception('User already exists with this SSN number ');
					}
				}

			 
				createOTP(wr);
			}
			return responseWrap;
		} catch (DmlException de) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(CLASS_NAME, DO_FINISH_REGISTRATION, de);
			throw new LPI_Exception(de.getDmlMessage(0));
		} catch (Exception e) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(CLASS_NAME, DO_FINISH_REGISTRATION, e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author              : MTX Group Product Team
	 * @description         : This Method will create unique otp every time user start registration
	 * @param userDetails   : firstName ,lastName email and required fields
	 * @return              : `String` OTP Value
	 */
	@TestVisible
	private static String createOTP(RegistrationFormWrapper userDetails) {
		OTP__c otp;
		try {
			
			List<OTP__c> markOldOTPInvalid = LPI_WithoutSharingUtility.getOtpRecordByEmail(userDetails.email);

			 
			otp = new OTP__c();
			otp.First_Name__c = userDetails.firstName;
			otp.Last_Name__c = userDetails.lastName;
			otp.Email__c = userDetails.email;
			otp.Type__c = 'Registration';
			otp.OTP_Value__c = (string.valueof(Math.abs(Crypto.getRandomLong()))).Substring(0, 6);
			otp.OTP_Sent_Count__c = 1;
			LPI_WithoutSharingUtility.insertSObject(otp);

			 
			for (OTP__c otpRecord : markOldOTPInvalid) {
				otpRecord.Is_Expired__c = true;
			}
			if (!markOldOTPInvalid.isEmpty()) {
				LPI_WithoutSharingUtility.upsertSObjectList(markOldOTPInvalid);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, CREATE_OTP, e);
			throw new LPI_Exception('Problem in OTP', e);
		}
		return otp.OTP_Value__c;
	}

	/**
	 * @author              : MTX Group Product Team
	 * @description         : This Method will resend otp every time user click on resent otp button
	 * @param otpValue      : passing OTP value
	 * @return              : `String` Send new OTP if time limit execeds
	 */
	@AuraEnabled
	public static ResponseWrapper resendOtp(String emailValue) {
		OTP__c otp;
		ResponseWrapper responseWrap = new ResponseWrapper();
		String errorMessage = '';
		try {
			List<OTP__c> otpList = LPI_WithoutSharingUtility.getOtpRecordByEmail(emailValue);
			if (!otpList.isEmpty()) {
				otp = otpList[0];
			} else {
				errorMessage = 'Entered OTP is Incorrect!!';
				throw new LPI_Exception(errorMessage);
			}
			
			if (System.now() <= otp.CreatedDate.addMinutes(Integer.valueof(Label.OTPValidTime))) {
				otp.Is_Email_Sent__c = false;
				otp.OTP_Sent_Count__c += 1;
				if (otp.OTP_Sent_Count__c > 4) {
					errorMessage = 'You have exceeded the maximum otp limit. Please try after some time.';
					throw new LPI_Exception(errorMessage);
				} else {
					LPI_WithoutSharingUtility.upsertSObject(otp);
				}
			} else {
				 
				List<OTP__c> markOldOTPInvalid = LPI_WithoutSharingUtility.getOtpRecordByEmail(emailValue);

				 
				OTP__c newOTP = otp.clone(false, true, false, false);
				newOtp.OTP_Value__c = (string.valueof(Math.abs(Crypto.getRandomLong()))).Substring(0, 6);
				newOTP.OTP_Sent_Count__c = 1;
				newOTP.Is_Email_Sent__c = false;
				LPI_WithoutSharingUtility.insertSObject(newOTP);

				 
				for (OTP__c otpRecord : markOldOTPInvalid) {
					otpRecord.Is_Expired__c = true;
				}
				if (!markOldOTPInvalid.isEmpty()) {
					LPI_WithoutSharingUtility.upsertSObjectList(markOldOTPInvalid);
				}
			}
		} catch (Exception e) {
			if (errorMessage != '') {
				LPI_ExceptionManager.logException(CLASS_NAME, RESEND_OTP, e);
			}
			errorMessage = errorMessage != '' ? errorMessage : 'Problem in resend OTP';
			throw new LPI_Exception(errorMessage, e);
		}
		return responseWrap;
	}

	/**
	 * @author              : MTX Group Product Team
	 * @param wrapperJSON   : passing Data and Otp
	 * @description         : Validating and Inserting user
	 * @exception           : error we will get if any issue occur will inserting account
	 */
	@AuraEnabled
	public static ResponseWrapper validateUserAndCreateUser(
		String otpValue,String wrapperJSON,String recaptchaResponse,String ctype
	) {
		String errorMessage = '';
		try {
			ResponseWrapper responseWrap = new ResponseWrapper();
			 
			RegistrationFormWrapper wrapper = (RegistrationFormWrapper) JSON.deserializeStrict(
				wrapperJSON,
				RegistrationFormWrapper.class
			);
			if (!LPI_ServiceUtility.checkForSpecialCharInString(wrapper.firstname)) {
				errorMessage = 'Special characters are not allowed';
				throw new LPI_Exception(errorMessage);
			}
			CaptchaWrapper inputWrapperObject;

			 
			inputWrapperObject = new CaptchaWrapper();
			inputWrapperObject.cflag = isRecaptchaDisabled();
			inputWrapperObject.ctype = ctype;
			String captchaWrapper = JSON.serialize(inputWrapperObject);
			inputWrapperObject = (CaptchaWrapper) JSON.deserializeStrict(captchaWrapper, CaptchaWrapper.class);

			 
			if (inputWrapperObject.cflag != true) {
				Boolean captchaValid = false;
				 
				if (String.isNotBlank(recaptchaResponse)) {
					if (inputWrapperObject.ctype == 'v3') {
						RecaptchaResponseWrapper captchaWrpMap = (RecaptchaResponseWrapper) JSON.deserializeStrict(
							recaptchaResponse,
							RecaptchaResponseWrapper.class
						);
						if (captchaWrpMap.action == 'Submit') {
							Map<String, Object> txnMap = new Map<String, Object>();
							txnMap = LPI_VerifyCaptcha.makeRequest(
								captchaWrpMap.response,
								captchaWrpMap.action,
								false
							);

							captchaValid = (Boolean) txnMap.get('valid');
						}
						if (!captchaValid) {
							responseWrap.isV3Failed = true;
						}
					} 
					 
				}
				if (Test.isRunningTest()) {
					captchaValid = true;
				}
				if (!captchaValid) {
					responseWrap.isCaptchaInvalid = true;
					responseWrap.isV3Failed = true;
					return responseWrap;
				}
			}
			if (wrapper.email != null && wrapper.email != '') {
				List<Otp__c> otpList = LPI_WithoutSharingUtility.getOtpRecordByEmail(wrapper.email);

				if (!otpList.isEmpty()) {
					Otp__c otp = otpList[0];
					 
					if (System.now() <= otp.CreatedDate.addMinutes(Integer.valueof(Label.OTPValidTime))) {
						if (otp.OTP_Value__c == otpValue) {
							 
							createUser(wrapper);
							responseWrap.isSuccess = true;
							return responseWrap;
						} else {
							responseWrap.isSuccess = false;
						}
					} else {
						errorMessage = 'The OTP has expired, Try resending a new OTP!';
						throw new LPI_Exception(errorMessage);
					}
				}
			}
			responseWrap.isSuccess = false;
			return responseWrap;
		} catch (Exception e) {
			if (errorMessage == '') {
				LPI_ExceptionManager.logException(CLASS_NAME, 'validateUserAndCreateUser', e);
				throw new LPI_Exception(e.getMessage());
			} else {
				throw new LPI_Exception(errorMessage);
			}
		}
	}

	/**
	 * @author              : MTX Group Product Team
	 * @param wrapperJSON   : passing Data in from of wrapper from Javascript to Create Person account
	 * @description         : Inserting user
	 * @exception           : error we will get if any issue occur will inserting account
	 */
	@TestVisible
	private static void createUser(RegistrationFormWrapper wr) {
		String errorMessage = '';
		Savepoint sp;
		try {
			Id personAccountRecordTypeId = LPI_UtilityDescribe.getRecordTypeIdWithName(
				'Account',
				LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE
			);

			 
			Account acc = new Account();
			acc.Combined_Name__pc = String.isNotBlank(wr.firstname) && String.isNotBlank(wr.middleName) ? wr.firstname + ' ' + wr.middleName + ' ' + wr.lastName
                : String.isNotBlank(wr.firstname) ? wr.firstname + ' ' + wr.lastName : String.isNotBlank(wr.middleName) ? wr.middleName + ' ' + wr.lastName : wr.lastName;

			acc.FirstName = LPI_VlocityUtility.updateStringToCamelCase(wr.firstname);
			acc.middleName = LPI_VlocityUtility.updateStringToCamelCase(wr.middleName);
			acc.LastName = LPI_VlocityUtility.updateStringToCamelCase(wr.lastName);
			acc.OwnerId = Label.UserOwnerId;
			acc.RecordTypeId = personAccountRecordTypeId;
			acc.PersonOtherStreet = wr.street1;
			acc.PersonOtherPostalCode = wr.zipcode;
			acc.PersonOtherCity = wr.city;
			if (wr.state != null) {
				acc.PersonOtherStateCode = wr.state;
			}
			if (wr.stateText != null) {
				acc.Other_State__c = wr.stateText;
			}
			acc.County__c = wr.county;
			acc.PersonOtherCountryCode = wr.country;
			acc.PersonEmail = wr.email;
			acc.Phone = wr.phone;
			// if (wr.ssn.contains('XXX')) {
			// 	acc.Social_Security_Number__c = wr.newssn;
			// } else {
			// 	acc.Social_Security_Number__c = wr.ssn;
			// }
			acc.Date_of_Birth__c = Date.valueOf(wr.birthdate);
			acc.Is_the_address_in_US_or_International__c = wr.addressInUSOrInternational;
			acc.Security_Question__c = wr.securityQuestionAnswer;

			sp = Database.setSavepoint();

			 
			List<Datacloud.MatchRecord> existingAccount = new List<Datacloud.MatchRecord>();
			existingAccount = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{acc}); 
			 
			List<User> userList;
			String contactId;

			 
			if(!existingAccount.isEmpty())
			{
				userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery('Id,Contact.Account.Social_Security_Number__c,Contact.Account.PersonEmail','Contact.AccountId = \''+existingAccount[0].getRecord().Id+'\'',null,null,null);
				if(userList.isEmpty())
				{
					 
					acc.Id = existingAccount[0].getRecord().Id;
					LPI_WithoutSharingUtility.updateSObject(acc);
					contactId = LPI_WithoutSharingUtility.getAccount(existingAccount[0].getRecord().Id).PersonContactId;	
				}else{
					if(!userList.isEmpty())
					{
						 
						if(userList[0].Contact.Account.Social_Security_Number__c  == acc.Social_Security_Number__c || userList[0].Contact.Account.PersonEmail  == acc.PersonEmail)
						{
							throw new LPI_Exception('User already exists');    
						}
						else{
							 
							Database.DMLOptions dml = new Database.DMLOptions(); 
							dml.DuplicateRuleHeader.AllowSave = true;
							Database.SaveResult sr = Database.insert(acc, dml);
							 
							contactId = LPI_WithoutSharingUtility.getAccount(acc.Id).PersonContactId;	
						}
					}
				}	
			}
			else
			{
				List<Account> existingAccountWithEmail = LPI_ServiceUtility.getDuplicateRecordsByEmail(new List<Account>{acc});
				if(!existingAccountWithEmail.isEmpty())
				{
					 
					userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery('Id','Contact.AccountId = \''+existingAccountWithEmail[0].Id+'\'',null,null,null);
					if(userList.isEmpty())
					{
						acc.Id = existingAccountWithEmail[0].Id;
						LPI_WithoutSharingUtility.updateSObject(acc);
						contactId = LPI_WithoutSharingUtility.getAccount(existingAccountWithEmail[0].Id).PersonContactId;	
					}else{
						throw new LPI_Exception('User already exists');
					}	
				}
				else {
					 
					LPI_WithoutSharingUtility.insertSObject(acc);
					 
					contactId = LPI_WithoutSharingUtility.getAccount(acc.Id).PersonContactId;	
				}
			}

			LPI_InsertUser.insertUser(contactId);

			
		}catch (DmlException de) {
            Database.rollback(sp);
            LPI_ExceptionManager.logException(CLASS_NAME, CREATE_USER, de);
            throw new LPI_Exception(de.getDmlMessage(0));
        }catch (Exception e) {
			Database.rollback(sp);
			if (errorMessage != '') {
				LPI_ExceptionManager.logException(CLASS_NAME, CREATE_USER, e);
				throw new LPI_Exception(e.getMessage());
			}
		}
	}

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of registration page
	 * @return  `RegistrationFormWrapperForBusiness`
	 */
	@AuraEnabled
	public static RegistrationFormWrapperForBusiness fetchRegistrationFormWrapperForBusiness() {
		RegistrationFormWrapperForBusiness wr = new RegistrationFormWrapperForBusiness();
		return wr;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @description                 : Here in this method we check captcha is enabled or not and after that send data in serialize form
	 * @param wrapperData           : data we are passing from portal like firstname ,lastname ,etc
	 * @param recaptchaResponse     : Passing captacha token value
	 * @param ctype                 : Passing captacha Version V2 or V3
	 * @return                      : `ResponseWrapper`
	 */
	@AuraEnabled
	public static ResponseWrapper doFinishRegistrationCapctchaForBusiness(
		String wrapperData, String recaptchaResponse, String ctype
	) {
		CaptchaWrapper inputWrapperObject;
		try {
			 
			inputWrapperObject = new CaptchaWrapper();
			inputWrapperObject.cflag = isRecaptchaDisabled();
			inputWrapperObject.ctype = ctype;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, DO_FINISH_REGISTRATION_CAPCTCHA, e);
			throw new LPI_Exception('Problem in Recaptcha', e);
		}
		return doFinishRegistrationForBusiness(wrapperData, JSON.serialize(inputWrapperObject), recaptchaResponse);
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method will verify the captcha and check user already exist or not in portal
	 * @param  wrapperJSON        : data we are passing from portal like firstname ,lastname ,etc
	 * @param  captchaWrapper     : Here we are checking captcha is disable or Enable
	 * @param  recaptchaResponse  : response we are sending back to javascript
	 * @return                    : return captcha is verified or not
	 * @exception                 : Handle the error in case Verification Failed or OTP Creation failed
	 */
	@TestVisible
	private static ResponseWrapper doFinishRegistrationForBusiness(
		String wrapperJSON, String captchaWrapper, String recaptchaResponse
	) {
		Savepoint sp;
		ResponseWrapper responseWrap = new ResponseWrapper();
		try {
		
			if (String.isNotEmpty(wrapperJSON) && String.isNotBlank(wrapperJSON)) {
				RegistrationFormWrapperForBusiness wr = (RegistrationFormWrapperForBusiness) JSON.deserializeStrict(
					wrapperJSON,
					RegistrationFormWrapperForBusiness.class
				);
				CaptchaWrapper inputWrapperObject = (CaptchaWrapper) JSON.deserializeStrict(
					captchaWrapper, CaptchaWrapper.class
				);

				 
				if (inputWrapperObject.cflag != true) {
					Boolean captchaValid = false;
					 
					if (String.isNotBlank(recaptchaResponse)) {
						if (inputWrapperObject.ctype == 'v3') {
							RecaptchaResponseWrapper captchaWrpMap = (RecaptchaResponseWrapper) JSON.deserializeStrict(
								recaptchaResponse,
								RecaptchaResponseWrapper.class
							);
							if (captchaWrpMap.action == 'Submit') {
								Map<String, Object> txnMap = new Map<String, Object>();
								txnMap = LPI_VerifyCaptcha.makeRequest(
									captchaWrpMap.response,
									captchaWrpMap.action,
									false
								);

								captchaValid = (Boolean) txnMap.get('valid');
							}
							if (!captchaValid) {
								responseWrap.isV3Failed = true;
							}
						} 
						 
					}
					if (Test.isRunningTest()) {
						captchaValid = true;
					}
					if (!captchaValid) {
						responseWrap.isCaptchaInvalid = true;
						responseWrap.isV3Failed = true;
						return responseWrap;
					}
				}
				sp = Database.setSavepoint();
				 
				String emailWithsuffix = wr.businessEmail + '.' + Label.PortalUserNameSuffix;
				List<User> lstUser = LPI_WithoutSharingUtility.getUserByUsername(emailWithsuffix);
				if (!lstUser.isEmpty()) {
					throw new LPI_Exception('An account already exists with this email Id. Please log into the account that is associated with this email address to proceed with your Individual/business application.');
				}

				String fieldToQuery = 'Id, Buisness_Email__c';
                String whereClause = '';
                boolean proceedQuery = false;
                if (String.isNotBlank(wr.moStateRegistrationNumber) ){
                     whereClause += '( MO_State_Registration_Number__c = \'' + wr.moStateRegistrationNumber + '\'';
                     proceedQuery = true;
                }
                if ( String.isNotBlank(wr.newEmployerIdentificationNum) && wr.newEmployerIdentificationNum != EIN_ZERO_NUM){
                    whereClause = String.isNotBlank(whereClause) ? whereClause + ' OR ' : '( ';
                    whereClause +=  'Federal_Employer_ID_Number_EIN__c = \'' + wr.newEmployerIdentificationNum + '\''+' ) ';
                    proceedQuery = true;
                }else{
					whereClause += ')';
				}

                whereClause = proceedQuery ?  whereClause + ' AND Buisness_Email__c != NULL' : ' Buisness_Email__c != NULL';
				LPI_AccountDAO.LPI_AccountWithoutSharingDAO accDAOWithoutSharing = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
                if(proceedQuery){
                    List<Account> accList = accDAOWithoutSharing.getAccountByDymanicQuery(fieldToQuery,whereClause,null,null,null);
                    if(!accList.isEmpty()){
                        Set<String> emailSet = new Set<String>();
                        for(Account acc : accList){
                            emailSet.add(acc.Buisness_Email__c);
                        }
                        lstUser = LPI_WithoutSharingUtility.getUserByEmail(emailSet);
                        if (!lstUser.isEmpty()) {
                            throw new LPI_Exception('Business user already exists with this LPI Registration Number or Federal Employer ID Number EIN!');
                        }
                    }
                }

				 
				Account businessAcc = accountFieldsMapping(wr);
				List<Datacloud.MatchRecord> existingAccount = new List<Datacloud.MatchRecord>();
				existingAccount = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{businessAcc});
				if (!existingAccount.isEmpty()) {

					Set<String> emailSet = new Set<String>();
					Set<Id> accountIdSet = new Set<Id>();
					Id accountId;
					for(Datacloud.MatchRecord data : existingAccount){
						accountIdSet.add(data.getRecord().Id);
						if(accountId == null){
							accountId = data.getRecord().Id;
						}
					}

					String fieldToQueryForAccount = 'Id, Buisness_Email__c';
					String whereClauseForAccount = ' Id IN ' + LPI_ServiceUtility.getStringValuesBySet(accountIdSet);
					
					List<Account> accDuplicateList = accDAOWithoutSharing.getAccountByDymanicQuery(fieldToQueryForAccount,whereClauseForAccount,null,null,null);

					for( Account acc : accDuplicateList ){
						emailSet.add(acc.Buisness_Email__c);
					}

					businessAcc.Id = accountId;
					List<User> listUser = LPI_WithoutSharingUtility.getUserByEmail(emailSet);

					if (!listUser.isEmpty()) {
						throw new LPI_Exception('Business user already exists with this name and address!');
					}
				}

				 
				createOTP(wr);
			}
			return responseWrap;
		} catch (DmlException de) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(CLASS_NAME, DO_FINISH_REGISTRATION, de);
			throw new LPI_Exception(de.getDmlMessage(0));
		} catch (Exception e) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(CLASS_NAME, DO_FINISH_REGISTRATION, e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @description                 : Account fields assignment
	 * @param wrapperData           : data we are passing from portal like firstname ,lastname ,etc
	 * @return                      : `Account`
	 */

	public static Account accountFieldsMapping(RegistrationFormWrapperForBusiness wr)
	{
		Savepoint sp = Database.setSavepoint();
		try{
			Id businessAccountRecordTypeId = LPI_UtilityDescribe.getRecordTypeIdWithName(
				'Account',
				LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE
				);
			Account businessAcc = new Account();

			String fieldToQueryAcc = 'Id, Buisness_Email__c';
			String whereClauseAcc = 'MO_State_Registration_Number__c = \'' + wr.moStateRegistrationNumber + '\''+
			' AND Buisness_Email__c != NULL';
			LPI_AccountDAO.LPI_AccountWithoutSharingDAO accDAOWithoutSharingBusiness = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
			List<Account> accListBusiness = accDAOWithoutSharingBusiness.getAccountByDymanicQuery(fieldToQueryAcc,whereClauseAcc,null,null,null);
			
			if(!accListBusiness.isEmpty()){
				businessAcc.Id = accListBusiness[0].Id;
			}

			businessAcc.MO_State_Registration_Number__c = wr.moStateRegistrationNumber;
			businessAcc.Federal_Employer_ID_Number_EIN__c = wr.newEmployerIdentificationNum == EIN_ZERO_NUM ? null : wr.newEmployerIdentificationNum;
			businessAcc.Name = LPI_VlocityUtility.updateStringToCamelCase(wr.businessName);
			businessAcc.Buisness_Email__c = wr.businessEmail;
			businessAcc.RecordTypeId = businessAccountRecordTypeId;
			businessAcc.Fictitious_Name__c = wr.businessFictitiousName;
			businessAcc.Phone = wr.businessPhone;
			businessAcc.BillingStreet = wr.businessAddress.street1;
			businessAcc.BillingCountryCode = wr.businessAddress.country;
			
			businessAcc.BillingCity= wr.businessAddress.city;
			businessAcc.BillingPostalCode= wr.businessAddress.zipcode;
			businessAcc.County__c = wr.businessAddress.county;
			businessAcc.Security_Question__c = wr.securityQuestionAnswer;
			businessAcc.Business_Identification_Number__c = wr.businessIdentificationNumber;
			if (wr.businessAddress.state != null) {
				businessAcc.BillingStateCode = wr.businessAddress.state;
			}

			if (wr.businessAddress.stateText != null) {
				businessAcc.Other_State__c = wr.businessAddress.stateText;
			}
			return businessAcc;
		} catch (DmlException de) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(CLASS_NAME, 'accountFieldsMapping', de);
			throw new LPI_Exception(de.getDmlMessage(0));
		} catch (Exception e) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(CLASS_NAME, 'accountFieldsMapping', e);
			throw new LPI_Exception(e.getMessage());
		}
	}
	/**
	 * @author              : MTX Group Product Team
	 * @param wrapperJSON   : passing Data and Otp
	 * @description         : Validating and Inserting user
	 * @exception           : error we will get if any issue occur will inserting account
	 */
	@AuraEnabled
	public static ResponseWrapper validateUserAndCreateUserForBusiness(
		String otpValue,
		String wrapperJSON,
		String recaptchaResponse,
		String ctype
	) {
		String errorMessage = '';
		try {
			ResponseWrapper responseWrap = new ResponseWrapper();
			 
			RegistrationFormWrapperForBusiness wrapper = (RegistrationFormWrapperForBusiness) JSON.deserializeStrict(
				wrapperJSON, RegistrationFormWrapperForBusiness.class
			);
			CaptchaWrapper inputWrapperObject;

			 
			inputWrapperObject = new CaptchaWrapper();
			inputWrapperObject.cflag = isRecaptchaDisabled();
			inputWrapperObject.ctype = ctype;
			String captchaWrapper = JSON.serialize(inputWrapperObject);
			inputWrapperObject = (CaptchaWrapper) JSON.deserializeStrict(captchaWrapper, CaptchaWrapper.class);

			 
			if (inputWrapperObject.cflag != true) {
				Boolean captchaValid = false;
				 
				if (String.isNotBlank(recaptchaResponse)) {
					if (inputWrapperObject.ctype == 'v3') {
						RecaptchaResponseWrapper captchaWrpMap = (RecaptchaResponseWrapper) JSON.deserializeStrict(
							recaptchaResponse,
							RecaptchaResponseWrapper.class
						);
						if (captchaWrpMap.action == 'Submit') {
							Map<String, Object> txnMap = new Map<String, Object>();
							txnMap = LPI_VerifyCaptcha.makeRequest(
								captchaWrpMap.response,
								captchaWrpMap.action,
								false
							);

							captchaValid = (Boolean) txnMap.get('valid');
						}
						if (!captchaValid) {
							responseWrap.isV3Failed = true;
						}
					} 
					 
				}
				if (Test.isRunningTest()) {
					captchaValid = true;
				}
				if (!captchaValid) {
					responseWrap.isCaptchaInvalid = true;
					responseWrap.isV3Failed = true;
					return responseWrap;
				}
			}
			if (wrapper.businessEmail != null && wrapper.businessEmail != '') {
				List<Otp__c> otpList = LPI_WithoutSharingUtility.getOtpRecordByEmail(wrapper.businessEmail);

				if (!otpList.isEmpty()) {
					Otp__c otp = otpList[0];
					 
					if (System.now() <= otp.CreatedDate.addMinutes(Integer.valueof(Label.OTPValidTime))) {
						if (otp.OTP_Value__c == otpValue) {
							 
							responseWrap.isSuccess = createBusinessAccount(wrapper);
							if(!responseWrap.isSuccess){
								responseWrap.message = 'There is an error in the registration process. Please contact the LPI team for further information.';
							}
							return responseWrap;
						} else {
							responseWrap.isSuccess = false;
						}
					} else {
						errorMessage = 'The OTP has expired, Try resending a new OTP!';
						throw new LPI_Exception(errorMessage);
					}
				}
			}
			responseWrap.isSuccess = false;
			return responseWrap;
		} catch (Exception e) {
			if (errorMessage == '') {
				LPI_ExceptionManager.logException(CLASS_NAME, 'validateUserAndCreateUser', e);
				throw new LPI_Exception(e.getMessage());
			} else {
				throw new LPI_Exception(errorMessage);
			}
		}
	}

	/**
	 * @author              : MTX Group Product Team
	 * @param wrapperJSON   : passing Data in from of wrapper from Javascript to Create Person account
	 * @description         : Inserting user
	 * @exception           : error we will get if any issue occur will inserting account
	 */
	public static Boolean createBusinessAccount(LPI_RegisterController.RegistrationFormWrapperForBusiness wr) {
		String errorMessage = '';
		Savepoint sp = Database.setSavepoint();

		try {
			List<Business_Relationships__c> insertUpdateRelationshipList = new List<Business_Relationships__c>();

			Id businessAccountRecordTypeId = LPI_UtilityDescribe.getRecordTypeIdWithName(
				'Account',
				LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE
			);

			Id personAccountRecordTypeId = LPI_UtilityDescribe.getRecordTypeIdWithName(
				'Account',
				LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE
			);
			Account businessAcc = accountFieldsMapping(wr);
			List<Datacloud.MatchRecord> existingAccount = new List<Datacloud.MatchRecord>();
			existingAccount = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{businessAcc});
			if (!existingAccount.isEmpty()) {
				businessAcc.Id = existingAccount[0].getRecord().Id;
			}
			LPI_WithoutSharingUtility.upsertSObject(businessAcc);

			Account businessPersonAcc = new Account();
			businessPersonAcc.LastName =  LPI_VlocityUtility.updateStringToCamelCase(wr.businessName);
			businessPersonAcc.PersonEmail =  LPI_VlocityUtility.updateStringToCamelCase(wr.businessEmail);
			businessPersonAcc.Buisness_Email__c	 =  LPI_VlocityUtility.updateStringToCamelCase(wr.businessEmail);
			businessPersonAcc.OwnerId = Label.UserOwnerId;
			businessPersonAcc.RecordTypeId = personAccountRecordTypeId;
			businessPersonAcc.Person_Account_For_Business__c = true;
			LPI_WithoutSharingUtility.insertSObject(businessPersonAcc);

			Business_Relationships__c brRecord = new Business_Relationships__c();
			brRecord.Roles__c = 'Person Account For Business';
			brRecord.Related_From__c = businessAcc.Id;
			brRecord.Related_To__c = businessPersonAcc.Id;
			brRecord.Start_Date__c = Date.today();
			brRecord.IsActive__c = true;
			insertUpdateRelationshipList.add(brRecord);

			Map<Integer, Account> accountIndexingMapForAuthContact = new Map<Integer, Account>();
			Map<Integer, ContactDeatils> initialWrapperMapForAuthContact = new Map<Integer, ContactDeatils>();
			Integer countAuth = 0;
			for(ContactDeatils con : wr.authContactList){
				Account personAcc = new Account();
				
				personAcc.RecordTypeId = personAccountRecordTypeId;
				personAcc.FirstName = LPI_VlocityUtility.updateStringToCamelCase(con.firstname);
				personAcc.middleName = LPI_VlocityUtility.updateStringToCamelCase(con.middleName);
				personAcc.LastName = LPI_VlocityUtility.updateStringToCamelCase(con.lastName);
				personAcc.Phone = con.phone;
				
				personAcc.PersonEmail = con.email;

				 
				List<Account> existingAuthorizedAccount = LPI_ServiceUtility.getDuplicateRecordsByEmail(new List<Account>{personAcc});
				 
				if (!existingAuthorizedAccount.isEmpty()) {
					 
					personAcc.Id = existingAuthorizedAccount[0].Id;
				}

				accountIndexingMapForAuthContact.put(countAuth, personAcc);
				initialWrapperMapForAuthContact.put(countAuth, con);
				countAuth = countAuth + 1;
			}
			LPI_WithoutSharingUtility.upsertSObjectList(accountIndexingMapForAuthContact.values());
			for(Integer var : accountIndexingMapForAuthContact.keySet()){
				Business_Relationships__c brRecordTemp = new Business_Relationships__c();
				brRecordTemp.Roles__c = 'Authorized Contact';
				if(businessAcc.ParentId != NULL){
					brRecordTemp.Related_From__c = businessAcc.ParentId;
				}else{
					brRecordTemp.Related_From__c = businessAcc.Id;
				}
				brRecordTemp.Related_To__c = accountIndexingMapForAuthContact.get(var).Id;
				brRecordTemp.Start_Date__c = Date.today();
				brRecordTemp.IsActive__c = true;
				insertUpdateRelationshipList.add(brRecordTemp);
			}

			 

			Map<Integer, Account> accountIndexingMap = new Map<Integer, Account>();
			Map<Integer, ContactDeatils> initialWrapperMap = new Map<Integer, ContactDeatils>();
			Integer count = 0;
			for(ContactDeatils con : wr.coorporateOfficerList){
				Account personAcc = new Account();
				
				personAcc.RecordTypeId = personAccountRecordTypeId;
				personAcc.FirstName = LPI_VlocityUtility.updateStringToCamelCase(con.firstname);
				personAcc.middleName = LPI_VlocityUtility.updateStringToCamelCase(con.middleName);
				personAcc.LastName = LPI_VlocityUtility.updateStringToCamelCase(con.lastName);
				personAcc.PersonMailingStreet = con.addressData.street1;
				personAcc.PersonMailingPostalCode = con.addressData.zipcode;
				personAcc.PersonMailingCity = con.addressData.city;
				
				if (con.addressData.state != null) {
					personAcc.PersonMailingStateCode = con.addressData.state;
				}

				if (con.addressData.stateText != null) {
					personAcc.Other_State__c = con.addressData.stateText;
				}

				personAcc.PersonMailingCountryCode = con.addressData.country;
				personAcc.County__c = con.addressData.county;
				if(con.birthdate != NULL && con.birthdate != ''){
					personAcc.Date_of_Birth__c = Date.valueOf(con.birthdate);
				}
				personAcc.Is_Corporate_Officer__c = true;
				accountIndexingMap.put(count, personAcc);
				initialWrapperMap.put(count, con);
				count = count + 1;
			}

			LPI_WithoutSharingUtility.upsertSObjectList(accountIndexingMap.values());
			for(Integer var : accountIndexingMap.keySet()){
				Business_Relationships__c brRecordTemp = new Business_Relationships__c();
				brRecordTemp.Roles__c = initialWrapperMap.get(var).role;
				if(businessAcc.ParentId != NULL){
					brRecordTemp.Related_From__c = businessAcc.ParentId;
				}else{
					brRecordTemp.Related_From__c = businessAcc.Id;
				}
				brRecordTemp.Related_To__c = accountIndexingMap.get(var).Id;
				brRecordTemp.Start_Date__c = Date.today();
				brRecordTemp.IsActive__c = true;
				insertUpdateRelationshipList.add(brRecordTemp);
			}

			LPI_WithoutSharingUtility.insertSObjectList(insertUpdateRelationshipList);
			LPI_InsertUser.insertUser(LPI_WithoutSharingUtility.getAccount(businessPersonAcc.Id).PersonContactId);
			if (errorMessage == '') {
				return true;
			}else{
				return false;
			}
		} catch (Exception e) {
			Database.rollback(sp);
			LPI_ExceptionManager.logException(LPI_RegisterController.CLASS_NAME, LPI_RegisterController.CREATE_USER, e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author               : MTX Group Product Team
	 * @description          : This Method will create unique otp every time user start registration
	 * @param businessDetails: Name, email required fields
	 * @return               : `String` OTP Value
	 */
	@TestVisible
	private static String createOTP(RegistrationFormWrapperForBusiness businessDetails) {
		OTP__c otp;
		try {
			 
			List<OTP__c> markOldOTPInvalid = LPI_WithoutSharingUtility.getOtpRecordByEmail(businessDetails.businessEmail);

		 
			otp = new OTP__c();
			otp.First_Name__c = businessDetails.businessName;
			otp.Email__c = businessDetails.businessEmail;
			otp.Type__c = 'Add Business';
			otp.OTP_Value__c = (string.valueof(Math.abs(Crypto.getRandomLong()))).Substring(0, 6);
			otp.OTP_Sent_Count__c = 1;
			LPI_WithoutSharingUtility.insertSObject(otp);

			 
			for (OTP__c otpRecord : markOldOTPInvalid) {
				otpRecord.Is_Expired__c = true;
			}
			if (!markOldOTPInvalid.isEmpty()) {
				LPI_WithoutSharingUtility.upsertSObjectList(markOldOTPInvalid);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, CREATE_OTP, e);
			throw new LPI_Exception('Problem in OTP', e);
		}
		return otp.OTP_Value__c;
	}

	public static Boolean isRecaptchaDisabled() {
		LPI_Recaptcha_Configuration__mdt recapConfig = LPI_Recaptcha_Configuration__mdt.getInstance('Recaptcha');
		return recapConfig.isDisabled__c;
	}
	

	/**
	 * @author      : MTX Group Product Team
	 * @since 		: Feb 20 2024
	 * @description : This method is used to fetch city and county on the basis of zipcode value
	 * @return		: Wrapper of DataWrapper
	 */
	@AuraEnabled
	public static DataWrapper getDataToPrepopulateBasedOnZipCode(String zipcode) {
        DataWrapper dataWrap = new DataWrapper();
		try {
			String orginalZipCode;
			if(String.isNotBlank(zipCode))
			{
				orginalZipCode = zipCode.deleteWhitespace();
			}
			if(String.isNotBlank(orginalZipCode) && orginalZipCode.length() >= 5){
				List<County_ZipCode_Inspector_Mapping__c> countyZiplist = new LPI_CountyZipCodeInspectorMappingDao.LPI_CountyZipCodeInspectorMappingWithoutSharingDao().getCountyZipCodeInspectorByDynamicQuery(
				'City__c ,County__c, ZipCode__c', 'ZipCode__c = \''+String.escapeSingleQuotes(orginalZipCode)+'\''+' And RecordType.Name = \''+ZIP_CITY_COUNTY_PRE_POPULATION+'\'', null, null, null); 
				if(!countyZiplist.isEmpty()){
					dataWrap.city = countyZiplist[0].City__c;
					dataWrap.county = countyZiplist[0].County__c;
				}	
			}
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getDataToPrepopulate', ex);
        }
		return dataWrap;
	}

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class ZipCountyCity LWC
	 */
	public class DataWrapper {		
		@AuraEnabled public string city;
		@AuraEnabled public string county;

		public DataWrapper(){
			city = '';
			county = '';
		}
	}

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of registration page
	 */
	public class RegistrationFormWrapper {
		@AuraEnabled public String firstName;
		@AuraEnabled public String middleName;
		@AuraEnabled public String lastName;
		@AuraEnabled public String email;
		@AuraEnabled public String birthdate;
		@AuraEnabled public String addressInUSOrInternational;
		@AuraEnabled public String phone;
		@AuraEnabled public String ssn;
		@AuraEnabled public String newssn;
		@AuraEnabled public String street1;
		@AuraEnabled public String city;
		@AuraEnabled public String state;
		@AuraEnabled public String stateText;
		@AuraEnabled public String county;
		@AuraEnabled public String zipcode;
		@AuraEnabled public String country;
		@AuraEnabled public String identityType;
		@AuraEnabled public String identityNumber;
		@AuraEnabled public String language;
		@AuraEnabled public String siteBaseUrl;
		@AuraEnabled public string profileUrl;
		@AuraEnabled public string securityQuestionAnswer;
		@AuraEnabled public string oldEmail;
		@AuraEnabled public string oldPhone;
		@AuraEnabled public string accId;
		@AuraEnabled public Id perConId;
		@AuraEnabled public String securityCode;
		@AuraEnabled public boolean isAccFoundAndEmailSent;
		@AuraEnabled public boolean isUserHavingSSN;
		 
		public RegistrationFormWrapper() {
			firstName = '';
			lastName = '';
			middleName = '';
			email = '';
			birthdate = '';
			addressInUSOrInternational = '';
			phone = '';
			ssn = '';
			newssn = '';
			street1 = '';
			city = '';
			state = '';
			stateText = '';
			county = '';
			zipcode = '';
			country = '';
			identityType = '';
			identityNumber = '';
			language = 'en_US';
			siteBaseUrl = Site.getBaseURL();
			oldEmail = '';
			oldPhone = '';
		}
	}

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of contact 
	 */
	public class ContactDeatils{
		@AuraEnabled public String firstName;
		@AuraEnabled public String middleName;
		@AuraEnabled public String lastName;
		@AuraEnabled public String email;
		@AuraEnabled public String phone;
		@AuraEnabled public String role;
		@AuraEnabled public String ssn;
		@AuraEnabled public String newssn;
		@AuraEnabled public String birthdate;
		@AuraEnabled public String index;
		@AuraEnabled public AddressDetails addressData;
		@AuraEnabled public String editButtonAriaLabel;
		@AuraEnabled public String deleteButtonAriaLabel;
		
		public ContactDeatils(){
			firstName = '';
			lastName = '';
			middleName = '';
			email = '';
			phone = '';
			role = '';
			ssn = '';
			newssn = '';
			birthdate = '';
			index = '';
			editButtonAriaLabel = '';
			deleteButtonAriaLabel = '';
			addressData = new AddressDetails();
		}
	}

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of Address 
	 */
	public class AddressDetails{
		@AuraEnabled public String street1;
		@AuraEnabled public String city;
		@AuraEnabled public String state;
		@AuraEnabled public String stateText;
		@AuraEnabled public String zipcode;
		@AuraEnabled public String country;
		@AuraEnabled public String county;
		@AuraEnabled public String type;

		public AddressDetails(){
			street1 = '';
			city = '';
			state = '';
			stateText = '';
			zipcode = '';
			country = '';
			type = '';
			county = '';
		}
	}

	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of registration page
	 */
	public class RegistrationFormWrapperForBusiness {
		@AuraEnabled public String businessName;
		@AuraEnabled public String moStateRegistrationNumber;
		@AuraEnabled public String businessEmail;
		@AuraEnabled public String businessFictitiousName;
		@AuraEnabled public String businessPhone;
		@AuraEnabled public String employerIdentificationNum;
		@AuraEnabled public String newEmployerIdentificationNum;

		@AuraEnabled public AddressDetails businessAddress;

		@AuraEnabled public ContactDeatils authorizedContactDetails;
		@AuraEnabled public List<ContactDeatils> authContactList;
		@AuraEnabled public List<ContactDeatils> coorporateOfficerList;
		@AuraEnabled public String language;
		@AuraEnabled public String siteBaseUrl;
		@AuraEnabled public String securityQuestionAnswer;
		@AuraEnabled public String businessIdentificationNumber;
		@AuraEnabled public String businessOutsideUS;
	 
		public RegistrationFormWrapperForBusiness() {
			this.businessName = '';
			this.moStateRegistrationNumber = '';
			this.businessEmail = '';
			this.businessFictitiousName = '';
			this.businessPhone = '';
			this.employerIdentificationNum = '';
			this.newEmployerIdentificationNum = '';
			this.businessAddress = new AddressDetails();

			this.authorizedContactDetails = new ContactDeatils();
			this.authContactList = new List<ContactDeatils>();
			this.coorporateOfficerList = new List<ContactDeatils>();

			this.language = 'en_US';
			this.siteBaseUrl = Site.getBaseURL();
		}
	}

	public class CaptchaWrapper {
		@AuraEnabled public Boolean cflag;
		@AuraEnabled public String ctype;
		@AuraEnabled public String tid;
	}

	public class ResponseWrapper {
		@AuraEnabled public Boolean isCaptchaInvalid { get; set; }
		@AuraEnabled public Boolean isV3Failed { get; set; }
		@AuraEnabled public Boolean isSuccess { get; set; }
		@AuraEnabled public String message { get; set; }
		public ResponseWrapper(){
			isCaptchaInvalid = false;
			isV3Failed = false;
			isSuccess = true;
			message = '';
		}
	}

	public class RecaptchaResponseWrapper {
		@AuraEnabled public String action;
		@AuraEnabled public String response;
	}
	
}