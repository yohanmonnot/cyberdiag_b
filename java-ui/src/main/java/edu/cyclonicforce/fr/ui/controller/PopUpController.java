package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.PopUpData;
import edu.cyclonicforce.fr.ui.metier.PopUpType;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;

import java.util.Objects;

public class PopUpController {
    @FXML
    public ImageView iconView;
    @FXML
    public Text titleText;
    @FXML
    public Text messageText;
    @FXML
    public Button cancelButton;
    @FXML
    public Button agreeButton;
    @FXML
    public VBox borderContainer;

    private PopUpData popUpData;
    private Runnable closeAction;

    public void setPopUpData(PopUpData popUpData) {
        this.popUpData = popUpData;
        refresh();
    }

    public void setCloseAction(Runnable closeAction) {
        this.closeAction = closeAction;
        refresh();
    }

    private void refresh() {
        if (popUpData != null) {
            if (titleText != null) {
                titleText.setText(popUpData.getTitle());
            }
            if (messageText != null) {
                messageText.setText(popUpData.getMessage());
            }
            if (borderContainer != null) {
                borderContainer.setStyle("-fx-border-color: " + popUpData.getType().getPopupInfo().getGlobalColor() + "; -fx-border-radius: 50; -fx-border-width: 8;");
            }
            if (iconView != null) {
                iconView.setImage(new Image(Objects.requireNonNull(getClass().getResourceAsStream("/edu/cyclonicforce/fr/ui/images/icons/popup/" + popUpData.getType().getPopupInfo().getIconPath()))));
            }
            if (agreeButton != null) {
                agreeButton.setVisible(popUpData.getType().getPopupInfo().isConfirmButton());
                agreeButton.setStyle("-fx-background-color: " + popUpData.getType().getPopupInfo().getConfirmButtonColor() + ";");
                if( popUpData.getAcceptButtonText() != null && !popUpData.getAcceptButtonText().isEmpty()) {
                    agreeButton.setText(popUpData.getAcceptButtonText());
                }
                if ( popUpData.getOnAccept() != null) {
                    agreeButton.setOnMouseClicked(event -> {
                        popUpData.getOnAccept().run();
                        if (closeAction != null) {
                            closeAction.run();
                        }
                    });
                }
            }
            if (cancelButton != null) {
                cancelButton.setVisible(popUpData.getType().getPopupInfo().isCancelButton());
                cancelButton.setStyle("-fx-background-color: " + popUpData.getType().getPopupInfo().getCancelButtonColor() + ";");
                if( popUpData.getCancelButtonText() != null && !popUpData.getCancelButtonText().isEmpty()) {
                    cancelButton.setText(popUpData.getCancelButtonText());
                }
                if ( popUpData.getOnCancel() != null) {
                    cancelButton.setOnMouseClicked(event -> {
                        popUpData.getOnCancel().run();
                        if (closeAction != null) {
                            closeAction.run();
                        }
                    });
                }
            }
        } else {
            System.err.println("PopUpData is not set in PopUpController.");
        }
    }
}
