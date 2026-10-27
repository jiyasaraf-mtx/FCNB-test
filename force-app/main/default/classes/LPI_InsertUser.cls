/**
 *
 * @author          : Saurabh Singh
 * @Description     : This class is used to Insert Registered user in without sharing mode as User.ProfileId is not writable in with sharing
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         21 Oct, 2022        Saurabh Singh                     Developement
 * -------------------------------------------------------------------------------------------------------
 */
public without sharing class LPI_InsertUser {
	/**
	 * @author               : Saurabh Singh
	 * @param conId          : Passing contact Id to attach it to User
	 * @return  `String`     : returning blank string if User is inserting successfully
	 * @last modified by     : Ayush Dev
	 * @last modified date   :
	 * @modified details
	 */
	public static String insertUser(String conId) {
		try {
			String conStringToQuery = 'ID,AccountId,FirstName,Phone,LastName,Email,Title';
			String conWhereClause = 'Id = \'' + String.escapeSingleQuotes(conId) + '\'';
			LPI_ContactDAO.LPI_ContactWithoutSharingDAO withoutsharingContact = new LPI_ContactDAO.LPI_ContactWithoutSharingDAO();
			List<Contact> contactList = withoutsharingContact.getContactByDymanicQuery(
				conStringToQuery,
				conWhereClause,
				null,
				null,
				null
			);
			String profileStringToQuery = 'Id';
			String profileWhereClause =
				'Profile.Name = \'' +
				String.escapeSingleQuotes(LPI_LiteralConstant.Portal_Profile_Name) +
				'\'';
			List<Profile> profileList = LPI_UserDao.getProfilesByDymanicQuery(
				profileStringToQuery,
				profileWhereClause
			);
			if (profileList.isEmpty()) {
				throw new LPI_Exception(LPI_LiteralConstant.NO_MATCH_PROFILE_FOUND);
			}

			Contact con;
			if (!contactList.isEmpty()) {
				con = contactList[0];
			}

			String alias =
				(con.FirstName != null ? con.FirstName.substring(0, 1).toUpperCase() : '') +
				(con.LastName.length() > 6 ? con.LastName.substring(0, 6) : con.LastName);
			String nickname =
				((con.FirstName != null && con.FirstName.length() > 0) ? con.FirstName.substring(0, 1) : '') +
				con.LastName.substring(0, 1);
			nickname = nickname + String.valueOf(Crypto.getRandomInteger()).substring(1, 7);

			User u = new User();
			u.FirstName = con.FirstName;
			u.LastName = con.LastName;
			u.Email = con.Email;
			u.ProfileId = profileList[0].Id;
			u.ContactId = con.Id;
			u.IsActive = true;
			u.CommunityNickname = nickname;
			u.TimeZoneSidKey = LPI_LiteralConstant.USER_TIMEZONE_SID_KEY;
			u.Alias = alias;
			u.EmailEncodingKey = LPI_LiteralConstant.USER_EMAIL_ENCODING_KEY;
			u.LanguageLocaleKey = LPI_LiteralConstant.USER_LANGUAGE_LOCALE_KEY;
			u.LocaleSidKey = LPI_LiteralConstant.USER_LOCALE_SID_KEY;
			u.UserName = con.Email + LPI_LiteralConstant.USER_USERNAME_SUFFIX;
			u.Phone = con.Phone;
			String userId = Site.createExternalUser(u, con.AccountId, null, true);
            
			return '';
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InsertUser', 'insertUser', e);
		}
		return null;
	}
}