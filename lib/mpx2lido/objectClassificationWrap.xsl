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
        FIELDS: objectWorkType (required), classification
        
        HISTORY: 
        - Older version had objekttyp mapped to objectWorkType when sachbegriff 
        is empty and objekttyp is not "Allgemein"; but since that should never
        be the case it was a stupid rule. Now we just fill in Objekttyp as a 
        classification.
        - There mpx records without sachbegriff. I think that is a mistake, but
        not sure how to go about it
    -->

    <xsl:template name="objectClassificationWrap">
        <lido:objectClassificationWrap>
            <lido:objectWorkTypeWrap>
                <xsl:choose>
                    <xsl:when test="mpx:sachbegriff">
                            <xsl:apply-templates select="mpx:sachbegriff" mode="workType">
                                <xsl:sort select="@art" />
                            </xsl:apply-templates>
                    </xsl:when>
                    <!-- 
                    not sure it's clever to use sachbegriffHierarchisch here; it 
                    would be better to eliminate records without sachbegriff
                    upstream (in m+).
                    -->
                    <xsl:otherwise>
                        <lido:objectWorkType>
                            <lido:term>
                                <xsl:value-of select="mpx:sachbegriffHierarchisch" />
                            </lido:term>
                        </lido:objectWorkType>
                    </xsl:otherwise>
                </xsl:choose>
            </lido:objectWorkTypeWrap>
            <xsl:if test="mpx:systematikArt or mpx:objekttyp ne 'Allgemein'">
                <lido:classificationWrap>
                    <xsl:apply-templates select="mpx:systematikArt" />
                    <xsl:apply-templates mode="classification" select="mpx:objekttyp [. eq 'Musikinstrument']" />
                </lido:classificationWrap>
            </xsl:if>
        </lido:objectClassificationWrap>
    </xsl:template>


    <!-- 
        "Sachbegriff" before "Weiterer Sachbegriff", using position() over 
        xsl:number

        HISTORY:
        20200114: sortorder added, TODO: not sure it's always in the right 
        order, currently known attributes "Sachbegriff" and "weiterer Sachbegriff".
    -->

    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff" 
        mode="workType">
        <lido:objectWorkType>
            <xsl:attribute name="lido:type">Sachbegriff</xsl:attribute>
            <xsl:attribute name="lido:sortorder">
                <xsl:value-of select="position()"/>
            </xsl:attribute>
            <lido:term>
                <xsl:value-of select="." />
            </lido:term>
        </lido:objectWorkType>
    </xsl:template>
    
    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:systematikArt">
            <lido:classification>
                <xsl:attribute name="lido:type">SystematikArt</xsl:attribute>
                <xsl:attribute name="lido:sortorder">
                    <xsl:number />
                </xsl:attribute>
                <lido:term>
                    <xsl:value-of select="." />
                </lido:term>
            </lido:classification>
    </xsl:template>

    <!-- only called when with certain terms, see above -->    
    <xsl:template mode="classification" 
        match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:objekttyp">
        <lido:classification>
            <xsl:attribute name="lido:type">Objekttyp</xsl:attribute>
            <lido:term>
                <xsl:value-of select="." />
            </lido:term>
        </lido:classification>
    </xsl:template>
</xsl:stylesheet>