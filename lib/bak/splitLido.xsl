<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="lido">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- expects a "big" lido and splits it in many small ones -->

	<xsl:template match="/">
		<xsl:for-each select="/lido:lidoWrap/lido:lido">
			<xsl:variable name="file" select="concat(normalize-space(lido:lidoRecID),'.lido')"/>
			<xsl:message><xsl:value-of select="$file"/></xsl:message>
			<xsl:result-document href="{$file}">
				<lido:lidoWrap xmlns:lido="http://www.lido-schema.org"
				               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				               xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
					<xsl:copy-of select="."/>
				</lido:lidoWrap>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>