// MyUtil
// http://grepcode.com/file/repository.grepcode.com/java/root/jdk/openjdk/6-b14/java/util/Arrays.java#Arrays.toString%28java.lang.Object%5B%5D%29

public class MyUtil {
    public static String arrays_toString(Object[] a) {
        if(a == null)
            return "null";
        int iMax = a.length - 1;
        if(iMax == -1)
            return "[]";
        StringBuilder s = new StringBuilder();
        s.append("[\n");
        for(int i = 0; ; i++) {
            s.append("\t< ");
            s.append(i);
            s.append(" >");
            s.append(a[i]);
            if(i == iMax)
                return s.append("]").toString();
            s.append('\n');
        }
    }
    public static String arrays_toString(int[] a) {
        if(a == null)
            return "null";
        int iMax = a.length - 1;
        if(iMax == -1)
            return "[]";
        StringBuilder s = new StringBuilder();
        s.append("[\n");
        for(int i = 0; ; i++) {
            s.append("\t< ");
            s.append(i);
            s.append(" >");
            s.append(a[i]);
            if(i == iMax)
                return s.append("]").toString();
            s.append('\n');
        }
    }
}
