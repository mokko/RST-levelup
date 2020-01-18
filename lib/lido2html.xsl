<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 	xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    >

	<xsl:output method="html" name="html" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />
	<!-- 
	PLAN 
	...intro...
	**recID as heading
	*objectPublishedID
	*category
	...descriptive...
	L1 Object Classification 
	L2 Object Identification 
	L3 Events  
	L4 Relations
	...administrative...
	L5 Rights 
	L6 Record 
	L7 Resources 
	
	Felder als eine dreispaltige Tabelle: Feldname, Feldwert, Attribute in key/value-Form

	<xsl:for-each select="//testrun">
		<xsl:variable name="filename" select="concat('output1/',@run,'.html')" />
		<xsl:value-of select="$filename" />  
		<xsl:result-document href="{$filename}" format="html">
	    <html><body>
	        <xsl:value-of select="@run"/>
	    </body></html>
		</xsl:result-document>
	/xsl:for-each
	
	-->
	<xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

	<xsl:template match="/">
				<xsl:apply-templates select="/lido:lidoWrap/lido:lido"/>
	</xsl:template>

	<!-- don't show (again) -->
	<xsl:template match="lido:lidoRecID|
		lido:objectWorkType/lido:term|
		lido:conceptID|
		lido:category/lido:term
		"/>

	<!-- INTRO -->	


	<xsl:template match="/lido:lidoWrap/lido:lido">
		<xsl:variable name="file" select="concat(normalize-space(lido:lidoRecID),'.html')"/>
		<xsl:result-document href="{$file}">
			<html>
				<header>
					<title>lido2html</title>
				</header>
				<body>
					<h1><xsl:value-of select="lido:lidoRecID"/></h1>
					<xsl:value-of select="$newline"/>
					<xsl:text>@source: </xsl:text>
					<xsl:value-of select="lido:lidoRecID/@lido:source"/>
					<xsl:text> @type: </xsl:text>
					<xsl:value-of select="lido:lidoRecID/@lido:type"/>
					<br/>
					<table border="1">
						<xsl:apply-templates select="*"/>
					</table> 
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>

	<!-- container with attributes -->
	<xsl:template match="lido:descriptiveMetadata|lido:administrativeMetadata">
		<tr>
			<td colspan="2" align="center">
				<h4>
					<xsl:value-of select="name()"/>
					<xsl:call-template name="attributeList"/>
				</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<!--  L1-L6 -->


	<xsl:template match="lido:objectClassificationWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L1 Object Classification</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template match="lido:objectIdentificationWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L2 Object Identification</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template match="lido:eventWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L3 Events</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template match="lido:objectRelationWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L4 Relations</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template match="lido:rightsWorkWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L5 Rights</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<xsl:template match="lido:recordWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L6 Record</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>
	 

	<xsl:template match="lido:resourceWrap">
		<tr>
			<td colspan="2">
			<h4>
				<xsl:text>L7 Resources</xsl:text>
			</h4>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<!-- non-repeatable container without attributes (all wraps) -->
	<xsl:template match="
		lido:objectWorkTypeWrap|
		lido:titleWrap|
		lido:inscriptionsWrap|
		lido:displayStateEditionWrap|
		lido:objectDescriptionWrap|
		lido:objectMeasurementsWrap|
		lido:objectdescriptionWrap|
		lido:repositoryWrap|
		lido:classificationWrap">
		<tr>
			<td colspan="2">
				<xsl:value-of select="name()"/>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>

	<!-- proper field not container?-->
	<xsl:template match="
		lido:objectWorkType|
		lido:category|
		lido:titleSet|
		lido:inscriptions|
		lido:repositorySet|
		lido:repositoryName|
		lido:workID|
		lido:repositoryLocation">
		<tr>
			<td>
				<xsl:value-of select="name()"/>
				<xsl:call-template name="attributeList"/>
			</td>
			<td>
				<xsl:for-each select="*">
					<xsl:value-of select="name()"/>
					<xsl:text>: </xsl:text> 
					<xsl:value-of select="."/>
					<xsl:call-template name="attributeList"/>
					<br/> 
				</xsl:for-each>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>
	

	<xsl:template name="attributeList">
		<xsl:if test="@*">
			<xsl:text> (</xsl:text>
			<xsl:for-each select="@*">
				<xsl:if test="position()!=1">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:text>@</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>=</xsl:text> 
				<xsl:value-of select="."/>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>	
	
</xsl:stylesheet>

