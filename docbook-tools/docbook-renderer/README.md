# DocBook Renderer

A tool to execute tag transformations and renders on a given DocBook into PDF
and HTML.

## Run as a CLI 
MacOS/Linux: 
```
    cd docbook-tools
    ./gradlew docbook-renderer:run --args="..."    
```
Windows: 
```
    cd docbook-tools
    gradlew.bat docbook-renderer:run --args="..."    
```
Args for PDF render:    
```
--input, -i path/to/docbook.xml (Required, expects none of our defined tags)
--output, -i path/to/output.pdf (Required)
--type, -t pdf (For pdf render)
--xsl, -x path/to/pdf.xsl (Required. Projects including docbook-stylesheets can use build/stylesheets-gen/pdf/pdf.xsl)
```
Args for HTML render:   
```
--input, -i path/to/docbook.xml (Required, expects none of our defined tags)
--output, -i path/to/output.html (Required)
--type, -t html (For html render)
--xsl, -x path/to/html.xsl (Required. Projects including docbook-stylesheets can use build/stylesheets-gen/html/html.xsl)
```