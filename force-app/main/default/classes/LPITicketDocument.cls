global without sharing class LPITicketDocument implements Callable {
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'handleTicketSubmit') {
                handleTicketSubmit(inputMap, outMap);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_PostSubmitController', 'invokeMethod', e);
            result = false;
        }
        return result;
    }
    
    global static void handleTicketSubmit(Map<String, Object> inputMap,Map<String, Object> outMap) {
        try {
            Map<String,Object> mapOfTicketData = (Map<String,Object>) inputMap.get('CreateTicket');
            Ticket__c  ticket = new Ticket__c();
            ticket.Category__c = mapOfTicketData.containskey('Category') ? (String)mapOfTicketData.get('Category') : '';
			ticket.I_need_Assistance_with__c = mapOfTicketData.containskey('NeedAssistance') ? (String)mapOfTicketData.get('NeedAssistance'):'';
            ticket.License_Type__c = mapOfTicketData.containskey('LicenseType') ? (String)mapOfTicketData.get('LicenseType'): '';
            ticket.Subject__c = mapOfTicketData.containskey('Subject') ? (String)mapOfTicketData.get('Subject') : '';
            ticket.First_Name__c = mapOfTicketData.containskey('FirstName') ? (String)mapOfTicketData.get('FirstName'):'';
            ticket.Last_Name__c = mapOfTicketData.containskey('LastName') ? (String)mapOfTicketData.get('LastName') : '';
            ticket.Email__c = mapOfTicketData.containskey('Email') ? (String)mapOfTicketData.get('Email') : '';
            ticket.Phone_Number__c = mapOfTicketData.containskey('PhoneNumber') ? (String)mapOfTicketData.get('PhoneNumber') : '';
            ticket.Description__c = mapOfTicketData.containskey('Description') ? (String)mapOfTicketData.get('Description') : '';
            
            if(mapOfTicketData.containskey('Address-Block')){
                Map<String,Object> mapOfAddress = (Map<String,Object>)mapOfTicketData.get('Address-Block');
                ticket.Street__c = mapOfAddress.containskey('Street') ? (String)mapOfAddress.get('Street') : '';
                ticket.City__c =  mapOfAddress.containskey('City') ? (String)mapOfAddress.get('City') : '';
                ticket.State__c =  mapOfAddress.containskey('State') ? (String)mapOfAddress.get('State') : '';
                ticket.Country__c =  mapOfAddress.containskey('Country') ? (String)mapOfAddress.get('Country') : '';
                ticket.Zipcode__c =  mapOfAddress.containskey('ZipCode') ? (String)mapOfAddress.get('ZipCode') : '';
            }
            ticket.Ticket_Status__c  = 'Submitted';
           	insert ticket;
            Ticket__c  newticket = [SELECT Id,Name FROM Ticket__c where Id=:ticket.Id LIMIT 1];
            outMap.put('TicketNumber',newticket.Name);
            if(mapOfTicketData.containskey('Document')){
                List<Object> listOfMapDoc = (List<Object>)mapOfTicketData.get('Document');
                Map<String,Object> mapOfDoc = (Map<String,Object>)listOfMapDoc[0];
                system.debug('mapOfDoc:- '+mapOfDoc);
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = (String)mapOfDoc.get('data');
                cdl.LinkedEntityId = ticket.Id;
                cdl.ShareType = 'V';
                insert cdl; 
            }   
        }catch (Exception e) {
            system.debug('error');
        }
    }
}