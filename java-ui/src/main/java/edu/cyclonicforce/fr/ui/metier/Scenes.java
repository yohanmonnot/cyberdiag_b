package edu.cyclonicforce.fr.ui.metier;

public enum Scenes {
    ACCUEIL("/edu/cyclonicforce/fr/ui/fxml/Accueil.fxml"),
    DASHBOARD("/edu/cyclonicforce/fr/ui/fxml/AcceuilApp.fxml"),
    DASHBOARD_MODULES("nope"),
    DASHBOARD_DIAGS("/edu/cyclonicforce/fr/ui/fxml/Diagnostics.fxml"),
    DASHBOARD_SETTINGS("nope"), // Exemple
    DASHBOARD_REPORTS("nope"),   // Exemple
    DASHBOARD_HELP("nope");

    private final String fxmlPath;

    // 3. Le constructeur (automatiquement appelé pour chaque constante)
    Scenes(String fxmlPath) {
        this.fxmlPath = fxmlPath;
    }

    // 4. Le Getter pour récupérer le chemin depuis le contrôleur
    public String getPath() {
        return this.fxmlPath;
    }
}
