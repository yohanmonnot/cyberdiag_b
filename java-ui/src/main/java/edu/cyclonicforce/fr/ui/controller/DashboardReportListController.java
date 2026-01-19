package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.layout.VBox;

public class DashboardReportListController implements DasboardController {
    @FXML
    public VBox reportBox;
    @FXML
    private VBox rootVBox;

    private AppController appController;

    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    @FXML
    public void initialize(){
        refresh();
    }

    private void refresh(){
        reportBox.getChildren().clear();

        ViewLoader<DashboardReportListElementController> loader = new ViewLoader<>();
        for (int i = 0; i < 10; i++) {
            loader.load("/edu/cyclonicforce/fr/ui/fxml/DashboardReportListElement.fxml", appController);

            DashboardReportListElementController controller = loader.getController();

            controller.setNote(i%5 + 1);

            reportBox.getChildren().add(loader.getRoot());
        }
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
