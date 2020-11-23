# DocBook Generator

Generates DocBook reports from templates in a Fuseki dataset.

## Run as a CLI 
MacOS/Linux: 
```
    cd docbook-tools
    ./gradlew docbook-generator:run --args="..."    
```
Windows: 
```
    cd docbook-tools
    gradlew.bat docbook-generator:run --args="..."    
```
Arguments:
```
--endpoint, -e http://fuseki:3030/dataset  (Required)
--input, -i http://example.org/documet-iri#Document (Required)
--output, -o output-filename.xml (Required)
--debug, -d (Optional)
```