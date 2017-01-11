// Read byte code
// $ java -'Dfile.encoding=ISO8859_1' JVM
// $ javac -J-'Dfile.encoding=UTF8' JVM.java
// $ javap -v Hello.class
import java.util.Arrays;
import java.io.File;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.*;

// ------------------------///
//  Exception for JVM
// ------------------------///
enum ECode {
    NOT_INITIALIZED,
    INVALID_ARG_READ,
    INVALID_INDEX,
    INVALID_MAGIC,
    INVALID_TAG_VALUE,
    CPOOL_ATTRIBUTE,
    EMPTY_CODE_LENGTH;
}

class JVMException extends Exception {
    ECode code;
    JVMException (ECode code) {
        this.code = code;
    }

    @Override
    public String getMessage() {
        String s = "";
        switch(this.code) {
        case NOT_INITIALIZED:
            s = "Not initialized class file data.";
            break;
        case INVALID_ARG_READ:
            s = "Parser failed. (read)";
            break;
        case INVALID_INDEX:
            s = "Parser failed. (out of index)";
            break;
        case INVALID_MAGIC:
            s = "Magic is not 0xCAFEBABE.";
            break;
        case INVALID_TAG_VALUE:
            s = "tag value is not correct.";
            break;
        case CPOOL_ATTRIBUTE:
            s = "reference to invalid constant_pool by attribute";
            break;
        case EMPTY_CODE_LENGTH:
            s = "code length in CodeAttribute is Empty";
            break;
        }
        return s;
    }
}

// ------------------------///
//  Structure for jvm
// ------------------------///
enum CONSTANT_TAG {
    CONSTANT_Class(7),
    CONSTANT_Fieldref(9),
    CONSTANT_Methodref(10),
    CONSTANT_InterfaceMethodref(11),
    CONSTANT_String(8),
    CONSTANT_Integer(3),
    CONSTANT_Float(4),
    CONSTANT_Long(5),
    CONSTANT_Double(6),
    CONSTANT_NameAndType(12),
    CONSTANT_Utf8(1),
    UNKNOWN(-1);
    private int val;
    private CONSTANT_TAG(int val) { this.val = val; }
    public int value() { return this.val; }
    public static CONSTANT_TAG get(int val) {
        for (CONSTANT_TAG tag : values()) {
            if (tag.value() == val) 
                return tag;
        }
        return UNKNOWN;
    }
}

class Cp_info {
    CONSTANT_TAG tag;
    int name_index;
    int class_index;
    int name_and_type_index;
    int string_index;
    long bytes;
    long high_bytes;
    long low_bytes;
    int descriptor_index;
    int length;
    int[] bytes_utf8;

    public String valueOfbytes_utf8() {
        String s2 = "";
        for(int i = 0; i < bytes_utf8.length; i++)
            s2 += (char)bytes_utf8[i];
        return s2;
    }
    @Override
    public String toString() {
        String s = "";
        switch(tag) {
        case CONSTANT_Class:
            s = "" + name_index;
            break;
        case CONSTANT_Fieldref:
        case CONSTANT_Methodref:
        case CONSTANT_InterfaceMethodref:
            s = "" + class_index + " " + name_and_type_index;
            break;
        case CONSTANT_String:
            s = "" + string_index;
            break;
        case CONSTANT_Integer:
        case CONSTANT_Float:
            s = "" + bytes;
            break;
        case CONSTANT_Long:
        case CONSTANT_Double:
            s = "" + high_bytes + " " + low_bytes;
            break;
        case CONSTANT_NameAndType:
            s = "" + name_index + " " + descriptor_index;
            break;
        case CONSTANT_Utf8:
            String s2 = valueOfbytes_utf8();
            s = "" + length + ", " + s2;
            break;
        }
        return tag.toString() + "{" + s + "}";
    }
}

// Attribute
class Class_info {
    int inner_class_info_index;
    int outer_class_info_index;
    int inner_name_index;
    int inner_class_access_flags;
}
class Exception_info {
    int start_pc;
    int end_pc;
    int handler_pc;
    int catch_type;
}

class LineNumber_info {
    int start_pc;
    int line_number;
}

class CodeAttribute {
    int max_stack;
    int max_locals;
    long code_length;
    int[] code;
    int exception_table_length;
    Exception_info[] exception_table;
    int attributes_count;
    Attribute_info[] attributes;
}

class Attribute_info {
    CONSTANT_TAG tag;
    int attribute_name_index;
    long attribute_length;
    int constantvalue_index;
    CodeAttribute code_attribute;
    int number_of_exception;
    int[] exception_index_table;
    int number_of_classes;
    Class_info[] classes;
    int sourcefile_index;
    int line_number_table_length;
    LineNumber_info[] line_number_table;

    @Override
    public String toString() {
        return ("{attribute_name_index: " + attribute_name_index +
                ", attribute_length: " + attribute_length);
    }
}

// field_info, method_info
class FM_info {
    int access_flags;
    int name_index;
    int descriptor_index;
    int attributes_count;
    Attribute_info[] attributes;

    @Override
    public String toString() {
        return ("{" + access_flags + ", " + name_index + ", " +
                descriptor_index + ", " + attributes_count + "," +
                Arrays.toString(attributes) + "}");
    }
}

class ClassFile {
    long magic;
    int minor_version;
    int major_version;
    int constant_pool_count;
    Cp_info[] constant_pool;
    int access_flags;
    int this_class;
    int super_class;
    int interfaces_count;
    int[] interfaces;
    int fields_count;
    FM_info[] fields;
    int methods_count;
    FM_info[] methods;
    int attributes_count;
    Attribute_info[] attributes;
    private String name(String s) { return "\t" + s + ": "; }
    public void print() {
        System.out.println("ClassFile {");
        System.out.println(name("magic") + magic);
        System.out.println(name("minor_version") + minor_version);
        System.out.println(name("major_version") + major_version);
        System.out.println(name("counstant_pool_count") + constant_pool_count);
        System.out.println(name("counstant_pool") +
                           Arrays.toString(constant_pool));
        System.out.println(name("access_flags") + access_flags);
        System.out.println(name("this_class") + this_class);
        System.out.println(name("super_class") + super_class);
        System.out.println(name("interfaces_count") + interfaces_count);
        System.out.println(name("interfaces") + Arrays.toString(interfaces));
        System.out.println(name("fields_count") + fields_count);
        System.out.println(name("fields") + Arrays.toString(fields));
        System.out.println(name("method_count") + methods_count);
        System.out.println(name("methods") + Arrays.toString(methods));
        System.out.println(name("attributes_count") + attributes_count);
        System.out.println(name("attributes") + Arrays.toString(attributes));
        System.out.println("}");
    }
}

// ------------------------///
//   JVM main
// ------------------------///
public class JVM {
    private String fname;
    private boolean state;

    private int[] data;
    private int len;
    private int ptr;

    private ClassFile cfile;

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

    // receives byte size (1 ~ 4)
    private long read(int bsize) throws JVMException {
        if(!this.state) {
            throw new JVMException(ECode.NOT_INITIALIZED);
        } else if(bsize < 0 || 4 < bsize) {
            throw new JVMException(ECode.INVALID_ARG_READ);
        }
        int nptr = this.ptr + bsize;
        long val = 0;
        if (this.len <= nptr - 1) {
            throw new JVMException(ECode.INVALID_INDEX);
        }
        for(int i = this.ptr; i < nptr; i++) {
            int n = this.data[i];
            val = (val << 8) | n;
        }
        this.ptr = nptr;
        return val;
    }
    private long readU1() throws JVMException { return read(1); }
    private long readU2() throws JVMException {	return read(2); }
    private long readU4() throws JVMException { return read(4); }

    private Cp_info[] constant_pool(int size) throws JVMException {
        Cp_info[] infos = new Cp_info[size];
        for(int i = 0; i < size; i++) {
            int tag_val = (int)(readU1());
            CONSTANT_TAG tag = CONSTANT_TAG.get(tag_val);
            Cp_info c = new Cp_info();
            c.tag = tag;
            switch(tag) {
            case CONSTANT_Class:
                c.name_index = (int)(readU2());
                break;
            case CONSTANT_Fieldref:
            case CONSTANT_Methodref:
            case CONSTANT_InterfaceMethodref:
                c.class_index = (int)(readU2());
                c.name_and_type_index = (int)(readU2());
                break;
            case CONSTANT_String:
                c.string_index = (int)(readU2());
                break;
            case CONSTANT_Integer:
            case CONSTANT_Float:
                c.bytes = readU4();
                break;
            case CONSTANT_Long:
            case CONSTANT_Double:
                c.high_bytes = readU4();
                c.low_bytes = readU4();
                break;
            case CONSTANT_NameAndType:
                c.name_index = (int)(readU2());
                c.descriptor_index = (int)(readU2());
                break;
            case CONSTANT_Utf8:
                int length = (int)(readU2());
                int[] bytes = new int[length];
                for(int k = 0; k < length; k++)
                    bytes[k] = (int)(readU1());
                c.length = length;
                c.bytes_utf8 = bytes;
                break;
            case UNKNOWN:
                throw new JVMException(ECode.INVALID_TAG_VALUE);
            }
            infos[i] = c;
        }
        return infos;
    }

    private Exception_info[] exceptionTable(int length) throws JVMException {
        Exception_info[] ext = new Exception_info[length];
        for(int k = 0; k < length; k++) {
            Exception_info ex = new Exception_info();
            ex.start_pc = (int)readU2();
            ex.end_pc = (int)readU2();
            ex.handler_pc = (int)readU2();
            ex.catch_type = (int)readU2();
            ext[k] = ex;
        }
        return ext;
    }

    private LineNumber_info[] lineNumberTable(int length) throws JVMException {
        LineNumber_info[] ls = new LineNumber_info[length];
        for(int i = 0; i < length; i++) {
            LineNumber_info n = new LineNumber_info();
            n.start_pc = (int)readU2();
            n.line_number = (int)readU2();
            ls[i] = n;
        }
        return ls;
    }

    private CodeAttribute codeAttribute() throws JVMException {
        CodeAttribute ca = new CodeAttribute();
        ca.max_stack = (int)readU2();
        ca.max_locals = (int)readU2();
        long code_length = readU4();
        if(code_length <= 0)
            throw new JVMException(ECode.EMPTY_CODE_LENGTH);
        int[] code = new int[(int)code_length];
        for(int k = 0; k < code_length; k++)
            code[k] = (int)readU1();
        ca.code_length = code_length;
        ca.code = code;

        int ext_length = (int)readU2();
        ca.exception_table_length = ext_length;
        ca.exception_table = exceptionTable(ext_length);

        int attributes_cnt = (int)readU2();
        ca.attributes_count = attributes_cnt;
        ca.attributes = attributes(attributes_cnt);
        return ca;
    }

    private Attribute_info[] attributes(int size) throws JVMException {
        Cp_info[] cps = cfile.constant_pool;
        Attribute_info[] as = new Attribute_info[size];
        for(int i = 0; i < size; i++) {
            int name_index = (int)readU2() - 1;
            if(cps.length <= name_index)
                throw new JVMException(ECode.CPOOL_ATTRIBUTE);
            Cp_info cp = cps[name_index];
            if(cp.tag != CONSTANT_TAG.CONSTANT_Utf8) {
                throw new JVMException(ECode.CPOOL_ATTRIBUTE);
            }
            Attribute_info a = new Attribute_info();
            a.tag = cp.tag;
            long length = readU4();
            String s = cp.valueOfbytes_utf8();
            if(s.equals("ConstantValue")) {
                a.constantvalue_index = (int)readU2();
            } else if(s.equals("Code")) {
                a.code_attribute = codeAttribute();
            } else if(s.equals("LineNumberTable")) {
                int llen = (int)readU2();
                a.line_number_table_length = llen;
                a.line_number_table = lineNumberTable(llen);
            } else if(s.equals("SourceFile")) {
                a.sourcefile_index = (int)readU2();
            } else {
                System.out.println(s);
                throw new JVMException(ECode.CPOOL_ATTRIBUTE);
            }
            a.attribute_name_index = name_index;
            a.attribute_length = length;
            as[i] = a;
        }
        return as;
    }

    private FM_info[] fields_methods(int size) throws JVMException {
        FM_info[] fms = new FM_info[size];
        for(int i = 0; i < size; i++) {
            FM_info f = new FM_info();
            f.access_flags = (int)readU2();
            f.name_index = (int)readU2() - 1;
            f.descriptor_index = (int)readU2();
            int alen = (int)readU2();
            f.attributes_count = alen;
            f.attributes = attributes(alen);
            fms[i] = f;
        }
        return fms;
    }

    public boolean classParser() {
        boolean success = false;
        try {
            cfile = new ClassFile();
            long magic = readU4();
            if(magic != 0xcafebabeL) {
                throw new JVMException(ECode.INVALID_MAGIC);
            }
            cfile.magic = magic;
            cfile.minor_version = (int)readU2();
            cfile.major_version = (int)readU2();
            int cpool_cnt = (int)readU2();
            cfile.constant_pool_count = cpool_cnt - 1;
            cfile.constant_pool = constant_pool(cpool_cnt - 1);;
            cfile.access_flags = (int)readU2();
            cfile.this_class = (int)readU2();
            cfile.super_class = (int)readU2();
            int interfaces_cnt = (int)readU2();
            int[] interfaces = new int[interfaces_cnt];
            for(int i = 0; i < interfaces_cnt; i++)
                interfaces[i] = (int)readU2();
            cfile.interfaces_count = interfaces_cnt;
            cfile.interfaces = interfaces;
            int fields_cnt = (int)readU2();
            cfile.fields_count = fields_cnt;
            cfile.fields = fields_methods(fields_cnt);
            int methods_cnt = (int)readU2();
            cfile.methods_count = methods_cnt;
            cfile.methods = fields_methods(methods_cnt);
            int attrs_cnt = (int)readU2();
            cfile.attributes_count = attrs_cnt;
            cfile.attributes = attributes(attrs_cnt);

            cfile.print();
            success = true;
        } catch(JVMException e) {
            System.out.println(e);
        }
        return success;
    }

    public static void main(String[] args) {
        JVM jvm = new JVM("Hello.class");
        jvm.classParser();
    }
}
