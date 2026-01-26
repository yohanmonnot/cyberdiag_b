package edu.cyclonicforce.fr.ui.metier.popup;

public interface PopupInfo {
    String getFxmlPath();
    String getGlobalColor();
    String getIconPath();
    boolean isConfirmButton();
    String getConfirmButtonColor();
    boolean isCancelButton();
    String getCancelButtonColor();
}
