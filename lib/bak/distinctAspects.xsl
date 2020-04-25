<xsl:stylesheet version="2.0"
	xmlns="http://www.mpx.org/mpx"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		
		<museumPlusExport level="distinctAspects" version="2.0">
			<multimediaobjekt>
				<xsl:for-each-group select="/mpx:museumPlusExport/mpx:multimediaobjekt/*" group-by="name()">
					<xsl:sort select="name()" />
					<xsl:element name="{name()}"/>
				</xsl:for-each-group>
			</multimediaobjekt>
			<personKörperschaft>
			<xsl:for-each-group select="/mpx:museumPlusExport/mpx:personKörperschaft/*" group-by="name()">
					<xsl:sort select="name()" />
					<xsl:element name="{name()}"/>
				</xsl:for-each-group>
			</personKörperschaft>
			<sammlungsobjekt>
			<xsl:for-each-group select="/mpx:museumPlusExport/mpx:sammlungsobjekt/*" group-by="name()">
					<xsl:sort select="name()" />
					<xsl:element name="{name()}"/>
				</xsl:for-each-group>
			</sammlungsobjekt>
		</museumPlusExport>
	</xsl:template>

</xsl:stylesheet>
