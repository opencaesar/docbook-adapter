# DocBook Adapter Gradle
A gradle interface to execute Docbook-Adapter. 

## Run as a Gradle Task
Add Docbook-Adapter to maven local. In the docbook-tools repo:      
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
		classpath 'io.opencaesar.docbook:docbook-adapter-gradle:+'
	}
}
```
#### Task for tag replacement: 
```
task docbookAdapterTag(type:io.opencaesar.docbook.adapter.DocbookAdapterTask) {
	input = file('path/to/input/docbook.xml')
	type = 'tag'
	xsl = file('path/to/stylesheet-gen/tag/all_transformations.xsl')
	original = file('path/to/docbook_xsl')
	frame = file('path/to/frame')	
}
```
#### Task for pdf render: 
```
task docbookAdapterPDF(type:io.opencaesar.docbook.adapter.DocbookAdapterTask) {
	input = file('path/to/input/docbook.xml')
	type = 'pdf'
	xsl = file('path/to/src-gen/pdf/pdf_ext.xsl')
}
```
#### Task for html render: 
```
task docbookAdapterHTML(type:io.opencaesar.docbook.adapter.DocbookAdapterTask) {
	input = file('path/to/input/docbook.xml')
	type = 'html'
	xsl = file('path/to/src-gen/html/html_ext.xsl')
	css = file('path/to/stylesheet-gen/default.css')
}
```
