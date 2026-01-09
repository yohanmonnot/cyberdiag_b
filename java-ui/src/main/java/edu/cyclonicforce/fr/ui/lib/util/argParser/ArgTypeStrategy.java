package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * Strategy interface for parsing different types of command-line argument values.
 *
 * @param <T> The type of the argument value after parsing.
 */
public interface ArgTypeStrategy<T> {
    /**
     * Parses the given string value into the appropriate type.
     * @param value The string value to parse.
     * @return The parsed value of type T.
     */
    T parse(String value);
    String getTypeName();
}