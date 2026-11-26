package org.jbed.source;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.view.Surface;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/** Font rasterization and surface presentation for the source runtime. */
public final class JbedGraphics {
    private JbedGraphics() {}

    public static native void attach(Surface surface, String framebufferPath, int width, int height);
    public static native void detach();
    public static native void repaint(int width, int height, int stride);

    public static int getFontSize() {
        return 14 | (18 << 8) | (22 << 16);
    }

    // Called once for each distinct native font configuration.
    public static Font createFont(int family, int style, float size, float skew,
                                  boolean underline, boolean antialias) {
        return new Font(family, style, size, skew, underline, antialias);
    }

    public static final class Glyph {
        public final Bitmap bitmap;
        public final int left;
        public final int top;

        Glyph(Bitmap bitmap, int left, int top) {
            this.bitmap = bitmap;
            this.left = left;
            this.top = top;
        }
    }

    public static final class Font {
        private static final int CACHE_PIXELS = 65536;
        private final Paint paint;
        public final float[] metrics;
        private final LinkedHashMap<String, Glyph> cache =
                new LinkedHashMap<String, Glyph>(16, 0.75f, true);
        private int cachedPixels;

        Font(int family, int style, float size, float skew, boolean underline, boolean antialias) {
            paint = new Paint();
            String name = family == 1 ? "monospace" : family == 2 ? "serif" : "sans-serif";
            paint.setTypeface(Typeface.create(name, style));
            paint.setTextSize(size);
            paint.setTextSkewX(skew);
            paint.setUnderlineText(underline);
            paint.setAntiAlias(antialias);
            paint.setColor(Color.WHITE);
            Paint.FontMetrics fm = paint.getFontMetrics();
            metrics = new float[] {fm.top, fm.ascent, fm.descent, fm.bottom, fm.leading};
        }

        public synchronized float measure(String text) {
            return paint.measureText(text);
        }

        public synchronized Glyph rasterize(String text, int left, int top, int right, int bottom) {
            Glyph hit = cache.get(text);
            if (hit != null) return hit;
            Rect bounds = new Rect();
            paint.getTextBounds(text, 0, text.length(), bounds);
            if (paint.isUnderlineText()) {
                bounds.union(0, 0, (int) Math.ceil(paint.measureText(text)),
                        (int) Math.ceil(metrics[2]) + 2);
            }
            if (bounds.isEmpty()) return null;
            bounds.inset(-2, -2);
            boolean complete = left <= bounds.left && top <= bounds.top
                    && right >= bounds.right && bottom >= bounds.bottom;
            if (!bounds.intersect(left, top, right, bottom)) return null;
            Bitmap bitmap = Bitmap.createBitmap(bounds.width(), bounds.height(), Bitmap.Config.ARGB_8888);
            new Canvas(bitmap).drawText(text, -bounds.left, -bounds.top, paint);
            Glyph glyph = new Glyph(bitmap, bounds.left, bounds.top);
            int pixels = bounds.width() * bounds.height();
            if (complete && pixels <= CACHE_PIXELS) {
                Iterator<Map.Entry<String, Glyph>> iterator = cache.entrySet().iterator();
                while ((cache.size() >= 16 || cachedPixels + pixels > CACHE_PIXELS) && iterator.hasNext()) {
                    Bitmap old = iterator.next().getValue().bitmap;
                    cachedPixels -= old.getWidth() * old.getHeight();
                    iterator.remove();
                }
                cache.put(text, glyph);
                cachedPixels += pixels;
            }
            return glyph;
        }
    }
}
