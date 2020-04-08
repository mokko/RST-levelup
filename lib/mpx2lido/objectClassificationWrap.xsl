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
        objectClassificarionWrap is required; is it the only required wrap? 
        No: also required is the objectWorkTyperWrap
    -->

    <xsl:template name="objectClassificationWrap">
        <lido:objectClassificationWrap>
            <xsl:choose>
                <xsl:when test="mpx:sachbegriff">
                    <lido:objectWorkTypeWrap>
                        <xsl:apply-templates select="mpx:sachbegriff" mode="workType">
                            <xsl:sort select="@art" />
                        </xsl:apply-templates>
                    </lido:objectWorkTypeWrap>
                </xsl:when>
                <!-- mandatory objectWorkTypeWrap -->
                <xsl:otherwise>
                    <lido:objectWorkTypeWrap>
                        <lido:objectWorkType>
                            <xsl:attribute name="lido:type">Objekttyp</xsl:attribute>
                            <lido:term>
                                <xsl:value-of select="mpx:objekttyp" />
                            </lido:term>
                        </lido:objectWorkType>
                    </lido:objectWorkTypeWrap>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="mpx:systematikArt">
                <lido:classificationWrap>
                    <xsl:apply-templates select="mpx:systematikArt" />
                </lido:classificationWrap>
            </xsl:if>
        </lido:objectClassificationWrap>
    </xsl:template>


    <!-- 
        20200114: sortorder added, TODO: not sure it's always in the right 
        order, currently known attributes "Sachbegriff" and "weiterer Sachbegriff".
        
        objectWorktype is required 
    -->
    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff" 
        mode="workType">
        <lido:objectWorkType>
            <!-- 
                (1) "Sachbegriff" before "Weiterer Sachbegriff", using position() over xsl:number
            -->
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
</xsl:stylesheet>