import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;
import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.Type;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.AbstractInsnNode;
import org.objectweb.asm.tree.FrameNode;
import org.objectweb.asm.tree.VarInsnNode;
import org.objectweb.asm.tree.IincInsnNode;
import org.objectweb.asm.tree.JumpInsnNode;
import org.objectweb.asm.tree.TableSwitchInsnNode;
import org.objectweb.asm.tree.LookupSwitchInsnNode;
import org.objectweb.asm.tree.TryCatchBlockNode;
import org.objectweb.asm.tree.FieldNode;
import org.objectweb.asm.tree.InsnNode;
import org.objectweb.asm.tree.MethodNode;

/** Adapts privileged Jbed ROM declarations for standard CLDC preverification.
 * The adapted jar is never compiled into the ROM: restore must run first. */
public final class RomPreverify {
    private static final String ACCESS = "JbedPreverifyAccess";
    private static final String TEMPORARY = "JbedPreverifyTemporary";
    private static final int VISIBILITY = Opcodes.ACC_PUBLIC | Opcodes.ACC_PRIVATE | Opcodes.ACC_PROTECTED;

    static final class SavedAccess extends Attribute {
        final int access;
        SavedAccess(int access) { super(ACCESS); this.access = access; }
        @Override protected Attribute read(ClassReader reader, int offset, int length,
                char[] characters, int codeOffset, Label[] labels) {
            if (length != 2) throw new IllegalArgumentException("Invalid " + ACCESS);
            return new SavedAccess(reader.readUnsignedShort(offset));
        }
        @Override protected ByteVector write(ClassWriter writer, byte[] code,
                int length, int maxStack, int maxLocals) {
            return new ByteVector().putShort(access);
        }
    }

    static final class Temporary extends Attribute {
        Temporary() { super(TEMPORARY); }
        @Override protected Attribute read(ClassReader reader, int offset, int length,
                char[] characters, int codeOffset, Label[] labels) {
            if (length != 0) throw new IllegalArgumentException("Invalid " + TEMPORARY);
            return new Temporary();
        }
        @Override protected ByteVector write(ClassWriter writer, byte[] code,
                int length, int maxStack, int maxLocals) { return new ByteVector(); }
    }

    private static List<Attribute> save(List<Attribute> attributes, int access) {
        List<Attribute> result = attributes == null ? new ArrayList<>() : new ArrayList<>(attributes);
        for (Attribute attribute : result)
            if (attribute.type.equals(ACCESS) || attribute.type.equals(TEMPORARY))
                throw new IllegalArgumentException("ROM has already been prepared for preverification");
        result.add(new SavedAccess(access));
        return result;
    }

    private static int restore(List<Attribute> attributes) {
        if (attributes != null) for (Attribute attribute : attributes)
            if (attribute instanceof SavedAccess) {
                int access = ((SavedAccess)attribute).access;
                attributes.remove(attribute);
                return access;
            }
        throw new IllegalArgumentException("Missing saved ROM access flags");
    }

    private static boolean temporary(MethodNode method) {
        if (method.attrs != null) for (Attribute attribute : method.attrs)
            if (attribute instanceof Temporary) return true;
        return false;
    }

    private static int visible(int access) { return (access & ~VISIBILITY) | Opcodes.ACC_PUBLIC; }

    static void prepare(ClassNode type) {
        type.attrs = save(type.attrs, type.access);
        type.access = visible(type.access);
        for (FieldNode field : type.fields) {
            field.attrs = save(field.attrs, field.access);
            field.access = visible(field.access);
        }
        for (MethodNode method : type.methods) {
            method.attrs = save(method.attrs, method.access);
            if (!method.name.equals("<clinit>")) method.access = visible(method.access);
        }
        for (Attribute attribute : type.attrs) {
            if (!(attribute instanceof BootSubset.UnavailableMethods)) continue;
            for (BootSubset.MissingMethod missing : ((BootSubset.UnavailableMethods)attribute).methods) {
                if (!missing.name.equals("<init>") && !missing.name.equals("<clinit>"))
                    throw new IllegalArgumentException("Expected metadata-only initializer");
                if (missing.descriptor.isEmpty())
                    throw new IllegalArgumentException("Initializer descriptor is unavailable in " + type.name);
                MethodNode facade = new MethodNode((missing.flags & Opcodes.ACC_STATIC) | Opcodes.ACC_PUBLIC,
                    missing.name, missing.descriptor, null, null);
                if (facade.name.equals("<clinit>")) facade.access = Opcodes.ACC_STATIC;
                // A constructor may throw before invoking super. This body exists
                // only for ProGuard member resolution and is removed afterwards;
                // jbedrom creates the real native constructor from ROM metadata.
                facade.instructions.add(new InsnNode(Opcodes.ACONST_NULL));
                facade.instructions.add(new InsnNode(Opcodes.ATHROW));
                facade.maxStack = 1;
                facade.maxLocals = (facade.access & Opcodes.ACC_STATIC) == 0 ? 1 : 0;
                for (Type argument : Type.getArgumentTypes(facade.desc)) facade.maxLocals += argument.getSize();
                facade.attrs = new ArrayList<>();
                facade.attrs.add(new Temporary());
                type.methods.add(facade);
            }
        }
    }

    /** Forget dead register-bank aliases in generated frames. In particular,
     * ProGuard can retain an initialized constructor alias in a handler that
     * is also reached before initialization. TOP is valid only if no path
     * reads the slot before overwriting it; include exception continuations. */
    static void pruneDeadFrameLocals(MethodNode method) {
        AbstractInsnNode[] code = method.instructions.toArray();
        int n = code.length;
        if (n == 0) return;
        java.util.IdentityHashMap<AbstractInsnNode, Integer> index = new java.util.IdentityHashMap<>();
        for (int i = 0; i < n; ++i) index.put(code[i], i);
        java.util.BitSet[] live = new java.util.BitSet[n];
        List<List<Integer>> normal = new ArrayList<>(), exceptional = new ArrayList<>();
        for (int i = 0; i < n; ++i) {
            live[i] = new java.util.BitSet(method.maxLocals);
            List<Integer> next = new ArrayList<>(), handlers = new ArrayList<>();
            normal.add(next); exceptional.add(handlers);
            AbstractInsnNode instruction = code[i];
            int op = instruction.getOpcode();
            if (instruction instanceof JumpInsnNode) {
                if (op == Opcodes.JSR) throw new IllegalArgumentException("Unexpected JSR in recovered ROM");
                next.add(index.get(((JumpInsnNode)instruction).label));
                if (op != Opcodes.GOTO && i + 1 < n) next.add(i + 1);
            } else if (instruction instanceof TableSwitchInsnNode) {
                TableSwitchInsnNode table = (TableSwitchInsnNode)instruction;
                next.add(index.get(table.dflt));
                for (var label : table.labels) next.add(index.get(label));
            } else if (instruction instanceof LookupSwitchInsnNode) {
                LookupSwitchInsnNode table = (LookupSwitchInsnNode)instruction;
                next.add(index.get(table.dflt));
                for (var label : table.labels) next.add(index.get(label));
            } else if (op != Opcodes.ATHROW && (op < Opcodes.IRETURN || op > Opcodes.RETURN) && i + 1 < n) next.add(i + 1);
            if (op >= 0 && method.tryCatchBlocks != null) for (TryCatchBlockNode handler : method.tryCatchBlocks)
                if (i >= index.get(handler.start) && i < index.get(handler.end)) handlers.add(index.get(handler.handler));
        }
        boolean changed;
        do {
            changed = false;
            for (int i = n - 1; i >= 0; --i) {
                java.util.BitSet value = new java.util.BitSet(method.maxLocals);
                for (int successor : normal.get(i)) value.or(live[successor]);
                AbstractInsnNode instruction = code[i];
                int op = instruction.getOpcode();
                if (instruction instanceof VarInsnNode) {
                    int slot = ((VarInsnNode)instruction).var;
                    boolean wide = op == Opcodes.LLOAD || op == Opcodes.DLOAD || op == Opcodes.LSTORE || op == Opcodes.DSTORE;
                    if (op >= Opcodes.ISTORE && op <= Opcodes.ASTORE) value.clear(slot, slot + (wide ? 2 : 1));
                    else if (op >= Opcodes.ILOAD && op <= Opcodes.ALOAD) value.set(slot, slot + (wide ? 2 : 1));
                    else throw new IllegalArgumentException("Unexpected local opcode " + op);
                } else if (instruction instanceof IincInsnNode) value.set(((IincInsnNode)instruction).var);
                // Exception edges see locals before the instruction's store.
                for (int successor : exceptional.get(i)) value.or(live[successor]);
                if (!value.equals(live[i])) { live[i] = value; changed = true; }
            }
        } while (changed);
        for (int i = 0; i < n; ++i) if (code[i] instanceof FrameNode) {
            FrameNode frame = (FrameNode)code[i];
            if (frame.type != Opcodes.F_NEW && frame.type != Opcodes.F_FULL)
                throw new IllegalArgumentException("Expected expanded CLDC frames");
            List<Object> locals = new ArrayList<>();
            int slot = 0;
            if (frame.local != null) for (Object type : frame.local) {
                boolean wide = type.equals(Opcodes.LONG) || type.equals(Opcodes.DOUBLE);
                if (live[i].get(slot) || (wide && live[i].get(slot + 1))) locals.add(type);
                else { locals.add(Opcodes.TOP); if (wide) locals.add(Opcodes.TOP); }
                slot += wide ? 2 : 1;
            }
            while (!locals.isEmpty() && locals.get(locals.size() - 1).equals(Opcodes.TOP)) locals.remove(locals.size() - 1);
            frame.local = locals;
        }
    }

    static void restore(ClassNode type) {
        type.access = restore(type.attrs);
        for (FieldNode field : type.fields) field.access = restore(field.attrs);
        type.methods.removeIf(RomPreverify::temporary);
        for (MethodNode method : type.methods) {
            method.access = restore(method.attrs);
            pruneDeadFrameLocals(method);
        }
    }

    public static void main(String[] arguments) throws IOException {
        if (arguments.length != 3 || (!arguments[0].equals("prepare") && !arguments[0].equals("restore")))
            throw new IllegalArgumentException("RomPreverify prepare|restore INPUT.jar OUTPUT.jar");
        boolean prepare = arguments[0].equals("prepare");
        Path output = Path.of(arguments[2]);
        if (output.toAbsolutePath().equals(Path.of(arguments[1]).toAbsolutePath()))
            throw new IllegalArgumentException("Input and output jars must differ");
        Files.createDirectories(output.toAbsolutePath().getParent());
        try (JarFile input = new JarFile(arguments[1]);
             JarOutputStream jar = new JarOutputStream(Files.newOutputStream(output))) {
            for (JarEntry entry : java.util.Collections.list(input.entries())) {
                byte[] bytes;
                try (var stream = input.getInputStream(entry)) { bytes = stream.readAllBytes(); }
                if (entry.getName().endsWith(".class")) {
                    ClassNode type = new ClassNode();
                    new ClassReader(bytes).accept(type, new Attribute[]{new SavedAccess(0),
                        new Temporary(), new BootSubset.UnavailableMethods()}, ClassReader.EXPAND_FRAMES);
                    if (prepare) prepare(type); else restore(type);
                    ClassWriter writer = new ClassWriter(0);
                    type.accept(writer);
                    bytes = writer.toByteArray();
                }
                JarEntry result = new JarEntry(entry.getName());
                result.setTime(0);
                jar.putNextEntry(result);
                jar.write(bytes);
                jar.closeEntry();
            }
        }
    }
}
