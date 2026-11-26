import javax.microedition.m3g.Transform;
import javax.microedition.m3g.VertexArray;

public final class TransformProbe {
    public static int result;

    public static void main(String[] arguments) {
        result = run();
        if (result != 42)
            throw new RuntimeException("M3G transform failed");
        System.out.println("M3G Transform + VertexArray: 42");
    }

    public static int run() {
        Transform matrix = new Transform();
        matrix.postTranslate(10.0f, 20.0f, 30.0f);
        matrix.postScale(2.0f, 3.0f, 4.0f);
        float[] vector = {1.0f, 2.0f, 3.0f, 1.0f};
        matrix.transform(vector);
        if (vector[0] != 12.0f || vector[1] != 26.0f || vector[2] != 42.0f || vector[3] != 1.0f)
            return 1;
        matrix.invert();
        matrix.transform(vector);
        if (vector[0] < 0.9999f || vector[0] > 1.0001f ||
            vector[1] < 1.9999f || vector[1] > 2.0001f ||
            vector[2] < 2.9999f || vector[2] > 3.0001f || vector[3] != 1.0f)
            return 2;
        Transform copy = new Transform(matrix);
        copy.postMultiply(matrix);
        float[] values = new float[16];
        copy.get(values);
        if (values[15] != 1.0f) return 3;
        VertexArray vertices = new VertexArray(2, 3, 2);
        short[] coordinates = {1, 2, 3, 4, 5, 6};
        vertices.set(0, 2, coordinates);
        if (vertices.getVertexCount() != 2 || vertices.getComponentCount() != 3 || vertices.getComponentType() != 2)
            return 4;
        Transform geometry = new Transform();
        geometry.postTranslate(10.0f, 20.0f, 30.0f);
        float[] transformed = new float[8];
        geometry.transform(vertices, transformed, true);
        if (transformed[0] != 11.0f || transformed[1] != 22.0f || transformed[2] != 33.0f || transformed[3] != 1.0f ||
            transformed[4] != 14.0f || transformed[5] != 25.0f || transformed[6] != 36.0f || transformed[7] != 1.0f)
            return 5;
        return 42;
    }
}
