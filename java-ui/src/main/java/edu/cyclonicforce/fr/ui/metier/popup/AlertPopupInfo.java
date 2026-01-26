package edu.cyclonicforce.fr.ui.metier.popup;

public class AlertPopupInfo implements PopupInfo {
    @Override
    public String getFxmlPath() {
        return "/edu/cyclonicforce/fr/ui/fxml/PopUp.fxml";
    }

    @Override
    public String getGlobalColor() {
        return "#F2FF04";
    }

    @Override
    public String getIconPath() {
        return "alert.png";
    }

    @Override
    public boolean isConfirmButton() {
        return true;
    }

    @Override
    public String getConfirmButtonColor() {
        return "0B6106";
    }

    @Override
    public boolean isCancelButton() {
        return true;
    }

    @Override
    public String getCancelButtonColor() {
        return "#780000";
    }
}
