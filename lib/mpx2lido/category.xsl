<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8"
        indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
        FIELDS: category
        
        HISTORY: 
        -category: I used to take category from objekttyp; now I attempt a
        mapping to CRM terms as recommended by LIDO spec. 20200411 
        -lido:cateogry moved to separate xsl file. 20200411
        - objekttyp=Musikinstrument remains at lido: classification; 
        it's certainly not a category in the Aristotelian sense 
        (no top-level classification)20200420 
    -->

    <xsl:template mode="category" match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:objekttyp">
        <lido:category>
            <xsl:choose>
                <xsl:when test=". eq 'Allgemein' or . eq 'Musikinstrument' ">
                    <lido:conceptID lido:type="URI">
                        <xsl:text>http://www.cidoc-crm.org/crm-concepts/E22</xsl:text>
                    </lido:conceptID>
                    <lido:term xml:lang="en">
                        <xsl:text>Man-Made Object</xsl:text>
                    </lido:term>
                </xsl:when>
                <xsl:when test=". eq 'Audio'">
                    <lido:conceptID lido:type="URI">
                        <xsl:text>http://www.cidoc-crm.org/crm-concepts/E84</xsl:text>
                    </lido:conceptID>
                    <lido:term xml:lang="en">
                        <xsl:text>Information Carrier</xsl:text>
                    </lido:term>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>
                        WARNING: Unknown LIDO category!
                        <xsl:value-of select="."/>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </lido:category>
    </xsl:template>
</xsl:stylesheet>