/**
 * @author       : Ramadevi Medoji
 * @description  : This Class can be used for any custom functions which can be called in IP's or DR's
 * @since        : 30-Jan-2024
 */
global class LPI_CustomFunctions implements Callable
{
    /*
        inputs - arguments - List<Object> of passed in arguments
        output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
    */
    public static Integer counter = 0;
    public Object call(String action, Map<String, Object> args) {

        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');

        return invokeMethod(action, input, output, options);
    }
    

    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if (methodName == 'GenerateNumberCounter')
        {
            output.put('result', GenerateNumberCounter());
        }
        return true;
    }
    global Integer GenerateNumberCounter(){
        counter = counter + 1;
        return counter;
    }
}