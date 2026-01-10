package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * Interface representing a command-line parameter.
 */
public interface Param {
    /**
     * Gets the name of the parameter.
     * @return the name of the parameter.
     */
    String getName();

    /**
     * Gets the description of the parameter.
     * @return the description of the parameter.
     */
    String description();

    /**
     * Indicates whether the parameter is a flag (boolean).
     * @return true if the parameter is a flag, false otherwise.
     */
    boolean getsIsFlag();

    /**
     * Gets the type strategy for parsing the parameter's value.
     * @return the type strategy.
     */
    ArgTypeStrategy<?> getTypeStrategy();
}
