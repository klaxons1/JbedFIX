package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import java.util.List;

/* JADX INFO: compiled from: AmsActivity.java */
/* JADX INFO: loaded from: classes.dex */
class AmsListAdapter extends BaseAdapter {
    private Context mContext;
    private LayoutInflater mInflater;
    List<JbedSelectorData> mList;

    public AmsListAdapter(Context context) {
        this.mContext = context;
        this.mInflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
    }

    @Override // android.widget.Adapter
    public int getCount() {
        return this.mList.size();
    }

    @Override // android.widget.Adapter
    public Object getItem(int position) {
        return this.mList.get(position);
    }

    @Override // android.widget.Adapter
    public long getItemId(int position) {
        return position;
    }

    @Override // android.widget.Adapter
    public View getView(int position, View convertView, ViewGroup parent) {
        JbedSelectorData data = this.mList.get(position);
        if (JbedConfig.Menu.isReconfigEnable() && data.isSuite()) {
            for (JbedSelectorData mChildren : data.mChildren) {
                if (mChildren.mIsRunning) {
                    data.mIsRunning = true;
                    break;
                }
            }
            for (JbedSelectorData mChildren2 : data.mChildren) {
                if (mChildren2.mIsPaused) {
                    data.mIsPaused = true;
                    break;
                }
            }
        }
        LinearLayout layout = (LinearLayout) this.mInflater.inflate(R.layout.list_selector_item, parent, false);
        if (data.mIsRunning) {
            layout.findViewById(R.id.progress_small).setVisibility(0);
        }
        TextView text = (TextView) layout.findViewById(R.id.list_item_text);
        TextView vendor = (TextView) layout.findViewById(R.id.vendor_text);
        TextView size = (TextView) layout.findViewById(R.id.size_text);
        TextView installDate = (TextView) layout.findViewById(R.id.install_date_text);
        ImageView icon = (ImageView) layout.findViewById(R.id.list_item_icon);
        if (!data.isMidlet() || (data.isMidlet() && data.mParent.getChildCount() == 1)) {
            if (!JbedConfig.ListItem.isVendorDisabled()) {
                vendor.setText(data.getVendorText());
            }
            if (!JbedConfig.ListItem.isSizeDisabled()) {
                size.setText(data.getSizeText(this.mContext));
            }
            if (!JbedConfig.ListItem.isDateDisabled()) {
                installDate.setText(data.getInstallTimeText());
            }
        }
        if (data == ((AmsActivity) this.mContext).mCurSelectedItem) {
            text.setEllipsize(TextUtils.TruncateAt.MARQUEE);
        } else {
            text.setEllipsize(TextUtils.TruncateAt.END);
        }
        String i18nString = null;
        FolderNameI18N folderNameI18N = new FolderNameI18N(this.mContext);
        if (data.getNameText().equals(FolderNameI18N.FOLDER_NAME_DOWNLOAD_GAMES)) {
            i18nString = folderNameI18N.getI18NStrings(1);
        } else if (data.getNameText().equals(FolderNameI18N.FOLDER_NAME_DOWNLOAD_APPLICATIONS)) {
            i18nString = folderNameI18N.getI18NStrings(2);
        }
        if (data.getNameText().equals(FolderNameI18N.FOLDER_NAME_DOWNLOAD_GAMES) || data.getNameText().equals(FolderNameI18N.FOLDER_NAME_DOWNLOAD_APPLICATIONS)) {
            text.setText(i18nString);
        } else if (data.getNameText().equals(JbedFileManager.SDCARD_FOLDER_NAME)) {
            text.setText(this.mContext.getString(R.string.PRJ_EXTERNAL_STORAGE_SDCARD));
        } else {
            text.setText(data.getNameText());
        }
        if (data.isFolder()) {
            if (JbedConfig.Menu.isReconfigEnable()) {
                if (data.mModifiableContent) {
                    icon.setBackgroundResource(R.drawable.general_info_folder);
                } else {
                    icon.setBackgroundResource(R.drawable.download_icon);
                }
            } else {
                icon.setBackgroundResource(R.drawable.folder);
            }
        } else if (data.getIcon(this.mContext) != null) {
            icon.setImageDrawable(data.getIcon(this.mContext));
        } else {
            icon.setBackgroundResource(R.drawable.default_midlet);
        }
        if (data.isDrmPending()) {
            layout.findViewById(R.id.drm_pending_icon).setVisibility(0);
        } else if (data.isDrmProtected()) {
            if (JbedConfig.Ams.isUsingSpecialIcon()) {
                layout.findViewById(R.id.lge_drm_protect_icon).setVisibility(0);
            } else if (data.mIsExpired) {
                layout.findViewById(16842752).setVisibility(0);
            } else {
                layout.findViewById(R.id.drm_protect_icon).setVisibility(0);
            }
        }
        if (data.isOnSdcard() && JbedConfig.Ams.isUsingSpecialIcon()) {
            layout.findViewById(R.id.lge_sdcard_icon).setVisibility(0);
        }
        return layout;
    }
}
