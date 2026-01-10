# Interface

## Arborescence
```
java-ui
├── build.gradle
├── README.md
└── src
    ├── main
    │   └── java
    │       └── ui
    │           ├── Controllers                 // package for all controllers
    │           │   └── exampleController.java
    │           └── Main.java                   // entry point of interface
    └── resources
        ├── fxml                                // folder for fxmls interfaces
        │   └── example.fxml
        └── styles                              // folder for style sheets
            └── example.css
```

## Building
### For testing
set your working dir to `cyberdiag_b/java-ui/`
execute `gradle clean build`
and to launch interface whith `java -jar java-ui/build/libs/java-ui-1.0.jar`

### To test in real case 
push your code into the functionality dev branch and merge this branch whith the main dev branch wait for th CI to complete and pull the main dev then test by launching the app