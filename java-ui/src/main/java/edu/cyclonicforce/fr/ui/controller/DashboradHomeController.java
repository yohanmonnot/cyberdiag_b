package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.List;

public class DashboradHomeController implements DasboardController {
    @FXML
    public HBox diagnosticCardsHBox;
    @FXML
    private VBox rootVBox;

    private AppController appController;
    private final List<DiagCardController> diagCardControllers = new ArrayList<>();

    @FXML
    public void initialize() {
        ViewLoader<DiagCardController> loader = new ViewLoader<>();
        for (int i = 0; i < 2; i++) {
            loader.load("/edu/cyclonicforce/fr/ui/fxml/DiagCard.fxml", appController);
            diagCardControllers.add(loader.getController());
            diagnosticCardsHBox.getChildren().add(loader.getRoot());
        }
    }

    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    @Override
    public void toggleSize(boolean menuOpen) {
        if (menuOpen) {
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