# DocBook Adapter

A CLI that replaces tags inside a DocBook with data from SPARQL frames 

# Run as CLI
MacOS/Linux:
```
    cd docbook-tools
    ./gradlew docbook-adapater:run --args="..."    
```
Windows:
```
    cd docbook-tools
    gradlew.bat docbook-adapater:run --args="..."    
```
Args:
```
    --input, -i path/to/docbook.xml
    --result, -r path/to/result_folder
```