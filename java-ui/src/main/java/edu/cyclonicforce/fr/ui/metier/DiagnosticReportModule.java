package edu.cyclonicforce.fr.ui.metier;

import java.util.Objects;

public class DiagnosticReportModule {
    private static final int[] VALID_EXIT_CODES = {0, 1};
    /**
     * Module name
     */
    private String name;
    /**
     * Module exit exitCode
     */
    private int exitCode;
    /**
     * Module error message (empty if no error)
     */
    private String error;
    /**
     * Module score (1-5)
     */
    private int score;
    /**
     * Module recommendation (empty if no recommendation)
     */
    private String recommendation;

    /**
     * Constructor
     * @param name module name
     * @param exitCode module exit code
     * @param error module error message
     * @param score module score (1-5)
     * @param recommendation module recommendation
     * @throws IllegalArgumentException if an argument is invalid
     */
    public DiagnosticReportModule(String name, int exitCode, String error, int score, String recommendation) {
        setName(name);
        setExitCode(exitCode);
        setError(error);
        setScore(score);
        setRecommendation(recommendation);
    }

    /**
     * Copy constructor
     * @param other DiagnosticReportModule to copy
     */
    public DiagnosticReportModule(DiagnosticReportModule other) {
        setName(other.getName());
        setExitCode(other.getExitCode());
        setError(other.getError());
        setScore(other.getScore());
        setRecommendation(other.getRecommendation());
    }

    /**
     * Constructor from ModuleReturn
     * @param moduleReturn module return
     * @param moduleName module name
     */
    public DiagnosticReportModule(ModuleReturn moduleReturn, String moduleName) {
        setName(moduleName);
        setExitCode(moduleReturn.getExitCode());
        setError(moduleReturn.getError());
        setScore(moduleReturn.getScore());
        setRecommendation(moduleReturn.getRecommendation());
    }

    /**
     * Returns the module name
     * @return Module name
     */
    public String getName() {
        return name;
    }
    /**
     * Sets the module name
     * @param name Module name
     */
    public void setName(String name) {
        if (name == null || name.isEmpty()) {
            this.name = "N/A";
        } else {
            this.name = name;
        }
    }

    /**
     * Returns the module exit code
     * @return Module exit code
     */
    public int getExitCode() {
        return exitCode;
    }
    /**
     * Sets the module exit code
     * @param exitCode Module exit code
     * @throws IllegalArgumentException if exitCode is invalid
     */
    public void setExitCode(int exitCode) {
        boolean isValid = false;
        for (int validCode : VALID_EXIT_CODES) {
            if (exitCode == validCode) {
                isValid = true;
                break;
            }
        }
        if (!isValid) {
            throw new IllegalArgumentException("Invalid exit code: " + exitCode);
        }
        this.exitCode = exitCode;
    }

    /**
     * Returns the module error message
     * @return Module error message
     */
    public String getError() {
        return error;
    }
    /**
     * Sets the module error message
     * @param error Module error message
     */
    public void setError(String error) {
        this.error = Objects.requireNonNullElse(error, "");
    }

    /**
     * Returns the module score
     * @return Module score (1-5)
     */
    public int getScore() {
        return score;
    }
    /**
     * Sets the module score
     * @param score Module score (1-5)
     * @throws IllegalArgumentException if score is out of range
     */
    public void setScore(int score) {
        if (score <= 0 || score > 5) {
            throw new IllegalArgumentException("Score must be between 1 and 5");
        }
        this.score = score;
    }

    /**
     * Returns the module recommendation
     * @return Module recommendation
     */
    public String getRecommendation() {
        return recommendation;
    }
    /**
     * Sets the module recommendation
     * @param recommendation Module recommendation
     */
    public void setRecommendation(String recommendation) {
        if (recommendation == null || recommendation.isEmpty()) {
            this.recommendation = "N/A";
        } else {
            this.recommendation = recommendation;
        }
    }
}
