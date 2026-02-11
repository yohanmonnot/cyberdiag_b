package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.TextField;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.DirectoryChooser;
import javafx.stage.Window;

import java.io.File;

public class DashboardSettingsController implements DasboardController {
    @FXML
    public TextField savePathTextField;
    @FXML
    public VBox rootVBox;
    @FXML
    public HBox browseSavePathField;

    AppController appController;
    SettingsSingleton settings = SettingsSingleton.getInstance();

    @FXML
    public void initialize() {
        String currentSavePath = settings.getArgumentValue("savePath");
        savePathTextField.setText(currentSavePath);
        savePathTextField.setDisable(true);
    }

    @FXML
    private void handleChooseDirectory(MouseEvent event) {
        if (event != null) {
            if (event.getSource()==browseSavePathField) {
                DirectoryChooser directoryChooser = new DirectoryChooser();
                directoryChooser.setTitle("Sélectionner un dossier");
                Window ownerWindow = ((Node) event.getTarget()).getScene().getWindow();

                File selectedDirectory = directoryChooser.showDialog(ownerWindow);

                if (selectedDirectory != null) {
                    String selectedPath = selectedDirectory.getAbsolutePath();
                    savePathTextField.setText(selectedPath);
                    settings.set("savePath", selectedPath);
                }
            }
        }
    }

    /**
     * Sets the application controller.
     * @param appController The main application controller
     */
    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Toggles the size of the dashboard based on the menu state.
     * @param menuState The current state of the menu
     */
    @Override
    public void toggleSize(boolean menuState) {
        if (menuState) {
            rootVBox.setMinWidth(1300);
            rootVBox.setPrefWidth(1300);
            rootVBox.setMaxWidth(1300);
        } else {
            rootVBox.setMinWidth(1500);
            rootVBox.setPrefWidth(1500);
            rootVBox.setMaxWidth(1500);
        }
    }
}
