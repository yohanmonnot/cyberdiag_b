package edu.cyclonicforce.fr.ui.metier;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DiagnosticReport {
    private String reportName;
    private String reportDate;
    private int number;
    private final Map<String, List<DiagnosticReportModule>> moduleResults = new HashMap<>();

    public DiagnosticReport(String reportName, String reportDate, int number, Map<String, List<DiagnosticReportModule>> moduleResults) {
        setReportName(reportName);
        setReportDate(reportDate);
        setNumber(number);
        setModuleResults(moduleResults);
    }

    public DiagnosticReport(DiagnosticReport other) {
        setReportName(other.getReportName());
        setReportDate(other.getReportDate());
        setNumber(other.getNumber());
        setModuleResults(other.getModuleResults());
    }

    public String getReportName() {
        return reportName;
    }
    public void setReportName(String reportName) {
        this.reportName = reportName;
    }

    public String getReportDate() {
        return reportDate;
    }
    public void setReportDate(String reportDate) {
        if (reportDate == null || reportDate.isEmpty() || !reportDate.matches("^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$")) {
            throw new IllegalArgumentException("Invalid date format. Expected format: YYYY-MM-DD HH:MM:SS");
        }
        this.reportDate = reportDate;
    }

    public int getNumber() {
        return number;
    }
    public void setNumber(int number) {
        if (number < 0) {
            throw new IllegalArgumentException("Number cannot be negative");
        }
        this.number = number;
    }

    public Map<String, List<DiagnosticReportModule>> getModuleResults() {
        Map<String, List<DiagnosticReportModule>> copy = new HashMap<>();
        for (Map.Entry<String, List<DiagnosticReportModule>> entry : this.moduleResults.entrySet()) {
            copy.put(entry.getKey(), new ArrayList<>(entry.getValue()));
        }
        return copy;
    }
    public void setModuleResults(Map<String, List<DiagnosticReportModule>> moduleResults) {
        this.moduleResults.clear();
        for (Map.Entry<String, List<DiagnosticReportModule>> entry : moduleResults.entrySet()) {
            this.moduleResults.put(entry.getKey(), new ArrayList<>(entry.getValue()));
        }
    }
    public void addModuleResult(String category, DiagnosticReportModule moduleReturn) {
        this.moduleResults.computeIfAbsent(category, k -> new ArrayList<>()).add(moduleReturn);
    }
    public void removeModuleResult(String category, DiagnosticReportModule moduleReturn) {
        List<DiagnosticReportModule> results = this.moduleResults.get(category);
        if (results != null) {
            results.remove(moduleReturn);
            if (results.isEmpty()) {
                this.moduleResults.remove(category);
            }
        }
    }

    public int getCategoryNote(String category) {
        List<DiagnosticReportModule> results = this.moduleResults.get(category);
        if (results == null || results.isEmpty()) {
            return 0;
        }
        int totalScore = 0;
        for (DiagnosticReportModule result : results) {
            totalScore += result.getScore();
        }
        return Math.round((float) totalScore / results.size());
    }
    public int getOverallNote() {
        if (this.moduleResults.isEmpty()) {
            return 0;
        }
        int totalScore = 0;
        int count = 0;
        for (String category : this.moduleResults.keySet()) {
            totalScore += getCategoryNote(category);
            count++;
        }
        return Math.round((float) totalScore / count);
    }
}
