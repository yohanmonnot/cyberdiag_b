package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.DiagnosticReportModule;
import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Polygon;
import javafx.scene.text.Text;

import java.util.ArrayList;
import java.util.List;

public class DashboardReportDetailCategoryController {
    @FXML
    public ImageView expandCollapseImageView;
    @FXML
    public Text categoryNameText;
    @FXML
    public Polygon Star1;
    @FXML
    public Polygon Star2;
    @FXML
    public Polygon Star3;
    @FXML
    public Polygon Star4;
    @FXML
    public Polygon Star5;
    @FXML
    public Text categoryScoreText;
    @FXML
    public VBox modulesContainerVBox;
    
    private Polygon[] stars;
    
    private AppController appController;
    private int note = 0;

    private String categoryName;
    private List<DiagnosticReportModule> moduleResults;
    
    @FXML
    public void initialize() {
        stars = new Polygon[]{Star1, Star2, Star3, Star4, Star5};

        expandCollapseImageView.setOnMouseClicked(event -> toggleExpandCollapse());

        refresh();
    }

    private void toggleExpandCollapse() {
        boolean isVisible = modulesContainerVBox.isVisible();
        modulesContainerVBox.setVisible(!isVisible);
        modulesContainerVBox.setManaged(!isVisible);
        if (isVisible) {
            expandCollapseImageView.setRotate(180);
        } else {
            expandCollapseImageView.setRotate(0);
        }
    }
    
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    public void setCategoryData(String categoryName, List<DiagnosticReportModule> moduleResults, int note) {
        this.categoryName = categoryName;

        List<DiagnosticReportModule> moduleResultsCopy = new ArrayList<>();
        for (DiagnosticReportModule moduleReturn : moduleResults) {
            moduleResultsCopy.add(new DiagnosticReportModule(moduleReturn));
        }
        this.moduleResults = moduleResultsCopy;

        if (note <= 0 || note > 5) {
            this.note = 0;
        } else {
            this.note = note;
        }
        refresh();
    }

    private void refresh() {
        categoryNameText.setText(categoryName==null?"unknown":categoryName);
        setNote(this.note);

        modulesContainerVBox.getChildren().clear();
        if (moduleResults != null) {
            for (DiagnosticReportModule moduleReturn : moduleResults) {
                addModule(moduleReturn);
            }
        }
    }

    private void addModule(DiagnosticReportModule moduleReturn) {
        ViewLoader<DashboardReportDetailModuleController> viewLoader = new ViewLoader<DashboardReportDetailModuleController>();
        viewLoader.load("/edu/cyclonicforce/fr/ui/fxml/DashboardReportDetailModule.fxml", appController);

        DashboardReportDetailModuleController moduleController = viewLoader.getController();
        moduleController.setModuleData(moduleReturn);

        modulesContainerVBox.getChildren().add(viewLoader.getRoot());
    }

    private void setNote(int note) {
        final String NOTE_PATTERN = "%d/5";

        if (note < 1 || note > 5) {
            this.note = 0;
            categoryScoreText.setText("N/A");
            for (Polygon star : stars) {
                star.setFill(Color.WHITE);
            }
        } else if (note <=2) {
            categoryScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.RED);
                }
            }
        } else if (note <=4) {
            categoryScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.YELLOW);
                }
            }
        } else {
            categoryScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.GREEN);
                }
            }
        }
    }
}
