// Read byte code
// $ java -'Dfile.encoding=ISO8859_1' JVM
import java.io.File;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;

public class JVM {
    static String fname = "Hello.class";

    static boolean isClassFile(String fname) {
	boolean state = false;

	try {
	    File file = new File(fname);
	    FileReader fr = new FileReader(file);

	    int n = -1;
	    long target = 0xcafebabeL;
	    long s = 0;
	    for(int i = 0; (n = fr.read()) != -1 && i < 4; i++) {
		s = (s << 8) | n ;
	    }
	    fr.close();
	    if(s == target) {
		state = true;
	    }
	} catch(FileNotFoundException e) {
	    System.out.println(e);
	} catch(IOException e) {
	    System.out.println(e);
	}
	return state;
    }

    public static void main(String[] args) {
	if(isClassFile(fname)) {
	    System.out.println("yes ^.^");
	} else {
	    System.out.println("no  ;_;");
	}
    }
}
