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
            s = "reference to unknown constant_pool by attribute";
            break;
        case EMPTY_CODE_LENGTH:
            s = "code length in CodeAttribute is Empty";
            break;
        }
        return s;
    }
}

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

// ------------------------///
//   JVM main
// ------------------------///
public class JVM {
    private static Util util;

    private String fname;
    private boolean state;
    private boolean parsed_cfile;
    private int[] data;
    private int len;
    private int ptr;

    private ClassFile cfile;

    public JVM(String fname) {
        this.fname = fname;
        this.ptr = 0;
        this.state = false;
        this.parsed_cfile = false;
        this.util = new Util();

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

    // ------------------------///
    //  Structure for jvm
    // ------------------------///
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
            StringBuilder s = new StringBuilder();
            for(int i = 0; i < bytes_utf8.length; i++)
                s.append((char)bytes_utf8[i]);
            return s.toString();
        }
        public String toString() {
            StringBuilder s = new StringBuilder();
            s.append(tag);
            s.append('{');
            switch(tag) {
            case CONSTANT_Class:
                s.append(name_index);
                break;
            case CONSTANT_Fieldref:
            case CONSTANT_Methodref:
            case CONSTANT_InterfaceMethodref:
                s.append(class_index);
                s.append(',');
                s.append(name_and_type_index);
                break;
            case CONSTANT_String:
                s.append(string_index);
                break;
            case CONSTANT_Integer:
            case CONSTANT_Float:
                s.append(bytes);
                break;
            case CONSTANT_Long:
            case CONSTANT_Double:
                s.append(high_bytes);
                s.append(',');
                s.append(low_bytes);
                break;
            case CONSTANT_NameAndType:
                s.append(name_index);
                s.append(',');
                s.append(descriptor_index);
                break;
            case CONSTANT_Utf8:
                s.append(length);
                s.append(',');
                s.append(valueOfbytes_utf8());
                break;
            }
            return s.append('}').toString();
        }
    }

    // Attribute
    class Exception_info {
        int start_pc;
        int end_pc;
        int handler_pc;
        int catch_type;
        public String toString() {
            return "{" + start_pc + ", " + end_pc + ", " + handler_pc +
                ", " + catch_type + "}";
        }
    }
    class Class_info {
        int inner_class_info_index;
        int outer_class_info_index;
        int inner_name_index;
        int inner_class_access_flags;
        public String toString() {
            return "{" + inner_class_info_index + ", " +
                outer_class_info_index + ", " + inner_name_index + ", " +
                inner_class_access_flags + "}";
        }
    }
    class LineNumber_info {
        int start_pc;
        int line_number;
        public String toString() {
            return "{" + start_pc + ", " + line_number + "}";
        }
    }
    class LocalVariable_info {
        int start_pc;
        int length;
        int name_index;
        int descriptor_index;
        int index;
        public String toString() {
            return "{" + start_pc + ", " + length + ", " + name_index + ", " +
                descriptor_index + ", " + index + "}";
        }
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
        public String toString() {
            return "{" + max_stack + ", " + max_locals + ", " + code_length +
                ", code: " + Arrays.toString(code) + ", " +
                exception_table_length + ", exception_table:" +
                Arrays.toString(exception_table) + ", " +
                attributes_count + ", attributes: " +
                util.Arrays.toString(attributes) + "}";
        }
    }

    class Attribute_info {
        String name;
        int attribute_name_index;
        int attribute_length;
        int constantvalue_index;
        CodeAttribute code_attribute;
        int[] exception_index_table;
        Class_info[] classes;
        int sourcefile_index;
        LineNumber_info[] line_number_table;
        LocalVariable_info[] local_variable_table;
        int[] others;
        /* "ConstantValue" "Code" "Exception":
           "InnerClasses" "Synthetic" "Deprecated"
           "SourceFile" "LineNumberTable" "LocalVariableTable" */
        public String toString() {
            String s = "_";
            switch(name) {
            case "ConstantValue":
                s = String.valueOf(constantvalue_index);
                break;
            case "Code":
                s = code_attribute.toString();
                break;
            case "Exception":
                s = Arrays.toString(exception_index_table);
            case "InnerClasses":
                s = Arrays.toString(classes);
            case "SourceFile":
                s = String.valueOf(sourcefile_index);
                break;
            case "LineNumberTable":
                s = Arrays.toString(line_number_table);
                break;
            case "LocalVariableTable":
                s = Arrays.toString(local_variable_table);
                break;
            }
            return name + "Attribute{attribute_name_index: " +
                attribute_name_index + ", attribute_length: " +
                attribute_length + ", " + s + "}";
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
            return ("FM_info{" + access_flags + ", " + name_index + ", " +
                    descriptor_index + ", " + attributes_count +
                    ", attributes:" + util.Arrays.toString(attributes) + "}");
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

        private String t(String s) { return "\n\t" + s + ": "; }
        public void print() {
            StringBuilder s = new StringBuilder();
            s.append("ClassFile {");
            s.append(t("magic") + magic);
            s.append(t("minor_version") + minor_version);
            s.append(t("major_version") + major_version);
            s.append(t("counstant_pool_count") + constant_pool_count);
            s.append(t("counstant_pool") + util.Arrays.toString(constant_pool));
            s.append(t("access_flags") + access_flags);
            s.append(t("this_class") + this_class);
            s.append(t("super_class") + super_class);
            s.append(t("interfaces_count") + interfaces_count);
            s.append(t("interfaces") + util.Arrays.toString(interfaces));
            s.append(t("fields_count") + fields_count);
            s.append(t("fields") + util.Arrays.toString(fields));
            s.append(t("method_count") + methods_count);
            s.append(t("methods") + util.Arrays.toString(methods));
            s.append(t("attributes_count") + attributes_count);
            s.append(t("attributes") + util.Arrays.toString(attributes));
            s.append("\n}");
            System.out.println(s);
        }
    }

    // receives byte size (1 ~ 4)
    private long read(int bsize) throws JVMException {
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
    private int readU1() throws JVMException { return (int)read(1); }
    private int readU2() throws JVMException { return (int)read(2); }
    private long readU4() throws JVMException { return read(4); }
    private int[] readU1_n(int n) throws JVMException {
        int[] arr = new int[n];
        for(int i = 0; i < n; i++)
            arr[i] = readU1();
        return arr;
    }
    private int[] readU2_n(int n) throws JVMException {
        int[] arr = new int[n];
        for(int i = 0; i < n; i++)
            arr[i] = readU2();
        return arr;
    }

    private Cp_info[] constant_pool(int size) throws JVMException {
        Cp_info[] infos = new Cp_info[size];
        infos[0] = null;
        for(int i = 1; i < size; i++) {
            int tag_val = readU1();
            CONSTANT_TAG tag = CONSTANT_TAG.get(tag_val);
            Cp_info c = new Cp_info();
            c.tag = tag;
            switch(tag) {
            case CONSTANT_Class:
                c.name_index = readU2();
                break;
            case CONSTANT_Fieldref:
            case CONSTANT_Methodref:
            case CONSTANT_InterfaceMethodref:
                c.class_index = readU2();
                c.name_and_type_index = readU2();
                break;
            case CONSTANT_String:
                c.string_index = readU2();
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
                c.name_index = readU2();
                c.descriptor_index = readU2();
                break;
            case CONSTANT_Utf8:
                int length = readU2();
                c.length = length;
                c.bytes_utf8 = readU1_n(length);
                break;
            case UNKNOWN:
                throw new JVMException(ECode.INVALID_TAG_VALUE);
            }
            infos[i] = c;
        }
        return infos;
    }

    private Exception_info[] exceptionTable(int length) throws JVMException {
        Exception_info[] xs = new Exception_info[length];
        for(int k = 0; k < length; k++) {
            Exception_info x = new Exception_info();
            x.start_pc = readU2();
            x.end_pc = readU2();
            x.handler_pc = readU2();
            x.catch_type = readU2();
            xs[k] = x;
        }
        return xs;
    }

    private Class_info[] classes(int length) throws JVMException {
        Class_info[] xs = new Class_info[length];
        for(int i = 0; i < length; i++) {
            Class_info x = new Class_info();
            x.inner_class_info_index = readU2();
            x.outer_class_info_index = readU2();
            x.inner_name_index = readU2();
            x.inner_class_access_flags = readU2();
            xs[i] = x;
        }
        return xs;
    }

    private LineNumber_info[] lineNumberTable(int length) throws JVMException {
        LineNumber_info[] xs = new LineNumber_info[length];
        for(int i = 0; i < length; i++) {
            LineNumber_info x = new LineNumber_info();
            x.start_pc = readU2();
            x.line_number = readU2();
            xs[i] = x;
        }
        return xs;
    }

    private LocalVariable_info[] localVariableTable(int length) throws JVMException {
        LocalVariable_info[] xs = new LocalVariable_info[length];
        for(int i = 0; i < length; i++) {
            LocalVariable_info x = new LocalVariable_info();
            x.start_pc = readU2();
            x.length = readU2();
            x.name_index = readU2();
            x.descriptor_index = readU2();
            x.index = readU2();
            xs[i] = x;
        }
        return xs;
    }

    private CodeAttribute codeAttribute() throws JVMException {
        CodeAttribute ca = new CodeAttribute();
        ca.max_stack = readU2();
        ca.max_locals = readU2();
        long code_length = readU4();
        if(code_length <= 0)
            throw new JVMException(ECode.EMPTY_CODE_LENGTH);
        ca.code_length = code_length;
        ca.code = readU1_n((int)code_length);

        int ext_length = readU2();
        ca.exception_table_length = ext_length;
        ca.exception_table = exceptionTable(ext_length);

        int attributes_cnt = readU2();
        ca.attributes_count = attributes_cnt;
        ca.attributes = attributes(attributes_cnt);
        return ca;
    }

    private Attribute_info[] attributes(int size) throws JVMException {
        Cp_info[] cps = cfile.constant_pool;
        Attribute_info[] as = new Attribute_info[size];
        for(int i = 0; i < size; i++) {
            int name_index = readU2();
            if(cps.length <= name_index) {
                System.out.println("invalid_name_index: " + name_index);
                throw new JVMException(ECode.CPOOL_ATTRIBUTE);
            }
            Cp_info cp = cps[name_index];
            if(cp.tag != CONSTANT_TAG.CONSTANT_Utf8) {
                throw new JVMException(ECode.CPOOL_ATTRIBUTE);
            }
            Attribute_info a = new Attribute_info();
            int length = (int)readU4();
            String s = cp.valueOfbytes_utf8();
            a.name = s;
            if(s.equals("ConstantValue")) {
                a.constantvalue_index = readU2();
            } else if(s.equals("Code")) {
                a.code_attribute = codeAttribute();
            } else if(s.equals("Exceptions")) {
                int number_of_exn = readU2();
                a.exception_index_table = readU2_n(number_of_exn);
            } else if(s.equals("InnerClasses")) {
                int number_of_cls = readU2();
                a.classes = classes(number_of_cls);
            } else if(s.equals("LineNumberTable")) {
                int lnt_len = readU2();
                a.line_number_table = lineNumberTable(lnt_len);
            } else if(s.equals("SourceFile")) {
                a.sourcefile_index = readU2();
            } else if(s.equals("LocalVariableTable")) {
                int lvt_len = readU2();
                a.local_variable_table = localVariableTable(lvt_len);
            } else if(!s.equals("Synthetic") && !s.equals("Deprecated")) {
                //System.out.println("unknown name: " + s + " length: " + length);
                a.others = readU1_n(length);
                /*
                throw new JVMException(ECode.CPOOL_ATTRIBUTE); */
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
            f.access_flags = readU2();
            f.name_index = readU2();
            f.descriptor_index = readU2();
            int alen = readU2();
            f.attributes_count = alen;
            f.attributes = attributes(alen);
            fms[i] = f;
        }
        return fms;
    }

    public void classParser() {
        try {
            if(!this.state)
                throw new JVMException(ECode.NOT_INITIALIZED);

            cfile = new ClassFile();
            long magic = readU4();
            if(magic != 0xcafebabeL) {
                throw new JVMException(ECode.INVALID_MAGIC);
            }
            cfile.magic = magic;
            cfile.minor_version = readU2();
            cfile.major_version = readU2();
            int cpool_cnt = readU2();
            cfile.constant_pool_count = cpool_cnt;
            cfile.constant_pool = constant_pool(cpool_cnt);;
            cfile.access_flags = readU2();
            cfile.this_class = readU2();
            cfile.super_class = readU2();
            int interfaces_cnt = readU2();
            cfile.interfaces_count = interfaces_cnt;
            cfile.interfaces = readU2_n(interfaces_cnt);
            int fields_cnt = readU2();
            cfile.fields_count = fields_cnt;
            cfile.fields = fields_methods(fields_cnt);
            int methods_cnt = readU2();
            cfile.methods_count = methods_cnt;
            cfile.methods = fields_methods(methods_cnt);
            int attrs_cnt = readU2();
            cfile.attributes_count = attrs_cnt;
            cfile.attributes = attributes(attrs_cnt);

            this.parsed_cfile = true;
            cfile.print();
        } catch(JVMException e) {
            this.parsed_cfile = false;
            System.out.println(e);
        }
    }

    public void jikkou() {
        try {
            if(!this.parsed_cfile)
                throw new JVMException(ECode.NOT_INITIALIZED);
        } catch(JVMException e) {
            System.out.println(e);
        }
    }

    public static void main(String[] args) {
        //JVM jvm = new JVM("Hello.class");
        JVM jvm = new JVM("TameikeSearch.class");
        jvm.classParser();
        // jvm.jikkou();
    }
}
