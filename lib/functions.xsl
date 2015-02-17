<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="http://data.comsode.eu/xslt/functions#"
    xmlns:uuid="java:java.util.UUID"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="f uuid"
    version="2.0">
    
    <xsl:function name="f:getDate" as="xsd:string">
        <xsl:param name="year" as="xsd:integer"/>
        <xsl:param name="month" as="xsd:integer"/>
        <xsl:param name="day" as="xsd:integer"/>
        <xsl:value-of select="concat($year, '-', format-number($month, '00'), '-', format-number($day, '00'))"/>
    </xsl:function>
    
    <xsl:function name="f:getInstanceUri" as="xsd:anyURI">
        <xsl:param name="ns" as="xsd:anyURI"/>
        <xsl:param name="class" as="xsd:string"/>
        <xsl:param name="key" as="xsd:string"/>
        <xsl:value-of select="concat($ns, f:kebabCase($class), '/', f:slugify($key))"/>
    </xsl:function>
    
    <xsl:function name="f:getInstanceUri" as="xsd:anyURI">
        <xsl:param name="ns" as="xsd:anyURI"/>
        <xsl:param name="class" as="xsd:string"/>
        <xsl:value-of select="f:getInstanceUri($ns, $class, uuid:randomUUID())"/>
    </xsl:function>
    
    <xsl:function name="f:kebabCase" as="xsd:string">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="f:slugify(replace($text, '(\p{Ll})(\p{Lu})', '$1-$2'))"/>
    </xsl:function>
    
    <xsl:function name="f:parseYYYYMMDD" as="xsd:date">
        <xsl:param name="dateString" as="xsd:string"/>
        <xsl:variable name="cleanerDateString" select="replace($dateString, 'O', '0')"/>
        <xsl:variable name="year" select="xsd:integer(substring($cleanerDateString, 1, 4))" as="xsd:integer" />
        <xsl:variable name="month" select="xsd:integer(substring($cleanerDateString, 5, 2))" as="xsd:integer" />
        <xsl:variable name="day" select="xsd:integer(substring($cleanerDateString, 7, 2))" as="xsd:integer" />
        <xsl:value-of select="f:getDate($year, $month, $day)"/>
    </xsl:function>
    
    <xsl:function name="f:slugify" as="xsd:anyURI">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="encode-for-uri(translate(replace(lower-case(normalize-unicode($text, 'NFKD')), '\P{IsBasicLatin}', ''), ' ', '-'))" />
    </xsl:function>
</xsl:stylesheet>