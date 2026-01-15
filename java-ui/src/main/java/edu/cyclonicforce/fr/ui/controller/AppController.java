package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.ListModule;
import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.ModuleType;
import edu.cyclonicforce.fr.ui.metier.ScanType;
import edu.cyclonicforce.fr.ui.metier.Scenes;
import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.scene.Scene;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

import java.util.List;
import java.util.Map;
import java.util.Objects;

public class AppController {
    private final Stage mainStage;
    private Scenes currentScene = null;

    private BorderPane dashboardRoot = null;
    private Scene dashboardScene = null;

    private MenuController menuController;

    private Map<ModuleType, List<Module>> modulesByType;

    // On garde une référence générique au contrôleur central s'il implémente l'interface
    private DasboardController dashboardController;
    private InScanController inScanController;

    // État du menu : true = ouvert (300px), false = fermé (100px)
    private boolean menuState = false;

    public AppController(Stage mainStage) {
        if (mainStage == null) throw new IllegalArgumentException("Stage cannot be null");
        this.mainStage = mainStage;

        refreshModules();
    }

    public void init() {
        setScene(Scenes.ACCUEIL);
        this.mainStage.show();
    }

    public void toggleMenu() {
        // On inverse l'état
        this.menuState = !this.menuState;

        // 1. On met à jour le Menu (Gauche)
        if (this.menuController != null) {
            this.menuController.setExpandedMode(this.menuState);
        }

        // 2. On met à jour le Dashboard (Centre) UNIQUEMENT s'il est chargé
        if (this.dashboardController != null) {
            this.dashboardController.toggleSize(this.menuState);
        }
    }

    public void setScene(Scenes sceneToDisplay) {
        switch (sceneToDisplay) {
            case ACCUEIL -> {
                ViewLoader<AccueilController> loader = new ViewLoader<>();
                loader.load(Scenes.ACCUEIL.getPath(), this);
                loader.getController().setAppController(this);

                Scene acceuilScene = new Scene(loader.getRoot());
                this.mainStage.setTitle("CyberDiag - Accueil");
                this.mainStage.setScene(acceuilScene);
                this.currentScene = sceneToDisplay;
            }

            case IN_SCAN -> {
                ViewLoader<InScanController> loader = new ViewLoader<>();
                loader.load(Scenes.IN_SCAN.getPath(), this);
                loader.getController().setAppController(this);

                this.inScanController = loader.getController();

                Scene inScanScene = new Scene(loader.getRoot());
                this.mainStage.setTitle("CyberDiag - Analyse en cours");
                this.mainStage.setScene(inScanScene);
                this.currentScene = sceneToDisplay;
            }

            case DASHBOARD_HELP, DASHBOARD_REPORTS, DASHBOARD_SETTINGS,
                 DASHBOARD_DIAGS, DASHBOARD_MODULES, DASHBOARD -> {

                if (this.dashboardRoot == null) {
                    initDashboardStructure();
                }

                this.mainStage.setTitle("CyberDiag - Dashboard");
                setDashboardCenter(sceneToDisplay);
                this.mainStage.setScene(this.dashboardScene);
                this.currentScene = sceneToDisplay;
            }
        }
    }

    private void initDashboardStructure() {
        this.dashboardRoot = new BorderPane();
        // Le BorderPane prendra toute la taille
        this.dashboardRoot.setPrefSize(1600, 900);

        ViewLoader<MenuController> menuLoader = new ViewLoader<>();
        menuLoader.load("/edu/cyclonicforce/fr/ui/fxml/menu.fxml", this);

        this.menuController = menuLoader.getController();
        this.menuController.setExpandedMode(false);
        this.menuController.setAppController(this);

        // Initialisation de l'état visuel du menu (Ouvert par défaut)
        this.menuController.setExpandedMode(this.menuState);

        this.dashboardRoot.setLeft(menuLoader.getRoot());

        this.dashboardScene = new Scene(this.dashboardRoot);
        this.dashboardScene.getStylesheets().add(
                Objects.requireNonNull(getClass().getResource("/edu/cyclonicforce/fr/ui/styles/Main.css")).toExternalForm()
        );
    }

    public void setDashboardCenter(Scenes scene) {
        if (scene.getPath() == null) {
            System.err.println("Pas de FXML pour : " + scene);
            return;
        }

        ViewLoader<Object> contentLoader = new ViewLoader<>();
        contentLoader.load(scene.getPath(), this);

        Object controller = contentLoader.getController();

        if (controller instanceof DasboardController) {
            this.dashboardController = (DasboardController) controller;
            this.dashboardController.toggleSize(this.menuState);
        } else {
            this.dashboardController = null;
        }

        if (scene.equals(Scenes.DASHBOARD_DIAGS) && controller instanceof DashboardDiagnosticsController diagController) {
            diagController.setDiagList(modulesByType.getOrDefault(ModuleType.DIAGNOSTIC, List.of()));
        } else if (scene.equals(Scenes.DASHBOARD_MODULES) && controller instanceof DashboardModulesController modController) {
            modController.setModuleList(modulesByType.getOrDefault(ModuleType.TOOL, List.of()));
        }

        this.dashboardRoot.setCenter(contentLoader.getRoot());
    }

    public void refreshModules() {
        try {
            ListModule listModule = new ListModule();
            listModule.run();
            modulesByType = listModule.getModulesByType();
        } catch (Exception e) {
            System.err.println("Error while retrieving module list: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public Map<ModuleType, List<Module>> getModulesByType() {
        return modulesByType;
    }

    public void startScan(ScanType scanType, String moduleName) {
        if (this.inScanController != null) {
            this.inScanController.startScan(scanType, moduleName);
            setScene(Scenes.IN_SCAN);
        } else {
            System.err.println("InScanController is not initialized.");
        }
    }
}
