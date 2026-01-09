package edu.cyclonicforce.fr.ui.lib.bashExecutor;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.ModuleType;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Class responsible for executing a Bash script to list modules
 */
public class ListModule {
    /**
     * Settings singleton instance for configuration access
     */
    private final SettingsSingleton settings;
    /**
     * Gson instance for JSON parsing
     */
    private final Gson gson;
    /**
     * List of modules retrieved from the Bash script
     */
    private final List<Module> modules = new ArrayList<>();

    /**
     * DTO : Exact structure of module JSON returned by the Bash script
     */
    private static class ModuleJsonDTO {
        String name;
        String version;
        String type;
        String description;
        String author;
    }

    /**
     * Constructor initializing Gson and settings
     */
    public ListModule() {
        this.gson = new Gson();
        this.settings = SettingsSingleton.getInstance();
    }

    /**
     * Executes the Bash script to list modules and parses the output
     */
    public void run() {
        String projectRootPath = settings.getArgumentValue("projectRootPath");
        System.out.println(projectRootPath);
        File projectRoot = new File(projectRootPath);
        File scriptFile = new File(projectRoot, "main.sh");

        this.modules.clear();

        if (!scriptFile.exists()) {
            throw new BashExecutionException("Script main.sh introuvable à : " + scriptFile.getAbsolutePath());
        }

        List<String> command = new ArrayList<>();
        command.add("bash");
        command.add(scriptFile.getName());
        command.add("--script");
        command.add("list");

        String jsonLine = null;

        try {
            ProcessBuilder pb = new ProcessBuilder(command);
            pb.directory(projectRoot);

            // Rediriger stderr vers stdout pour voir les erreurs dans le flux principal si besoin
            // (Attention: cela peut polluer le JSON si le script est bavard en erreur,
            // mais votre script sépare bien les logs du JSON final)
            pb.redirectErrorStream(true);

            Process process = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // On capture la ligne qui contient le tableau JSON [...]
                if (line.startsWith("[") && line.endsWith("]")) {
                    jsonLine = line;
                } else {
                    // Optionnel : Afficher les logs de debug du bash dans la console Java
                    // System.out.println("[BASH] " + line);
                }
            }
            process.waitFor();

        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors de l'exécution du processus Bash : " + e.getMessage(), e);
        }

        if (jsonLine == null) {
            // Si aucun JSON n'est trouvé (ex: aucun module ou erreur silencieuse), on renvoie une liste vide
        }

        try {
            // 1. Désérialiser le JSON en une liste de DTOs
            Type listType = new TypeToken<ArrayList<ModuleJsonDTO>>(){}.getType();
            List<ModuleJsonDTO> rawModules = gson.fromJson(jsonLine, listType);

            // 2. Convertir les DTOs en objets métier 'Module'
            List<Module> finalModules = new ArrayList<>();

            for (ModuleJsonDTO raw : rawModules) {
                try {
                    Module m = new Module(
                            raw.name,
                            raw.version,
                            raw.type,
                            raw.description,
                            raw.author,
                            new ArrayList<>()
                    );
                    finalModules.add(m);
                } catch (IllegalArgumentException e) {
                    System.err.println("Module invalide ignoré : " + raw.name + " - " + e.getMessage());
                }
            }

            this.modules.addAll(finalModules);
        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors du parsing du JSON : " + e.getMessage() + "\nJSON reçu : " + jsonLine, e);
        }
    }

    /**
     * Gets the list of modules
     * @return List of modules
     */
    public List<Module> getModules() {
        return new ArrayList<>(this.modules);
    }

    /**
     * Groups modules by their type
     * @return Map of ModuleType to list of Modules
     */
    public HashMap<ModuleType, List<Module>> getModulesByType() {
        HashMap<ModuleType, List<Module>> map = new HashMap<>();

        for (Module m : this.modules) {
            ModuleType type = m.getType();
            map.putIfAbsent(type, new ArrayList<>());
            map.get(type).add(m);
        }

        return map;
    }
}