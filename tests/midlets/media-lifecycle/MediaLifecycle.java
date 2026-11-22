import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Vector;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.CommandListener;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Displayable;
import javax.microedition.lcdui.Form;
import javax.microedition.lcdui.StringItem;
import javax.microedition.lcdui.TextField;
import javax.microedition.media.Manager;
import javax.microedition.media.MediaException;
import javax.microedition.media.Player;
import javax.microedition.media.PlayerListener;
import javax.microedition.midlet.MIDlet;

/** MMAPI regression test; configure MediaTest-BadURL with an HTTP 200 invalid MP3. */
public final class MediaLifecycle extends MIDlet implements CommandListener {
    private final Command runCommand = new Command("Run", Command.OK, 1);
    private final Command exitCommand = new Command("Exit", Command.EXIT, 2);
    private final Form form = new Form("Media lifecycle");
    private final TextField badUrl = new TextField("Invalid MP3 URL", "", 512, TextField.URL);
    private final StringItem output = new StringItem("Results", "");
    private Display display;
    private TestRun active;
    private boolean started;

    protected void startApp() {
        if (started) return;
        started = true;
        display = Display.getDisplay(this);
        String url = getAppProperty("MediaTest-BadURL");
        if (url != null) badUrl.setString(url);
        form.append(badUrl);
        form.append(output);
        form.addCommand(runCommand);
        form.addCommand(exitCommand);
        form.setCommandListener(this);
        display.setCurrent(form);
        if (!"false".equals(getAppProperty("MediaTest-Autostart"))) startTests();
    }

    protected void pauseApp() { }

    protected void destroyApp(boolean unconditional) {
        if (active != null) active.cancelled = true;
    }

    public void commandAction(Command command, Displayable screen) {
        if (command == exitCommand) {
            destroyApp(true);
            notifyDestroyed();
        } else if (command == runCommand) {
            startTests();
        }
    }

    private void startTests() {
        if (active != null && !active.finished) return;
        String goodUrl = getAppProperty("MediaTest-GoodURL");
        active = new TestRun(badUrl.getString().trim(), goodUrl == null ? "" : goodUrl.trim(),
                propertyInt("MediaTest-Cycles", 24, 1, 1000),
                propertyInt("MediaTest-TimeoutMs", 10000, 2000, 60000));
        new Thread(active).start();
    }

    private int propertyInt(String name, int fallback, int minimum, int maximum) {
        try {
            int value = Integer.parseInt(getAppProperty(name));
            if (value >= minimum && value <= maximum) return value;
        } catch (Exception ignored) { }
        return fallback;
    }

    private final class TestRun implements Runnable {
        private final String url;
        private final String goodUrl;
        private final int cycles;
        private final int timeout;
        private final Vector closedObservers = new Vector();
        private final StringBuffer transcript = new StringBuffer();
        private String stage;
        private long deadline;
        private int failures;
        private boolean timedOut;
        volatile boolean finished;
        volatile boolean cancelled;

        TestRun(String url, String goodUrl, int cycles, int timeout) {
            this.url = url;
            this.goodUrl = goodUrl;
            this.cycles = cycles;
            this.timeout = timeout;
        }

        private synchronized void log(String message) {
            System.out.println("[media-test] " + message);
            transcript.append(message).append('\n');
            if (transcript.length() > 4000) transcript.delete(0, transcript.length() - 4000);
            final String text = transcript.toString();
            display.callSerially(new Runnable() {
                public void run() { output.setText(text); }
            });
        }

        private synchronized void fail(String message) {
            failures++;
            log("FAIL " + message);
        }

        private synchronized void stage(String name) {
            stage = name;
            deadline = System.currentTimeMillis() + timeout;
        }

        private synchronized boolean shouldStop() {
            return cancelled || timedOut;
        }

        public void run() {
            log("START completion=3 close=" + cycles + " timeout=" + timeout + "ms");
            new Thread(new Runnable() {
                public void run() { watch(); }
            }).start();
            try {
                for (int i = 0; i < 3 && !shouldStop(); i++) playToEnd(i + 1);
                for (int i = 0; i < cycles && !shouldStop(); i++) closeEarly(i + 1);
                if (!shouldStop()) {
                    stage("waiting for stale close callbacks");
                    Thread.sleep(1200);
                    int late = 0;
                    for (int i = 0; i < closedObservers.size(); i++) {
                        late += ((Events) closedObservers.elementAt(i)).lateEndCount();
                    }
                    if (late == 0) log("PASS no END_OF_MEDIA after close");
                    else fail(late + " END_OF_MEDIA events after close");
                }
                if (!shouldStop()) {
                    if (goodUrl.length() == 0) log("SKIP valid remote: set MediaTest-GoodURL");
                    else validRemote();
                }
                if (!shouldStop()) {
                    if (url.length() == 0) log("SKIP remote: set MediaTest-BadURL or URL field");
                    else invalidRemote();
                }
            } catch (Exception error) {
                fail("test runner: " + error);
            } finally {
                synchronized (this) {
                    finished = true;
                    stage = null;
                    log((failures == 0 && !cancelled ? "PASS" : "FAIL")
                            + " finished; failures=" + failures
                            + (goodUrl.length() == 0 ? "; valid remote SKIPPED" : "")
                            + (url.length() == 0 ? "; invalid remote SKIPPED" : ""));
                }
            }
        }

        private void watch() {
            while (!finished && !cancelled) {
                synchronized (this) {
                    if (stage != null && System.currentTimeMillis() >= deadline) {
                        timedOut = true;
                        fail("TIMEOUT in " + stage + "; Exit/relaunch if the call stays blocked");
                        return;
                    }
                }
                try { Thread.sleep(100); } catch (InterruptedException ignored) { }
            }
        }

        private Player localPlayer(Events events, int milliseconds) throws Exception {
            stage("local createPlayer");
            Player player = Manager.createPlayer(new ByteArrayInputStream(wav(milliseconds)), "audio/x-wav");
            events.player = player;
            player.addPlayerListener(events);
            stage("local realize");
            player.realize();
            stage("local prefetch");
            player.prefetch();
            return player;
        }

        private void close(Events events) {
            if (events.player == null) return;
            stage("close");
            events.markClosed();
            events.player.close();
            if (events.player.getState() != Player.CLOSED) fail("close left player open");
            events.player.close();
            closedObservers.addElement(events);
        }

        private void playToEnd(int cycle) throws Exception {
            Events events = new Events();
            try {
                Player player = localPlayer(events, 250);
                stage("completion " + cycle + " start");
                player.start();
                stage("completion " + cycle + " END_OF_MEDIA");
                events.awaitTerminal(timeout - 500);
                if (events.errorCount != 0) fail("completion " + cycle + " ERROR: " + events.errorData);
                else if (events.endCount != 1) fail("completion " + cycle + " END_OF_MEDIA count=" + events.endCount);
                else log("PASS completion " + cycle + " END_OF_MEDIA");
            } catch (Exception error) {
                fail("completion " + cycle + ": " + error);
            } finally {
                close(events);
            }
        }

        private void closeEarly(int cycle) throws Exception {
            Events events = new Events();
            try {
                Player player = localPlayer(events, 1000);
                stage("close cycle " + cycle + " start");
                player.start();
                close(events);
                events.player = null;
                if (cycle % 4 == 0 || cycle == cycles) log("PASS create/start/close " + cycle + "/" + cycles);
            } catch (Exception error) {
                fail("close cycle " + cycle + ": " + error);
            } finally {
                close(events);
            }
        }

        private boolean nativeHttpUrl(String value) {
            // Jbed routes HTTP URLs ending in .mp3 directly to its native URI player.
            return value.toLowerCase().startsWith("http://") && value.toLowerCase().endsWith(".mp3");
        }

        private void validRemote() {
            if (!nativeHttpUrl(goodUrl)) {
                fail("valid remote URL must use http:// and end in .mp3");
                return;
            }
            Events events = new Events();
            long begin = System.currentTimeMillis();
            String operation = "createPlayer";
            try {
                log("VALID REMOTE begin (HTTP 200, audio/mpeg, valid MP3)");
                stage("valid remote " + operation);
                events.player = Manager.createPlayer(goodUrl);
                events.player.addPlayerListener(events);
                operation = "realize";
                stage("valid remote " + operation);
                events.player.realize();
                operation = "prefetch";
                stage("valid remote " + operation);
                events.player.prefetch();
                operation = "start";
                stage("valid remote " + operation);
                events.player.start();
                stage("valid remote END_OF_MEDIA");
                events.awaitTerminal(timeout - 500);
                if (events.errorCount != 0) fail("valid remote ERROR: " + events.errorData);
                else if (events.endCount != 1) fail("valid remote END_OF_MEDIA count=" + events.endCount);
                else log("PASS valid remote MP3 END_OF_MEDIA in " + (System.currentTimeMillis() - begin) + "ms");
            } catch (Exception error) {
                fail("valid remote " + operation + ": " + error);
            } finally {
                close(events);
            }
        }

        private void invalidRemote() {
            if (!nativeHttpUrl(url)) {
                fail("remote URL must use http://, end in .mp3, and return HTTP 200 invalid MP3 bytes");
                return;
            }
            Events events = new Events();
            long begin = System.currentTimeMillis();
            String operation = "createPlayer";
            boolean rejected = false;
            try {
                stage("remote " + operation);
                log("REMOTE begin (HTTP 200, audio/mpeg, invalid MP3 bytes)");
                events.player = Manager.createPlayer(url);
                events.player.addPlayerListener(events);
                operation = "realize";
                stage("remote " + operation);
                events.player.realize();
                operation = "prefetch";
                stage("remote " + operation);
                events.player.prefetch();
                operation = "start";
                stage("remote " + operation);
                events.player.start();
                stage("remote ERROR callback");
                events.awaitTerminal(timeout - 500);
                rejected = events.errorCount > 0;
                if (rejected) log("REMOTE ERROR: " + events.errorData);
            } catch (MediaException error) {
                rejected = true;
                log("REMOTE " + operation + " MediaException: " + error.getMessage());
            } catch (IOException error) {
                rejected = true;
                log("REMOTE " + operation + " IOException: " + error.getMessage());
            } catch (Exception error) {
                fail("remote unexpected " + operation + ": " + error);
            } finally {
                if (events.endCount != 0) fail("invalid remote media emitted END_OF_MEDIA");
                if (!rejected) fail("invalid remote media did not report failure");
                else if (!shouldStop()) log("PASS remote failure returned in "
                        + (System.currentTimeMillis() - begin) + "ms");
                close(events);
            }
        }
    }

    private static final class Events implements PlayerListener {
        Player player;
        volatile int endCount;
        volatile int errorCount;
        volatile String errorData;
        private boolean closed;
        private int lateEnds;

        public synchronized void playerUpdate(Player source, String event, Object data) {
            if (PlayerListener.END_OF_MEDIA.equals(event)) {
                endCount++;
                if (closed) lateEnds++;
            } else if (PlayerListener.ERROR.equals(event)) {
                errorCount++;
                errorData = String.valueOf(data);
            }
            notifyAll();
        }

        synchronized void markClosed() { closed = true; }
        synchronized int lateEndCount() { return lateEnds; }

        synchronized void awaitTerminal(long milliseconds) throws InterruptedException {
            long deadline = System.currentTimeMillis() + milliseconds;
            while (endCount == 0 && errorCount == 0) {
                long remaining = deadline - System.currentTimeMillis();
                if (remaining <= 0) return;
                wait(remaining);
            }
        }
    }

    private static byte[] wav(int milliseconds) {
        int samples = milliseconds * 8;
        byte[] bytes = new byte[44 + samples];
        ascii(bytes, 0, "RIFF");
        littleEndian(bytes, 4, bytes.length - 8, 4);
        ascii(bytes, 8, "WAVEfmt ");
        littleEndian(bytes, 16, 16, 4);
        littleEndian(bytes, 20, 1, 2);
        littleEndian(bytes, 22, 1, 2);
        littleEndian(bytes, 24, 8000, 4);
        littleEndian(bytes, 28, 8000, 4);
        littleEndian(bytes, 32, 1, 2);
        littleEndian(bytes, 34, 8, 2);
        ascii(bytes, 36, "data");
        littleEndian(bytes, 40, samples, 4);
        for (int i = 0; i < samples; i++) bytes[44 + i] = (byte)(i % 32 < 16 ? 132 : 124);
        return bytes;
    }

    private static void ascii(byte[] target, int offset, String value) {
        for (int i = 0; i < value.length(); i++) target[offset + i] = (byte)value.charAt(i);
    }

    private static void littleEndian(byte[] target, int offset, int value, int count) {
        for (int i = 0; i < count; i++) {
            target[offset + i] = (byte)value;
            value >>>= 8;
        }
    }
}
