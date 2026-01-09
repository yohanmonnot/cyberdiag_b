package edu.cyclonicforce.fr.ui.metier;

public enum Scenes {
<<<<<<< HEAD
    ACCUEIL("/edu/cyclonicforce/fr/ui/fxml/Accueil.fxml"),
    DASHBOARD("/edu/cyclonicforce/fr/ui/fxml/AcceuilApp.fxml"),
    DASHBOARD_MODULES("/edu/cyclonicforce/fr/ui/fxml/Modules.fxml"),
    DASHBOARD_DIAGS("/edu/cyclonicforce/fr/ui/fxml/Diagnostics.fxml"),
    DASHBOARD_SETTINGS(null),
    DASHBOARD_REPORTS(null),
    DASHBOARD_HELP(null),
    IN_SCAN("/edu/cyclonicforce/fr/ui/fxml/InScan.fxml");

    private final String fxmlPath;

    // 3. Le constructeur (automatiquement appelé pour chaque constante)
    Scenes(String fxmlPath) {
        this.fxmlPath = fxmlPath;
    }

    // 4. Le Getter pour récupérer le chemin depuis le contrôleur
    public String getPath() {
        return this.fxmlPath;
    }
=======
    ACCEUIL,
    DASHBOARD,
    DASHBOARD_MODULES,
    DASHBOARD_DIAGS,
    DASHBOARD_SETTINGS,
    DASHBOARD_REPORTS,
    DASHBOARD_HELP
>>>>>>> 5343811 (JE SUIS UN AVION)
}
