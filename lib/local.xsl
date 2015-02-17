<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "entities.dtd">
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:f="http://data.comsode.eu/xslt/functions#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    version="2.0"
    xpath-default-namespace="http://www.loc.gov/MARC21/slim">
    
    <!-- Local definitions of the 9XX fields by the Slovak National Library.
    Include stylesheet that needs its including stylesheet to provide the $ns variable. -->
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Code of record's creator -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '974']]" mode="record">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getInstanceUri($ns, 'Identifier')}">
                <skos:notation><xsl:value-of select="."/></skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <!-- Date of record's creation -->
    <xsl:template match="subfield[@code = 'd'][parent::datafield[@tag = '974']]" mode="record">
        <dcterms:issued rdf:datatype="&xsd;date"><xsl:value-of select="f:parseYYYYMMDD(.)"/></dcterms:issued>
    </xsl:template>
    
    <!-- Document's kind code -->
    <xsl:template match="datafield[@tag = '992']" mode="document">
        <dcterms:type><xsl:value-of select="."/></dcterms:type>
    </xsl:template>
</xsl:stylesheet>