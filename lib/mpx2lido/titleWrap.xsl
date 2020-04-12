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
        FIELDS: title
        
        Sachbegriff[einheimische Bezeichnung (lokal)] ist kein Sachbegriff, 
        sondern overloading.
        
        lido:titleSet bekommt alle mpx:titel; nur wenn keine vorhanden, nimm 
        den ersten Sachbegriff. Das kann gerne die einheimische Bezeichnung  
        sein. Wir haben dann Sachbegriff (z.B. Sandale) und Titel z.B. 
        "Kamaa-maia" (objId/1000025).
    -->

    <xsl:template name="titleWrap">
        <lido:titleWrap>
            <xsl:choose>
                <xsl:when test="mpx:titel">
                    <xsl:apply-templates mode="title" select="mpx:titel"/>
                </xsl:when>
                <xsl:when test="mpx:sachbegriff and not (mpx:titel)">
                    <xsl:apply-templates mode="title" select="mpx:sachbegriff[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <lido:titleSet>
                        <lido:appellationValue>
                            <xsl:attribute name="lido:pref">preferred</xsl:attribute>
                            <xsl:text>kein Titel</xsl:text>
                            <xsl:message>
                                <xsl:text>objId/</xsl:text>
                                <xsl:value-of select="@objId"/>
                                <xsl:text> Error: Kein lido:title! Fix sachbegriff in m+</xsl:text>
                            </xsl:message>
                        </lido:appellationValue>
                    </lido:titleSet>
                </xsl:otherwise>
            </xsl:choose>
        </lido:titleWrap>
    </xsl:template>

    <xsl:template mode="title" match="mpx:titel|mpx:sachbegriff">
        <lido:titleSet>
            <lido:appellationValue>
                <xsl:attribute name="xml:lang">
                    <xsl:choose>
                        <xsl:when test="@art = 'Übersetzung engl.'">
                            <xsl:text>en</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>de</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="position() = 1">
                    <xsl:attribute name="lido:pref">preferred</xsl:attribute>
                </xsl:if>
                <xsl:if test="@art">
                    <xsl:attribute name="lido:type">
                        <xsl:value-of select="@art"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="lido:encodinganalog">
                    <xsl:value-of select="name()"/>
                </xsl:attribute>
                <xsl:value-of select="." />
            </lido:appellationValue>
        </lido:titleSet>
    </xsl:template>
</xsl:stylesheet>