package org.dsi.ifc.carplay;

import com.mst2.carplayscale.NeutralProbe;

/**
 * ABI-faithful P0468 shadow. Phase C only adds a fail-safe load marker; all
 * fields, constructors, getters and string formatting retain stock behavior.
 */
public class ServiceConfiguration {
    public AppStateRequest[] initialAppState;
    public ResourceRequest[] initialResources;
    public int screenResolution;
    public int xResolution;
    public int yResolution;
    public int xOffset;
    public int yOffset;
    public String displayName;
    public boolean useRightHandDrive;
    public int touchpadXResolution;
    public int touchpadYResolution;
    public String[] bluetoothIdentities;
    public boolean startInNightMode;
    public int physicalDisplayHeight;
    public int physicalDisplayWidth;
    public int inputFeatures;

    public ServiceConfiguration() {
        this.initialAppState = null;
        this.initialResources = null;
        this.screenResolution = 0;
        this.xResolution = 0;
        this.yResolution = 0;
        this.xOffset = 0;
        this.yOffset = 0;
        this.displayName = "";
        this.useRightHandDrive = false;
        this.touchpadXResolution = 0;
        this.touchpadYResolution = 0;
        this.bluetoothIdentities = null;
        this.startInNightMode = false;
        this.physicalDisplayHeight = 0;
        this.physicalDisplayWidth = 0;
        this.inputFeatures = 0;
        NeutralProbe.markLoaded();
    }

    public ServiceConfiguration(AppStateRequest[] initialAppState,
            ResourceRequest[] initialResources, int screenResolution,
            int xOffset, int yOffset, String displayName,
            boolean useRightHandDrive, int touchpadXResolution,
            int touchpadYResolution, String[] bluetoothIdentities,
            boolean startInNightMode, int physicalDisplayHeight,
            int physicalDisplayWidth, int inputFeatures) {
        this.initialAppState = initialAppState;
        this.initialResources = initialResources;
        this.screenResolution = screenResolution;
        this.xResolution = 0;
        this.yResolution = 0;
        this.xOffset = xOffset;
        this.yOffset = yOffset;
        this.displayName = displayName;
        this.useRightHandDrive = useRightHandDrive;
        this.touchpadXResolution = touchpadXResolution;
        this.touchpadYResolution = touchpadYResolution;
        this.bluetoothIdentities = bluetoothIdentities;
        this.startInNightMode = startInNightMode;
        this.physicalDisplayHeight = physicalDisplayHeight;
        this.physicalDisplayWidth = physicalDisplayWidth;
        this.inputFeatures = inputFeatures;
        NeutralProbe.markLoaded();
    }

    public ServiceConfiguration(AppStateRequest[] initialAppState,
            ResourceRequest[] initialResources, int screenResolution,
            int xResolution, int yResolution, int xOffset, int yOffset,
            String displayName, boolean useRightHandDrive,
            int touchpadXResolution, int touchpadYResolution,
            String[] bluetoothIdentities, boolean startInNightMode,
            int physicalDisplayHeight, int physicalDisplayWidth,
            int inputFeatures) {
        this.initialAppState = initialAppState;
        this.initialResources = initialResources;
        this.screenResolution = screenResolution;
        this.xResolution = xResolution;
        this.yResolution = yResolution;
        this.xOffset = xOffset;
        this.yOffset = yOffset;
        this.displayName = displayName;
        this.useRightHandDrive = useRightHandDrive;
        this.touchpadXResolution = touchpadXResolution;
        this.touchpadYResolution = touchpadYResolution;
        this.bluetoothIdentities = bluetoothIdentities;
        this.startInNightMode = startInNightMode;
        this.physicalDisplayHeight = physicalDisplayHeight;
        this.physicalDisplayWidth = physicalDisplayWidth;
        this.inputFeatures = inputFeatures;
        NeutralProbe.markLoaded();
    }

    public AppStateRequest[] getInitialAppState() {
        return this.initialAppState;
    }

    public ResourceRequest[] getInitialResources() {
        return this.initialResources;
    }

    public int getScreenResolution() {
        return this.screenResolution;
    }

    public int getXResolution() {
        return this.xResolution;
    }

    public int getYResolution() {
        return this.yResolution;
    }

    public int getXOffset() {
        return this.xOffset;
    }

    public int getYOffset() {
        return this.yOffset;
    }

    public String getDisplayName() {
        return this.displayName;
    }

    public boolean isUseRightHandDrive() {
        return this.useRightHandDrive;
    }

    public int getTouchpadXResolution() {
        return this.touchpadXResolution;
    }

    public int getTouchpadYResolution() {
        return this.touchpadYResolution;
    }

    public String[] getBluetoothIdentities() {
        return this.bluetoothIdentities;
    }

    public boolean isStartInNightMode() {
        return this.startInNightMode;
    }

    public int getPhysicalDisplayWidth() {
        return this.physicalDisplayWidth;
    }

    public int getPhysicalDisplayHeight() {
        return this.physicalDisplayHeight;
    }

    public int getInputFeatures() {
        return this.inputFeatures;
    }

    public String toString() {
        int length;
        int last;
        int index;
        StringBuffer result = new StringBuffer(1000);
        result.append("ServiceConfiguration");
        result.append('(');
        result.append("initialAppState");
        result.append('[');
        if (this.initialAppState != null) {
            result.append(this.initialAppState.length);
        }
        result.append(']');
        result.append('=');
        result.append('{');
        if (this.initialAppState != null) {
            length = this.initialAppState.length;
            last = length - 1;
            for (index = 0; index < length; ++index) {
                result.append(this.initialAppState[index]);
                if (index < last) {
                    result.append(',');
                }
            }
        } else {
            result.append(this.initialAppState);
        }
        result.append('}');
        result.append(',');
        result.append("initialResources");
        result.append('[');
        if (this.initialResources != null) {
            result.append(this.initialResources.length);
        }
        result.append(']');
        result.append('=');
        result.append('{');
        if (this.initialResources != null) {
            length = this.initialResources.length;
            last = length - 1;
            for (index = 0; index < length; ++index) {
                result.append(this.initialResources[index]);
                if (index < last) {
                    result.append(',');
                }
            }
        } else {
            result.append(this.initialResources);
        }
        result.append('}');
        result.append(',');
        result.append("screenResolution");
        result.append('=');
        result.append(this.screenResolution);
        result.append(',');
        result.append("xResolution");
        result.append('=');
        result.append(this.xResolution);
        result.append(',');
        result.append("yResolution");
        result.append('=');
        result.append(this.yResolution);
        result.append(',');
        result.append("xOffset");
        result.append('=');
        result.append(this.xOffset);
        result.append(',');
        result.append("yOffset");
        result.append('=');
        result.append(this.yOffset);
        result.append(',');
        result.append("displayName");
        result.append('=');
        result.append('"');
        result.append(this.displayName);
        result.append('"');
        result.append(',');
        result.append("useRightHandDrive");
        result.append('=');
        result.append(this.useRightHandDrive);
        result.append(',');
        result.append("touchpadXResolution");
        result.append('=');
        result.append(this.touchpadXResolution);
        result.append(',');
        result.append("touchpadYResolution");
        result.append('=');
        result.append(this.touchpadYResolution);
        result.append(',');
        result.append("bluetoothIdentities");
        result.append('[');
        if (this.bluetoothIdentities != null) {
            result.append(this.bluetoothIdentities.length);
        }
        result.append(']');
        result.append('=');
        result.append('{');
        if (this.bluetoothIdentities != null) {
            length = this.bluetoothIdentities.length;
            last = length - 1;
            for (index = 0; index < length; ++index) {
                result.append('"');
                result.append(this.bluetoothIdentities[index]);
                result.append('"');
                if (index < last) {
                    result.append(',');
                }
            }
        } else {
            result.append(this.bluetoothIdentities);
        }
        result.append('}');
        result.append(',');
        result.append("startInNightMode");
        result.append('=');
        result.append(this.startInNightMode);
        result.append(',');
        result.append("physicalDisplayHeight");
        result.append('=');
        result.append(this.physicalDisplayHeight);
        result.append(',');
        result.append("physicalDisplayWidth");
        result.append('=');
        result.append(this.physicalDisplayWidth);
        result.append(',');
        result.append("inputFeatures");
        result.append('=');
        result.append(this.inputFeatures);
        result.append(')');
        return result.toString();
    }
}
