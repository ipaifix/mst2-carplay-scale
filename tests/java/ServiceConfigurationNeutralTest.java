import org.dsi.ifc.carplay.ServiceConfiguration;

public final class ServiceConfigurationNeutralTest {
    private static int assertions;

    private static void expect(boolean condition, String message) {
        ++assertions;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    public static void main(String[] args) {
        ServiceConfiguration defaults = new ServiceConfiguration();
        expect(defaults.initialAppState == null, "default initialAppState");
        expect(defaults.initialResources == null, "default initialResources");
        expect(defaults.screenResolution == 0, "default screenResolution");
        expect(defaults.xResolution == 0, "default xResolution");
        expect(defaults.yResolution == 0, "default yResolution");
        expect(defaults.displayName.equals(""), "default displayName");
        expect(defaults.physicalDisplayHeight == 0, "default physical height");
        expect(defaults.physicalDisplayWidth == 0, "default physical width");

        ServiceConfiguration legacy = new ServiceConfiguration(
                null, null, 3, 4, 5, "VW", true, 800, 480,
                new String[] { "bt" }, true, 105, 174, 7);
        expect(legacy.screenResolution == 3, "legacy screenResolution");
        expect(legacy.xResolution == 0, "legacy xResolution remains zero");
        expect(legacy.yResolution == 0, "legacy yResolution remains zero");
        expect(legacy.xOffset == 4, "legacy xOffset");
        expect(legacy.yOffset == 5, "legacy yOffset");
        expect(legacy.physicalDisplayHeight == 105, "legacy physical height unchanged");
        expect(legacy.physicalDisplayWidth == 174, "legacy physical width unchanged");

        ServiceConfiguration full = new ServiceConfiguration(
                null, null, 3, 800, 480, 4, 5, "VW", false,
                800, 480, new String[] { "bt" }, false, 105, 174, 9);
        expect(full.getScreenResolution() == 3, "full screenResolution");
        expect(full.getXResolution() == 800, "full xResolution unchanged");
        expect(full.getYResolution() == 480, "full yResolution unchanged");
        expect(full.getXOffset() == 4, "full xOffset");
        expect(full.getYOffset() == 5, "full yOffset");
        expect(full.getPhysicalDisplayHeight() == 105, "full physical height unchanged");
        expect(full.getPhysicalDisplayWidth() == 174, "full physical width unchanged");
        expect(full.getInputFeatures() == 9, "full inputFeatures");
        expect(full.toString().indexOf("xResolution=800") >= 0, "stock toString xResolution");
        expect(full.toString().indexOf("physicalDisplayHeight=105") >= 0, "stock toString height");
        expect(full.toString().indexOf("physicalDisplayWidth=174") >= 0, "stock toString width");

        System.out.println(assertions + " Java assertions passed");
    }
}
