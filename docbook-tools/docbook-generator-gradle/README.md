# DocBook Generator Gradle
A gradle interface to execute Docbook-Generator. 

## Run as a Gradle Task
Add Docbook-Generator to maven local. In the docbook-tools repo:    
  
#### Linux/MacOS:
```
./gradlew publishToMavenLocal
```
#### Windows:
```
gradlew.bat publishToMavenLocal
```
#### Add to a gradle.build script: 
```
buildscript {
	repositories {
		mavenLocal()
  	  mavenCentral()
		jcenter()
	}
	dependencies {
		classpath 'io.opencaesar.docbook:docbook-generator-gradle:+'
	}
}
```
#### Task for docbook generation: 
```
task docbookGeneratorTask(type:io.opencaesar.docbook.renderer.DocbookGeneratorTask) {
	input = file('build/documents/wbs.json')
	output = file('build/documents/wbs.xml')
}
```