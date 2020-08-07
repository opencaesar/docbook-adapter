# DocBook Adapter Gradle
A gradle interface to execute Docbook-Adapter. 

## Run as a Gradle Task
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
Task for tag replacement: 
```
task docbookAdapterTag(type:io.opencaesar.docbook.adapter.DocbookAdapterTask) {
	input = file('path/to/input/docbook.xml')
	type = 'tag'
	xsl = file('path/to/stylesheet-gen/tag/all_transformations.xsl')
	original = file('path/to/docbook_xsl')
	frame = file('path/to/frame')	
}
```