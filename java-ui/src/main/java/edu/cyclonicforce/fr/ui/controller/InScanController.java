package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.ModuleExecutor;
import edu.cyclonicforce.fr.ui.lib.bashExecutor.ReportExec;
import edu.cyclonicforce.fr.ui.metier.*;
import edu.cyclonicforce.fr.ui.metier.Module;
import javafx.application.Platform; // Import nécessaire pour les mises à jour UI
import javafx.fxml.FXML;
import javafx.scene.control.ScrollPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.StrokeType;
import javafx.scene.text.Font;
import javafx.scene.text.Text;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for the InScan view.
 */
public class InScanController {

    @FXML public Text progressText;
    @FXML public HBox progressBar;
    @FXML public VBox logContainer;
    @FXML public ScrollPane logScrollPane;

    private static final String MODULE_START_MESSAGE = "Démarrage du module %s..."; // Correction typo "madule"
    private static final String MODULE_END_MESSAGE = "Module %s terminé.";
    private static final String DIAG_CATEGORY_START_MESSAGE = "Démarrage de la catégorie de diagnostic %s...";
    private static final String DIAG_CATEGORY_END_MESSAGE = "Catégorie de diagnostic %s terminée.";

    private AppController appController;
    private Map<ModuleType, List<Module>> modulesByType;

    private int totalModules = 0;
    private int completedModules = 0;
    private DiagnosticReport diagnosticReport;

    @FXML
    public void initialize() {
        logContainer.getChildren().clear();
    }

    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Starts a scan based on the specified type and module name inside a detached thread.
     */
    public void startScan(ScanType scanType, String moduleName) {
        if (appController != null) {
            this.modulesByType = appController.getModulesByType();
        }

        Thread scanThread = new Thread(() -> {
            updateProgress(0.0);
            this.completedModules = 0;
            if (scanType == ScanType.DIAGNOSTIC) {
                List<Module> diags = modulesByType.get(ModuleType.DIAGNOSTIC);
                if (diags != null) {
                    for (Module diag : diags) {
                        if (diag.getName().equals(moduleName)) {
                            System.out.println(moduleName);
                            Diagnostic diagnostic = new Diagnostic(diag);

                            initializeReport(diagnostic.getTitle());
                            this.totalModules = diagnostic.getTotalSteps();
                            updateProgress(0.0);

                            startDiag(diagnostic);
                            System.out.println(diagnostic);
                            break;
                        }
                    }
                }
            } else if (scanType == ScanType.MODULE) {
                List<Module> modules = modulesByType.get(ModuleType.TOOL);
                if (modules != null) {
                    for (Module module : modules) {
                        if (module.getName().equals(moduleName)) {
                            System.out.println(moduleName);
                            initializeReport(module.getName());
                            this.totalModules = 1;
                            startModule(module, "Standalone Module Scan");

                            Runnable afterModule = () -> {
                                addPageLog("Showing report...");
                                showReport();
                            };

                            Runnable onAccept = () -> {
                                addPageLog("Saving report...");
                                saveReport();
                                addPageLog("Report saved.");
                                afterModule.run();
                            };

                            PopUpData reportPopUp = new PopUpData(
                                    PopUpType.ALERT,
                                    "Module terminé",
                                    "Le module " + module.getName() + " est terminé. Voulez-vous sauvegarder le rapport ?",
                                    "oui",
                                    onAccept,
                                    "non",
                                    afterModule
                            );
                            Platform.runLater(() -> {
                                appController.openPopup(reportPopUp);
                            });

                            break;
                        }
                    }
                }
            }
        });

        scanThread.setDaemon(true);
        scanThread.start();
    }

    private void startModule(Module module, String category) {
        ModuleExecutor executor = new ModuleExecutor();
        try {
            String startMsg = String.format(MODULE_START_MESSAGE, module.getName());
            addPageLog(startMsg);

            System.out.println(module.toString());
            System.out.println(startMsg);

            ModuleReturn result = executor.runModule(module.getName(), null);

            completedModules++;
            updateProgress(calculateProgress(completedModules, totalModules));

            System.out.println(String.format(MODULE_END_MESSAGE, module.getName()));

            DiagnosticReportModule reportModule = new DiagnosticReportModule(result, module.getName());
            diagnosticReport.addModuleResult(category, reportModule);

            addPageLog(String.format(MODULE_END_MESSAGE, module.getName()));
            addPageLog(result.toString());
        } catch (Exception e) {
            addPageLog("Erreur lors de l'exécution du module " + module.getName() + " : " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void startDiag(Diagnostic diag) {
        Map<String, Module[]> steps = diag.getSteps();

        for (String category : steps.keySet()) {
            String categoryStartMsg = String.format(DIAG_CATEGORY_START_MESSAGE, category);
            addPageLog(categoryStartMsg);

            Module[] modules = steps.get(category);
            for (Module module : modules) {
                startModule(module, category);
            }
            String categoryEndMsg = String.format(DIAG_CATEGORY_END_MESSAGE, category);
            addPageLog(categoryEndMsg);
        }

        Runnable afterDiagnostic = () -> {
            addPageLog("Showing report...");
            showReport();
        };

        Runnable onAccept = () -> {
            addPageLog("Saving report...");
            saveReport();
            addPageLog("Report saved.");
            afterDiagnostic.run();
        };

        PopUpData reportPopUp = new PopUpData(
                PopUpType.ALERT,
                "Diagnostic terminé",
                "Le diagnostic est terminé. Voulez-vous sauvegarder le rapport ?",
                "oui",
                onAccept,
                "non",
                afterDiagnostic
        );
        Platform.runLater(() -> {
            appController.openPopup(reportPopUp);
        });
    }

    private void updateProgress(double progress) {
        Platform.runLater(() -> {
            if (progress > 1 || progress < 0) {
                progressBar.setScaleX(0);
                progressText.setText("0%");
            } else {
                progressBar.setScaleX(progress);
                int percentage = (int) (progress * 100);
                progressText.setText(percentage + "%");
            }
        });
    }

    /**
     * Adds a log message to the page safely from any thread.
     */
    private void addPageLog(String message) {
        Platform.runLater(() -> {
            Text logText = new Text(message);
            logText.setFill(Color.WHITE);
            logText.setStrokeType(StrokeType.OUTSIDE);
            logText.setStrokeWidth(0.0);
            logText.setWrappingWidth(1468.0);
            logText.setFont(Font.font(36.0));
            logContainer.getChildren().add(logText);
            logScrollPane.setVvalue(1.0);
        });
    }

    private double calculateProgress(double current, double total) {
        if (total == 0) return 0.0;
        return current / total;
    }

    private void showReport() {
        Platform.runLater(() -> {
            appController.showReportDetail(diagnosticReport);
        });
    }

    private void initializeReport(String reportName) {
        String date = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        this.diagnosticReport = new DiagnosticReport(reportName, date, 0, new HashMap<String, List<DiagnosticReportModule>>());
    }

    private void saveReport() {
        ReportExec reportExec = new ReportExec();
        reportExec.addReport(diagnosticReport);
    }
}