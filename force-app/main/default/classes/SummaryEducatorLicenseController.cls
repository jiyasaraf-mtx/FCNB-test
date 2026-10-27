public without sharing class SummaryEducatorLicenseController {
    @AuraEnabled
    public static IADataWrapper getIaId(string parId){
        IADataWrapper getIaData = new IADataWrapper();
        //system.assert(false,parId);
        string IaName = '';
        string iaId = [Select Id From IndividualApplication Where SavedApplicationRefId =:parId LIMIT 1].Id;
        if(iaId != ''){
            getIaData =  getPersonalInformation(iaId, IaName);
        }
        return getIaData;
    }
    @AuraEnabled
    public static IADataWrapper  getPersonalInformation( string recordId, string IaName){
       IADataWrapper getDataFrmIA = new IADataWrapper();
       string AccountId;
       IndividualApplication iaData = new IndividualApplication();
        if(recordId != '' && recordId != null){
             iaData = [Select Id, AccountId, Transaction_Suitability_Questions__c From IndividualApplication Where Id =:recordId Limit 1 ];
             AccountId = [Select Id, AccountId From IndividualApplication Where Id =:recordId LIMIT 1].AccountId;
            }
            if(IaName != null && IaName != ''){
                iaData = [Select Id, AccountId, Transaction_Suitability_Questions__c From IndividualApplication Where Name =:IaName Limit 1 ];
                AccountId = [Select Id, AccountId From IndividualApplication Where Id =:iaData.Id LIMIT 1].AccountId;
            }
            if(iaData!= null){
                getDataFrmIA.TransactioSuitabilityQuestion  = iaData.Transaction_Suitability_Questions__c;}
                
             
            if(AccountId!=''){
                Account getPersonInfo = [select Id, FirstName, LastName,Suffix,Date_of_Birth__c,PersonEmail,Phone,Social_Security_Number__c,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                                         From Account Where Id =:AccountId];
                getDataFrmIA.FirstName = getPersonInfo.FirstName;
                getDataFrmIA.LastName = getPersonInfo.LastName;
                getDataFrmIA.Suffix = getPersonInfo.Suffix;
                getDataFrmIA.DateOfBirth = getPersonInfo.Date_of_Birth__c;
                getDataFrmIA.Email = getPersonInfo.PersonEmail;
                getDataFrmIA.Phone = getPersonInfo.Phone;
                getDataFrmIA.SocialSecurityNumber = getPersonInfo.Social_Security_Number__c;
                getDataFrmIA.CityPerson = getPersonInfo.BillingCity;
                getDataFrmIA.StreetPerson = getPersonInfo.BillingStreet;
                getDataFrmIA.StatePerson = getPersonInfo.BillingState;
                getDataFrmIA.CountryPerson = getPersonInfo.BillingCountry;
                getDataFrmIA.ZipPostalPerson = getPersonInfo.BillingPostalCode;
            }
           List<Degree__c> degreeData = [Select Id,Institution_Name__c,City__c,Country__c,Degree_Obtained__c,State__c,Street__c,Major__c,Minor__c,Graduation_Date__c,Attend_in_WI__c From Degree__c Where Individual_Application__c =:recordId LIMIT 1];
            If(degreeData.size()>0){
                getDataFrmIA.InstitudeName = degreeData[0].Institution_Name__c;
                getDataFrmIA.InstitudeAddress_Street = degreeData[0].Street__c;
                getDataFrmIA.InstitudeAddress_City = degreeData[0].City__c;
                getDataFrmIA.InstitudeAddress_State = degreeData[0].State__c;
                getDataFrmIA.InstitudeAddress_Country = degreeData[0].Country__c;
                getDataFrmIA.Major = degreeData[0].Major__c;
                getDataFrmIA.Minor = degreeData[0].Minor__c;
                getDataFrmIA.GratuatedDate = degreeData[0].Graduation_Date__c;
                getDataFrmIA.AttendINwi = degreeData[0].Attend_in_WI__c;
                getDataFrmIA.DegreeObtain = degreeData[0].Degree_Obtained__c;
                
            }
            List<Work_History__c> workHistory = [Select Id,Bilingual_Assignment__c,Employment_City__c,Employer_Contact_Phone__c,Employment_Contact_Name__c,Employment_Country__c,Employment_End_Month__c,Employment_End_Year__c,Employment_Start_Month__c,Employment_Start_Year__c,Employment_State__c,Full_Time_Part_Time_Percentage__c,High_Grade__c,Long_Term_Substitute__c,Low_Grade__c,Positions_or_Subjects_Taught__c,School_Agency_or_Instution__c
                                         From Work_History__c Where Individual_Application__c =:recordId LIMIt 1];
            if(workHistory.size()>0){
                getDataFrmIA.School_WH = workHistory[0].School_Agency_or_Instution__c;
                getDataFrmIA.EmploymentCity_WH = workHistory[0].Employment_City__c;
                getDataFrmIA.EmploymentCountry_WH = workHistory[0].Employment_Country__c;
                getDataFrmIA.EmploymentState_WH = workHistory[0].Employment_State__c;
                getDataFrmIA.EmploymentContactName_WH = workHistory[0].Employment_Contact_Name__c;
                getDataFrmIA.EmployementStartMonth_WH = workHistory[0].Employment_Start_Month__c;
                getDataFrmIA.EmployementEndMonth_WH = workHistory[0].Employment_End_Month__c;
                getDataFrmIA.EmployementStartYear_WH = workHistory[0].Employment_Start_Year__c;
                getDataFrmIA.EmployementEndyear_WH = workHistory[0].Employment_End_Year__c;
                getDataFrmIA.Position = workHistory[0].Positions_or_Subjects_Taught__c;
                getDataFrmIA.BilingualAssigment = workHistory[0].Bilingual_Assignment__c;
                getDataFrmIA.LowGrade = workHistory[0].Low_Grade__c;
                getDataFrmIA.HighGrade = workHistory[0].High_Grade__c;
                getDataFrmIA.LongTermSubstitute = workHistory[0].Long_Term_Substitute__c;
                getDataFrmIA.FullTimePercentage = workHistory[0].Full_Time_Part_Time_Percentage__c;
            }
        
       return getDataFrmIA;
    }
    public class IADataWrapper{
        @AuraEnabled
        public  String FirstName;
        @AuraEnabled
        public  String TransactioSuitabilityQuestion;
        @AuraEnabled
        public  String LastName;
        @AuraEnabled
        public  String Suffix;
         @AuraEnabled
        public  Date DateOfBirth;
        @AuraEnabled
        public  String Email;
        @AuraEnabled
        public  String Phone;
        @AuraEnabled
        public  String SocialSecurityNumber;
        @AuraEnabled
        public  String CityPerson;
        @AuraEnabled
        public  String StreetPerson;
        @AuraEnabled
        public  String StatePerson;
        @AuraEnabled
        public  String CountryPerson;
        @AuraEnabled
        public  String ZipPostalPerson;
        @AuraEnabled
        public  String InstitudeName;
        @AuraEnabled
        public  String InstitudeAddress_Street;
        @AuraEnabled
        public  String InstitudeAddress_City;
        @AuraEnabled
        public  String InstitudeAddress_State;
        @AuraEnabled
        public  String InstitudeAddress_Country;
        @AuraEnabled
        public  String InstitudeAddress_ZipPostalCode;
        @AuraEnabled
        public  String Major;
        @AuraEnabled
        public  String Minor;
        @AuraEnabled
        public  Date GratuatedDate;
        
        @AuraEnabled
        public  String DegreeObtain;
        @AuraEnabled
        public  String AttendINwi;
        @AuraEnabled
        public  String School_WH;
        @AuraEnabled
        public  String EmploymentCity_WH;
        @AuraEnabled
        public  String EmploymentCountry_WH;
        @AuraEnabled
        public  String EmploymentState_WH;
        @AuraEnabled
        public  String EmploymentContactName_WH;
        @AuraEnabled
        public  String EmployementStartMonth_WH;
        @AuraEnabled
        public  String EmployementEndMonth_WH;
        @AuraEnabled
        public  Decimal EmployementStartYear_WH;
        @AuraEnabled
        public  Decimal EmployementEndyear_WH;
        @AuraEnabled
        public  String Position;
        @AuraEnabled
        public  String BilingualAssigment;
        @AuraEnabled
        public  String LowGrade;
        @AuraEnabled
        public  String HighGrade;
        @AuraEnabled
        public  String LongTermSubstitute;
        @AuraEnabled
        public  Decimal FullTimePercentage;
        
    }
}