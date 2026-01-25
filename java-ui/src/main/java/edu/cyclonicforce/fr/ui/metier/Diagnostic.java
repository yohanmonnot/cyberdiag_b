package edu.cyclonicforce.fr.ui.metier;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.DiagStepReader;
import edu.cyclonicforce.fr.ui.lib.bashExecutor.ListModule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Class representing a diagnostic with its metadata and steps.
 */
public class Diagnostic {
    /**
     * Title of the diagnostic.
     */
    private String title;
    /**
     * Version of the diagnostic.
     */
    private String version;
    /**
     * Author of the diagnostic.
     */
    private String author;
    /**
     * Description of the diagnostic.
     */
    private String description;
    /**
     * Level of the diagnostic.
     */
    private String level;
    /**
     * Steps of the diagnostic, mapped by step names.
     */
    private Map<String, Module[]> steps;

    /**
     * Constructor for Diagnostic.
     * @param title Title of the diagnostic.
     * @param version Version of the diagnostic.
     * @param author Author of the diagnostic.
     * @param description Description of the diagnostic.
     * @param level Level of the diagnostic.
     * @param steps Steps of the diagnostic, mapped by step names.
     */
    public Diagnostic(String title, String version, String author, String description, String level, Map<String, Module[]> steps) {
        setTitle(title);
        setVersion(version);
        setAuthor(author);
        setDescription(description);
        setLevel(level);
        setSteps(steps);
    }

    /**
     * Constructor for Diagnostic without steps.
     * Don't forget to set steps later using setSteps or setStepsViaString.
     * @param title the title of the diagnostic
     * @param version the version of the diagnostic
     * @param author the author of the diagnostic
     * @param description the description of the diagnostic
     * @param level the level of the diagnostic
     */
    public Diagnostic(String title, String version, String author, String description, String level) {
        setTitle(title);
        setVersion(version);
        setAuthor(author);
        setDescription(description);
        setLevel(level);
        this.steps = new HashMap<>();
    }

    public Diagnostic(Module module) {
        if (module == null) {
            throw new IllegalArgumentException("Module cannot be null");
        }
        if (module.getType() != ModuleType.DIAGNOSTIC) {
            throw new IllegalArgumentException("Module must be of type DIAGNOSTIC");
        }

        setTitle(module.getName());
        setVersion(module.getVersion());
        setAuthor(module.getAuthor());
        setDescription(module.getDescription());
        setLevel("Basic");
        DiagStepReader stepReader = new DiagStepReader();
        setStepsViaString(stepReader.read(module.getName()));
    }

    /**
     * Copy constructor for Diagnostic.
     * @param other Diagnostic object to copy from.
     */
    public Diagnostic(Diagnostic other) {
        setTitle(other.getTitle());
        setVersion(other.getVersion());
        setAuthor(other.getAuthor());
        setDescription(other.getDescription());
        setLevel(other.getLevel());
        setSteps(other.getSteps());
    }

    /**
     * Get the title of the diagnostic.
     * @return Title of the diagnostic.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Get the version of the diagnostic.
     * @return Version of the diagnostic.
     */
    public String getVersion() {
        return version;
    }

    /**
     * Get the author of the diagnostic.
     * @return Author of the diagnostic.
     */
    public String getAuthor() {
        return author;
    }

    /**
     * Get the description of the diagnostic.
     * @return Description of the diagnostic.
     */
    public String getDescription() {
        return description;
    }

    /**
     * Get the level of the diagnostic.
     * @return Level of the diagnostic.
     */
    public String getLevel() {
        return level;
    }

    /**
     * Get the steps of the diagnostic.
     * @return Steps of the diagnostic.
     */
    public Map<String, Module[]> getSteps() {
        Map<String, Module[]> stepsCopy = new HashMap<>();
        for (Map.Entry<String, Module[]> entry : steps.entrySet()) {
            stepsCopy.put(entry.getKey(), entry.getValue().clone());
        }
        return stepsCopy;
    }

    /**
     * Set the steps of the diagnostic.
     * @param steps Steps of the diagnostic.
     */
    public void setSteps(Map<String, Module[]> steps) {
        this.steps = new HashMap<>();
        for (Map.Entry<String, Module[]> entry : steps.entrySet()) {
            this.steps.put(entry.getKey(), entry.getValue().clone());
        }
    }

    /**
     * Set the steps of the diagnostic using a map of step names to module names.
     * @param steps Steps of the diagnostic.
     */
    public void setStepsViaString(Map<String, String[]> steps) {
        this.steps = new HashMap<>();

        if (steps == null || steps.isEmpty()) {
            return;
        }

        ListModule moduleLister = new ListModule();

        try {
            moduleLister.run();
        } catch (Exception e) {
            System.err.println("Error loading modules in Diagnostic: " + e.getMessage());
        }

        Map<ModuleType, List<Module>> modules = moduleLister.getModulesByType();

        List<Module> toolModules = modules != null ? modules.get(ModuleType.TOOL) : null;

        if (toolModules == null) {
            throw new IllegalArgumentException("Warning: No TOOL modules found via ListModule.");
        }

        Map<String, Module> availableToolsMap = new HashMap<>();
        for (Module m : toolModules) {
            availableToolsMap.put(m.getName(), m);
        }

        for (Map.Entry<String, String[]> entry : steps.entrySet()) {
            String stepName = entry.getKey();
            String[] moduleNames = entry.getValue();

            List<Module> modulesForStep = new ArrayList<>();

            if (moduleNames != null) {
                for (String moduleName : moduleNames) {
                    Module foundModule = availableToolsMap.get(moduleName);
                    if (foundModule != null) {
                        modulesForStep.add(foundModule);
                    } else {
                        System.err.println("Warning: Module not found: " + moduleName);
                    }
                }
            }

            this.steps.put(stepName, modulesForStep.toArray(new Module[0]));
        }
    }

    /**
     * Set the title of the diagnostic.
     * @param title Title of the diagnostic.
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Set the version of the diagnostic.
     * @param version Version of the diagnostic.
     */
    public void setVersion(String version) {
        this.version = version;
    }

    /**
     * Set the author of the diagnostic.
     * @param author Author of the diagnostic.
     */
    public void setAuthor(String author) {
        this.author = author;
    }

    /**
     * Set the description of the diagnostic.
     * @param description Description of the diagnostic.
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Set the level of the diagnostic.
     * @param level Level of the diagnostic.
     */
    public void setLevel(String level) {
        this.level = level;
    }

    public int getTotalSteps() {
        int total = 0;
        for (Module[] modules : steps.values()) {
            total += modules.length;
        }
        return total;
    }

    /**
     * String representation of the Diagnostic object.
     * @return String representation of the Diagnostic.
     */
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        for (Map.Entry<String, Module[]> entry : steps.entrySet()) {
            sb.append(entry.getKey()).append("=[");
            Module[] modules = entry.getValue();
            for (int i = 0; i < modules.length; i++) {
                sb.append(modules[i].getName());
                if (i < modules.length - 1) {
                    sb.append(", ");
                }
            }
            sb.append("], ");
        }
        sb.substring(0, sb.length() - 3);
        sb.append("}");
        return String.format("Diagnostic{title='%s', version='%s', author='%s', description='%s', level='%s', steps=%s}",
                title, version, author, description, level, sb);
    }
}
