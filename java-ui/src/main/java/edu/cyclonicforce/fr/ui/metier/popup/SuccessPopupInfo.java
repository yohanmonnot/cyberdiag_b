package edu.cyclonicforce.fr.ui.metier.popup;

public class SuccessPopupInfo implements PopupInfo {
    @Override
    public String getFxmlPath() {
        return "/edu/cyclonicforce/fr/ui/fxml/PopUp.fxml";
    }

    @Override
    public String getGlobalColor() {
        return "#04B917";
    }

    @Override
    public String getIconPath() {
        return "valid.png";
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
