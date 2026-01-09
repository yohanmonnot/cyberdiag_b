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

import java.util.*;

/**
 * Principal controller of the application managing scene transitions and module interactions.
 */
public class AppController {
    /**
     * The main application stage.
     */
    private final Stage mainStage;
    /**
     * The currently displayed scene.
     */
    private Scenes currentScene = null;
    /**
     * The root layout for the dashboard scene.
     */
    private BorderPane dashboardRoot = null;
    /**
     * The dashboard scene instance.
     */
    private Scene dashboardScene = null;
    /**
     * The menu controller for handling menu interactions.
     */
    private MenuController menuController;
    /**
     * A mapping of module types to their corresponding modules.
     */
    private Map<ModuleType, List<Module>> modulesByType;
    /**
     * Reference to the dashboard controller for updating dashboard content.
     */
    private DasboardController dashboardController;
    /**
     * Reference to the in-scan controller for managing scan operations.
     */
    private InScanController inScanController;
    /**
     * State of the menu (expanded or collapsed).
     */
    private boolean menuState = true;

    /**
     * Constructor for AppController.
     * @param mainStage The main application stage.
     */
    public AppController(Stage mainStage) {
        if (mainStage == null) throw new IllegalArgumentException("Stage cannot be null");
        this.mainStage = mainStage;

        refreshModules();
    }

    /**
     * Initializes the application by setting the initial scene and displaying the main stage.
     */
    public void init() {
        setScene(Scenes.ACCUEIL);
        this.mainStage.show();
    }

    /**
     * Toggles the menu state between expanded and collapsed, updating the dashboard accordingly.
     */
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

    /**
     * Sets the current scene based on the specified scene to display.
     * @param sceneToDisplay The scene to display.
     */
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

    /**
     * Initializes the dashboard structure with a BorderPane layout and loads the menu.
     */
    private void initDashboardStructure() {
        this.dashboardRoot = new BorderPane();
        // Le BorderPane prendra toute la taille
        this.dashboardRoot.setPrefSize(1600, 900);

        ViewLoader<MenuController> menuLoader = new ViewLoader<>();
        menuLoader.load("/edu/cyclonicforce/fr/ui/fxml/menu.fxml", this);

        this.menuController = menuLoader.getController();
        this.menuController.setAppController(this);

        // Initialisation de l'état visuel du menu (Ouvert par défaut)
        this.menuController.setExpandedMode(this.menuState);

        this.dashboardRoot.setLeft(menuLoader.getRoot());

        this.dashboardScene = new Scene(this.dashboardRoot);
        this.dashboardScene.getStylesheets().add(
                Objects.requireNonNull(getClass().getResource("/edu/cyclonicforce/fr/ui/styles/Main.css")).toExternalForm()
        );
    }

    /**
     * Sets the center content of the dashboard based on the specified scene.
     * @param scene The scene to load in the dashboard center.
     */
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

    /**
     * Refreshes the list of available modules by executing the ListModule command.
     */
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

    /**
     * Launches a scan with the specified type and module name.
     * @param scanType The type of scan to perform.
     * @param moduleName The name of the module to use for the scan.
     */
    public void launchScan(ScanType scanType, String moduleName) {
        setScene(Scenes.IN_SCAN);
        System.out.println("Launching scan: " + scanType + " for module: " + moduleName);
        if (this.inScanController != null) {
            this.inScanController.startScan(scanType, moduleName);
        }
    }

    /**
     * Gets a copy of the modules mapped by their types.
     * @return A map of module types to lists of modules.
     */
    public Map<ModuleType, List<Module>> getModulesByType() {
        Map<ModuleType, List<Module>> copy = new HashMap<>();

        for (Map.Entry<ModuleType, List<Module>> entry : modulesByType.entrySet()) {
            copy.put(entry.getKey(), new ArrayList<>(entry.getValue()));
        }

        return copy;
    }
}