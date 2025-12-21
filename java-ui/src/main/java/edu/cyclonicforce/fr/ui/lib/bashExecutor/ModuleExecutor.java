package edu.cyclonicforce.fr.ui.lib.bashExecutor;

import com.google.gson.Gson;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/**
 * Gère l'exécution des modules via le script principal Bash.
 */
public class ModuleExecutor {

    private final SettingsSingleton settings;
    private final Gson gson;

    public ModuleExecutor() {
        this.gson = new Gson();
        this.settings = SettingsSingleton.getInstance();
    }

    /**
     * Exécute un module et retourne un objet ModuleReturn.
     * * @param name Nom du module à lancer (ex: "diskUsage")
     * @param args Liste des arguments additionnels (ex: ["--test"])
     * @return ModuleReturn contenant les données parsées du JSON
     */
    public ModuleReturn runModule(String name, List<String> args) throws BashExecutionException {
        // 1. Localisation du script principal
        String projectRootPath = settings.getArgumentValue("projectRootPath");
        File projectRoot = new File(projectRootPath);
        File scriptFile = new File(projectRoot, "main.sh");

        if (!scriptFile.exists()) {
            throw new BashExecutionException("Script main.sh introuvable à : " + scriptFile.getAbsolutePath());
        }

        // 2. Construction de la commande
        List<String> command = new ArrayList<>();
        command.add("bash");
        command.add(scriptFile.getName());
        command.add("--script");
        command.add(name);

        if (args != null && !args.isEmpty()) {
            command.addAll(args);
        }

        String jsonLine = null;

        // 3. Exécution de la commande
        try {
            ProcessBuilder pb = new ProcessBuilder(command);
            pb.directory(projectRoot); // Définit le contexte d'exécution à la racine du projet
            pb.redirectErrorStream(true); // Fusionne les erreurs avec la sortie standard

            Process process = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();

                // Détection de la ligne JSON (format : { ... })
                if (line.startsWith("{") && line.endsWith("}")) {
                    jsonLine = line;
                }
            }

            process.waitFor();

        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors de l'exécution du module : " + e.getMessage(), e);
        }

        // 4. Traitement du résultat
        if (jsonLine == null) {
            throw new BashExecutionException("Aucune sortie JSON détectée lors de l'exécution du module.");
        }

        try {
            System.out.println("JSON reçu : " + jsonLine);
            // Mapping automatique vers ModuleReturn (les noms des clés JSON correspondent aux attributs)
            return gson.fromJson(jsonLine, ModuleReturn.class);
        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors de la désérialisation du JSON : " + e.getMessage(), e);
        }
    }
}
