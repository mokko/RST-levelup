<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mpx="http://www.mpx.org/mpx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- copy this file to temp subdir and use it from there -->
	<xsl:variable name="collection" select="collection('../1-XML?select=*.xml')"/>

	<xsl:template match="/">
	
		<museumPlusExport level="join" version="2.0">
			<xsl:for-each select="$collection/*/*">
				<xsl:sort select="name()" order="ascending" />
				<xsl:sort select="@mulId|@kueId|@objId" />
				<xsl:copy-of select="." />
			</xsl:for-each>
		</museumPlusExport>
	</xsl:template>

</xsl:stylesheet>