import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSet(byte[]  v)
    {
        int length = v.length;
        value = new AtomicIntegerArray(length);
        for(int i=0;i<length;i++){
            value.set(i,v[i]);
        }  //AtomicIntegerArray cannot be directly constructed from byte[] 
        maxval = 127;
    }
    
    GetNSet(byte[] v, byte m) 
    { 
        int length = v.length;
        value = new AtomicIntegerArray(length);
        for(int i=0;i<length;i++){
            value.set(i,v[i]);
        }  //AtomicIntegerArray cannot be directly constructed from byte[]
        maxval = m;
    }
    
    public int size() {return value.length();}
    
    public byte[] current() 
    {
        int length = value.length();
        byte[] result = new byte[length];
        for(int i=0;i<length;i++)
        {
            result[i] = (byte) value.get(i);
	    //forget the coersion first time , have to  !!!!
        }
        return result;
    }

    public boolean swap(int i ,int j ){
        int valuei = value.get(i);
        int valuej = value.get(j);
        if(valuei <=0 || valuej >= maxval){
            return false;
        }
        valuei--;
        valuej++;
        value.set(i,valuei);
        value.set(j,valuej);
	return true;
    }
}



