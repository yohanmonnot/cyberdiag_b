package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * Exception thrown when there is an error parsing command-line arguments.
 */
public class ArgParseException extends RuntimeException {
    /**
     * Constructor for ArgParseException.
     * @param message The error message.
     */
    public ArgParseException(String message) {
        super(message);
    }

    /**
     * Constructor for ArgParseException with cause.
     * @param message The error message.
     * @param cause The cause of the exception.
     */
    public ArgParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
