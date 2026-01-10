package edu.cyclonicforce.fr.ui.lib.util;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

/**
 * A singleton logger class for logging messages with different severity levels to both console and a log file.
 */
public class Logger {
    /**
     * The singleton instance of the Logger.
     */
    private static Logger instance = null;

    /**
     * The date-time formatter for log timestamps.
     */
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * The settings singleton instance for configuration.
     */
    private final SettingsSingleton settings = SettingsSingleton.getInstance();
    /**
     * The path to the log file.
     */
    private String logFilePath = Objects.requireNonNullElse(settings.getArgumentValue("logs-output"), "logs/javaUi.log");

    /**
     * Private constructor to prevent instantiation.
     */
    private Logger() {
        File logFile = new File(logFilePath);
        File parentDir = logFile.getParentFile();
        if (parentDir != null && !parentDir.exists()) {
            boolean created = parentDir.mkdirs();
            if (created) {
                System.out.println("Dossier de logs créé : " + parentDir.getAbsolutePath());
            }
        }
    }

    /**
     * Returns the singleton instance of the Logger.
     * @return the Logger instance
     */
    public static synchronized Logger getInstance() {
        if (instance == null) {
            instance = new Logger();
        }
        return instance;
    }

    /**
     * Logs an informational message if verbose or debug mode is enabled.
     * @param message the message to log
     */
    public void log(String message) {
        if (settings.getArgumentValue("verbose") == Boolean.TRUE || settings.getArgumentValue("debug") == Boolean.TRUE) {
            print("INFO", message);
        }
    }

    /**
     * Logs a formatted informational message if verbose or debug mode is enabled.
     * @param format the format string
     * @param args the arguments for the format string
     */
    public void log(String format, Object... args) {
        log(String.format(format, args));
    }

    /**
     * Logs a debug message if debug mode is enabled.
     * @param message the debug message to log
     */
    public void debug(String message) {
        if (settings.getArgumentValue("debug") == Boolean.TRUE) {
            print("DEBUG", message);
        }
    }

    /**
     * Logs a formatted debug message if debug mode is enabled.
     * @param format the format string
     * @param args the arguments for the format string
     */
    public void debug(String format, Object... args) {
        debug(String.format(format, args));
    }

    /**
     * Logs an error message.
     * @param message the error message to log
     */
    public void error(String message) {
        print("ERROR", message);
    }

    /**
     * Logs a formatted error message.
     * @param format the format string
     * @param args the arguments for the format string
     */
    public void error(String format, Object... args) {
        error(String.format(format, args));
    }

    /**
     * Logs an error message along with a throwable's message and stack trace if enabled.
     * @param message the error message to log
     * @param t the throwable associated with the error
     */
    public void error(String message, Throwable t) {
        print("ERROR", message + " -> " + t.getMessage());
        if (settings.getArgumentValue("show-stack-trace") == Boolean.TRUE) {
            StringBuilder sb = new StringBuilder();
            for (StackTraceElement element : t.getStackTrace()) {
                sb.append("\t at ").append(element.toString()).append("\n");
            }
            writeToFile(sb.toString());

            t.printStackTrace();
        }
    }

    /**
     * Sets the log file path.
     * @param path the new log file path
     */
    public void setLogFilePath(String path) {
        this.logFilePath = path;
        // Création du nouveau dossier si nécessaire
        File logFile = new File(logFilePath);
        if (logFile.getParentFile() != null) {
            logFile.getParentFile().mkdirs();
        }
    }

    /**
     * Gets the current timestamp formatted for logging.
     * @return the formatted timestamp
     */
    private String getTimestamp() {
        return LocalDateTime.now().format(DATE_FORMATTER);
    }

    /**
     * Prints the log message to console and writes it to the log file.
     * @param level the log level
     * @param message the log message
     */
    private void print(String level, String message) {
        String finalLog = String.format("%s : %s : %s", getTimestamp(), level, message);

        System.out.println(finalLog);
        writeToFile(finalLog);
    }

    /**
     * Writes a log line to the log file.
     * @param logLine the log line to write
     */
    private synchronized void writeToFile(String logLine) {
        try (FileWriter fw = new FileWriter(logFilePath, true);
             PrintWriter pw = new PrintWriter(fw)) {
            pw.println(logLine);
        } catch (IOException e) {
            System.err.println("CRITICAL: Impossible d'écrire dans le fichier de log (" + logFilePath + ") : " + e.getMessage());
        }
    }
}