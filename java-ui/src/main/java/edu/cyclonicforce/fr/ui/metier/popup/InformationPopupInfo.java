package edu.cyclonicforce.fr.ui.metier.popup;

public class InformationPopupInfo implements PopupInfo {
    @Override
    public String getFxmlPath() {
        return "/edu/cyclonicforce/fr/ui/fxml/PopUp.fxml";
    }

    @Override
    public String getGlobalColor() {
        return "#AEAAAA";
    }

    @Override
    public String getIconPath() {
        return "info.png";
    }

    @Override
    public boolean isConfirmButton() {
        return true;
    }

    @Override
    public String getConfirmButtonColor() {
        return getGlobalColor();
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
