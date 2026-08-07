package com.esmertec.android.jbed.jsr;

import android.graphics.Rect;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public class JbedVideoPlayerState implements Parcelable {
    public static final Parcelable.Creator<JbedVideoPlayerState> CREATOR = new Parcelable.Creator<JbedVideoPlayerState>() { // from class: com.esmertec.android.jbed.jsr.JbedVideoPlayerState.1
        /* JADX WARN: Can't rename method to resolve collision */
        @Override // android.os.Parcelable.Creator
        public JbedVideoPlayerState createFromParcel(Parcel source) {
            return new JbedVideoPlayerState(source);
        }

        /* JADX WARN: Can't rename method to resolve collision */
        @Override // android.os.Parcelable.Creator
        public JbedVideoPlayerState[] newArray(int size) {
            return new JbedVideoPlayerState[size];
        }
    };
    private static final String TAG = "JbedVideoPlayerState";
    public String dataSource;
    public Rect displayViewRect;
    public boolean isCapture;
    public boolean isPlaying;
    public boolean isVisible;
    public int position;
    public Rect regionViewRect;
    public Suspend suspend;

    public enum Suspend {
        NONE,
        DOING,
        DONE
    }

    public JbedVideoPlayerState() {
        this.regionViewRect = new Rect(0, 0, 0, 0);
        this.displayViewRect = new Rect(0, 0, 0, 0);
        this.suspend = Suspend.NONE;
    }

    public JbedVideoPlayerState(Parcel source) {
        this.regionViewRect = new Rect(0, 0, 0, 0);
        this.displayViewRect = new Rect(0, 0, 0, 0);
        this.suspend = Suspend.NONE;
        this.dataSource = source.readString();
        this.regionViewRect = (Rect) source.readParcelable(Rect.class.getClassLoader());
        this.displayViewRect = (Rect) source.readParcelable(Rect.class.getClassLoader());
        this.position = source.readInt();
        this.isPlaying = source.readInt() == 1;
        this.isVisible = source.readInt() == 1;
        this.isCapture = source.readInt() == 1;
        switch (source.readInt()) {
            case 0:
                this.suspend = Suspend.NONE;
                break;
            case 1:
                this.suspend = Suspend.DOING;
                break;
            case 2:
                this.suspend = Suspend.DONE;
                break;
        }
    }

    public void printToString() {
        if (Log.isLoggable(TAG, 3)) {
            Log.d(TAG, toString());
        }
    }

    public String toString() {
        String msg = this.dataSource;
        return ((((((msg + ", " + this.suspend) + ", " + this.regionViewRect) + ", " + this.displayViewRect) + ", " + this.position) + ", " + this.isPlaying) + ", " + this.isVisible) + ", " + this.isCapture;
    }

    public boolean updateRegionViewRect(boolean isLoc, int param1, int param2) {
        if (isLoc) {
            if (this.regionViewRect.left == param1 && this.regionViewRect.top == param2) {
                return false;
            }
            this.regionViewRect.right = this.regionViewRect.width() + param1;
            this.regionViewRect.bottom = this.regionViewRect.height() + param2;
            this.regionViewRect.left = param1;
            this.regionViewRect.top = param2;
            return true;
        }
        if (this.regionViewRect.width() == param1 && this.regionViewRect.height() == param2) {
            return false;
        }
        this.regionViewRect.right = this.regionViewRect.left + param1;
        this.regionViewRect.bottom = this.regionViewRect.top + param2;
        return true;
    }

    public boolean updateDisplayViewRect(boolean isLoc, int param1, int param2) {
        if (isLoc) {
            if (this.displayViewRect.left == param1 && this.displayViewRect.top == param2) {
                return false;
            }
            this.displayViewRect.right = this.displayViewRect.width() + param1;
            this.displayViewRect.bottom = this.displayViewRect.height() + param2;
            this.displayViewRect.left = param1;
            this.displayViewRect.top = param2;
            return true;
        }
        if (this.displayViewRect.width() == param1 && this.displayViewRect.height() == param2) {
            return false;
        }
        this.displayViewRect.right = this.displayViewRect.left + param1;
        this.displayViewRect.bottom = this.displayViewRect.top + param2;
        return true;
    }

    @Override // android.os.Parcelable
    public int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public void writeToParcel(Parcel parcel, int arg1) {
        parcel.writeString(this.dataSource);
        parcel.writeParcelable(this.regionViewRect, 0);
        parcel.writeParcelable(this.displayViewRect, 0);
        parcel.writeInt(this.position);
        parcel.writeInt(this.isPlaying ? 1 : 0);
        parcel.writeInt(this.isVisible ? 1 : 0);
        parcel.writeInt(this.isCapture ? 1 : 0);
        if (this.suspend == Suspend.NONE) {
            parcel.writeInt(0);
        } else if (this.suspend == Suspend.DOING) {
            parcel.writeInt(1);
        } else if (this.suspend == Suspend.DONE) {
            parcel.writeInt(2);
        }
    }
}
