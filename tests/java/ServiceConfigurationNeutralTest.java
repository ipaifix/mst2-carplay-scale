import java.io.File;
import java.io.FileOutputStream;
import org.dsi.ifc.carplay.ServiceConfiguration;

public final class ServiceConfigurationNeutralTest {
    private static int assertions;
    private static File stateDirectory;

    private static void expect(boolean condition, String message) {
        ++assertions;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static void writeConfig(String value) throws Exception {
        File config = new File(stateDirectory, "config");
        if (value == null) {
            config.delete();
            return;
        }
        FileOutputStream output = new FileOutputStream(config);
        try {
            output.write(value.getBytes("UTF-8"));
        } finally {
            output.close();
        }
    }

    private static ServiceConfiguration configuration() {
        return new ServiceConfiguration(null, null, 3, 800, 480, 4, 5,
                "VW", false, 800, 480, null, false, 105, 174, 9);
    }

    private static void expectScale(String config, int height, int width) throws Exception {
        writeConfig(config);
        ServiceConfiguration value = configuration();
        expect(value.xResolution == 800, "logical width unchanged for " + config);
        expect(value.yResolution == 480, "logical height unchanged for " + config);
        expect(value.touchpadXResolution == 800, "touch width unchanged for " + config);
        expect(value.touchpadYResolution == 480, "touch height unchanged for " + config);
        expect(value.physicalDisplayHeight == height, "physical height for " + config);
        expect(value.physicalDisplayWidth == width, "physical width for " + config);
    }

    public static void main(String[] args) throws Exception {
        stateDirectory = new File(System.getProperty("test.state.dir"));
        stateDirectory.mkdirs();
        System.setProperty("carplayscale.state.dir", stateDirectory.getAbsolutePath());
        writeConfig(null);

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

        expectScale(null, 105, 174);
        expectScale("invalid\n", 105, 174);
        expectScale("scale=0\n", 105, 174);
        expectScale("scale=999999999999999999999\n", 105, 174);
        expectScale("scale=101\n", 105, 174);
        expectScale("scale=120\nunexpected\n", 105, 174);
        expectScale("scale=100\n", 105, 174);
        expectScale("scale=110\n", 116, 191);
        expectScale("scale=115\n", 121, 200);
        expectScale("scale=120\n", 126, 209);
        expectScale("scale=125\n", 131, 218);

        System.out.println(assertions + " Java assertions passed");
    }
}
