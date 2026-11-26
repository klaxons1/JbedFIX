import java.util.ArrayList;
import java.util.Map;
import java.util.TreeMap;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import org.objectweb.asm.Attribute;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.FieldNode;
import org.objectweb.asm.tree.MethodNode;

public final class RomPreverifyTest {
    private static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static ClassNode roundtrip(ClassNode type) {
        ClassWriter writer = new ClassWriter(0);
        type.accept(writer);
        ClassNode read = new ClassNode();
        new ClassReader(writer.toByteArray()).accept(read, new Attribute[]{
            new RomPreverify.SavedAccess(0), new RomPreverify.Temporary(),
            new BootSubset.UnavailableMethods()}, 0);
        return read;
    }

    private static void noAdapterAttributes(java.util.List<Attribute> attributes) {
        if (attributes != null) for (Attribute attribute : attributes)
            check(!attribute.type.startsWith("JbedPreverify"), "Preverification marker leaked into ROM");
    }

    private static Map<String, Integer> declarations(String path) throws Exception {
        Map<String, Integer> declarations = new TreeMap<>();
        try (JarFile jar = new JarFile(path)) {
            for (JarEntry entry : java.util.Collections.list(jar.entries())) {
                if (!entry.getName().endsWith(".class")) continue;
                ClassNode type = new ClassNode();
                try (var input = jar.getInputStream(entry)) {
                    new ClassReader(input.readAllBytes()).accept(type, 0);
                }
                noAdapterAttributes(type.attrs);
                declarations.put(type.name, type.access);
                for (FieldNode field : type.fields) {
                    noAdapterAttributes(field.attrs);
                    declarations.put(type.name + " field " + field.name + " " + field.desc, field.access);
                }
                for (MethodNode method : type.methods) {
                    noAdapterAttributes(method.attrs);
                    declarations.put(type.name + " method " + method.name + " " + method.desc, method.access);
                }
            }
        }
        return declarations;
    }

    public static void main(String[] arguments) throws Exception {
        if (arguments.length == 2) {
            check(declarations(arguments[0]).equals(declarations(arguments[1])),
                "Preverification changed ROM declarations or access flags");
            System.out.println("All ROM class, field and method access flags restored");
            return;
        }
        check(arguments.length == 0, "Expected zero arguments or original/restored jars");
        ClassNode type = new ClassNode();
        type.version = Opcodes.V1_5;
        type.name = "fixture/Internal";
        type.superName = "java/lang/Object";
        type.access = Opcodes.ACC_FINAL | Opcodes.ACC_SUPER;
        int classAccess = type.access;
        int fieldAccess = Opcodes.ACC_PRIVATE | Opcodes.ACC_STATIC | Opcodes.ACC_FINAL;
        int methodAccess = Opcodes.ACC_PROTECTED | Opcodes.ACC_NATIVE | Opcodes.ACC_FINAL;
        type.fields.add(new FieldNode(fieldAccess, "value", "I", null, null));
        type.methods.add(new MethodNode(methodAccess, "internal", "()V", null, null));
        BootSubset.UnavailableMethods missing = new BootSubset.UnavailableMethods();
        missing.methods.add(new BootSubset.MissingMethod("<init>", "(J)V", 0));
        type.attrs = new ArrayList<>();
        type.attrs.add(missing);
        RomPreverify.prepare(type);
        check((type.access & Opcodes.ACC_PUBLIC) != 0, "class not exposed");
        check((type.fields.get(0).access & Opcodes.ACC_PRIVATE) == 0, "field still private");
        check((type.methods.get(0).access & Opcodes.ACC_PUBLIC) != 0, "method not exposed");
        check(type.methods.size() == 2, "metadata constructor not represented");
        check(type.methods.get(1).maxLocals == 3, "wide constructor argument slots");
        check(type.methods.get(1).instructions.getLast().getOpcode() == Opcodes.ATHROW,
            "facade must never return an uninitialized object");
        type = roundtrip(type);
        try {
            RomPreverify.prepare(type);
            throw new AssertionError("double preparation accepted");
        } catch (IllegalArgumentException expected) { }
        RomPreverify.restore(type);
        check(type.access == classAccess, "class flags changed");
        check(type.fields.get(0).access == fieldAccess, "field flags changed");
        check(type.methods.get(0).access == methodAccess, "method flags changed");
        check(type.methods.size() == 1, "temporary constructor leaked into runtime ROM");
        check(type.attrs.size() == 1 && type.attrs.get(0) instanceof BootSubset.UnavailableMethods,
            "original constructor metadata not preserved");
        try {
            RomPreverify.restore(type);
            throw new AssertionError("restoring an unprepared class accepted");
        } catch (IllegalArgumentException expected) { }
        System.out.println("ROM preverification access and initializer roundtrip passed");
    }
}
