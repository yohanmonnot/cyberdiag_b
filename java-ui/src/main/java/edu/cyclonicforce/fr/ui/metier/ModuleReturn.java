package edu.cyclonicforce.fr.ui.metier;

import java.util.Objects;

/**
 * ModuleReturn class
 * @author Célian Touzeau
 * @version 1
 */
public class ModuleReturn {
    private static final int[] VALID_EXIT_CODES = {0, 1};
    /**
     * Module exit exitCode
     */
    private int exitCode;
    /**
     * Module error message (empty if no error)
     */
    private String error;
    /**
     * Module score (0-5)
     */
    private int score;
    /**
     * Module recommendation (empty if no recommendation)
     */
    private String recommendation;

    /**
     * Constructor
     * @param exitCode Module exit exitCode
     * @param error Module error message (empty if no error)
     * @param score Module score (0-5)
     * @param recommendation Module recommendation (empty if no recommendation)
     * @throws IllegalArgumentException if an argument is invalid
     */
    public ModuleReturn(int exitCode, String error, int score, String recommendation) {
        if (isNotValidExitCode(exitCode)) {
            throw new IllegalArgumentException("Status cannot be null or empty");
        }
        this.exitCode = exitCode;

        this.error = Objects.requireNonNullElse(error, "");

        if (score < 0 || score > 5) {
            throw new IllegalArgumentException("Score must be between 0 and 5");
        }
        this.score = score;
        
        this.recommendation = Objects.requireNonNullElse(recommendation, "");
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
     * @throws IllegalArgumentException if exitCode is null or empty
     */
    public void setExitCode(int exitCode) {
        if (!isNotValidExitCode(exitCode)) {
            throw new IllegalArgumentException("Status cannot be null or empty");
        }
        this.exitCode = exitCode;
    }

    /**
     * Returns the error message
     * @return Error message or empty string if no error
     */
    public String getError() {
        return error;
    }
    /**
     * Sets the error message
     * @param error Error message or empty string if no error
     */
    public void setError(String error) {
        this.error = Objects.requireNonNullElse(error, "");
    }

    /**
     * Returns the score
     * @return Score (0-5)
     */
    public int getScore() {
        return score;
    }
    /**
     * Sets the score
     * @param score Score (0-5)
     * @throws IllegalArgumentException if score is not between 0 and 5
     */
    public void setScore(int score) {
        if (score < 0 || score > 5) {
            throw new IllegalArgumentException("Score must be between 0 and 5");
        }
        this.score = score;
    }

    /**
     * Returns the recommendation
     * @return Recommendation or empty string if no recommendation
     */
    public String getRecommendation() {
        return recommendation;
    }
    /**
     * Sets the recommendation
     * @param recommendation Recommendation or empty string if no recommendation
     */
    public void setRecommendation(String recommendation) {
        this.recommendation = Objects.requireNonNullElse(recommendation, "");
    }

    public String toString() {
        return "ModuleReturn{ exitCode=" + exitCode + ", error='" + error + "', score=" + score + ", recommendation='" + recommendation + "' }";
    }

    // helpers

    /**
     * Checks if the exit code is valid
     * @param code Exit code to check
     * @return True if the exit code is valid, false otherwise
     */
    private boolean isNotValidExitCode(int code) {
        boolean ret = true;

        for (int validCode : VALID_EXIT_CODES) {
            if (code == validCode) {
                ret = false;
                break;
            }
        }

        return ret;
    }
}
