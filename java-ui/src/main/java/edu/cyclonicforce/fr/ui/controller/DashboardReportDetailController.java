package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.DiagnosticReport;
import edu.cyclonicforce.fr.ui.metier.DiagnosticReportModule;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;
import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Polygon;
import javafx.scene.text.Text;

import java.util.List;
import java.util.Map;

public class DashboardReportDetailController implements DasboardController {
    @FXML
    public VBox rootVBox;
    @FXML
    public Text diagnosticNameText;
    @FXML
    public Text diagnosticDateNumberText;
    @FXML
    public Polygon diagnosticScoreStar1;
    @FXML
    public Polygon diagnosticScoreStar2;
    @FXML
    public Polygon diagnosticScoreStar3;
    @FXML
    public Polygon diagnosticScoreStar4;
    @FXML
    public Polygon diagnosticScoreStar5;
    @FXML
    public Text diagnosticScoreText;
    @FXML
    public VBox categoriesBox;

    private Polygon[] diagnosticScoreStars;

    private AppController appController;
    private DiagnosticReport diagnosticReport;

    private int note = 0;

    @FXML
    public void initialize() {
        diagnosticScoreStars = new Polygon[]{
                diagnosticScoreStar1,
                diagnosticScoreStar2,
                diagnosticScoreStar3,
                diagnosticScoreStar4,
                diagnosticScoreStar5
        };

        refresh();
    }

    public void setDiagnosticReport(DiagnosticReport diagnosticReport) {
        this.diagnosticReport = new DiagnosticReport(diagnosticReport);
        refresh();
    }

    private void refresh() {
        if (diagnosticReport != null) {
            diagnosticNameText.setText(diagnosticReport.getReportName());
            diagnosticDateNumberText.setText(String.format("%s - %d", diagnosticReport.getReportDate(), diagnosticReport.getNumber()));
            setNote(diagnosticReport.getOverallNote());
        } else {
            diagnosticNameText.setText("N/A");
            diagnosticDateNumberText.setText("N/A - N/A");
            setNote(0);
        }

        categoriesBox.getChildren().clear();

        if (diagnosticReport != null) {
            for (Map.Entry<String, List<DiagnosticReportModule>> categoryEntry : diagnosticReport.getModuleResults().entrySet()) {
                addCategory(categoryEntry);
            }
        }
    }

    private void addCategory(Map.Entry<String, List<DiagnosticReportModule>> categoryEntry) {
        ViewLoader<DashboardReportDetailCategoryController> viewLoader = new ViewLoader<>();
        viewLoader.load("/edu/cyclonicforce/fr/ui/fxml/DashboardReportDetailCategory.fxml", appController);

        DashboardReportDetailCategoryController controller = viewLoader.getController();
        controller.setCategoryData(
                categoryEntry.getKey(),
                categoryEntry.getValue(),
                diagnosticReport.getCategoryNote(categoryEntry.getKey())
        );

        categoriesBox.getChildren().add(viewLoader.getRoot());
    }

    private void setNote(int note) {
        final String NOTE_PATTERN = "%d/5";
        this.note = note;

        if (note < 1 || note > 5) {
            this.note = 0;
            diagnosticScoreText.setText("N/A");
            for (Polygon star : diagnosticScoreStars) {
                star.setFill(Color.WHITE);
            }
        } else if (note <=2) {
            diagnosticScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : diagnosticScoreStars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.RED);
                }
            }
        } else if (note <=4) {
            diagnosticScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : diagnosticScoreStars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.YELLOW);
                }
            }
        } else {
            diagnosticScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : diagnosticScoreStars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.GREEN);
                }
            }
        }
    }

    /**
     * Sets the application controller.
     * @param appController The application controller
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
