<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <!-- Descriptive Metadata -->
    <xsl:import href="mpx2lido/objectClassificationWrap.xsl" />
    <xsl:import href="mpx2lido/objectIdentificationWrap.xsl" />
    <xsl:import href="mpx2lido/eventWrap.xsl" />
    <xsl:import href="mpx2lido/objectRelationWrap.xsl" />
    <!-- Administrative Metadata -->
    <xsl:import href="mpx2lido/rightsWorkWrap.xsl" />
    <xsl:import href="mpx2lido/recordWrap.xsl" />
    <xsl:import href="mpx2lido/resourceWrap.xsl" />

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />


    <xsl:template match="/">
            <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
    </xsl:template>


    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
        <xsl:message>
            <xsl:text>2LIDO-objId: </xsl:text>
            <xsl:value-of select="@objId" />
        </xsl:message>
        <xsl:variable name="file" select="concat(normalize-space(@objId),'.lido')"/>
        <xsl:result-document href="{$file}">
            <lido:lidoWrap xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
                <lido:lido>
                    <lido:lidoRecID>
                        <xsl:attribute name="lido:source">
                            <xsl:value-of select="mpx:verwaltendeInstitution" />
                        </xsl:attribute>
                        <xsl:attribute name="lido:type">local</xsl:attribute>
                        <xsl:text>objId/</xsl:text>
                        <xsl:value-of select="@objId" />
                    </lido:lidoRecID>
        
                    <!-- lido:category -->
                    <xsl:apply-templates select="mpx:objekttyp" />
        
                    <lido:descriptiveMetadata xml:lang="de">
                        <xsl:call-template name="objectClassificationWrap"/>
                        <xsl:call-template name="objectIdentificationWrap"/>
                        <xsl:call-template name="eventWrap"/>
                        <xsl:call-template name="objectRelationWrap"/>
                    </lido:descriptiveMetadata>
        
                    <lido:administrativeMetadata xml:lang="en">
                        <xsl:call-template name="rightsWorkWrap"/>
                        <xsl:call-template name="recordWrap"/>
                        <xsl:call-template name="resourceWrap"/>
                    </lido:administrativeMetadata>
                </lido:lido>
            </lido:lidoWrap>
        </xsl:result-document>
    </xsl:template>

    <!-- using objekttyp for main category, not CIDOC terminology -->
    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:objekttyp">
        <lido:category>
            <lido:conceptID lido:type="URI">
                <xsl:text>http://www.mpx.org/concepts/Objekttyp/</xsl:text>
                <xsl:value-of select="." />
            </lido:conceptID>
            <lido:term xml:lang="de">
                <xsl:value-of select="." />
            </lido:term>
        </lido:category>
    </xsl:template>
</xsl:stylesheet>