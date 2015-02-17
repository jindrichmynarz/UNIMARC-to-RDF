<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "lib/entities.dtd">
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:bibo="http://purl.org/ontology/bibo/"
    xmlns:biro="http://purl.org/spar/biro/"
    xmlns:dbpo="http://dbpedia.org/ontology/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:f="http://data.comsode.eu/xslt/functions#"
    xmlns:fl="http://data.comsode.eu/xslt/functions-local#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:schema="http://schema.org/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="f fl"
    version="2.0"
    xpath-default-namespace="http://www.loc.gov/MARC21/slim">
    
    <!-- Functions -->
    
    <xsl:import href="lib/functions.xsl" />
    
    <!-- Parameters -->
    
    <xsl:param name="ns">http://data.snk.sk/resource/</xsl:param>
    
    <!-- Partially applied functions -->
    
    <xsl:function name="fl:getInstanceUri" as="xsd:anyURI">
        <xsl:param name="class" as="xsd:string"/>
        <xsl:param name="key" as="xsd:string"/>
        <xsl:value-of select="f:getInstanceUri($ns, $class, $key)"/>
    </xsl:function>
    
    <xsl:function name="fl:getInstanceUri" as="xsd:anyURI">
        <xsl:param name="class" as="xsd:string"/>
        <xsl:value-of select="f:getInstanceUri($ns, $class)"/>
    </xsl:function>
    
    <!-- Output -->
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC" />
    <xsl:strip-space elements="*"/>
    
    <!-- Global variables -->
    
    <xsl:variable name="collectionUri" select="f:getInstanceUri($ns, 'BibliographicCollection')"/>
    
    <!--- Templates -->
    
    <xsl:template match="/collection">
        <rdf:RDF>
            <biro:BibliographicCollection rdf:about="{$collectionUri}"/>
            <xsl:apply-templates/>
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template match="record">
        <xsl:variable name="id" select="controlfield[@tag = '001']"/>
        <xsl:variable name="publisherUri" select="f:getInstanceUri($ns, 'Organization')"/>
        <xsl:variable name="publisherAddressUri" select="f:getInstanceUri($ns, 'PostalAddress')"/>
        <xsl:variable name="recordCreatorUri" select="f:getInstanceUri($ns, 'Organization')"/>
        <xsl:variable name="recordCreatorAddressUri" select="f:getInstanceUri($ns, 'PostalAddress')"/>
        
        <biro:BibliographicRecord rdf:about="{f:getInstanceUri($ns, 'BibliographicRecord', $id)}">
            <biro:isElementOf rdf:resource="{$collectionUri}"/>
            <xsl:apply-templates mode="record">
                <xsl:with-param name="recordCreatorUri" select="$recordCreatorUri" tunnel="yes"/>
                <xsl:with-param name="recordCreatorAddressUri" select="$recordCreatorAddressUri" tunnel="yes"/>
            </xsl:apply-templates>
            <biro:references>
                <bibo:Document rdf:about="{f:getInstanceUri($ns, 'Document', $id)}">
                    <xsl:apply-templates mode="document">
                        <xsl:with-param name="publisherUri" select="$publisherUri" tunnel="yes"/>
                        <xsl:with-param name="publisherAddressUri" select="$publisherAddressUri" tunnel="yes"/>
                    </xsl:apply-templates>
                </bibo:Document>
            </biro:references>
        </biro:BibliographicRecord>
    </xsl:template>
    
    <!-- Record identifier -->
    <xsl:template match="controlfield[@tag = '001']" mode="record">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getInstanceUri($ns, 'Identifier', .)}">
                <skos:notation><xsl:value-of select="."/></skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <!-- National bibliography number -->
    <xsl:template match="datafield[@tag = '020']" mode="record">
        <xsl:variable name="identifier" select="subfield[@code = 'b']"/>
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getInstanceUri($ns, 'Identifier', $identifier)}">
                <skos:notation><xsl:value-of select="$identifier"/></skos:notation>
                <xsl:apply-templates mode="record"/>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <!-- Record's creator -->
    <xsl:template match="datafield[@tag = '020' or @tag = '801' or @tag = '974']" mode="record">
        <xsl:param name="recordCreatorUri" tunnel="yes"/>
        <dcterms:creator>
            <schema:Organization rdf:about="{$recordCreatorUri}">
                <xsl:apply-templates select="subfield[@code = 'a' or @code = 'b']" mode="record"/>
            </schema:Organization>
        </dcterms:creator>
        <xsl:apply-templates select="subfield[@code = 'd']" mode="record"/>
    </xsl:template>
    
    <!-- National bibliography number | Country code -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '020']]" mode="record">
        <xsl:param name="recordCreatorAddressUri" tunnel="yes"/>
        <schema:address>
            <schema:PostalAddress rdf:about="{$recordCreatorAddressUri}">
                <schema:addressCountry><xsl:value-of select="."/></schema:addressCountry>
            </schema:PostalAddress>
        </schema:address>
    </xsl:template>
    
    <!-- General processing data -->
    <xsl:template match="datafield[@tag = '100']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- General processing data | General processing data -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '100']]" mode="record">
        <dcterms:created rdf:datatype="&xsd;date"><xsl:value-of select="f:parseYYYYMMDD(substring(., 1, 8))"/></dcterms:created>
        <xsl:variable name="typeOfPublicationDate" select="substring(., 9, 1)"/>
        <xsl:variable name="publicationDate1" select="substring(., 10, 4)"/>
        <xsl:variable name="publicationDate2" select="substring(., 14, 4)"/>
        <xsl:variable name="governmentPublication" select="substring(., 21, 1)"/>
        <xsl:variable name="modifiedRecordCode" select="substring(., 22, 1)"/>
        <xsl:variable name="languageOfCataloguing" select="substring(., 23, 3)"/>
        <xsl:variable name="transliterationCode" select="substring(., 26, 1)"/>
        <xsl:variable name="characterSets" select="f:partition(substring(., 27, 4), 2)"/>
        <xsl:variable name="additionalCharacterSets" select="f:partition(substring(., 31, 4), 2)"/>
        <xsl:variable name="scriptOfTheTitle" select="substring(., 35, 2)"/>
    </xsl:template>
    
    <!-- General processing data | General processing data -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '100']]" mode="document">
        <xsl:variable name="targetAudienceNs">http://iflastandards.info/ns/unimarc/terms/tac#</xsl:variable>
        <xsl:variable name="targetAudienceCode" select="f:partition(substring(., 18, 3), 1)"/>
        <!-- If $targetAudienceCode is in the enumeration of valid codes. -->
        <xsl:if test="$targetAudienceCode = ('a', 'b', 'c', 'd', 'e', 'k', 'm', 'u')">
            <dcterms:audience rdf:resource="{concat($targetAudienceNs, $targetAudienceCode)}"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Language of the item -->
    <xsl:template match="datafield[@tag = '101']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Language of the item | Language of text, soundtrack etc. -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '101']]" mode="document">
        <dcterms:language><xsl:value-of select="."/></dcterms:language>
    </xsl:template>
    
    <!-- Language of the item | Language of original work -->
    <xsl:template match="subfield[@code = 'c'][parent::datafield[@tag = '101']]" mode="document">
        <dcterms:language><xsl:value-of select="."/></dcterms:language>
    </xsl:template>
    
    <!-- dcterms:publisher -->
    <xsl:template match="datafield[@tag = '102' or @tag = '210'][subfield[@code = 'a']]" mode="document">
        <xsl:param name="publisherUri" tunnel="yes"/>
        <xsl:param name="publisherAddressUri" tunnel="yes"/>
        <dcterms:publisher>
            <schema:Organization rdf:about="{$publisherUri}">
                <xsl:apply-templates select="subfield[@code = 'c']" mode="document"/>
                <schema:address>
                    <schema:PostalAddress rdf:about="{$publisherAddressUri}">
                        <xsl:apply-templates select="subfield[@code = 'a']" mode="document"/>
                    </schema:PostalAddress>
                </schema:address>
            </schema:Organization>
        </dcterms:publisher>
        <xsl:apply-templates select="subfield[@code = 'd']" mode="document"/>
    </xsl:template>
    
    <!-- Country of publication or production | Country of publication -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '102']]" mode="document">
        <schema:addressCountry><xsl:value-of select="."/></schema:addressCountry>
    </xsl:template>
    
    <!-- Coded data field: textual material, monographic -->
    <xsl:template match="datafield[@tag = '105']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Coded data field: textual material, monographic | Monograph Coded Data -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '105']]" mode="document">
        <xsl:variable name="illustrationCodes" select="f:partition(substring(., 1, 4), 1)"/>
        <xsl:variable name="formOfContentsCodes" select="f:partition(substring(., 5, 4), 1)"/>
        <xsl:variable name="conferenceOrMeetingCode" select="substring(., 9, 1)"/>
        <xsl:variable name="festschriftIndicator" select="substring(., 10, 1)"/>
        <xsl:variable name="indexIndicator" select="substring(., 11, 1)"/>
        <xsl:variable name="literatureCode" select="substring(., 12, 1)"/>
        <xsl:variable name="bibliographyCode" select="substring(., 13, 1)"/>
        
        <xsl:if test="$festschriftIndicator = '1'">
            <rdf:type rdf:resource="&lv;Festschrift"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Coded data field: antiquarian - general -->
    <xsl:template match="datafield[@tag = '140']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Coded data field: antiquarian - general | Antiquarian coded data - general -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '140']]" mode="document">
        <xsl:variable name="illustrationCodesBook" select="f:partition(substring(., 1, 3), 1)"/>
        <xsl:variable name="illustrationCodesFullPagePlates" select="f:partition(substring(., 4, 3), 1)"/>
        <xsl:variable name="illustrationCodeTechnique" select="substring(., 8, 1)"/>
        <xsl:variable name="formOfContentsCode" select="f:partition(substring(., 9, 8), 2)"/>
    </xsl:template>
    
    <!-- Title and statement of responsibility -->
    <xsl:template match="datafield[@tag = '200']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Title and statement of responsibility | Title proper -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '200']]" mode="document">
        <dcterms:title><xsl:value-of select="."/></dcterms:title>
    </xsl:template>
    
    <!-- Title and statement of responsibility | Other title information -->
    <xsl:template match="subfield[@code = 'e'][parent::datafield[@tag = '200']]" mode="document">
        <dbpo:subtitle><xsl:value-of select="."/></dbpo:subtitle>
    </xsl:template>
    
    <!-- Title and statement of responsibility | Number of a part  -->
    <xsl:template match="subfield[@code = 'h'][parent::datafield[@tag = '200']]" mode="document">
        <bibo:number><xsl:value-of select="."/></bibo:number>
    </xsl:template>
    
    <!-- Publication, distribution, etc. | Place of publication, distribution, etc. -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '210']]" mode="document">
        <!-- Filter out "sine loco" -->
        <xsl:if test="not(matches(., '^\[?[sS]\.[lL]\.\]?$'))">
            <schema:addressLocality><xsl:value-of select="."/></schema:addressLocality>
        </xsl:if>
    </xsl:template>
    
    <!-- Publication, distribution, etc. | Name of publisher, distributor, etc. -->
    <xsl:template match="subfield[@code = 'c'][parent::datafield[@tag = '210']]" mode="document">
        <schema:name><xsl:value-of select="."/></schema:name>
    </xsl:template>
    
    <!-- Publication, distribution, etc. | Date of publication, distribution, etc. -->
    <xsl:template match="subfield[@code = 'd'][parent::datafield[@tag = '210']]" mode="document">
        <dcterms:issued><xsl:value-of select="."/></dcterms:issued>
    </xsl:template>
    
    <!-- Physical description -->
    <xsl:template match="datafield[@tag = '215']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Physical description | Specific material designation and extent of item -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '215']]" mode="document">
        <dcterms:extent><xsl:value-of select="."/></dcterms:extent>
    </xsl:template>
    
    <!-- Physical description | Dimensions -->
    <xsl:template match="subfield[@code = 'd'][parent::datafield[@tag = '215']]" mode="document">
        <dcterms:format><xsl:value-of select="."/></dcterms:format>
    </xsl:template>
    
    <!-- Notes pertaining to coded information -->
    <xsl:template match="datafield[@tag = '303']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Notes pertaining to coded information | Text of note -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '303']]" mode="document">
        <skos:note><xsl:value-of select="."/></skos:note>
    </xsl:template>
    
    <!-- Notes pertaining to edition and bibliographic history -->
    <xsl:template match="datafield[@tag = '305']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Notes pertaining to edition and bibliographic history | Text of note -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '305']]" mode="document">
        <skos:historyNote><xsl:value-of select="."/></skos:historyNote>
    </xsl:template>
    
    <!-- Contents note -->
    <xsl:template match="datafield[@tag = '327']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Contents note | Text of note -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '327']]" mode="document">
        <skos:note><xsl:value-of select="."/></skos:note>
    </xsl:template>
    
    <!-- Uniform title -->
    <xsl:template match="datafield[@tag = '500']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Uniform title | Uniform title -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '500']]" mode="document">
        <skos:prefLabel><xsl:value-of select="."/></skos:prefLabel>
    </xsl:template>
    
    <!-- Personal name used as subject -->
    <xsl:template match="datafield[@tag = '600']" mode="document">
        <dcterms:subject>
            <schema:Person rdf:about="{f:getInstanceUri($ns, 'Person')}">
                <xsl:apply-templates mode="document"/>
            </schema:Person>
        </dcterms:subject>
    </xsl:template>
    
    <!-- Personal name used as subject | Entry element -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '600']]" mode="document">
        <schema:name><xsl:value-of select="."/></schema:name>
    </xsl:template>
    
    <!-- Personal name used as subject | Additions to name other than dates -->
    <xsl:template match="subfield[@code = 'c'][parent::datafield[@tag = '600']]" mode="document">
        <schema:description><xsl:value-of select="."/></schema:description>
    </xsl:template>
    
    <!-- Uncontrolled subject terms -->
    <xsl:template match="datafield[@tag = '610']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Uncontrolled subject terms | Subject term -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '610']]" mode="document">
        <dcterms:subject>
            <skos:Concept rdf:about="{f:getInstanceUri($ns, 'Concept')}">
                <skos:prefLabel><xsl:value-of select="."/></skos:prefLabel>
            </skos:Concept>
        </dcterms:subject>
    </xsl:template>
    
    <!-- Universal Decimal Classification -->
    <xsl:template match="datafield[@tag = '675']" mode="document">
        <xsl:apply-templates mode="document"/>
    </xsl:template>
    
    <!-- Universal Decimal Classification | Number -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '675']]" mode="document">
        <dcterms:subject>
            <skos:Concept rdf:about="{f:getInstanceUri($ns, 'Concept')}">
                <skos:notation><xsl:value-of select="."/></skos:notation>
                <skos:inScheme rdf:resource="http://udcdata.info/udc-schema"/>
            </skos:Concept>
        </dcterms:subject>
    </xsl:template>
    
    <!-- Personal name - primary responsibility -->
    <xsl:template match="datafield[@tag = '700']" mode="document">
        <dcterms:creator>
            <schema:Person rdf:about="{f:getInstanceUri($ns, 'Person')}">
                <xsl:apply-templates mode="document"/>
            </schema:Person>
        </dcterms:creator>
    </xsl:template>
    
    <!-- Personal name - primary/secondary responsibility | Entry element -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '700' or @tag = '702']]" mode="document">
        <schema:name><xsl:value-of select="."/></schema:name>
    </xsl:template>
    
    <!-- Personal name - primary/secondary responsibility | Part of name other than entry element -->
    <xsl:template match="subfield[@code = 'b'][parent::datafield[@tag = '700' or @tag = '702']]" mode="document">
        <schema:additionalName><xsl:value-of select="."/></schema:additionalName>
    </xsl:template>
    
    <!-- Personal name - primary/secondary responsibility, Personal name used as subject | Dates -->
    <xsl:template match="subfield[@code = 'd'][parent::datafield[@tag = '600' or @tag = '700' or @tag = '702']]" mode="document">
        <xsl:analyze-string select="." regex="^(\d{{4}})-(\d{{4}})$">
            <xsl:matching-substring>
                <schema:birthDate><xsl:value-of select="regex-group(1)"/></schema:birthDate>
                <schema:deathDate><xsl:value-of select="regex-group(2)"/></schema:deathDate>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <schema:description><xsl:value-of select="."/></schema:description>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- Personal name - primary/secondary responsibility | Relator code -->
    <xsl:template match="subfield[@code = '4'][parent::datafield[@tag = '700' or @tag = '702']]" mode="document">
        <schema:roleName><xsl:value-of select="."/></schema:roleName>
    </xsl:template>
    
    <!-- Personal name - secondary responsibility -->
    <xsl:template match="datafield[@tag = '702']" mode="document">
        <dcterms:contributor>
            <schema:Person rdf:about="{f:getInstanceUri($ns, 'Person')}">
                <xsl:apply-templates mode="document"/>
            </schema:Person>
        </dcterms:contributor>
    </xsl:template>
    
    <!-- Corporate body name - secondary responsibility -->
    <xsl:template match="datafield[@tag = '712']" mode="document">
        <dcterms:contributor>
            <schema:Organization rdf:about="{f:getInstanceUri($ns, 'Organization')}">
                <xsl:apply-templates mode="document"/>
            </schema:Organization>
        </dcterms:contributor>
    </xsl:template>
    
    <!-- Corporate body name - secondary responsibility | Entry element -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '712']]" mode="document">
        <schema:name><xsl:value-of select="."/></schema:name>    
    </xsl:template>
    
    <!-- Corporate body name - secondary responsibility | Addition to name or qualifier -->
    <xsl:template match="subfield[@code = 'c'][parent::datafield[@tag = '712']]" mode="document">
        <schema:address>
            <schema:PostalAddress rdf:about="{f:getInstanceUri($ns, 'PostalAddress')}">
                <schema:description><xsl:value-of select="."/></schema:description>
            </schema:PostalAddress>
        </schema:address>
    </xsl:template>
    
    <!-- Corporate body name - secondary responsibility | Relator code
    FIXME: Some values aren't valid local names, so that they cannot be used directly as http://id.loc.gov/vocabulary/relators/ properties
    (instead of generic dcterms:contributor).  It requires further cleaning. -->
    <xsl:template match="subfield[@code = '4'][parent::datafield[@tag = '712']]" mode="document">
        <schema:roleName><xsl:value-of select="."/></schema:roleName>    
    </xsl:template>
    
    <!-- Originating source | Country -->
    <xsl:template match="subfield[@code = 'a'][parent::datafield[@tag = '801']]" mode="record">
        <xsl:param name="recordCreatorAddressUri" tunnel="yes"/>
        <schema:address>
            <schema:PostalAddress rdf:about="{$recordCreatorAddressUri}">
                <schema:addressCountry><xsl:value-of select="."/></schema:addressCountry>
            </schema:PostalAddress>
        </schema:address>
    </xsl:template>
    
    <!-- Originating source | Agency -->
    <xsl:template match="subfield[@code = 'b'][parent::datafield[@tag = '801']]" mode="record">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getInstanceUri($ns, 'Identifier')}">
                <skos:notation><xsl:value-of select="."/></skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <!-- Include templates for locally defined 9XX fields -->
    <xsl:include href="lib/local.xsl"/>
    
    <!-- Catch-all empty template -->
    <xsl:template match="text()|@*" mode="#all"/>
    
</xsl:stylesheet>