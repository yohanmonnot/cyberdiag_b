package edu.cyclonicforce.fr.ui.metier;

import java.util.function.Consumer;

public class PopUpData {
    private final PopUpType type;
    private final String title;
    private final String message;
    private final String acceptButtonText;
    private final Runnable onAccept;
    private final String cancelButtonText;
    private final Runnable onCancel;

    public PopUpData(PopUpType type, String title, String message, String acceptButtonText, Runnable onAccept, String cancelButtonText, Runnable onCancel) {
        this.type = type;
        this.title = title;
        this.message = message;
        this.acceptButtonText = acceptButtonText;
        this.onAccept = onAccept;
        this.cancelButtonText = cancelButtonText;
        this.onCancel = onCancel;
    }

    public PopUpType getType() {
        return type;
    }

    public String getFxmlPath() {
        return type.getFxmlPath();
    }

    public String getTitle() {
        return title;
    }

    public String getMessage() {
        return message;
    }

    public String getAcceptButtonText() {
        return acceptButtonText;
    }

    public Runnable getOnAccept() {
        return onAccept;
    }

    public String getCancelButtonText() {
        return cancelButtonText;
    }

    public Runnable getOnCancel() {
        return onCancel;
    }
}
