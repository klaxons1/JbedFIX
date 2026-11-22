package com.google.android.collect;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;

/** Compatibility replacement for the hidden Android framework Lists helper. */
public final class Lists {
    private Lists() { }
    public static <E> ArrayList<E> newArrayList() { return new ArrayList<E>(); }
    public static <E> ArrayList<E> newArrayList(E... elements) {
        return new ArrayList<E>(Arrays.asList(elements));
    }
    public static <E> ArrayList<E> newArrayList(Collection<? extends E> elements) {
        return new ArrayList<E>(elements);
    }
}
