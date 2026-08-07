package com.esmertec.android.jbed.ams;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.util.SimpleEntry;
import com.google.android.collect.Lists;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class PermissionEventHandler {

    private static class PermissionBuilder {
        private Map<Byte, SimpleEntry<Byte, String>> mAllowedMap = new HashMap();
        private byte mAllowedSet;
        private Context mContext;
        byte mCurrentAllowed;
        private List<SimpleEntry<Byte, String>> mPermissionList;

        PermissionBuilder(Context context, byte allowedSet, byte defaultAllowed) {
            this.mContext = context;
            this.mAllowedSet = allowedSet;
            this.mCurrentAllowed = defaultAllowed;
        }

        void addPermission(byte value, int textResId) {
            this.mAllowedMap.put(Byte.valueOf(value), new SimpleEntry<>(Byte.valueOf(value), this.mContext.getString(textResId)));
        }

        List<SimpleEntry<Byte, String>> getAvailablePermissions() {
            if (this.mPermissionList == null) {
                this.mPermissionList = Lists.newArrayList();
                for (int mask = 1; mask <= 127; mask <<= 1) {
                    if ((this.mAllowedSet & mask) != 0) {
                        this.mPermissionList.add(this.mAllowedMap.get(Byte.valueOf((byte) mask)));
                    }
                }
            }
            return this.mPermissionList;
        }

        int getDefaultAllowedPos() {
            return getAvailablePermissions().indexOf(this.mAllowedMap.get(Byte.valueOf(this.mCurrentAllowed)));
        }

        void bindToSpinner(Spinner spinner) {
            ArrayAdapter<SimpleEntry<Byte, String>> adapter = new ArrayAdapter<>(this.mContext, R.layout.simple_spinner_item, (SimpleEntry<Byte, String>[]) getAvailablePermissions().toArray(new SimpleEntry[getAvailablePermissions().size()]));
            adapter.setDropDownViewResource(R.layout.simple_spinner_dropdown_item);
            spinner.setAdapter((SpinnerAdapter) adapter);
            spinner.setSelection(getDefaultAllowedPos());
        }
    }

    public static class RequestPermissionEventHandler extends AmsEventHandler {
        private static AlertDialog mRequestPermissionAlert = null;
        private PermissionBuilder mBuilder;
        private String mLabel;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            if (data == null) {
                throw new IllegalArgumentException("pass the invalid data in REQUEST_PERMISSION event!!!");
            }
            DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
            if (JbedConfig.isSupportSoftKeyboard()) {
                readJbedString(in);
            }
            byte allowedSet = in.readByte();
            byte defaultAllowed = in.readByte();
            this.mLabel = readJbedString(in);
            readJbedString(in);
            readJbedString(in);
            in.close();
            this.mBuilder = new PermissionBuilder(this.mContext, allowedSet, defaultAllowed);
            this.mBuilder.addPermission((byte) 1, R.string.AMS_QUERY_NEVER);
            this.mBuilder.addPermission((byte) 2, R.string.AMS_QUERY_NOT_THIS_SESSION);
            this.mBuilder.addPermission((byte) 4, R.string.AMS_QUERY_NOT_THIS_USE);
            this.mBuilder.addPermission((byte) 8, R.string.AMS_QUERY_THIS_USE);
            this.mBuilder.addPermission(AmsConstants.PERM_ANSWER_SESSION, R.string.AMS_QUERY_THIS_SESSION);
            this.mBuilder.addPermission(AmsConstants.PERM_ANSWER_ALWAYS, R.string.AMS_QUERY_ALWAYS);
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LayoutInflater inflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
            LinearLayout layout = (LinearLayout) inflater.inflate(R.layout.request_permission_dialog, (ViewGroup) null);
            TextView textLabel = (TextView) layout.findViewById(R.id.permissiontext);
            textLabel.setText(this.mLabel);
            final Spinner spinner = (Spinner) layout.findViewById(R.id.permissionspinner);
            this.mBuilder.bindToSpinner(spinner);
            mRequestPermissionAlert = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_OPTIONS_COMMAND)).setView(layout).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.PermissionEventHandler.RequestPermissionEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) RequestPermissionEventHandler.this.mClient).requestPermissionAnswer(RequestPermissionEventHandler.this.mEvent.mResult, ((Byte) ((SimpleEntry) spinner.getSelectedItem()).getKey()).byteValue());
                }
            }).setCancelable(false).create();
            mRequestPermissionAlert.setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.PermissionEventHandler.RequestPermissionEventHandler.2
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface dialog) {
                    ((AmsClient) RequestPermissionEventHandler.this.mClient).requestPermissionAnswer(RequestPermissionEventHandler.this.mEvent.mResult, (byte) 4);
                }
            });
            mRequestPermissionAlert.show();
        }

        public static void cancelPermissionEventHandler() {
            if (mRequestPermissionAlert != null && mRequestPermissionAlert.isShowing()) {
                mRequestPermissionAlert.cancel();
                mRequestPermissionAlert = null;
            }
        }
    }

    public static class PermissionsEventHandler extends AmsEventHandler {
        private LayoutInflater mInflater;
        private List<FgPermission> mPermissionItemList = Lists.newArrayList();

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            if (data == null) {
                throw new IllegalArgumentException("pass the invalid data in RUNTIME_ERROR event!!!");
            }
            DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
            in.readInt();
            int fgTypeCount = in.readInt();
            readJbedString(in);
            for (int i = 0; i < fgTypeCount; i++) {
                String typeText = readJbedString(in);
                int fgCountPerType = in.readInt();
                for (int j = 0; j < fgCountPerType; j++) {
                    FgPermission item = new FgPermission();
                    item.mTypeText = typeText;
                    item.mIndex = (byte) in.readInt();
                    byte allowedSet = in.readByte();
                    byte currentAllowed = in.readByte();
                    item.mChangable = in.readBoolean();
                    item.mLabel = readJbedString(in);
                    item.mBuilder = new PermissionBuilder(this.mContext, allowedSet, currentAllowed);
                    item.mBuilder.addPermission((byte) 1, R.string.AMS_ALWAYS);
                    item.mBuilder.addPermission((byte) 2, R.string.AMS_NEVER);
                    item.mBuilder.addPermission((byte) 4, R.string.AMS_PROMPT);
                    item.mBuilder.addPermission((byte) 8, R.string.AMS_SESSION);
                    item.mBuilder.addPermission(AmsConstants.PERM_ANSWER_SESSION, R.string.AMS_ONESHOT);
                    if (!"reserved".equals(typeText)) {
                        this.mPermissionItemList.add(item);
                    }
                }
            }
            in.close();
            this.mInflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
        }

        static class FgPermission {
            PermissionBuilder mBuilder;
            boolean mChangable;
            byte mIndex;
            String mLabel;
            String mTypeText;

            FgPermission() {
            }
        }

        class PermissionItemAdapter extends ArrayAdapter<FgPermission> {
            public PermissionItemAdapter(List<FgPermission> permissions) {
                super(PermissionsEventHandler.this.mContext, -1, permissions);
            }

            @Override // android.widget.ArrayAdapter, android.widget.Adapter
            public View getView(final int position, View convertView, ViewGroup parent) {
                LinearLayout layout = (LinearLayout) PermissionsEventHandler.this.mInflater.inflate(R.layout.permission_item, parent, false);
                final FgPermission item = (FgPermission) PermissionsEventHandler.this.mPermissionItemList.get(position);
                TextView text = (TextView) layout.findViewById(R.id.typetext);
                text.setText(item.mTypeText);
                TextView text2 = (TextView) layout.findViewById(R.id.fgtext);
                text2.setText(item.mLabel);
                final Spinner spinner = (Spinner) layout.findViewById(R.id.itemspinner);
                item.mBuilder.bindToSpinner(spinner);
                spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() { // from class: com.esmertec.android.jbed.ams.PermissionEventHandler.PermissionsEventHandler.PermissionItemAdapter.1
                    @Override // android.widget.AdapterView.OnItemSelectedListener
                    public void onItemSelected(AdapterView av, View v, int p, long id) {
                        Byte select = (Byte) ((SimpleEntry) av.getAdapter().getItem(p)).getKey();
                        if (item.mBuilder.mCurrentAllowed != select.byteValue()) {
                            if (((FgPermission) PermissionsEventHandler.this.mPermissionItemList.get(position)).mChangable) {
                                Map.Entry<Integer, String> result = ((AmsClient) PermissionsEventHandler.this.mClient).checkPermissionAnswer(((FgPermission) PermissionsEventHandler.this.mPermissionItemList.get(position)).mIndex, select.byteValue());
                                switch (result.getKey().intValue()) {
                                    case 1:
                                        item.mBuilder.mCurrentAllowed = select.byteValue();
                                        return;
                                    case 2:
                                    case 3:
                                    case 4:
                                    default:
                                        throw new IllegalArgumentException("PermissionItemAdapter unkonw return value");
                                    case 5:
                                        item.mBuilder.mCurrentAllowed = select.byteValue();
                                        PermissionsEventHandler.this.showWarning(result.getValue());
                                        return;
                                    case 6:
                                        spinner.setSelection(item.mBuilder.getDefaultAllowedPos());
                                        PermissionsEventHandler.this.showError(result.getValue());
                                        return;
                                }
                            }
                            spinner.setSelection(item.mBuilder.getDefaultAllowedPos());
                            PermissionsEventHandler.this.showWarning(PermissionsEventHandler.this.mContext.getString(R.string.PRJ_WARNING_NOT_CHANGE_PERMISSION_PROPERTY));
                        }
                    }

                    @Override // android.widget.AdapterView.OnItemSelectedListener
                    public void onNothingSelected(AdapterView arg0) {
                    }
                });
                return layout;
            }
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            View view = this.mInflater.inflate(R.layout.list_content, (ViewGroup) null);
            ListView listView = (ListView) view.findViewById(R.id.listview);
            listView.setFocusable(false);
            listView.setAdapter((ListAdapter) new PermissionItemAdapter(this.mPermissionItemList));
            new AlertDialog.Builder(getContext()).setView(listView).setTitle(this.mContext.getString(R.string.AMS_OPTIONS_COMMAND)).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.PermissionEventHandler.PermissionsEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) PermissionsEventHandler.this.mClient).requestPermissionAnswerCommit();
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
        }
    }

    public static class RequestPushEventHandler extends AmsEventHandler {
        private static final String TAG = "RequestPushEventHandler";
        private static AlertDialog mRequestPushAlert = null;
        private byte allowedSet;
        private PermissionBuilder mBuilder;
        private String prompt;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            if (data == null) {
                throw new IllegalArgumentException("pass the invalid data in RUNTIME_ERROR event!!!");
            }
            DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
            this.allowedSet = in.readByte();
            readJbedString(in);
            readJbedString(in);
            readJbedString(in);
            readJbedString(in);
            this.prompt = readJbedString(in);
            in.close();
            this.mBuilder = new PermissionBuilder(this.mContext, this.allowedSet, AmsConstants.PERM_ANSWER_SESSION);
            this.mBuilder.addPermission((byte) 1, R.string.AMS_QUERY_NEVER);
            this.mBuilder.addPermission((byte) 2, R.string.AMS_QUERY_NOT_THIS_SESSION);
            this.mBuilder.addPermission((byte) 4, R.string.AMS_QUERY_NOT_THIS_USE);
            this.mBuilder.addPermission((byte) 8, R.string.AMS_QUERY_THIS_USE);
            this.mBuilder.addPermission(AmsConstants.PERM_ANSWER_SESSION, R.string.AMS_QUERY_THIS_SESSION);
            this.mBuilder.addPermission(AmsConstants.PERM_ANSWER_ALWAYS, R.string.AMS_QUERY_ALWAYS);
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LayoutInflater inflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
            LinearLayout layout = (LinearLayout) inflater.inflate(R.layout.request_permission_dialog, (ViewGroup) null);
            TextView textLabel = (TextView) layout.findViewById(R.id.permissiontext);
            textLabel.setText(this.prompt);
            final Spinner spinner = (Spinner) layout.findViewById(R.id.permissionspinner);
            this.mBuilder.bindToSpinner(spinner);
            mRequestPushAlert = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_OPTIONS_COMMAND)).setView(layout).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.PermissionEventHandler.RequestPushEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) RequestPushEventHandler.this.mClient).requestPushAnswer(RequestPushEventHandler.this.mEvent.mResult, ((Byte) ((SimpleEntry) spinner.getSelectedItem()).getKey()).byteValue());
                }
            }).setCancelable(false).create();
            mRequestPushAlert.setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.PermissionEventHandler.RequestPushEventHandler.2
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface dialog) {
                    ((AmsClient) RequestPushEventHandler.this.mClient).requestPushAnswer(RequestPushEventHandler.this.mEvent.mResult, (byte) 4);
                }
            });
            mRequestPushAlert.show();
        }

        public static void cancelPushEventHandler() {
            if (mRequestPushAlert != null && mRequestPushAlert.isShowing()) {
                mRequestPushAlert.cancel();
                mRequestPushAlert = null;
            }
        }
    }
}
