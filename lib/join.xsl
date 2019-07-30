<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mpx="http://www.mpx.org/mpx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<!-- xsl:attribute name="level">join</xsl:attribute -->
		<xsl:apply-templates select="*" />

	</xsl:template>


	<xsl:template match="*">
		<xsl:copy>
			<xsl:for-each select="/*/*|document ('B.xml')/*/*">
				<xsl:sort select="name()" order="ascending" />
				<xsl:sort select="@mulId|@kueId|@objId" />
				<xsl:copy-of select="." />
			</xsl:for-each>
		</xsl:copy>

	</xsl:template>
</xsl:stylesheet>