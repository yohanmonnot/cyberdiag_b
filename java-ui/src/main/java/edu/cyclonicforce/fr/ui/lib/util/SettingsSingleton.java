package edu.cyclonicforce.fr.ui.lib.util;

import edu.cyclonicforce.fr.ui.lib.util.argParser.ArgParser;

import java.util.HashMap;
import java.util.Map;

/**
 * A singleton class to manage application settings parsed from command-line arguments.
 */
public class SettingsSingleton {
    /**
     * The single instance of SettingsSingleton.
     */
    private static SettingsSingleton instance = null;
    /**
     * A map to store parsed argument names and their corresponding values.
     */
    private final Map<String, Object> parsedArguments;

    /**
     * Private constructor to prevent instantiation from outside the class.
     */
    private SettingsSingleton() {
        // Private constructor to prevent instantiation
        this.parsedArguments = new HashMap<String, Object>();
        this.parsedArguments.putAll(getConstants());
    }

    /**
     * Returns the single instance of SettingsSingleton.
     * @return the single instance of SettingsSingleton
     */
    public static SettingsSingleton getInstance() {
        if (instance == null) {
            instance = new SettingsSingleton();
        }
        return instance;
    }

    /**
     * Returns a map of constant settings.
     * @return a map of constant settings
     */
    private static Map<String, Object> getConstants() {
        return Map.of(
                "projectRootPath", ".",
                "savePath", "./reports-exports"
        );
    }

    /**
     * Parses command-line arguments and stores them in the parsedArguments map.
     * @param args the command-line arguments to parse
     */
    public void parseArguments(String[] args) {
        this.parsedArguments.putAll(ArgParser.parseArgs(args));
    }

    /**
     * Retrieves the value of a parsed argument by its name.
     * @param argName the name of the argument
     * @param <T> the expected type of the argument value
     * @return the value of the argument, or null if not found
     */
    @SuppressWarnings("unchecked")
    public <T> T getArgumentValue(String argName) {
        if (!this.parsedArguments.containsKey(argName)) {
            return null;
        }
        return (T) this.parsedArguments.get(argName);
    }

    public void set(String argName, Object value) {
        this.parsedArguments.put(argName, value);
    }
}
