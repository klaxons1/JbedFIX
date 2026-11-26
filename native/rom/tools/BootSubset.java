import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.charset.StandardCharsets;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.Label;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.tree.AbstractInsnNode;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.FieldInsnNode;
import org.objectweb.asm.tree.MethodInsnNode;
import org.objectweb.asm.tree.MethodNode;
import org.objectweb.asm.tree.TypeInsnNode;

/** Keeps ROM layouts and bytecode reachable by a program and native callbacks. */
public final class BootSubset {
    private static final class MissingMethod {
        final String name, descriptor;
        final int flags;
        MissingMethod(String name, String descriptor, int flags) {
            this.name = name;
            this.descriptor = descriptor;
            this.flags = flags;
        }
    }

    private static final class UnavailableMethods extends Attribute {
        final ArrayList<MissingMethod> methods = new ArrayList<>();
        UnavailableMethods() { super("JbedUnavailableMethods"); }

        @Override protected Attribute read(ClassReader reader, int offset, int length,
                char[] characters, int codeOffset, Label[] labels) {
            if (length < 4 || reader.readUnsignedShort(offset) != 1)
                throw new IllegalArgumentException("Unsupported JbedUnavailableMethods attribute");
            UnavailableMethods result = new UnavailableMethods();
            int end = offset + length, count = reader.readUnsignedShort(offset + 2);
            offset += 4;
            for (int i = 0; i < count; ++i) {
                String[] values = new String[2];
                for (int j = 0; j < values.length; ++j) {
                    if (offset + 2 > end) throw new IllegalArgumentException("Truncated missing method");
                    int size = reader.readUnsignedShort(offset);
                    offset += 2;
                    if (offset + size > end) throw new IllegalArgumentException("Truncated missing method name");
                    byte[] bytes = new byte[size];
                    for (int k = 0; k < size; ++k) bytes[k] = (byte)reader.readByte(offset + k);
                    values[j] = new String(bytes, StandardCharsets.UTF_8);
                    offset += size;
                }
                if (offset + 4 > end) throw new IllegalArgumentException("Truncated missing method flags");
                result.methods.add(new MissingMethod(values[0], values[1], reader.readInt(offset)));
                offset += 4;
            }
            if (offset != end) throw new IllegalArgumentException("Unexpected missing method data");
            return result;
        }

        @Override protected ByteVector write(ClassWriter writer, byte[] code,
                int length, int maxStack, int maxLocals) {
            ByteVector output = new ByteVector().putShort(1).putShort(methods.size());
            for (MissingMethod method : methods) {
                for (String value : new String[]{method.name, method.descriptor}) {
                    byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
                    output.putShort(bytes.length).putByteArray(bytes, 0, bytes.length);
                }
                output.putInt(method.flags);
            }
            return output;
        }
    }

    private final Map<String, ClassNode> classes = new TreeMap<>();
    private final Set<String> selected = new HashSet<>();
    private final Set<String> bindings = new HashSet<>();
    private final Set<String> instantiated = new HashSet<>();
    private final ArrayDeque<String> pending = new ArrayDeque<>();
    private final ArrayList<MethodInsnNode> virtualCalls = new ArrayList<>();

    private static String key(String owner, String name, String descriptor) {
        return owner + " " + name + " " + descriptor;
    }

    private void add(String owner, String name, String descriptor) {
        ClassNode type = classes.get(owner);
        if (type == null) return;
        for (MethodNode method : type.methods) {
            if (!method.name.equals(name) || !method.desc.equals(descriptor)) continue;
            String entry = key(owner, name, descriptor);
            if (selected.add(entry)) pending.add(entry);
            return;
        }
        if (type.attrs != null) for (Attribute attribute : type.attrs) {
            if (!(attribute instanceof UnavailableMethods)) continue;
            for (MissingMethod method : ((UnavailableMethods)attribute).methods) {
                if (!method.name.equals(name) || !method.descriptor.equals(descriptor)) continue;
                String entry = key(owner, name, descriptor);
                if (selected.add(entry)) pending.add(entry);
                return;
            }
        }
        if (!name.startsWith("<") && type.superName != null)
            add(type.superName, name, descriptor);
    }

    private void initialize(String owner) {
        add(owner, "<clinit>", "()V");
        ClassNode type = classes.get(owner);
        if (type != null && type.superName != null) initialize(type.superName);
    }

    private boolean hasSelected(String owner, String name, String descriptor) {
        if (selected.contains(key(owner, name, descriptor))) return true;
        ClassNode type = classes.get(owner);
        return !name.startsWith("<") && type != null && type.superName != null &&
            hasSelected(type.superName, name, descriptor);
    }

    private boolean subtype(String owner, String target) {
        if (owner.equals(target)) return true;
        ClassNode type = classes.get(owner);
        if (type == null) return false;
        if (type.superName != null && subtype(type.superName, target)) return true;
        for (String implemented : type.interfaces)
            if (subtype(implemented, target)) return true;
        return false;
    }

    private void instantiate(String owner) {
        initialize(owner);
        if (!instantiated.add(owner)) return;
        add(owner, "finalize", "()V");
        for (MethodInsnNode call : virtualCalls)
            if (subtype(owner, call.owner)) add(owner, call.name, call.desc);
    }

    private void root(String owner, String name, String descriptor, boolean virtual) {
        initialize(owner);
        add(owner, name, descriptor);
        if (!hasSelected(owner, name, descriptor))
            throw new IllegalArgumentException("Unknown ROM root " + key(owner, name, descriptor));
        ClassNode type = classes.get(owner);
        if (type == null) return;
        if (virtual) {
            MethodInsnNode call = new MethodInsnNode((type.access & Opcodes.ACC_INTERFACE) != 0
                ? Opcodes.INVOKEINTERFACE : Opcodes.INVOKEVIRTUAL, owner, name, descriptor,
                (type.access & Opcodes.ACC_INTERFACE) != 0);
            virtualCalls.add(call);
            for (String instantiatedType : instantiated)
                if (subtype(instantiatedType, owner)) add(instantiatedType, name, descriptor);
        }
        if ((type.access & (Opcodes.ACC_ABSTRACT | Opcodes.ACC_INTERFACE)) == 0)
            for (MethodNode method : type.methods)
                if (method.name.equals(name) && method.desc.equals(descriptor) &&
                        (method.access & Opcodes.ACC_STATIC) == 0) instantiate(owner);
    }

    private void startup() {
        root("com/jbed/runtime/Isolate", "initIsolate", "()V", false);
        root("com/jbed/runtime/Isolate", "activate", "()V", false);
        root("com/jbed/runtime/Isolate", "deactivate", "()Z", false);
        root("com/jbed/runtime/Isolate", "run", "()V", false);
        root("java/lang/Thread", "run", "()V", true);
        root("com/jbed/runtime/IsolateContext", "run", "()V", true);
        root("com/jbed/runtime/Scheduled", "destroy0", "()V", false);
        root("com/jbed/runtime/Isolate", "uncaughtException", "(Ljava/lang/Throwable;)V", false);
        root("com/jbed/runtime/Isolate", "quit", "(I)V", false);
        root("java/lang/Throwable", "printStackTrace", "()V", true);
        root("com/jbed/reflect/ClassAccess$ClassIterator", "<init>",
            "(Lcom/jbed/reflect/ClassAccess;Z)V", false);
        root("com/jbed/reflect/ClassAccess$ClassIterator", "reset", "()V", false);
        root("com/jbed/reflect/ClassAccess$ClassIterator", "nextClass", "()Ljava/lang/Class;", false);
    }

    private ClassNode read(byte[] bytes) {
        ClassNode type = new ClassNode();
        new ClassReader(bytes).accept(type, new Attribute[]{new UnavailableMethods()}, 0);
        classes.put(type.name, type);
        return type;
    }

    private void follow() {
        while (!pending.isEmpty()) {
            String entry = pending.remove();
            String[] parts = entry.split(" ", 3);
            if (bindings.contains(entry)) continue;
            MethodNode body = null;
            for (MethodNode method : classes.get(parts[0]).methods)
                if (method.name.equals(parts[1]) && method.desc.equals(parts[2])) body = method;
            if (body == null)
                throw new IllegalArgumentException("Missing source binding for " + entry);
            for (AbstractInsnNode instruction : body.instructions) {
                if (instruction instanceof MethodInsnNode) {
                    MethodInsnNode call = (MethodInsnNode) instruction;
                    add(call.owner, call.name, call.desc);
                    if (call.getOpcode() == Opcodes.INVOKESTATIC) initialize(call.owner);
                    if (call.getOpcode() == Opcodes.INVOKEVIRTUAL || call.getOpcode() == Opcodes.INVOKEINTERFACE) {
                        virtualCalls.add(call);
                        for (String owner : instantiated)
                            if (subtype(owner, call.owner)) add(owner, call.name, call.desc);
                    }
                } else if (instruction instanceof FieldInsnNode) {
                    FieldInsnNode field = (FieldInsnNode) instruction;
                    if (field.getOpcode() == Opcodes.GETSTATIC || field.getOpcode() == Opcodes.PUTSTATIC)
                        initialize(field.owner);
                } else if (instruction instanceof TypeInsnNode && instruction.getOpcode() == Opcodes.NEW) {
                    instantiate(((TypeInsnNode) instruction).desc);
                }
            }
        }
    }

    private void write(Path output) throws IOException {
        Files.createDirectories(output.toAbsolutePath().getParent());
        try (JarOutputStream jar = new JarOutputStream(Files.newOutputStream(output))) {
            for (ClassNode type : classes.values()) {
                type.methods.removeIf(method -> !selected.contains(key(type.name, method.name, method.desc)));
                if (type.attrs != null) type.attrs.removeIf(attribute -> {
                    if (!(attribute instanceof UnavailableMethods)) return false;
                    UnavailableMethods missing = (UnavailableMethods)attribute;
                    missing.methods.removeIf(method -> !selected.contains(key(type.name, method.name, method.descriptor)));
                    return missing.methods.isEmpty();
                });
                for (MethodNode method : type.methods) {
                    if (!bindings.contains(key(type.name, method.name, method.desc)) || method.name.startsWith("<"))
                        continue;
                    method.access = (method.access | Opcodes.ACC_NATIVE) & ~Opcodes.ACC_ABSTRACT;
                    method.instructions.clear();
                    method.tryCatchBlocks.clear();
                    if (method.localVariables != null) method.localVariables.clear();
                }
                ClassWriter writer = new ClassWriter(0);
                type.accept(writer);
                JarEntry entry = new JarEntry(type.name + ".class");
                entry.setTime(0);
                jar.putNextEntry(entry);
                jar.write(writer.toByteArray());
                jar.closeEntry();
            }
        }
        System.out.println("ROM subset: " + selected.size() + " methods, " + classes.size() + " class layouts");
    }

    public static void main(String[] arguments) throws IOException {
        if (arguments.length < 4)
            throw new IllegalArgumentException("BootSubset RUNTIME.jar NATIVE.bindings OUTPUT.jar CALLER.class | --startup | --root OWNER NAME DESCRIPTOR | --virtual-root OWNER NAME DESCRIPTOR [...]");
        BootSubset subset = new BootSubset();
        try (JarFile jar = new JarFile(arguments[0])) {
            for (JarEntry entry : java.util.Collections.list(jar.entries())) {
                if (!entry.getName().endsWith(".class")) continue;
                try (InputStream input = jar.getInputStream(entry)) {
                    subset.read(input.readAllBytes());
                }
            }
        }
        for (String line : Files.readAllLines(Path.of(arguments[1]))) {
            String[] words = line.trim().split("\\s+");
            if (words.length >= 4 && !words[0].startsWith("#") && !words[0].equals("field"))
                subset.bindings.add(key(words[0], words[1], words[2]));
        }
        for (int i = 3; i < arguments.length; ++i) {
            if (arguments[i].equals("--startup")) {
                subset.startup();
                continue;
            }
            if (arguments[i].equals("--root") || arguments[i].equals("--virtual-root")) {
                boolean virtual = arguments[i].equals("--virtual-root");
                if (i + 3 >= arguments.length) throw new IllegalArgumentException("--root requires owner, name and descriptor");
                String owner = arguments[++i], name = arguments[++i], descriptor = arguments[++i];
                subset.root(owner, name, descriptor, virtual);
                continue;
            }
            ClassNode caller = subset.read(Files.readAllBytes(Path.of(arguments[i])));
            for (MethodNode method : caller.methods) subset.add(caller.name, method.name, method.desc);
        }
        subset.add("java/lang/Object", "<init>", "()V");
        for (String owner : subset.classes.keySet())
            if (subset.subtype(owner, "java/lang/Throwable")) subset.add(owner, "<init>", "()V");
        subset.follow();
        subset.write(Path.of(arguments[2]));
    }
}
