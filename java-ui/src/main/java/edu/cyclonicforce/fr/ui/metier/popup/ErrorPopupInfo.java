package edu.cyclonicforce.fr.ui.metier.popup;

public class ErrorPopupInfo implements PopupInfo {
    @Override
    public String getFxmlPath() {
        return "/edu/cyclonicforce/fr/ui/fxml/PopUp.fxml";
    }

    @Override
    public String getGlobalColor() {
        return "#A8040A";
    }

    @Override
    public String getIconPath() {
        return "error.png";
    }

    @Override
    public boolean isConfirmButton() {
        return true;
    }

    @Override
    public String getConfirmButtonColor() {
        return "#AEAAAA";
    }

    @Override
    public boolean isCancelButton() {
        return false;
    }

    @Override
    public String getCancelButtonColor() {
        return "";
    }
}
