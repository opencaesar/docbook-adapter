# DocBook Stylesheets
A repo containing the XSLs used to perform tag replacement, PDF render, and HTML render in DocBook-Adapter. 

## How to publish to local maven 
#### Linux/MacOS:
```
./gradlew publishToMavenLocal
```

#### Windows:
```
gradlew.bat publishToMavenLocal
```

## Downloading the files from MavenLocal in a gradle buildscript
Add to a build.gradle file 
```
repositories {
   mavenLocal()
}

configurations { 
	stylesheets 
}

dependencies {
  stylesheets "io.opencaesar.docbook:docbook-stylesheets:+"
}

// Zips stylesheets from docbook-stylesheets and places them in build/stylesheets-gen 
task dependencyUnzip(type: Copy) {
  from configurations.stylesheets.files.collect { zipTree(it) }
  into file("build/stylesheets-gen")
}
```
Then execute ./gradlew dependencyUnzip
