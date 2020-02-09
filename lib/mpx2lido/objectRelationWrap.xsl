<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="objectRelationWrap">
		<xsl:apply-templates select="mpx:oov"/>
	</xsl:template>
	
	<xsl:template match="mpx:oov">
		<lido:relatedWorkSet>
			<lido:relatedWork><xsl:value-of select="."/></lido:relatedWork>
			<lido:relatedWorkRelType>
				<lido:term>
					<xsl:value-of select="@art"/>
				</lido:term>
			</lido:relatedWorkRelType>
		</lido:relatedWorkSet>
	</xsl:template>
</xsl:stylesheet>