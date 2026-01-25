package edu.cyclonicforce.fr.ui.lib.bashExecutor;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Executes diagnostic scripts and parses the output as a Map of String arrays.
 */
public class DiagStepReader {

    private final SettingsSingleton settings;
    private final Gson gson;

    public DiagStepReader() {
        this.gson = new Gson();
        this.settings = SettingsSingleton.getInstance();
    }

    /**
     * Runs a diagnostic script and expects a JSON map of string arrays.
     * Executes: bash main.sh --script <nomDiag>
     *
     * @param nomDiag The name of the diagnostic to run
     * @return Map<String, String[]> where key is the step name and value is an array of strings (logs/info)
     * @throws BashExecutionException if execution fails or JSON parsing fails
     */
    public Map<String, String[]> read(String nomDiag) throws BashExecutionException {
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
        command.add(nomDiag);

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

            int exitCode = process.waitFor();
            if (exitCode != 0 && jsonLine == null) {
                throw new BashExecutionException("Le script a échoué avec le code : " + exitCode);
            }

        } catch (Exception e) {
            throw new BashExecutionException("Erreur lors de l'exécution du diagnostic : " + e.getMessage(), e);
        }

        if (jsonLine == null) {
            throw new BashExecutionException("Aucune sortie JSON détectée pour le diagnostic " + nomDiag);
        }

        try {
            System.out.println("JSON reçu (Diag Map) : " + jsonLine);

            Type mapType = new TypeToken<Map<String, String[]>>(){}.getType();
            return gson.fromJson(jsonLine, mapType);

        } catch (Exception e) {
            throw new BashExecutionException("Erreur de désérialisation JSON (Map<String, String[]>) : " + e.getMessage(), e);
        }
    }
}