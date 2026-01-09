package edu.cyclonicforce.fr.ui.lib.bashExecutor;

/**
 * Exception thrown when a Bash execution fails.
 */
public class BashExecutionException extends RuntimeException {
    /**
     * Constructor
     * @param message The exception message
     */
    public BashExecutionException(String message) {
        super(message);
    }

    /**
     * Constructor
     * @param message The exception message
     * @param cause The cause of the exception
     */
    public BashExecutionException(String message, Throwable cause) {
        super(message, cause);
    }
}
