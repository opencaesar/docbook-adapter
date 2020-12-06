# DocBook Generator

Converts document tree JSON files produced by `owl-doc` (from `owl-tools`)
into docbook XML.

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
--input, -i input-filename.json  (Required)
--output, -o output-filename.xml (Required)
--debug, -d (Optional)
```