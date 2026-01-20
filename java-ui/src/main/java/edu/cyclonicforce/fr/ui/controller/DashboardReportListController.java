package edu.cyclonicforce.fr.ui.controller;

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

    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
        refresh();
    }

    @FXML
    public void initialize(){
        refresh();
    }

    private void refresh(){
        reportBox.getChildren().clear();

        ViewLoader<DashboardReportListElementController> loader = new ViewLoader<>();

        // --- MAP POUR RAPPORT 1 (Note finale : 1) ---
        Map<String, List<DiagnosticReportModule>> map1 = new HashMap<>();
        List<DiagnosticReportModule> list1 = new ArrayList<>();
        // Un module qui échoue presque tout (Score 1)
        list1.add(new DiagnosticReportModule("diskCheck", 0, "", 1, "Remplacer le disque dur immédiatement."));
        map1.put("Hardware", list1);


        // --- MAP POUR RAPPORT 2 (Note finale : 2) ---
        Map<String, List<DiagnosticReportModule>> map2 = new HashMap<>();
        List<DiagnosticReportModule> list2 = new ArrayList<>();
        // Score moyen de 2
        list2.add(new DiagnosticReportModule("HardCheck", 0, "", 2, "Nettoyer les ventilateurs."));
        map2.put("System", list2);


        // --- MAP POUR RAPPORT 3 (Note finale : 3) ---
        Map<String, List<DiagnosticReportModule>> map3 = new HashMap<>();
        // Catégorie 1 : Réseau (Score 3)
        List<DiagnosticReportModule> list3a = new ArrayList<>();
        list3a.add(new DiagnosticReportModule("NetChack", 0, "", 3, "Vérifier le câble Ethernet."));
        map3.put("Network", list3a);
        // Catégorie 2 : Sécurité (Score 3)
        List<DiagnosticReportModule> list3b = new ArrayList<>();
        list3b.add(new DiagnosticReportModule("MalwareCheck", 0, "", 3, "Mettre à jour l'antivirus."));
        map3.put("Security", list3b);


        // --- MAP POUR RAPPORT 4 (Note finale : 4) ---
        Map<String, List<DiagnosticReportModule>> map4 = new HashMap<>();
        List<DiagnosticReportModule> list4 = new ArrayList<>();
        // Score solide de 4
        list4.add(new DiagnosticReportModule("processCheck", 0, "", 4, "Optimiser les processus de démarrage."));
        map4.put("Performance", list4);


        // --- MAP POUR RAPPORT 5 (Note finale : 5) ---
        Map<String, List<DiagnosticReportModule>> map5 = new HashMap<>();
        List<DiagnosticReportModule> list5 = new ArrayList<>();
        // Score parfait (5)
        list5.add(new DiagnosticReportModule("sysCheck", 0, "", 5, "Système en parfait état."));
        list5.add(new DiagnosticReportModule("uiiiiiiiiiiiiiii", 0, "", 5, "Aucune action requise."));
        map5.put("Optimization", list5);


        // 2. Création du tableau de rapports
        DiagnosticReport[] reports = new DiagnosticReport[]{
                new DiagnosticReport("Rapport Critique", "2024-01-15 09:30:00", 0, map1),
                new DiagnosticReport("Rapport Faible",   "2024-02-20 14:15:00", 0, map2),
                new DiagnosticReport("Rapport Moyen",    "2024-03-10 10:00:00", 0, map3),
                new DiagnosticReport("Rapport Bon",      "2024-04-05 16:45:00", 0, map4),
                new DiagnosticReport("Rapport Excellent","2024-05-12 16:45:00", 1, map5),
        };

        for (DiagnosticReport report : reports) {
            loader.load("/edu/cyclonicforce/fr/ui/fxml/DashboardReportListElement.fxml", appController);

            DashboardReportListElementController controller = loader.getController();

            controller.setDiagnosticReport(report);
            if (appController != null) {
                controller.setAppController(appController);
            } else {
                System.err.println("AppController is null in DashboardReportListController");
            }

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
