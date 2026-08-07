package com.esmertec.android.jbed.jsr;

import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.service.JbedService;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

/* JADX INFO: loaded from: classes.dex */
public class JbedLapiManager implements JbedService.LifecycleListener {
    private static final int AVAILABLE = 1;
    private static final boolean DEBUG = false;
    private static final int DISTANCE_COARSE_ACCURACY = 25;
    private static final int DISTANCE_FINER_ACCURACY = 10;
    private static JbedLapiManager INSTANCE = null;
    private static final int INVALID_NATIVE_ID = 0;
    private static final int JPL_LOC_FAILURE = -1;
    private static final int JPL_LOC_INTERRUPTED = -2;
    private static final int JPL_LOC_SUCCESS = 0;
    private static final int JPL_LOC_WOULDBLOCK = -3;
    private static final int MTA_ASSISTED = 262144;
    private static final int MTA_UNASSISTED = 524288;
    private static final int MTE_ANGLEOFARRIVAL = 32;
    private static final int MTE_CELLID = 8;
    private static final int MTE_SATELLITE = 1;
    private static final int MTE_SHORTRANGE = 16;
    private static final int MTE_TIMEDIFFERENCE = 2;
    private static final int MTE_TIMEOFARRIVAL = 4;
    private static final int MTY_NETWORKBASED = 131072;
    private static final int MTY_TERMINALBASED = 65536;
    private static final int OUT_OF_SERVICE = 3;
    private static final int RESPONSE_TIME = 5000;
    private static final String TAG = "JbedLapiManager";
    private static final int TEMPORARILY_UNAVAILABLE = 2;
    private Handler mHandler;
    private LocationManager mLocationManager;
    private LocationProviderProxy[] mProviders;

    private static native void nativeInitialization(String str);

    /* JADX INFO: Access modifiers changed from: private */
    public static native void notifyNative(int i, int i2);

    class LocationProviderProxy implements LocationListener {
        private Location mLastLocation;
        private LocationProvider mProvider;
        private int mStatus = 0;
        private LocationProviderProxy mInstance = this;
        private List<Integer> mEnableNotifiers = new ArrayList();

        LocationProviderProxy(String name) {
            this.mProvider = JbedLapiManager.this.mLocationManager.getProvider(name);
            this.mLastLocation = new Location(name);
        }

        public void onCreate() {
            JbedLapiManager.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedLapiManager.LocationProviderProxy.1
                @Override // java.lang.Runnable
                public void run() {
                    JbedLapiManager.this.mLocationManager.requestLocationUpdates(LocationProviderProxy.this.mProvider.getName(), 0L, 0.0f, LocationProviderProxy.this.mInstance);
                }
            });
        }

        public void onDestroy() {
            JbedLapiManager.this.mLocationManager.removeUpdates(this);
        }

        public LocationProvider getProvider() {
            return this.mProvider;
        }

        public Location getLocation() {
            Location loc = JbedLapiManager.this.mLocationManager.getLastKnownLocation(this.mProvider.getName());
            if (loc == null) {
                loc = JbedLapiManager.this.mLocationManager.getLastKnownLocation("network");
            }
            if (loc != null) {
                this.mLastLocation.set(loc);
            } else {
                this.mLastLocation.reset();
            }
            return this.mLastLocation;
        }

        public int enable(int nativeId) {
            if (this.mProvider == null) {
                return -1;
            }
            int res = -3;
            Location loc = getLocation();
            if (loc != null) {
                this.mStatus = 2;
            }
            if (this.mStatus == 2) {
                res = 0;
            } else {
                synchronized (this.mEnableNotifiers) {
                    if (this.mEnableNotifiers.size() <= 0) {
                    }
                    if (nativeId != 0) {
                        this.mEnableNotifiers.add(Integer.valueOf(nativeId));
                    }
                }
            }
            return res;
        }

        public int disable(int nativeId) {
            return this.mProvider == null ? -1 : 0;
        }

        public void interrupt() {
            synchronized (this.mEnableNotifiers) {
                for (int i = 0; i < this.mEnableNotifiers.size(); i++) {
                    JbedLapiManager.this.notifyNewState(this.mEnableNotifiers.get(i).intValue(), -2);
                }
                this.mEnableNotifiers.clear();
            }
        }

        public void notifyTimeout(int nativeId) {
            synchronized (this.mEnableNotifiers) {
                while (true) {
                    int i = this.mEnableNotifiers.indexOf(Integer.valueOf(nativeId));
                    if (i != -1) {
                        this.mEnableNotifiers.remove(i);
                    }
                }
            }
        }

        public boolean isEnabled() {
            return JbedLapiManager.this.mLocationManager.isProviderEnabled(this.mProvider.getName());
        }

        public int getProviderState() {
            switch (this.mStatus) {
                case 1:
                    return 2;
                case 2:
                    return 1;
                default:
                    return 3;
            }
        }

        @Override // android.location.LocationListener
        public void onLocationChanged(Location loc) {
            if (loc != null) {
                this.mLastLocation.set(loc);
            }
        }

        @Override // android.location.LocationListener
        public void onStatusChanged(String provider, int status, Bundle extras) {
            if (this.mProvider != null && provider != null && provider.equals(this.mProvider.getName())) {
                this.mStatus = status;
                int res = status == 2 ? 0 : -1;
                synchronized (this.mEnableNotifiers) {
                    for (int i = 0; i < this.mEnableNotifiers.size(); i++) {
                        JbedLapiManager.this.notifyNewState(this.mEnableNotifiers.get(i).intValue(), res);
                    }
                    this.mEnableNotifiers.clear();
                }
            }
        }

        @Override // android.location.LocationListener
        public void onProviderEnabled(String provider) {
        }

        @Override // android.location.LocationListener
        public void onProviderDisabled(String provider) {
            if (this.mProvider != null && provider != null && provider.equals(this.mProvider.getName())) {
                synchronized (this.mEnableNotifiers) {
                    for (int i = 0; i < this.mEnableNotifiers.size(); i++) {
                        JbedLapiManager.this.notifyNewState(this.mEnableNotifiers.get(i).intValue(), -1);
                    }
                    this.mEnableNotifiers.clear();
                }
            }
        }
    }

    static {
        nativeInitialization(JbedProvider.Settings.DEFAULT_LAPI_DIR);
    }

    public JbedLapiManager(Handler handler) {
        INSTANCE = this;
        this.mHandler = handler;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        if (this.mLocationManager == null && context != null) {
            this.mLocationManager = (LocationManager) context.getSystemService("location");
        }
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        this.mProviders = null;
        this.mLocationManager = null;
        INSTANCE = null;
        this.mHandler = null;
    }

    private boolean checkProviders() {
        if (this.mProviders == null) {
            List<String> names = this.mLocationManager.getAllProviders();
            if (names == null) {
                return false;
            }
            this.mProviders = new LocationProviderProxy[names.size()];
            for (int i = 0; i < names.size(); i++) {
                this.mProviders[i] = new LocationProviderProxy(names.get(i));
                this.mProviders[i].onCreate();
            }
        }
        return true;
    }

    private static int getProviderCount() {
        if (INSTANCE.checkProviders()) {
            return INSTANCE.mProviders.length;
        }
        return -1;
    }

    private static byte[] getProviderInfos() {
        if (!INSTANCE.checkProviders()) {
            return null;
        }
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bout);
        try {
            out.writeInt(INSTANCE.mProviders.length);
            for (int i = 0; i < INSTANCE.mProviders.length; i++) {
                LocationProvider provider = INSTANCE.mProviders[i].getProvider();
                if (provider == null) {
                    return null;
                }
                out.writeInt(i);
                int value = provider.getAccuracy();
                if (value == 1) {
                    value = 10;
                } else if (value == 2) {
                    value = 25;
                }
                out.writeInt(value);
                out.writeInt(value);
                out.writeInt(RESPONSE_TIME);
                out.writeInt(provider.getPowerRequirement());
                out.writeBoolean(provider.hasMonetaryCost());
                out.writeBoolean(provider.supportsSpeed() && provider.supportsBearing());
                out.writeBoolean(provider.supportsAltitude());
                out.writeBoolean(false);
            }
            out.flush();
        } catch (IOException e) {
        }
        return bout.toByteArray();
    }

    private static byte[] getLocation(int providerId) {
        Location loc = INSTANCE.mProviders[providerId].getLocation();
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bout);
        try {
            out.writeFloat(loc.getBearing());
            out.writeInt(327681);
            out.writeFloat((float) loc.getAltitude());
            out.writeDouble(loc.getLatitude());
            out.writeDouble(loc.getLongitude());
            out.writeFloat(loc.getAccuracy());
            out.writeFloat(loc.getAccuracy());
            out.writeFloat(loc.getSpeed());
            Calendar cal = Calendar.getInstance();
            TimeZone tz = cal.getTimeZone();
            out.writeLong(loc.getTime() + ((long) tz.getRawOffset()));
            out.writeBoolean(INSTANCE.mProviders[providerId].isEnabled());
            out.writeBoolean(false);
            out.writeUTF("");
            out.writeUTF("");
            out.writeUTF("" + loc.getExtras());
            out.flush();
        } catch (IOException e) {
        }
        return bout.toByteArray();
    }

    private static int openProvider(int providerId, int nativeId) {
        if (providerId < 0 || providerId >= INSTANCE.mProviders.length) {
            return -1;
        }
        return INSTANCE.mProviders[providerId].enable(nativeId);
    }

    private static int closeProvider(int providerId, int nativeId) {
        if (providerId < 0 || providerId >= INSTANCE.mProviders.length) {
            return -1;
        }
        return INSTANCE.mProviders[providerId].disable(nativeId);
    }

    private static void interrupt(int providerId) {
        if (providerId >= 0 && providerId < INSTANCE.mProviders.length) {
            INSTANCE.mProviders[providerId].interrupt();
        }
    }

    private static void finalize(int providerId) {
        if (providerId >= 0 && providerId < INSTANCE.mProviders.length) {
            INSTANCE.mProviders[providerId].onDestroy();
        }
    }

    private static void notifyTimeout(int providerId, int nativeId) {
        if (providerId >= 0 && providerId < INSTANCE.mProviders.length) {
            INSTANCE.mProviders[providerId].notifyTimeout(nativeId);
        }
    }

    private static int getProviderState(int providerId) {
        if (providerId < 0 || providerId >= INSTANCE.mProviders.length) {
            return 3;
        }
        return INSTANCE.mProviders[providerId].getProviderState();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void notifyNewState(final int nativeId, final int res) {
        Message msg = this.mHandler.obtainMessage(3);
        msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedLapiManager.1
            @Override // java.lang.Runnable
            public void run() {
                JbedLapiManager.notifyNative(nativeId, res);
            }
        };
        msg.sendToTarget();
    }

    private static void log(String msg) {
    }
}
