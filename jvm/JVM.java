// Read byte code
// $ java -'Dfile.encoding=ISO8859_1' JVM
// $ javac -J-'Dfile.encoding=UTF8' JVM.java
// $ javap -v Hello.class
/* import java.util.Arrays;
   import java.util.Stack; */
import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.file.*;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

// ------------------------///
//  Exception for JVM
// ------------------------///
enum ECode {
    ASSERT_ERROR,
    CPOOL_ATTRIBUTE,
    EMPTY_CODE_LENGTH,
    INVALID_CPOOL_INDEX,
    INVALID_INDEX,
    INVALID_MAGIC,
    INVALID_TAG_VALUE,
    INVALID_UTF8,
    NOT_INITIALIZED,
    NO_MAIN_FUNC,
    OPERAND_ERROR,
    TYPEF_ERROR,
    UNDEFINED_OP;
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
        case ASSERT_ERROR:
            s = "assertion error";
            break;
        case CPOOL_ATTRIBUTE:
            s = "reference to unknown constant_pool by attribute";
            break;
        case EMPTY_CODE_LENGTH:
            s = "code length in CodeAttribute is Empty";
            break;
        case INVALID_CPOOL_INDEX:
            s = "reference to non-exists constant-pool";
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
        case INVALID_UTF8:
            s = "cannot convert bytes into utf8 codes";
            break;
        case NOT_INITIALIZED:
            s = "Not initialized class file data.";
            break;
        case NO_MAIN_FUNC:
            s = "There is no main function";
            break;
        case OPERAND_ERROR:
            s = "No valid operand";
            break;
        case TYPEF_ERROR:
            s = "Type format error";
            break;
        case UNDEFINED_OP:
            s = "Operator is undefined yet";
            break;
        }
        return s;
    }
}

enum CONSTANT_TAG {
    Class(7),
    Fieldref(9),
    Methodref(10),
    InterfaceMethodref(11),
    String(8),
    Integer(3),
    Float(4),
    Long(5),
    Double(6),
    NameAndType(12),
    Utf8(1),
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
    private byte[] data;
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
            this.data = Files.readAllBytes(src);
            this.len = this.data.length;
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
        String label;

        public String toString() {
            StringBuilder s = new StringBuilder();
            s.append(tag);
            s.append('{');
            switch(tag) {
            case Class:
                s.append(name_index);
                break;
            case Fieldref:
            case Methodref:
            case InterfaceMethodref:
                s.append(class_index);
                s.append(',');
                s.append(name_and_type_index);
                break;
            case String:
                s.append(string_index);
                break;
            case Integer:
            case Float:
                s.append(bytes);
                break;
            case Long:
            case Double:
                s.append(high_bytes);
                s.append(',');
                s.append(low_bytes);
                break;
            case NameAndType:
                s.append(name_index);
                s.append(',');
                s.append(descriptor_index);
                break;
            case Utf8:
                s.append(label);
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
        int[] code;
        Exception_info[] exception_table;
        Attribute_info[] attributes;
        public String toString() {
            return "{" + max_stack + ", " + max_locals + ", code: " +
                Arrays.toString(code) + ", exception_table:" +
                Arrays.toString(exception_table) + ", attributes: " +
                util.Arrays.toString(attributes) + "}";
        }
    }

    class Attribute_info {
        String name;
        int attribute_name_index;
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
                attribute_name_index + ", " + s + "}";
        }
    }

    // field_info, method_info
    class FM_info {
        int access_flags;
        int name_index;
        int descriptor_index;
        Attribute_info[] attributes;

        @Override
        public String toString() {
            return ("FM_info{" + access_flags + ", " + name_index + ", " +
                    descriptor_index + ", attributes:" +
                    util.Arrays.toString(attributes) + "}");
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
        int[] interfaces;
        FM_info[] fields;
        FM_info[] methods;
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
            s.append(t("interfaces") + util.Arrays.toString(interfaces));
            s.append(t("fields") + util.Arrays.toString(fields));
            s.append(t("methods") + util.Arrays.toString(methods));
            s.append(t("attributes") + util.Arrays.toString(attributes));
            s.append("\n}");
            System.out.println(s);
        }
    }

    // receives byte size (1 ~ 4)
    private long read(int bsize) throws JVMException {
        int nptr = this.ptr + bsize;
        long val = 0;
        if (this.len <= nptr - 1)
            throw new JVMException(ECode.INVALID_INDEX);
        for(int i = this.ptr; i < nptr; i++) {
            byte b = this.data[i];
            int n = 0xFF & b;
            val = (val << 8) | n;
        }
        this.ptr = nptr;
        return val;
    }
    private byte[] read_bytes(int bsize) throws JVMException {
        int nptr = this.ptr + bsize;
        byte[] b = new byte[bsize];
        for(int i = this.ptr; i < nptr; i++)
            b[i - this.ptr] = this.data[i];
        this.ptr = nptr;
        return b;
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
            case Class:
                c.name_index = readU2();
                break;
            case Fieldref:
            case Methodref:
            case InterfaceMethodref:
                c.class_index = readU2();
                c.name_and_type_index = readU2();
                break;
            case String:
                c.string_index = readU2();
                break;
            case Integer:
            case Float:
                c.bytes = readU4();
                break;
            case Long:
            case Double:
                c.high_bytes = readU4();
                c.low_bytes = readU4();
                break;
            case NameAndType:
                c.name_index = readU2();
                c.descriptor_index = readU2();
                break;
            case Utf8:
                try {
                    int length = readU2();
                    byte[] utf8 = read_bytes(length);
                    c.label = new String(utf8, "UTF-8");
                    System.out.println(c.label);
                } catch(UnsupportedEncodingException e) {
                    throw new JVMException(ECode.INVALID_UTF8);
                }
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
        ca.code = readU1_n((int)code_length);

        int ext_length = readU2();
        ca.exception_table = exceptionTable(ext_length);

        int attributes_cnt = readU2();
        ca.attributes = attributes(attributes_cnt);
        return ca;
    }

    private Attribute_info[] attributes(int size) throws JVMException {
        Cp_info[] cps = cfile.constant_pool;
        Attribute_info[] as = new Attribute_info[size];
        for(int i = 0; i < size; i++) {
            int name_index = readU2();
            Cp_info cp = getConstantPool(name_index);
            if(cp.tag != CONSTANT_TAG.Utf8) {
                throw new JVMException(ECode.CPOOL_ATTRIBUTE);
            }
            Attribute_info a = new Attribute_info();
            a.attribute_name_index = name_index;
            int length = (int)readU4();
            String s = cp.label;
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
                System.out.println("unknown name: " + s + " length: " + length);
                a.others = readU1_n(length);
            }
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
            cfile.interfaces = readU2_n(interfaces_cnt);
            int fields_cnt = readU2();
            cfile.fields = fields_methods(fields_cnt);
            int methods_cnt = readU2();
            cfile.methods = fields_methods(methods_cnt);
            int attrs_cnt = readU2();
            cfile.attributes = attributes(attrs_cnt);

            this.parsed_cfile = true;
            cfile.print();
        } catch(JVMException e) {
            this.parsed_cfile = false;
            System.out.println(e);
        }
    }

    private Cp_info getConstantPool(int index) throws JVMException {
        Cp_info[] cps = cfile.constant_pool;
        if(cps.length <= index)
            throw new JVMException(ECode.INVALID_CPOOL_INDEX);
        return cps[index];
    }

    // ++++++++++++++++++
    //   jikkou
    // ++++++++++++++++++
    private int[] getMainCode() throws JVMException {
        FM_info[] methods = cfile.methods;
        for(int i = 0; i < methods.length; i++) {
            FM_info method = methods[i];
            int index = method.name_index;
            Cp_info cp = getConstantPool(index);
            String s = cp.label;
            if(s.equals("main"))
                return method.attributes[0].code_attribute.code;
        }
        throw new JVMException(ECode.NO_MAIN_FUNC);
    }
    
    private Class[] getClassesByFType(String s) throws JVMException {
        if(s.charAt(0) != '(')
            throw new JVMException(ECode.TYPEF_ERROR);
        List<Class> clst = new ArrayList<Class>();
        int length = s.length();
        int i = 1;
        while(i < length) {
            char c = s.charAt(i);
            if(c == ')')
                break;

            switch (c) {
            case 'B':
                clst.add(byte.class);
                break;
            case 'C':
                clst.add(char.class);
                break;
            case 'D':
                clst.add(double.class);
                break;
            case 'F':
                clst.add(float.class);
                break;
            case 'I':
                clst.add(int.class);
                break;
            case 'J':
                clst.add(long.class);
                break;
            case 'S':
                clst.add(short.class);
                break;
            case 'Z':
                clst.add(boolean.class);
                break;
            case 'L':
                try {
                    int n = i + 1;
                    while(s.charAt(i) != ';')
                        i++;
                    String className = s.substring(n, i);
                    Class cls = Class.forName(className.replaceAll("/", "."));
                    clst.add(cls);
                } catch(ClassNotFoundException e) {
                    throw new JVMException(ECode.TYPEF_ERROR);
                }
                break;
            case '[':
                try {
                    int n = i;
                    while(s.charAt(i) == '[')
                        i++;
                    if(s.charAt(i) == 'L') {
                        while(s.charAt(i) != ';')
                            i++;
                    } else {
                        i++;
                    }
                    String className = s.substring(n, i);
                    Class cls = Class.forName(className.replaceAll("/", "."));
                    clst.add(cls);
                } catch(ClassNotFoundException e) {
                    throw new JVMException(ECode.TYPEF_ERROR);
                }
            }
            i++;
        }
        return clst.toArray(new Class[clst.size()]);
    }

    private void assertEq(Object a, Object b) throws JVMException {
        if(a != b)
            throw new JVMException(ECode.ASSERT_ERROR);
    }

    private void codeJikkou(int[] code) throws JVMException {
        Stack stk = new Stack();
        int index, i = 0;
        int length = code.length;
        while(i < length) {
            System.out.println("VM loop ip=" + i + " op=" + code[i] +
                               " stk_size=" + stk.size());
            switch(code[i]) {
            case 178: // getstatic 222
                index = (code[i + 1] << 8) | code[i + 2];
                i = i + 3;
                Cp_info field_ref = getConstantPool(index);
                assertEq(field_ref.tag, CONSTANT_TAG.Fieldref);
                Cp_info cls = getConstantPool(field_ref.class_index);
                assertEq(cls.tag, CONSTANT_TAG.Class);
                Cp_info name_and_type =
                    getConstantPool(field_ref.name_and_type_index);
                assertEq(name_and_type.tag, CONSTANT_TAG.NameAndType);
                Cp_info cls_desc = getConstantPool(cls.name_index);
                assertEq(cls_desc.tag, CONSTANT_TAG.Utf8);
                String cls_name = cls_desc.label;
                Cp_info field_desc = getConstantPool(name_and_type.name_index);
                assertEq(field_desc.tag, CONSTANT_TAG.Utf8);
                String field_name = field_desc.label;

                System.out.println("[getstatic] " + cls_name + ", " + field_name);
                try {
                    Class c = Class.forName(cls_name.replaceAll("/", "."));
                    Field f = c.getField(field_name);
                    System.out.println("[getstatic] " + c + ", " + f);
                    // // import java.lang.reflect.Modifier;
                    // Modifier.isStatic(f.getModifiers())
                    Object o = f.get(c);
                    System.out.println(o);
                    stk.push(o);
                } catch (ClassNotFoundException e) {
                    System.out.println("[getstatic] error " + e);
                } catch (NoSuchFieldException e) {
                    System.out.println("[getstatic] error " + e);
                } catch (IllegalAccessException e) {
                    System.out.println("[getstatic] error " + e);
                }
                break;
            case 182: // invokevirtual 257
                index = (code[i + 1] << 8) | code[i + 2];
                i = i + 3;
                Cp_info method_ref = getConstantPool(index);
                assertEq(method_ref.tag, CONSTANT_TAG.Methodref);
                Cp_info cls2 = getConstantPool(method_ref.class_index);
                assertEq(cls2.tag, CONSTANT_TAG.Class);
                Cp_info name_and_type2 =
                    getConstantPool(method_ref.name_and_type_index);
                assertEq(name_and_type2.tag, CONSTANT_TAG.NameAndType);
                Cp_info cls_desc2 = getConstantPool(cls2.name_index);
                assertEq(cls_desc2.tag, CONSTANT_TAG.Utf8);
                String cls_name2 = cls_desc2.label;
                Cp_info method_desc = getConstantPool(name_and_type2.name_index);
                assertEq(method_desc.tag, CONSTANT_TAG.Utf8);
                String method_name = method_desc.label;
                Cp_info method_desc2 = getConstantPool(name_and_type2.descriptor_index);
                assertEq(method_desc2.tag, CONSTANT_TAG.Utf8);
                String method_type = method_desc2.label;
                System.out.println("[invokevirtual] " +
                                   cls_name2 + " " + method_name + " " + method_type);
                try {
                    Class c = Class.forName(cls_name2.replaceAll("/", "."));
                    Class[] args_clss = getClassesByFType(method_type);
                    Method m = c.getMethod(method_name, args_clss);
                    System.out.println("[invokevirtual] " + c + ", " + m);

                    int argc = args_clss.length;
                    Object[] args = new Object[argc];
                    for(int k = argc - 1; 0 <= k; k--) {
                        Object o1 = stk.pop();
                        Class c1 = args_clss[k];
                        if(!c1.equals(o1.getClass()))
                            throw new JVMException(ECode.OPERAND_ERROR);
                        args[k] = o1;
                    }
                    Object mobj = stk.pop();
                    m.invoke(mobj, args);
                } catch (ClassNotFoundException e) {
                    System.out.println("[invokevirtual] error " + e);
                } catch (NoSuchMethodException e) {
                    System.out.println("[invokevirtual] error " + e);
                } catch (IllegalAccessException e) {
                    System.out.println("[invokevirtual] error " + e);
                } catch (InvocationTargetException e) {
                System.out.println("[invokevirtual] error " + e);
                }
                break;
            case 18:  // ldc 281
                index = code[i + 1];
                i = i + 2;
                Cp_info cp = getConstantPool(index);
                CONSTANT_TAG tag = cp.tag;
                switch(tag) {
                case Integer:
                    long val = cp.bytes;
                    System.out.println("[ldc] " + val);
                    stk.push(val);
                    break;
                    /* case Float:
                       long bits = cp.bytes;
                       float f;
                       if(bits == 0x7f800000)
                       f = Float.POSITIVE_INFINITY;
                       else if(bits == 0xff800000)
                       f = Float.NEGATIVE_INFINITY;
                       else if((0x7f800001 <= bits && bits <= 0x7fffffff) ||
                       (0xff800001 <= bits && bits <= 0xffffffff))
                       f = Float.NaN;
                       else {
                       int s = (((int)(bits >> 31)) == 0) ? 1 : -1;
                       int e = ((int)(bits >> 23)) & 0xff;
                       int m = (e == 0) ?
                       (bits & 0x7fffff) << 1 : (bits & 0x7fffff) | 0x800000;
                       f = s * m * (float)Math.pow(2, e - 150);
                       }
                       System.out.println("[ldc] " + f);
                       stk.push(f);
                       break;*/
                case String:
                    Cp_info string_desc = getConstantPool(cp.string_index);
                    assertEq(string_desc.tag, CONSTANT_TAG.Utf8);
                    System.out.println("[ldc] " + string_desc.label);
                    stk.push(string_desc.label);
                    break;
                default:
                    throw new JVMException(ECode.OPERAND_ERROR);
                }
                break;
            case 177: // return 319
                i++;
                if(i == length - 1)
                    throw new JVMException(ECode.OPERAND_ERROR);
                break;
            default:
                System.out.println(code[i]);
                throw new JVMException(ECode.UNDEFINED_OP);
            }
        }
    }

    public void jikkou() {
        try {
            if(!this.parsed_cfile)
                throw new JVMException(ECode.NOT_INITIALIZED);
            int[] code = getMainCode();
            codeJikkou(code);
        } catch(JVMException e) {
            System.out.println(e);
        }
    }

    public static void main(String[] args) {
        JVM jvm = new JVM("Hello.class");
        //JVM jvm = new JVM("TameikeSearch.class");
        jvm.classParser();
        jvm.jikkou();
    }
}
