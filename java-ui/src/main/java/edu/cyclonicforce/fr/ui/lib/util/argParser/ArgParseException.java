package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * Exception thrown when there is an error parsing command-line arguments.
 */
public class ArgParseException extends RuntimeException {
    public ArgParseException(String message) {
        super(message);
    }
    public ArgParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
