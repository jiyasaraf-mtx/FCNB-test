/**
 * Employer Portal – Annual Financial Filings CRUD and Salesforce Files helpers.
 */
public without sharing class EMP_FinancialFilingCtrl {
	private static final String DEFAULT_LICENCE_TYPE = 'Insurance Company';
	private static final String DEFAULT_FILING_TYPE = 'Annual Financial Filing';

	private static final String STATUS_DRAFT = 'Draft';
	private static final String STATUS_SUBMITTED = 'Submitted';
	private static final String STATUS_ACCEPTED = 'Accepted';
	private static final String STATUS_REJECTED = 'Rejected';
	private static final String STATUS_REQUEST_MISSING = 'Request Missing Schedule';
	private static final String STATUS_MISSING_SUBMITTED = 'Missing Schedule Submitted';

	@AuraEnabled
	public static List<LicenseOption> searchBusinessLicenses(String searchTerm) {
		List<LicenseOption> options = new List<LicenseOption>();
		String term = searchTerm == null ? '' : searchTerm.trim();
		String likeTerm = '%' + term + '%';

		List<BusinessLicense> licenses;
		if (String.isBlank(term)) {
			licenses = [
				SELECT Id, Name, Status, Account.Name
				FROM BusinessLicense
				ORDER BY Name
				LIMIT 50
			];
		} else {
			licenses = [
				SELECT Id, Name, Status, Account.Name
				FROM BusinessLicense
				WHERE Name LIKE :likeTerm
				ORDER BY Name
				LIMIT 50
			];
		}

		for (BusinessLicense bl : licenses) {
			LicenseOption opt = new LicenseOption();
			opt.id = bl.Id;
			opt.name = bl.Name;
			opt.status = bl.Status;
			opt.accountName = bl.Account != null ? bl.Account.Name : null;
			opt.label = String.isNotBlank(opt.accountName)
				? bl.Name + ' · ' + opt.accountName
				: bl.Name;
			options.add(opt);
		}
		return options;
	}

	@AuraEnabled
	public static FilingPageResult getFilings() {
		FilingPageResult result = new FilingPageResult();
		Id accountId = resolveAccountId();
		result.accountId = accountId;
		result.accountName = resolveAccountName(accountId);
		result.parentLicence = '';
		result.licenceType = DEFAULT_LICENCE_TYPE;
		result.filingType = DEFAULT_FILING_TYPE;

		List<Financial_Filing__c> rows = [
			SELECT
				Id,
				Name,
				Status__c,
				Filing_Type__c,
				Reporting_Year__c,
				Period_Start__c,
				Period_End__c,
				Due_Date__c,
				Parent_Licence__c,
				Business_License__c,
				Licence_Type__c,
				Filer_First_Name__c,
				Filer_Last_Name__c,
				Filer_Email__c,
				Filer_Phone__c,
				Total_Assets__c,
				Total_Liabilities__c,
				NB_Written_Premiums__c,
				Other_NB_Amounts__c,
				Attestation__c,
				Description__c,
				Account__c
			FROM Financial_Filing__c
			WHERE Account__c = :accountId OR Account__c = NULL
			ORDER BY Reporting_Year__c DESC NULLS LAST, CreatedDate DESC
			LIMIT 200
		];

		Map<Id, FileInfo> fileByFiling = getPrimaryFiles(new Map<Id, Financial_Filing__c>(rows).keySet());

		for (Financial_Filing__c row : rows) {
			FilingDTO dto = toDto(row);
			if (fileByFiling.containsKey(row.Id)) {
				FileInfo fi = fileByFiling.get(row.Id);
				dto.documentName = fi.title;
				dto.contentDocumentId = fi.contentDocumentId;
				dto.contentVersionId = fi.contentVersionId;
			}
			result.filings.add(dto);
			if (row.Status__c == STATUS_DRAFT) {
				result.countDraft++;
			} else if (row.Status__c == STATUS_SUBMITTED) {
				result.countSubmitted++;
			} else if (row.Status__c == STATUS_MISSING_SUBMITTED) {
				result.countMissingScheduleSubmitted++;
			} else if (row.Status__c == STATUS_ACCEPTED) {
				result.countAccepted++;
			} else if (row.Status__c == STATUS_REJECTED) {
				result.countRejected++;
			} else if (row.Status__c == STATUS_REQUEST_MISSING) {
				result.countRequestMissingSchedule++;
			}
		}

		if (!result.filings.isEmpty()) {
			result.currentFiling = result.filings[0];
			for (FilingDTO f : result.filings) {
				if (f.status == 'Draft') {
					result.currentFiling = f;
					break;
				}
			}
			if (result.currentFiling != null && String.isNotBlank(result.currentFiling.parentLicence)) {
				result.parentLicence = result.currentFiling.parentLicence;
			}
		}
		return result;
	}

	@AuraEnabled
	public static FilingDTO createFiling(
		String reportingYear,
		Date periodStart,
		Date periodEnd,
		String parentLicence,
		Id businessLicenseId
	) {
		Id accountId = resolveAccountId();
		User u = [
			SELECT Id, FirstName, LastName, Email, Phone, Contact.AccountId
			FROM User
			WHERE Id = :UserInfo.getUserId()
			LIMIT 1
		];

		Integer yearInt = 2025;
		try {
			yearInt = Integer.valueOf(reportingYear);
		} catch (Exception e) {
			yearInt = Date.today().year();
		}

		String licenceName = parentLicence;
		Id licenseId = businessLicenseId;
		if (licenseId != null) {
			BusinessLicense bl = [SELECT Id, Name FROM BusinessLicense WHERE Id = :licenseId LIMIT 1];
			licenceName = bl.Name;
			licenseId = bl.Id;
		} else if (String.isNotBlank(licenceName)) {
			List<BusinessLicense> matches = [
				SELECT Id, Name
				FROM BusinessLicense
				WHERE Name = :licenceName
				LIMIT 1
			];
			if (!matches.isEmpty()) {
				licenseId = matches[0].Id;
				licenceName = matches[0].Name;
			}
		}

		if (String.isBlank(licenceName)) {
			throw new AuraHandledException('Please select a Parent Licence.');
		}

		Financial_Filing__c filing = new Financial_Filing__c(
			Account__c = accountId,
			Status__c = 'Draft',
			Filing_Type__c = DEFAULT_FILING_TYPE,
			Reporting_Year__c = String.valueOf(yearInt),
			Period_Start__c = periodStart != null ? periodStart : Date.newInstance(yearInt, 1, 1),
			Period_End__c = periodEnd != null ? periodEnd : Date.newInstance(yearInt, 12, 31),
			Due_Date__c = Date.newInstance(yearInt + 1, 3, 31),
			Parent_Licence__c = licenceName,
			Business_License__c = licenseId,
			Licence_Type__c = DEFAULT_LICENCE_TYPE,
			Filer_First_Name__c = u.FirstName,
			Filer_Last_Name__c = u.LastName,
			Filer_Email__c = u.Email,
			Filer_Phone__c = u.Phone,
			Attestation__c = 'Not Complete',
			Description__c = 'Draft annual filing.'
		);
		insert filing;

		Financial_Filing__c created = [
			SELECT
				Id,
				Name,
				Status__c,
				Filing_Type__c,
				Reporting_Year__c,
				Period_Start__c,
				Period_End__c,
				Due_Date__c,
				Parent_Licence__c,
				Business_License__c,
				Licence_Type__c,
				Filer_First_Name__c,
				Filer_Last_Name__c,
				Filer_Email__c,
				Filer_Phone__c,
				Total_Assets__c,
				Total_Liabilities__c,
				NB_Written_Premiums__c,
				Other_NB_Amounts__c,
				Attestation__c,
				Description__c,
				Account__c
			FROM Financial_Filing__c
			WHERE Id = :filing.Id
			LIMIT 1
		];
		return toDto(created);
	}

	@AuraEnabled
	public static FilingDTO saveFiling(String payloadJson) {
		Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(payloadJson);
		Id filingId = (Id) String.valueOf(payload.get('id'));
		Financial_Filing__c filing = [
			SELECT Id, Status__c
			FROM Financial_Filing__c
			WHERE Id = :filingId
			LIMIT 1
		];
		String previousStatus = filing.Status__c;
		if (previousStatus != null
			&& previousStatus != STATUS_DRAFT
			&& previousStatus != STATUS_REQUEST_MISSING) {
			throw new AuraHandledException('Only Draft or Request Missing Schedule filings can be edited.');
		}

		String language = payload.containsKey('language')
			? String.valueOf(payload.get('language'))
			: null;

		if (payload.containsKey('reportingYear')) {
			filing.Reporting_Year__c = String.valueOf(payload.get('reportingYear'));
		}
		if (payload.containsKey('periodStart') && payload.get('periodStart') != null) {
			filing.Period_Start__c = Date.valueOf(String.valueOf(payload.get('periodStart')));
		}
		if (payload.containsKey('periodEnd') && payload.get('periodEnd') != null) {
			filing.Period_End__c = Date.valueOf(String.valueOf(payload.get('periodEnd')));
		}
		if (payload.containsKey('dueDate') && payload.get('dueDate') != null) {
			filing.Due_Date__c = Date.valueOf(String.valueOf(payload.get('dueDate')));
		}
		if (payload.containsKey('filerFirstName')) {
			filing.Filer_First_Name__c = String.valueOf(payload.get('filerFirstName'));
		}
		if (payload.containsKey('filerLastName')) {
			filing.Filer_Last_Name__c = String.valueOf(payload.get('filerLastName'));
		}
		if (payload.containsKey('filerEmail')) {
			filing.Filer_Email__c = String.valueOf(payload.get('filerEmail'));
		}
		if (payload.containsKey('filerPhone')) {
			filing.Filer_Phone__c = String.valueOf(payload.get('filerPhone'));
		}
		if (payload.containsKey('parentLicence')) {
			filing.Parent_Licence__c = String.valueOf(payload.get('parentLicence'));
		}
		if (payload.containsKey('businessLicenseId')) {
			Object blVal = payload.get('businessLicenseId');
			if (blVal == null || String.isBlank(String.valueOf(blVal))) {
				filing.Business_License__c = null;
			} else {
				Id blId = (Id) String.valueOf(blVal);
				filing.Business_License__c = blId;
				BusinessLicense bl = [SELECT Name FROM BusinessLicense WHERE Id = :blId LIMIT 1];
				filing.Parent_Licence__c = bl.Name;
			}
		}
		if (payload.containsKey('totalAssets') && payload.get('totalAssets') != null) {
			filing.Total_Assets__c = Decimal.valueOf(String.valueOf(payload.get('totalAssets')));
		}
		if (payload.containsKey('totalLiabilities') && payload.get('totalLiabilities') != null) {
			filing.Total_Liabilities__c = Decimal.valueOf(String.valueOf(payload.get('totalLiabilities')));
		}
		if (payload.containsKey('nbWrittenPremiums') && payload.get('nbWrittenPremiums') != null) {
			filing.NB_Written_Premiums__c = Decimal.valueOf(String.valueOf(payload.get('nbWrittenPremiums')));
		}
		if (payload.containsKey('attestation')) {
			filing.Attestation__c = String.valueOf(payload.get('attestation'));
		}
		if (payload.containsKey('description')) {
			filing.Description__c = String.valueOf(payload.get('description'));
		}
		if (payload.containsKey('status')) {
			String requestedStatus = String.valueOf(payload.get('status'));
			filing.Status__c = resolveTargetStatus(previousStatus, requestedStatus);
		}
		update filing;

		Financial_Filing__c refreshed = [
			SELECT
				Id,
				Name,
				Status__c,
				Filing_Type__c,
				Reporting_Year__c,
				Period_Start__c,
				Period_End__c,
				Due_Date__c,
				Parent_Licence__c,
				Business_License__c,
				Licence_Type__c,
				Filer_First_Name__c,
				Filer_Last_Name__c,
				Filer_Email__c,
				Filer_Phone__c,
				Total_Assets__c,
				Total_Liabilities__c,
				NB_Written_Premiums__c,
				Other_NB_Amounts__c,
				Attestation__c,
				Description__c,
				Account__c
			FROM Financial_Filing__c
			WHERE Id = :filing.Id
			LIMIT 1
		];
		if (previousStatus == STATUS_DRAFT && refreshed.Status__c == STATUS_SUBMITTED) {
			sendSubmissionConfirmationEmail(refreshed, language);
		}

		FilingDTO dto = toDto(refreshed);
		Map<Id, FileInfo> files = getPrimaryFiles(new Set<Id>{ refreshed.Id });
		if (files.containsKey(refreshed.Id)) {
			FileInfo fi = files.get(refreshed.Id);
			dto.documentName = fi.title;
			dto.contentDocumentId = fi.contentDocumentId;
			dto.contentVersionId = fi.contentVersionId;
		}
		return dto;
	}

	/**
	 * @description Determines the allowed target status given the previous status and the
	 *              status requested by the portal. Prevents unexpected status transitions.
	 */
	private static String resolveTargetStatus(String previousStatus, String requestedStatus) {
		if (String.isBlank(requestedStatus)) {
			return previousStatus;
		}
		if (previousStatus == STATUS_DRAFT) {
			if (requestedStatus == STATUS_DRAFT || requestedStatus == STATUS_SUBMITTED) {
				return requestedStatus;
			}
			return STATUS_DRAFT;
		}
		if (previousStatus == STATUS_REQUEST_MISSING) {
			if (requestedStatus == STATUS_MISSING_SUBMITTED || requestedStatus == STATUS_REQUEST_MISSING) {
				return requestedStatus;
			}
			// Saving edits from a Request Missing Schedule filing keeps it actionable.
			return STATUS_REQUEST_MISSING;
		}
		return previousStatus;
	}

	/**
	 * @description Sends a plain-text/HTML confirmation email to the logged-in user when an
	 *              Annual Financial Filing transitions from Draft to Submitted.
	 *              Uses an Org-Wide Email Address so Experience Cloud / portal users can send.
	 */
	private static void sendSubmissionConfirmationEmail(Financial_Filing__c filing, String language) {
		try {
			String lang = (String.isNotBlank(language) && language.startsWith('fr')) ? 'fr' : 'en_US';

			String subjectTemplate = System.Label.get('', 'EP_FF_Email_Subject', lang);
			String greetingTemplate = System.Label.get('', 'EP_FF_Email_Greeting', lang);
			String receivedTemplate = System.Label.get('', 'EP_FF_Email_Received', lang);
			String filingNumberTemplate = System.Label.get('', 'EP_FF_Email_Filing_Number', lang);
			String filingStatusTemplate = System.Label.get('', 'EP_FF_Email_Filing_Status', lang);
			String bodyReview = System.Label.get('', 'EP_FF_Email_Body_Review', lang);
			String thankYou = System.Label.get('', 'EP_FF_Email_Thank_You', lang);
			String signature = System.Label.get('', 'EP_FF_Email_Signature', lang);
			String statusDisplay = System.Label.get('', 'EP_Under_Review', lang);

			Set<String> toAddresses = new Set<String>();
			String loggedInEmail = UserInfo.getUserEmail();
			if (String.isNotBlank(loggedInEmail)) {
				toAddresses.add(loggedInEmail.trim());
			}
			if (String.isNotBlank(filing.Filer_Email__c)) {
				toAddresses.add(filing.Filer_Email__c.trim());
			}
			if (toAddresses.isEmpty()) {
				return;
			}

			String firstName = String.isNotBlank(filing.Filer_First_Name__c)
				? filing.Filer_First_Name__c
				: UserInfo.getFirstName();
			if (String.isBlank(firstName)) {
				firstName = UserInfo.getName();
			}

			String employerName = resolveAccountName(filing.Account__c);
			String filingNumber = filing.Name;
			String reportingYear = filing.Reporting_Year__c;

			String subject = subjectTemplate.replace('{0}', filingNumber == null ? '' : filingNumber);
			String greeting = greetingTemplate.replace('{0}', firstName == null ? '' : firstName);
			String received = receivedTemplate
				.replace('{0}', employerName == null ? '' : employerName)
				.replace('{1}', reportingYear == null ? '' : reportingYear);
			String filingNumberLine = filingNumberTemplate.replace('{0}', filingNumber == null ? '' : filingNumber);
			String filingStatusLine = filingStatusTemplate.replace('{0}', statusDisplay == null ? '' : statusDisplay);

			String plainBody = greeting + '\n\n' + received + '\n\n'
				+ filingNumberLine + '\n' + filingStatusLine + '\n\n'
				+ bodyReview + '\n\n' + thankYou + '\n' + signature;

			String htmlBody = '<p>' + greeting + '</p>'
				+ '<p>' + received + '</p>'
				+ '<p>' + filingNumberLine + '<br/>' + filingStatusLine + '</p>'
				+ '<p>' + bodyReview + '</p>'
				+ '<p>' + thankYou + '<br/>' + signature + '</p>';

			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(new List<String>(toAddresses));
			email.setCcAddresses(new List<String>{ 'rishi.kansara@mtxg.ai' });
			email.setSubject(subject);
			email.setPlainTextBody(plainBody);
			email.setHtmlBody(htmlBody);
			email.setSaveAsActivity(false);
			email.setUseSignature(false);
			email.setTreatTargetObjectAsRecipient(false);

			Id oweaId = resolveOrgWideEmailAddressId();
			if (oweaId != null) {
				email.setOrgWideEmailAddressId(oweaId);
			}

			Messaging.SendEmailResult[] results = Messaging.sendEmail(
				new List<Messaging.SingleEmailMessage>{ email },
				false
			);
			if (results != null && !results.isEmpty() && !results[0].isSuccess()) {
				String errorMsg = 'Financial filing confirmation email failed';
				if (results[0].getErrors() != null && !results[0].getErrors().isEmpty()) {
					errorMsg = results[0].getErrors()[0].getMessage();
				}
				LPI_ExceptionManager.logException(
					'EMP_FinancialFilingCtrl',
					'sendSubmissionConfirmationEmail',
					'EmailSendFailure',
					errorMsg,
					null,
					null
				);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('EMP_FinancialFilingCtrl', 'sendSubmissionConfirmationEmail', ex);
		}
	}

	/**
	 * @description Resolves a verified Org-Wide Email Address so Experience Cloud / portal users
	 *              can send confirmation emails.
	 */
	private static Id resolveOrgWideEmailAddressId() {
		List<OrgWideEmailAddress> owea = [
			SELECT Id
			FROM OrgWideEmailAddress
			WHERE Address IN (
				'ria.goel+noreply@mtxb2b.com',
				'ayush.dev@mtxb2b.com',
				'shreay.mittal@mtxb2b.com'
			)
			ORDER BY CreatedDate ASC
			LIMIT 1
		];
		if (!owea.isEmpty()) {
			return owea[0].Id;
		}
		List<OrgWideEmailAddress> anyOwea = [
			SELECT Id
			FROM OrgWideEmailAddress
			LIMIT 1
		];
		return anyOwea.isEmpty() ? null : anyOwea[0].Id;
	}

	@AuraEnabled
	public static List<FileInfo> getFiles(Id filingId) {
		Map<Id, FileInfo> mapFiles = getPrimaryFiles(new Set<Id>{ filingId });
		List<FileInfo> all = new List<FileInfo>();
		for (ContentDocumentLink cdl : [
			SELECT
				ContentDocumentId,
				ContentDocument.Title,
				ContentDocument.FileExtension,
				ContentDocument.ContentSize,
				ContentDocument.LatestPublishedVersionId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :filingId
			ORDER BY SystemModstamp DESC
		]) {
			FileInfo fi = new FileInfo();
			fi.contentDocumentId = cdl.ContentDocumentId;
			fi.contentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
			fi.title = cdl.ContentDocument.Title;
			fi.extension = cdl.ContentDocument.FileExtension;
			fi.size = cdl.ContentDocument.ContentSize;
			all.add(fi);
		}
		return all;
	}

	@AuraEnabled
	public static void removeFile(Id contentDocumentId, Id filingId) {
		List<ContentDocumentLink> links = [
			SELECT Id
			FROM ContentDocumentLink
			WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :filingId
		];
		if (!links.isEmpty()) {
			delete links;
		}
		List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
		if (!docs.isEmpty()) {
			delete docs;
		}
	}

	@AuraEnabled
	public static String getPreviewUrl(Id contentDocumentId) {
		if (contentDocumentId == null) {
			return null;
		}
		return '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
	}

	private static Id resolveAccountId() {
		User u = [
			SELECT Id, ContactId, Contact.AccountId, AccountId
			FROM User
			WHERE Id = :UserInfo.getUserId()
			LIMIT 1
		];
		if (u.Contact != null && u.Contact.AccountId != null) {
			return u.Contact.AccountId;
		}
		if (u.AccountId != null) {
			return u.AccountId;
		}
		List<AccountContactRelation> acrs = [
			SELECT AccountId
			FROM AccountContactRelation
			WHERE ContactId = :u.ContactId AND IsActive = TRUE
			ORDER BY CreatedDate DESC
			LIMIT 1
		];
		if (!acrs.isEmpty()) {
			return acrs[0].AccountId;
		}
		return null;
	}

	private static String resolveAccountName(Id accountId) {
		if (accountId == null) {
			return 'Employer Account';
		}
		Account a = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
		return a.Name;
	}

	private static Map<Id, FileInfo> getPrimaryFiles(Set<Id> filingIds) {
		Map<Id, FileInfo> result = new Map<Id, FileInfo>();
		if (filingIds == null || filingIds.isEmpty()) {
			return result;
		}
		for (ContentDocumentLink cdl : [
			SELECT
				LinkedEntityId,
				ContentDocumentId,
				ContentDocument.Title,
				ContentDocument.FileExtension,
				ContentDocument.ContentSize,
				ContentDocument.LatestPublishedVersionId
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :filingIds
			ORDER BY SystemModstamp DESC
		]) {
			if (result.containsKey(cdl.LinkedEntityId)) {
				continue;
			}
			FileInfo fi = new FileInfo();
			fi.contentDocumentId = cdl.ContentDocumentId;
			fi.contentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
			fi.title = cdl.ContentDocument.Title;
			fi.extension = cdl.ContentDocument.FileExtension;
			fi.size = cdl.ContentDocument.ContentSize;
			result.put(cdl.LinkedEntityId, fi);
		}
		return result;
	}

	private static FilingDTO toDto(Financial_Filing__c row) {
		FilingDTO dto = new FilingDTO();
		dto.id = row.Id;
		dto.name = row.Name;
		dto.status = row.Status__c;
		dto.filingType = row.Filing_Type__c;
		dto.reportingYear = row.Reporting_Year__c;
		dto.periodStart = row.Period_Start__c;
		dto.periodEnd = row.Period_End__c;
		dto.dueDate = row.Due_Date__c;
		dto.parentLicence = row.Parent_Licence__c;
		dto.businessLicenseId = row.Business_License__c;
		dto.licenceType = row.Licence_Type__c;
		dto.filerFirstName = row.Filer_First_Name__c;
		dto.filerLastName = row.Filer_Last_Name__c;
		dto.filerEmail = row.Filer_Email__c;
		dto.filerPhone = row.Filer_Phone__c;
		dto.filerName = ((row.Filer_First_Name__c == null ? '' : row.Filer_First_Name__c) +
			' ' +
			(row.Filer_Last_Name__c == null ? '' : row.Filer_Last_Name__c))
			.trim();
		dto.totalAssets = row.Total_Assets__c;
		dto.totalLiabilities = row.Total_Liabilities__c;
		dto.nbWrittenPremiums = row.NB_Written_Premiums__c;
		dto.otherNbAmounts = row.Other_NB_Amounts__c;
		dto.attestation = row.Attestation__c;
		dto.description = row.Description__c;
		dto.accountId = row.Account__c;
		dto.periodLabel = formatPeriod(row.Period_Start__c, row.Period_End__c);
		dto.dueDateLabel = formatDate(row.Due_Date__c);
		dto.isDraft = row.Status__c == STATUS_DRAFT;
		dto.isRequestMissingSchedule = row.Status__c == STATUS_REQUEST_MISSING;
		dto.isEditable = row.Status__c == STATUS_DRAFT || row.Status__c == STATUS_REQUEST_MISSING;
		return dto;
	}

	private static String formatDate(Date d) {
		if (d == null) {
			return '';
		}
		Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
		return dt.format('dd MMM yyyy');
	}

	private static String formatPeriod(Date startDate, Date endDate) {
		if (startDate == null && endDate == null) {
			return '';
		}
		return formatDate(startDate) + ' – ' + formatDate(endDate);
	}

	public class FilingPageResult {
		@AuraEnabled public Id accountId;
		@AuraEnabled public String accountName;
		@AuraEnabled public String parentLicence;
		@AuraEnabled public String licenceType;
		@AuraEnabled public String filingType;
		@AuraEnabled public List<FilingDTO> filings = new List<FilingDTO>();
		@AuraEnabled public FilingDTO currentFiling;
		@AuraEnabled public Integer countDraft = 0;
		@AuraEnabled public Integer countSubmitted = 0;
		@AuraEnabled public Integer countAccepted = 0;
		@AuraEnabled public Integer countRejected = 0;
		@AuraEnabled public Integer countRequestMissingSchedule = 0;
		@AuraEnabled public Integer countMissingScheduleSubmitted = 0;
	}

	public class FilingDTO {
		@AuraEnabled public Id id;
		@AuraEnabled public String name;
		@AuraEnabled public String status;
		@AuraEnabled public String filingType;
		@AuraEnabled public String reportingYear;
		@AuraEnabled public Date periodStart;
		@AuraEnabled public Date periodEnd;
		@AuraEnabled public Date dueDate;
		@AuraEnabled public String periodLabel;
		@AuraEnabled public String dueDateLabel;
		@AuraEnabled public String parentLicence;
		@AuraEnabled public Id businessLicenseId;
		@AuraEnabled public String licenceType;
		@AuraEnabled public String filerFirstName;
		@AuraEnabled public String filerLastName;
		@AuraEnabled public String filerName;
		@AuraEnabled public String filerEmail;
		@AuraEnabled public String filerPhone;
		@AuraEnabled public Decimal totalAssets;
		@AuraEnabled public Decimal totalLiabilities;
		@AuraEnabled public Decimal nbWrittenPremiums;
		@AuraEnabled public Decimal otherNbAmounts;
		@AuraEnabled public String attestation;
		@AuraEnabled public String description;
		@AuraEnabled public Id accountId;
		@AuraEnabled public String documentName;
		@AuraEnabled public Id contentDocumentId;
		@AuraEnabled public Id contentVersionId;
		@AuraEnabled public Boolean isDraft;
		@AuraEnabled public Boolean isEditable;
		@AuraEnabled public Boolean isRequestMissingSchedule;
	}

	public class FileInfo {
		@AuraEnabled public Id contentDocumentId;
		@AuraEnabled public Id contentVersionId;
		@AuraEnabled public String title;
		@AuraEnabled public String extension;
		@AuraEnabled public Long size;
	}

	public class LicenseOption {
		@AuraEnabled public Id id;
		@AuraEnabled public String name;
		@AuraEnabled public String label;
		@AuraEnabled public String status;
		@AuraEnabled public String accountName;
	}
}