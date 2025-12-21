package edu.cyclonicforce.fr.ui.lib.bashExecutor;

import com.google.gson.Gson;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class ListModule {
    private final SettingsSingleton settings;
    private final Gson gson;

    public ListModule () {
        this.gson = new Gson();
        this.settings = SettingsSingleton.getInstance();
    }

    public void run() {
        String projectRootPath = settings.getArgumentValue("projectRootPath");
        File projectRoot = new File(projectRootPath);
        File scriptFile = new File(projectRoot, "main.sh");

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
            pb.redirectErrorStream(true);

            Process process = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();

                if (line.startsWith("{") && line.endsWith("}")) {
                    jsonLine = line;
                }
            }

            process.waitFor();

        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors de l'exécution du module : " + e.getMessage(), e);
        }

        if (jsonLine == null) {
            throw new BashExecutionException("Aucune sortie JSON détectée lors de l'exécution du module.");
        }

        try {
            System.out.println("JSON reçu : " + jsonLine);
            // Mapping automatique vers ModuleReturn (les noms des clés JSON correspondent aux attributs)
            // return gson.fromJson(jsonLine, Module.class);
        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors de la désérialisation du JSON : " + e.getMessage(), e);
        }
    }
}
