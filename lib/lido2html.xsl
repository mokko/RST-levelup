<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 	xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="lido xsi h"
    >

	<xsl:output method="html" name="html" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- ROOT -->
	<xsl:template match="/">
				<xsl:apply-templates select="/lido:lidoWrap/lido:lido"/>
	</xsl:template>



	<!-- INTRO -->	
	<xsl:template match="/lido:lidoWrap/lido:lido">
		<xsl:variable name="file" select="concat(normalize-space(lido:lidoRecID),'.html')"/>
		<xsl:result-document href="{$file}" method="html" encoding="UTF-8">
			<html>
				<header>
					<title>lido2html</title>
				</header>
				<body>
					<h1><xsl:value-of select="lido:lidoRecID"/></h1>
					<table border="1" width="800">
					<xsl:apply-templates select="*"/>
					</table> 
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="w">
		<xsl:for-each select="@*">
			<xsl:text>@</xsl:text>
			<xsl:value-of select="name()"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="lido:objectPublishedID|lido:lidoRecID">
		<tr>
			<td>
				<xsl:value-of select="name()"/>
				<xsl:call-template name="attributeList"/>
			</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>


	<!-- don't show (again) -->
	<xsl:template match="//lido:term|
		//lido:appellationValue|
		//lido:descriptiveNoteValue|
		//lido:conceptID
		"/>


	<!-- 
		TOP LEVEL containers:
		container with attributes 
	-->
	<xsl:template match="lido:descriptiveMetadata|lido:administrativeMetadata">
		<tr>
			<td colspan="2" align="center">
				<h4>
					<xsl:value-of select="name()"/>
					<xsl:call-template name="attributeList"/>
				</h4>
			</td>
		</tr>
		<xsl:apply-templates/>
	</xsl:template>


	<!--  		
		 2nd level container L1-L7 
	 -->
	<xsl:template match="lido:objectClassificationWrap|
		lido:objectIdentificationWrap|
		lido:eventWrap|
		lido:objectRelationWrap|
		lido:rightsWorkWrap|
		lido:recordWrap|
		lido:resourceWrap">
		<tr>
			<td colspan="2">
				<h4>
					<xsl:number count="." level="single" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="replace(name(),'lido:','')"/>
				</h4>
			</td>
		</tr>
		<xsl:apply-templates/>
	</xsl:template>


	<!-- 
		3rd level: non-repeatable container without attributes (all remaining wraps)
		subjectWrap is on a different level, but still a wrap (not required, non-repeatable)
	-->

	<xsl:template match="
		lido:objectWorkTypeWrap|
		lido:titleWrap|
		lido:inscriptionsWrap|
		lido:displayStateEditionWrap|
		lido:objectDescriptionWrap|
		lido:objectMeasurementsWrap|
		lido:objectdescriptionWrap|
		lido:repositoryWrap|
		lido:classificationWrap|
		lido:subjectWrap|
		lido:actor
		">
		<tr>
			<td colspan="2" align="left">
				<h4>
					<xsl:value-of select="name()"/>
				</h4>
			</td>
		</tr>
		<xsl:apply-templates/>
	</xsl:template>


	<!-- 
		CONTAINER WITH OPTIONAL ATTRIBUTES (not-required, repeatable), e.g. eventSet which has @sortorder and two subelements displayEvent and event  
	-->
	<xsl:template match="lido:eventSet|
		lido:event|
		lido:resourceSet|
		lido:repositorySet|
		lido:eventActor|
		lido:objectMeasurementsSet|
		lido:eventDate|
		lido:date|
		lido:actorInRole|
		lido:objectMeasurements|
		lido:measurementsSet|
		lido:rightsWorkSet|
		lido:eventMaterialsTech|
		lido:repositoryName|
		lido:recordRights|
		lido:repositoryLocation|
		lido:partOfPlace
		">
		<tr>
			<td colspan="2" align="left">
				<h4>
					<xsl:value-of select="name()"/>
					<xsl:call-template name="attributeList"/>
				</h4>
			</td>
		</tr>
		<xsl:apply-templates/>
	</xsl:template>



	<!-- FIELD TYPE 1
	DOESN'T WORK TODO: ActorID
	-->
	<xsl:template match="
		lido:objectWorkType|
		lido:category|
		lido:namePlaceSet|
		lido:classification|
		lido:titleSet|
		lido:actorID|
		lido:inscriptions|
		lido:objectDescriptionSet|
		lido:recordID|
		lido:materialsTech|
		lido:recordType|
		lido:recordSource|
		lido:recordInfoSet|
		lido:eventType|lido:Culture|
		lido:eventPlace|
		lido:rightsHolder|
		lido:rightsHolder|lido:namePlaceSet|
		lido:nameActorSet|lido:vitalDatesActor|lido:genderActor|lido:rightsType|lido:rightsHolder|lido:legalBodyName
		">
		<tr>
			<td>
				<xsl:value-of select="name()"/>
				<xsl:call-template name="attributeList"/>
			</td>
			<td>
				<xsl:for-each select="*">
					<xsl:value-of select="name()"/>
					<xsl:call-template name="attributeList"/>
					<xsl:text>: </xsl:text> 
					<xsl:value-of select="."/>
					<br/> 
				</xsl:for-each>
			</td>
		</tr>
		<xsl:apply-templates select="*"/>
	</xsl:template>


	<!--  FIELD TYPE 2: element with attributes plus one value, repeatable -->
	<xsl:template match="lido:displayEvent|
		lido:workID|
		lido:displayActorInRole|	
		lido:extentMeasurements|
		lido:displayObjectMeasurements|
		lido:displayDate|
		lido:legalBodyID|
		lido:roleActor|
		lido:earliestDate|
		lido:latestDate|
		lido:measurementType|
		lido:measurementUnit|
		lido:measurementValue|
		lido:placeID|
		lido:extentMeasurements|
		lido:legalBodyWeblink|
		lido:displayPlace|lido:displayMaterialsTech
	">
		<tr>
			<td>
				<xsl:value-of select="name()"/>
				<xsl:call-template name="attributeList"/>
			</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>


	<!-- 
		NAMED TEMPLATES
	-->		
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

