package com.mst2.carplayscale;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import org.dsi.ifc.carplay.ServiceConfiguration;

/**
 * Reads a deliberately small configuration file and adjusts only the physical
 * display dimensions. All failures fall back to the untouched stock values.
 */
public final class CarPlayScale {
    private static final String DEFAULT_STATE_DIR = "/tsd/var/carplayscale";
    private static final String STATE_DIR_PROPERTY = "carplayscale.state.dir";
    private static final long MAX_LOG_SIZE = 65536L;

    private CarPlayScale() {
    }

    public static void apply(ServiceConfiguration configuration) {
        if (configuration == null) {
            return;
        }
        try {
            int scale = readScale();
            int stockHeight = configuration.physicalDisplayHeight;
            int stockWidth = configuration.physicalDisplayWidth;
            int appliedHeight = stockHeight;
            int appliedWidth = stockWidth;

            if (scale != 100) {
                appliedHeight = scaleDimension(stockHeight, scale);
                appliedWidth = scaleDimension(stockWidth, scale);
                configuration.physicalDisplayHeight = appliedHeight;
                configuration.physicalDisplayWidth = appliedWidth;
            }

            logConfiguration(configuration, scale, stockHeight, stockWidth,
                    appliedHeight, appliedWidth);
        } catch (Throwable ignored) {
            // A configuration or logging error must leave stock CarPlay usable.
        }
    }

    static int readScale() {
        BufferedReader reader = null;
        try {
            File config = new File(getStateDir(), "config");
            reader = new BufferedReader(new InputStreamReader(
                    new FileInputStream(config), "UTF-8"));
            String line = reader.readLine();
            if (line == null || line.length() > 32) {
                return 100;
            }
            if (reader.readLine() != null) {
                return 100;
            }
            line = line.trim();
            if (!line.startsWith("scale=")) {
                return 100;
            }
            int scale = Integer.parseInt(line.substring(6));
            if (scale == 100 || scale == 110 || scale == 115
                    || scale == 120 || scale == 125) {
                return scale;
            }
        } catch (Throwable ignored) {
            return 100;
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (Throwable ignored) {
                }
            }
        }
        return 100;
    }

    private static int scaleDimension(int stockValue, int scale) {
        if (stockValue <= 0) {
            return stockValue;
        }
        long scaled = ((long)stockValue * (long)scale + 50L) / 100L;
        if (scaled <= 0L || scaled > 2147483647L) {
            return stockValue;
        }
        return (int)scaled;
    }

    private static String getStateDir() {
        try {
            String override = System.getProperty(STATE_DIR_PROPERTY);
            if (override != null && override.length() > 0) {
                return override;
            }
        } catch (Throwable ignored) {
        }
        return DEFAULT_STATE_DIR;
    }

    private static void logConfiguration(ServiceConfiguration configuration,
            int scale, int stockHeight, int stockWidth,
            int appliedHeight, int appliedWidth) {
        Writer writer = null;
        try {
            File log = new File(getStateDir(), "carplayscale.log");
            boolean append = !log.exists() || log.length() < MAX_LOG_SIZE;
            writer = new OutputStreamWriter(new FileOutputStream(log, append), "UTF-8");
            StringBuffer line = new StringBuffer(320);
            line.append(System.currentTimeMillis());
            line.append(" phase=D/E");
            line.append(" scale=").append(scale);
            line.append(" screenResolution=").append(configuration.screenResolution);
            line.append(" xResolution=").append(configuration.xResolution);
            line.append(" yResolution=").append(configuration.yResolution);
            line.append(" xOffset=").append(configuration.xOffset);
            line.append(" yOffset=").append(configuration.yOffset);
            line.append(" touchpadXResolution=").append(configuration.touchpadXResolution);
            line.append(" touchpadYResolution=").append(configuration.touchpadYResolution);
            line.append(" stockPhysicalHeight=").append(stockHeight);
            line.append(" stockPhysicalWidth=").append(stockWidth);
            line.append(" appliedPhysicalHeight=").append(appliedHeight);
            line.append(" appliedPhysicalWidth=").append(appliedWidth);
            line.append(" inputFeatures=").append(configuration.inputFeatures);
            line.append('\n');
            writer.write(line.toString());
            writer.flush();
        } catch (Throwable ignored) {
        } finally {
            if (writer != null) {
                try {
                    writer.close();
                } catch (Throwable ignored) {
                }
            }
        }
    }
}
