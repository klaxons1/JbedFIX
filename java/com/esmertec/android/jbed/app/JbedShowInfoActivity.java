package com.esmertec.android.jbed.app;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.ams.AmsActivity;
import com.esmertec.android.jbed.ams.BasicEventHandler;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedShowInfoActivity extends Activity {
    private static final boolean DEBUG = false;
    private static final String TAG = "JbedShowInfoActivity";
    private static String pkgName = null;
    private String str1;
    private String str2;

    @Override // android.app.Activity
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        if (intent.getBooleanExtra("no_sdcard", false)) {
            new AlertDialog.Builder(this).setTitle(getString(R.string.AMS_WARNING)).setMessage(getString(R.string.AMS_LAUNCH_ON_UNAVAILABLE_REMOVABLE_MEDIA)).setCancelable(false).setNeutralButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    JbedShowInfoActivity.this.finish();
                }
            }).show();
            return;
        }
        String stringExtra = intent.getStringExtra("oom");
        this.str1 = stringExtra;
        if (stringExtra != null) {
            new AlertDialog.Builder(this).setTitle(getString(R.string.AMS_LAUNCH_REQUEST_TITLE)).setMessage(this.str1).setCancelable(false).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.3
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    Intent amsIntent = new Intent(JbedShowInfoActivity.this, (Class<?>) AmsActivity.class);
                    JbedShowInfoActivity.this.startActivity(amsIntent);
                    JbedShowInfoActivity.this.finish();
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    dialog.dismiss();
                    JbedShowInfoActivity.this.finish();
                }
            }).show();
            return;
        }
        if (intent.getBooleanExtra("noRootInfo", false)) {
            String application = getString(R.string.AMS_PERM_TYPE_MONEY_POPUP_APP);
            String deletion = getString(R.string.PRJ_DELETE_MULTI_MIDLETS);
            String msg = getString(R.string.AMS_FOLDER_ERROR_NOT_EXISTS, new Object[]{application});
            String msg2 = msg + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + deletion;
            pkgName = intent.getStringExtra("packageName");
            new AlertDialog.Builder(this).setTitle(getString(R.string.AMS_WARNING)).setMessage(msg2).setCancelable(false).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.5
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    List<PackageInfo> packageList = JbedShowInfoActivity.this.getPackageManager().getInstalledPackages(0);
                    for (int i = 0; i < packageList.size(); i++) {
                        if (packageList.get(i).packageName.equals(JbedShowInfoActivity.pkgName)) {
                            JbedShowInfoActivity.this.getPackageManager().deletePackage(JbedShowInfoActivity.pkgName, null, 0);
                            break;
                        }
                    }
                    JbedShowInfoActivity.this.finish();
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.4
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    dialog.dismiss();
                    JbedShowInfoActivity.this.finish();
                }
            }).show();
            return;
        }
        String stringExtra2 = intent.getStringExtra("init_error");
        this.str1 = stringExtra2;
        if (stringExtra2 != null) {
            new AlertDialog.Builder(this).setTitle(getString(R.string.AMS_WARNING)).setMessage(getString(R.string.AMS_MIDLET_INIT_ERROR) + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + getString(R.string.PRJ_SDCARD_ERROR_MESSAGE)).setCancelable(false).setNeutralButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.6
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    JbedShowInfoActivity.this.finish();
                }
            }).show();
            return;
        }
        String stringExtra3 = intent.getStringExtra("error");
        this.str2 = stringExtra3;
        if (stringExtra3 != null) {
            new AlertDialog.Builder(this).setTitle(getString(R.string.AMS_WARNING)).setMessage(getString(R.string.AMS_MIDLET_INIT_ERROR)).setCancelable(false).setNeutralButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.app.JbedShowInfoActivity.7
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    JbedShowInfoActivity.this.finish();
                }
            }).show();
        }
    }
}
