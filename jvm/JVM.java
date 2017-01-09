// Read byte code
// $ java -'Dfile.encoding=ISO8859_1' JVM
import java.io.File;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.*;

public class JVM {
    private String fname;
    private boolean state;

    private int[] data;
    private int len;
    private int ptr;

    public JVM(String fname) {
	this.fname = fname;
	this.ptr = 0;
	this.state = false;

	try {
	    Path src = Paths.get(fname);
	    byte[] tmp = Files.readAllBytes(src);
	    this.len = tmp.length;
	    int[] data = new int[tmp.length];
	    for(int i = 0; i < tmp.length; i++) {
		int val = 0xFF & tmp[i];
		data[i] = val;
	    }
	    this.data = data;
	    this.state = true;
	} catch(OutOfMemoryError e) {
	    System.out.println(e);
	} catch(IOException e) {
	    System.out.println(e);
	}
    }

    private int readU1() throws IOException {
	int nptr = this.ptr + 1;
	int val = 0;
	if(this.len <= nptr) throw new IOException();
	val = this.data[nptr];
	this.ptr = nptr;

	return val;
    }

    private int readU2() throws IOException {
    }

    private int readU4() throws IOException {
    }

    public boolean classParser() {
	boolean success = false;
	return success;
    }

    public static void main(String[] args) {
	JVM jvm = new JVM("Hello.class");
	if(jvm.classParser()) {
	    // System.out.println("yes ^.^");
	} else {
	    System.out.println("failed classParser");
	}
    }
}
