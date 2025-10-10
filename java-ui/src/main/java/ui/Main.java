package ui;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, Java UI!");
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}