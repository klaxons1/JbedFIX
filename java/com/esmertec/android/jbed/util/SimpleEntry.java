package com.esmertec.android.jbed.util;

import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class SimpleEntry<K, V> implements Map.Entry<K, V> {
    K key;
    V value;

    public SimpleEntry(K key, V value) {
        this.key = key;
        this.value = value;
    }

    @Override // java.util.Map.Entry
    public K getKey() {
        return this.key;
    }

    @Override // java.util.Map.Entry
    public V getValue() {
        return this.value;
    }

    @Override // java.util.Map.Entry
    public V setValue(V value) {
        V oldValue = this.value;
        this.value = value;
        return oldValue;
    }

    @Override // java.util.Map.Entry
    public boolean equals(Object o) {
        if (!(o instanceof Map.Entry)) {
            return false;
        }
        Map.Entry e = (Map.Entry) o;
        return eq(this.key, e.getKey()) && eq(this.value, e.getValue());
    }

    @Override // java.util.Map.Entry
    public int hashCode() {
        return (this.key == null ? 0 : this.key.hashCode()) ^ (this.value == null ? 0 : this.value.hashCode());
    }

    public String toString() {
        return this.value.toString();
    }

    static boolean eq(Object o1, Object o2) {
        if (o1 == null) {
            return o2 == null;
        }
        return o1.equals(o2);
    }
}
