global with sharing class LPI_MergeJSON implements Callable {
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
        	outMap.put('omnidata', inputMap);
        }
        catch (Exception ex) {
           System.debug('Error Occured >>>inputMap>>>'+ex);
        }
        return result;
    }
}