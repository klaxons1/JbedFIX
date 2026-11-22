package com.esmertec.android.jbed.util;

import java.io.File;
import java.io.FilenameFilter;

/* JADX INFO: loaded from: classes.dex */
public class FileUtil {

    public static class PrefixFilenameFilter implements FilenameFilter {
        private String mPrefix;

        public PrefixFilenameFilter(String prefix) {
            this.mPrefix = prefix;
        }

        @Override // java.io.FilenameFilter
        public boolean accept(File f, String fileName) {
            return fileName.startsWith(this.mPrefix);
        }
    }

    public static void cleanFiles(String dirName, FilenameFilter filenameFilter) {
        File dir = new File(dirName);
        File[] files = dir.listFiles(filenameFilter);
        for (int i = 0; files != null && i < files.length; i++) {
            files[i].delete();
        }
    }

    public static void cleanFiles(String dirName, String fileNamePrefex) {
        cleanFiles(dirName, new PrefixFilenameFilter(fileNamePrefex));
    }

    public static int getDirFileNum(String dirName, FilenameFilter filenameFilter) {
        File dir = new File(dirName);
        File[] files = dir.listFiles(filenameFilter);
        if (files != null) {
            return files.length;
        }
        return 0;
    }

    public static int getDirFileNum(String dirName, String fileNamePrefex) {
        return getDirFileNum(dirName, new PrefixFilenameFilter(fileNamePrefex));
    }

    public static int getFilesSizeWithPrefix(String dirName, String fileNamePrefex) {
        int result = 0;
        File dir = new File(dirName);
        File[] files = dir.listFiles(new PrefixFilenameFilter(fileNamePrefex));
        for (int i = 0; files != null && i < files.length; i++) {
            result = (int) (((long) result) + files[i].length());
        }
        return result;
    }
}
