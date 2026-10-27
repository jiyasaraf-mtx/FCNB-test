/**
    @author = George Acker
    A self-referencing (recursive) class that stores an n-tier grouping.
    This is a generic replacement for creating maps of maps, maps of maps of maps, etc...
    Best use case is when you have generic code and you aren't sure how deep your map nesting may go.  Rather than concatenating keys in a single keyset, this is a much safer approach.
    From your code, instantiate the root with the base constructor.  Then call the putData and getData methods as appropriate.
    The list sizes you pass in should always be the same length.  It doesn't make sense to change the size of your MapChain.
    Data should only ever live at the last layer of the MapChain.  Basically, whenever data != null, grouping.size() == 0 and when grouping.size() != 0, data == null.
        It may actually still work if this is not the case, but it is an un-intended side effect so be careful.
    Keyset method has been implemented so you can get back a list of list of objects (a list of your keys)
        Order within the outer list is arbitrary because it uses the map keyset method.  The inner lists will be ordered as they are the actual keys.
    Order of the list of keys is important.  Don't forget this if you are using sets to drive the data in the chain.  You may have to copy the set to a list to ensure order.
        Make sure that if your MapChain has keys of type {a, b, c} that you are always passing values in this order.
*/
public class LPI_Utility_MapChain
{
    public object data;
    public Map<object,LPI_Utility_MapChain> grouping;
    
    // Call this constructor to instantiate the first object.  Think of it as the root.  It will never have data != null and contains your first tier of mappings
    public LPI_Utility_MapChain()
    {
        grouping = new Map<object,LPI_Utility_MapChain>();
    }
    
    // You should never need to call this, hence why it is private.
    private LPI_Utility_MapChain(object obj, List<object> fields)
    {
        grouping = new Map<object,LPI_Utility_MapChain>();
        if (fields != null)
        {
            insertData(this,fields,obj);
        }
    }
    
    //Pass the root chain in, along with a list of fields in the order you want them parsed and get back an object
    public object getData(List<object> flds)
    {
        List<object> fields = new List<object>(flds); //cloning because if get returns null you may want to put the data in with the same list
        LPI_Utility_MapChain chain = findChainLink(this,fields);
        return chain.data;
    }
    
    //Pass the root chain in, along with a list of fields in the order you want them parsed and the data to be put into the map chain
    public void putData(List<object> flds, object obj)
    {
        List<object> fields = new List<object>(flds); //cloning to avoid destroying the list that was passed in
        LPI_Utility_MapChain chain = findChainLink(this,fields);
        insertData(chain,fields,obj);
    }
    
    //Get back a set of all of the keys (represented as lists, so you get a set of a list of objects).
    public Set<List<object>> keySet()
    {
        return keySet(this);
    }
    
    private static Set<List<object>> keySet(LPI_Utility_MapChain chain)
    {
        Set<List<object>> keys = new Set<List<object>>();
        for(object o :chain.grouping.keyset())
        {
            Set<List<object>> childKeyset = keySet(chain.grouping.get(o));
            for (List<object> childKeys :childkeyset)
            {
                object[] keyList = new object[]{o};
                keyList.addAll(childKeys);
                keys.add(keyList);
            }
            if (childKeyset.size() == 0) //if no child keys, then we need to just return the keys in this chain as a list of a list of size one
            {
                object[] keyList = new object[]{o};
                keys.add(keyList);
            }
        }
        return keys;
    }
    
    private static LPI_Utility_MapChain findChainLink(LPI_Utility_MapChain chain, List<object> fields)
    {
        while(chain.grouping != null && fields.size() > 0 && chain.grouping.containsKey(fields[0]))
        {
            chain = chain.grouping.get(fields[0]);
            fields.remove(0);
        }
        return chain;
    }
    
    private static void insertData(LPI_Utility_MapChain chain, List<object> fields, object obj)
    {
        if (fields.size() == 0)
            chain.data = obj;
        else
        {
            object f = fields.remove(0);
            chain.grouping.put(f,new LPI_Utility_MapChain(obj,fields));
        }
    }
}