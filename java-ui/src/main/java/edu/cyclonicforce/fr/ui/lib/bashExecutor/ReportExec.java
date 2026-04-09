package edu.cyclonicforce.fr.ui.lib.bashExecutor;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import edu.cyclonicforce.fr.ui.metier.DiagnosticReport;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Class responsible for executing the 'reports' module Bash scripts via main.sh.
 * Handles Add, Get, List, and Remove operations.
 */
public class ReportExec {

    private final SettingsSingleton settings;
    private final Gson gson;

    public ReportExec() {
        this.gson = new Gson();
        this.settings = SettingsSingleton.getInstance();
    }

    /**
     * Adds a new report to the database.
     * Corresponds to: ./main.sh --script reports --add '{json}'
     *
     * @param report The report object to add.
     * @throws BashExecutionException if execution fails.
     */
    public void addReport(DiagnosticReport report) {
        // Serialisation de l'objet Java en JSON string
        String jsonPayload = gson.toJson(report);

        List<String> args = new ArrayList<>();
        args.add("--add");
        args.add(jsonPayload);

        executeBash("Report added successfully", args);
    }

    /**
     * Lists reports matching the criteria.
     * Corresponds to: ./main.sh --script reports --list ...
     *
     * @param nameFilter   Optional name filter (can be null or empty)
     * @param dateFilter   Optional date filter (YYYY-MM-DD HH:MM:SS)
     * @param numberFilter Optional number filter
     * @return A list of DiagnosticReport objects.
     */
    public List<DiagnosticReport> listReports(String nameFilter, String dateFilter, Integer numberFilter) {
        List<String> args = new ArrayList<>();
        args.add("--list");
        addFilterArgs(args, nameFilter, dateFilter, numberFilter);

        String jsonOutput = executeBash(null, args);

        if (jsonOutput == null || jsonOutput.isEmpty() || jsonOutput.equals("[]")) {
            return new ArrayList<>();
        }

        try {
            Type listType = new TypeToken<ArrayList<DiagnosticReport>>(){}.getType();
            return gson.fromJson(jsonOutput, listType);
        } catch (Exception e) {
            throw new BashExecutionException("Erreur parsing JSON (list): " + e.getMessage(), e);
        }
    }

    /**
     * Gets a single report matching the criteria.
     * Corresponds to: ./main.sh --script reports --get ...
     *
     * @param nameFilter   Optional name filter
     * @param dateFilter   Optional date filter
     * @param numberFilter Optional number filter
     * @return A single DiagnosticReport object, or null if not found.
     */
    public DiagnosticReport getReport(String nameFilter, String dateFilter, Integer numberFilter) {
        List<String> args = new ArrayList<>();
        args.add("--get");
        addFilterArgs(args, nameFilter, dateFilter, numberFilter);

        // Si getReport.sh ne trouve rien, il renvoie une erreur (exit code 1).
        // Nous devons gérer l'exception pour renvoyer null proprement.
        try {
            String jsonOutput = executeBash(null, args);
            if (jsonOutput == null || jsonOutput.isEmpty()) {
                return null;
            }
            return gson.fromJson(jsonOutput, DiagnosticReport.class);
        } catch (BashExecutionException e) {
            // Si le script retourne une erreur car aucun rapport n'est trouvé, on retourne null
            if (e.getMessage().contains("No report found")) {
                return null;
            }
            throw e;
        }
    }

    /**
     * Removes reports matching the criteria.
     * Corresponds to: ./main.sh --script reports --remove ...
     *
     * @param nameFilter   Optional name filter
     * @param dateFilter   Optional date filter
     * @param numberFilter Optional number filter
     */
    public void removeReport(String nameFilter, String dateFilter, Integer numberFilter) {
        List<String> args = new ArrayList<>();
        args.add("--remove");
        addFilterArgs(args, nameFilter, dateFilter, numberFilter);

        executeBash("Report(s) removed successfully", args);
    }

    // --- Private Helpers ---

    /**
     * Helper to append filter arguments to the command list.
     */
    private void addFilterArgs(List<String> args, String name, String date, Integer number) {
        if (name != null && !name.isEmpty()) {
            args.add("--name");
            args.add(name);
        }
        if (date != null && !date.isEmpty()) {
            args.add("--date");
            args.add(date);
        }
        if (number != null) {
            args.add("--number");
            args.add(String.valueOf(number));
        }
    }

    /**
     * Core execution logic.
     * Constructs the command: bash main.sh --script reports [moduleArgs]
     *
     * @param expectedSuccessMessage Optional string to check in output to confirm success (for non-JSON commands).
     * @param moduleArgs The arguments specific to the module (e.g., --add {...}).
     * @return The stdout content (useful for JSON returns).
     */
    private String executeBash(String expectedSuccessMessage, List<String> moduleArgs) {
        String projectRootPath = settings.getArgumentValue("projectRootPath");
        File projectRoot = new File(projectRootPath);
        File scriptFile = new File(projectRoot, "main.sh");

        if (!scriptFile.exists()) {
            throw new BashExecutionException("Script main.sh introuvable à : " + scriptFile.getAbsolutePath());
        }

        // Construction de la commande principale
        // ./main.sh --script reports ...
        List<String> command = new ArrayList<>();
        command.add("bash");
        command.add(scriptFile.getName());
        command.add("--script");
        command.add("reports");

        // Ajout des arguments du module (ex: --add, --list, le json, les filtres...)
        command.addAll(moduleArgs);

        StringBuilder outputBuilder = new StringBuilder();
        String jsonLine = null;

        try {
            ProcessBuilder pb = new ProcessBuilder(command);
            pb.directory(projectRoot);

            // On sépare stderr pour ne pas polluer le JSON si possible,
            // ou on le fusionne si on veut debuguer. Ici, fusionné pour capturer les erreurs logguées.
            pb.redirectErrorStream(true);

            Process process = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // Capture du JSON (Objet {...} ou Array [...])
                if ((line.startsWith("{") && line.endsWith("}")) || (line.startsWith("[") && line.endsWith("]"))) {
                    jsonLine = line;
                }
                outputBuilder.append(line).append("\n");
            }

            int exitCode = process.waitFor();

            if (exitCode != 0) {
                // Gestion fine : si c'est un "get" qui échoue car pas trouvé, c'est géré plus haut.
                // Sinon, c'est une vraie erreur.
                throw new BashExecutionException("Erreur Bash (Code " + exitCode + "): " + outputBuilder.toString());
            }

        } catch (BashExecutionException e) {
            throw e;
        } catch (Exception e) {
            throw new BashExecutionException("Erreur système lors de l'exécution Bash : " + e.getMessage(), e);
        }

        // Pour les commandes qui ne retournent pas de JSON (add, remove)
        if (expectedSuccessMessage != null) {
            if (!outputBuilder.toString().contains(expectedSuccessMessage)) {
                // Ce n'est pas forcément une erreur bloquante si l'exitCode est 0,
                // mais on peut vouloir logger un warning.
            }
            return outputBuilder.toString();
        }

        // Pour les commandes qui retournent du JSON (list, get)
        return jsonLine;
    }
}