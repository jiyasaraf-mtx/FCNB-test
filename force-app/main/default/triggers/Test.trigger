trigger Test on Account (before insert) {
  	Set<String> setAccount = new Set<String>();
    for(Account acc : trigger.new){
        setAccount.add(acc.Id);
    }  
    
    List<Contact> listOfCoint = [select Id,Name from Contact where AccountId IN:trigger.new];
    
}