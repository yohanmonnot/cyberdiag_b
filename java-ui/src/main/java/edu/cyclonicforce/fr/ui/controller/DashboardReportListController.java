package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.ReportExec;
import edu.cyclonicforce.fr.ui.metier.DiagnosticReport;
import edu.cyclonicforce.fr.ui.metier.DiagnosticReportModule;
import edu.cyclonicforce.fr.ui.metier.DiagnosticReportModule;
import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DashboardReportListController implements DasboardController {
    @FXML
    public VBox reportBox;
    @FXML
    private VBox rootVBox;

    private AppController appController;
    private List<DiagnosticReport> diagnosticReportList;
    private List<DashboardReportListElementController> dashboardReportListElementControllers;

    public DashboardReportListController() {
        this.diagnosticReportList = new ArrayList<>();
        this.dashboardReportListElementControllers = new ArrayList<>();
    }

    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
        refresh();
    }

    private void refresh(){
        reportBox.getChildren().clear();
        refreshReportList();

        for (DiagnosticReport report : diagnosticReportList) {
            addReportElement(report);
        }
    }

    private void refreshReportList(){
        this.diagnosticReportList.clear();

        ReportExec reportExec = new ReportExec();

        this.diagnosticReportList.addAll(reportExec.listReports(null, null, null));
    }

    private void addReportElement(DiagnosticReport report) {
        ViewLoader<DashboardReportListElementController> loader = new ViewLoader<>();

        loader.load("/edu/cyclonicforce/fr/ui/fxml/DashboardReportListElement.fxml", appController);

        DashboardReportListElementController controller = loader.getController();

        controller.setDiagnosticReport(report);
        if (appController != null) {
            controller.setAppController(appController);
        } else {
            System.err.println("AppController is null in DashboardReportListController");
        }
        this.dashboardReportListElementControllers.add(controller);

        reportBox.getChildren().add(loader.getRoot());
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
