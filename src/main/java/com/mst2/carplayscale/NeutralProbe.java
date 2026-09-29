package com.mst2.carplayscale;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

/**
 * Phase C probe. Every failure is deliberately contained so the stock
 * ServiceConfiguration behavior remains available.
 */
public final class NeutralProbe {
    private static final String LOG_PATH = "/tsd/var/carplayscale/carplayscale.log";
    private static final long MAX_LOG_SIZE = 65536L;
    private static boolean marked;

    private NeutralProbe() {
    }

    public static void markLoaded() {
        if (marked) {
            return;
        }
        marked = true;
        try {
            File log = new File(LOG_PATH);
            boolean append = !log.exists() || log.length() < MAX_LOG_SIZE;
            Writer writer = new OutputStreamWriter(new FileOutputStream(log, append), "UTF-8");
            try {
                writer.write(Long.toString(System.currentTimeMillis()));
                writer.write(" phase=C neutral ServiceConfiguration shadow loaded\n");
                writer.flush();
            } finally {
                writer.close();
            }
        } catch (Throwable ignored) {
            // Diagnostics must never prevent CarPlay or the HMI from starting.
        }
    }
}
