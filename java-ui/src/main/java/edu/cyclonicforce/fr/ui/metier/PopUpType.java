package edu.cyclonicforce.fr.ui.metier;

import edu.cyclonicforce.fr.ui.metier.popup.AlertPopupInfo;
import edu.cyclonicforce.fr.ui.metier.popup.ErrorPopupInfo;
import edu.cyclonicforce.fr.ui.metier.popup.InformationPopupInfo;
import edu.cyclonicforce.fr.ui.metier.popup.PopupInfo;

public enum PopUpType {
    INFO(new InformationPopupInfo()),
    ALERT(new AlertPopupInfo()),
    ERROR(new ErrorPopupInfo()),
    CONFIRM(new AlertPopupInfo());

    /**
     * Popup infos
     */
    private final PopupInfo popupInfo;

    /**
     * Constructor
     * @param popupInfo Info of the popup
     */
    PopUpType(PopupInfo popupInfo) {
        this.popupInfo = popupInfo;
    }

    /**
     * Returns the popup info
     * @return popup info
     */
    public PopupInfo getPopupInfo() {
        return popupInfo;
    }

    /**
     * Returns the FXML file path
     * @return FXML file path
     */
    public String getFxmlPath() {
        return popupInfo.getFxmlPath();
    }
}
