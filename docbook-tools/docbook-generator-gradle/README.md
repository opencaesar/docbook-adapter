# DocBook Generator Gradle
A gradle interface to execute Docbook-Adapter. 

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
task docbookGeneratorTask(type:io.opencaesar.docbook.adapter.DocbookGeneratorTask) {
	endpoint = 'http://localhost:3030/firesat'
	input = 'http://opencaesar.io/programs/earth-science/projects/firesat/documents/work-breakdown-structure#WorkBreakdownStructure'
	output = file('build/documents/wbs.xml')
}
```