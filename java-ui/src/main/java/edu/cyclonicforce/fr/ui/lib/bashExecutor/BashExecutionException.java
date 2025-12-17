package edu.cyclonicforce.fr.ui.lib.bashExecutor;

public class BashExecutionException extends RuntimeException {
    public BashExecutionException(String message) {
        super(message);
    }

    public BashExecutionException(String message, Throwable cause) {
        super(message, cause);
    }
}
