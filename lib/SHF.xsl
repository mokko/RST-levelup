<xsl:stylesheet version="2.0"
	xmlns="http://www.mpx.org/npx"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mpx="http://www.mpx.org/mpx" 
    xmlns:npx="http://www.mpx.org/npx"

    exclude-result-prefixes="mpx npx">
    
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

    <!-- strict push sequence-->

    <xsl:template match="/">
    <shf version="20190927">
        <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
    </shf>
    </xsl:template>
    

    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
        <xsl:variable name="objId" select="@objId"/>
        <xsl:element name="sammlungsobjekt">
            <xsl:attribute name="objId">
                <xsl:value-of select="@objId"/>
            </xsl:attribute>
            <xsl:attribute name="exportdatum">
                <xsl:value-of select="@exportdatum"/>
            </xsl:attribute>

            <!-- referenziertes Felder (works only with $objId not with @objId)-->
            <xsl:apply-templates select="/mpx:museumPlusExport/mpx:ausstellung/mpx:objekt[. = $objId]"/>

            
            <xsl:apply-templates select="mpx:ausstellung|
                                         mpx:anzahlTeile|
                                         mpx:bearbDatum|
                                         mpx:datierung"/>

                                         
            <xsl:if test="(mpx:verwaltendeInstitution and mpx:erwerbungsart and mpx:erwerbDatum) or mpx:erwerbNotiz[@Ausgabe]">
                <xsl:element name="erwerbNotizAusgabe">
                    <xsl:choose>
                        <xsl:when test="mpx:erwerbNotiz[@Ausgabe]">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                            <xsl:when test="mpx:verwaltendeInstitution and mpx:erwerbDatum and mpx:erwerbungsart">
                                <xsl:value-of select="mpx:verwaltendeInstitution"/> 
                                <xsl:text> (oder eine Vorgängerinstitution) erwarb das Objekt </xsl:text> 
                                <xsl:value-of select="mpx:erwerbDatum"/> 
                                <xsl:text> durch </xsl:text>
                                <xsl:value-of select="mpx:erwerbungsart"/>
                                <xsl:text>.</xsl:text>
                             </xsl:when>
                             <xsl:when test="mpx:verwaltendeInstitution and mpx:erwerbDatum">
                                <xsl:value-of select="mpx:verwaltendeInstitution"/> 
                                <xsl:text> (oder eine Vorgängerinstitution) erwarb das Objekt </xsl:text> 
                                <xsl:value-of select="mpx:erwerbDatum"/>
                                <xsl:text>.</xsl:text>                            
                             </xsl:when>
                             <xsl:when test="mpx:verwaltendeInstitution and mpx:erwerbungsart">
                                <xsl:value-of select="mpx:verwaltendeInstitution"/> 
                                <xsl:text> (oder eine Vorgängerinstitution) erwarb das Objekt </xsl:text> 
                                <xsl:value-of select="mpx:erwerbDatum"/> 
                                <xsl:text>.</xsl:text>
                             </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:if>
                
            <xsl:if test="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:geogrBezug">
                <xsl:element name="geogrBezug">
                    <xsl:for-each select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:geogrBezug">
                        <xsl:value-of select="normalize-space()"/>
                        <xsl:if test="position()!=last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
                
            <xsl:apply-templates select="mpx:handlingVerpackungTransport|
                                         mpx:identNr[@art='Ident. Nr.']|
                                         mpx:kABeleuchtung|
                                         mpx:kALuftfeuchtigkeit|
                                         mpx:kABemLeihfähigkeit|
                                         mpx:kATemperatur"/>

            <!-- Quali in the back-->
            <xsl:if test="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:maßangaben">
                <xsl:element name="maßangaben">
                    <xsl:for-each select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:maßangaben">
                        <xsl:value-of select="normalize-space()"/>
                        <xsl:if test="@typ">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@typ"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:if test="position()!=last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>

            <xsl:apply-templates select="mpx:materialTechnik[@art eq 'Ausgabe']"/>

            <xsl:element name="objId">
                <xsl:value-of select="@objId"/>
            </xsl:element>
            
            <xsl:apply-templates select="mpx:onlineBeschreibung"/>


            <xsl:if test="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:sachbegriff">
                <xsl:element name="sachbegriff">
                    <xsl:for-each select="/mpx:museumPlusExport/mpx:sammlungsobjekt[@objId eq $objId]/mpx:sachbegriff">
                        <xsl:value-of select="normalize-space()"/>
                        <xsl:if test="@art">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@art"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:if test="position()!=last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
            
            <xsl:apply-templates select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId]/mpx:standardbild"/>

            <xsl:apply-templates select="mpx:titel|
                                         mpx:verantwortlich|
                                         mpx:verwaltendeInstitution|
                                         mpx:wGAusVorgaben|
                                         mpx:wGGruppe|
                                         mpx:wGRestzeit_gh|
                                         mpx:wGStänderung|
                                         mpx:wGZustand"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt/mpx:standardbild">
        <xsl:element name="standardbild">
            <xsl:value-of select="../mpx:pfadangabe"/>
            <xsl:text>\</xsl:text>
            <xsl:value-of select="../mpx:dateiname"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="../mpx:erweiterung"/>
        </xsl:element>
        <xsl:element name="standardbildUrheber">
            <xsl:value-of select="../mpx:personenKörperschaften"/>
        </xsl:element>
    </xsl:template>


    <!-- 0-n Attribute aus mpx übernehmen -->
    <xsl:template match="
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:anzahlTeile|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:bearbDatum|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:datierung|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:handlingVerpackungTransport|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:kABeleuchtung|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:kABemLeihfähigkeit|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:kALuftfeuchtigkeit|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:kATemperatur|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:maßangaben|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:onlineBeschreibung|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:sachbegriff|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:titel|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:verantwortlich|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:verwaltendeInstitution|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:wGAusVorgaben|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:wGGruppe|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:wGRestzeit_gh|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:wGStänderung|
                /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:wGZustand
                ">
        <xsl:element name="{name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <!--no attibutes-->
    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:identNr[@art='Ident. Nr.']|
                         /mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:materialTechnik[@art eq 'Ausgabe']">
        <xsl:element name="{name()}">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    
    <!-- Ich nehme hier mal an, dass jedes Objekt immer nur in einer HF Ausstellung zu sehen sein wird; es
    ist aber durchaus möglich, dass ein Objekt von einer in die andere Ausstellung wechselt. Dann wären auch Daten 
    wichtig. -->
    <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt/mpx:ausstellung">
        <xsl:if test="matches(., 'HUFO')">
            <xsl:element name="{name()}">
                <xsl:value-of select="."/>
            </xsl:element>
            <xsl:element name="ausstellungSektion">
                    <xsl:value-of select="@sektion"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    
    <!-- ausstellung as separate entity -->
 

    <xsl:template match="/mpx:museumPlusExport/mpx:ausstellung/mpx:objekt">
        <xsl:element name="ausstellung">
            <xsl:attribute name="sektion">
                <xsl:value-of select="@sektion"/>
            </xsl:attribute>
            <xsl:value-of select="../mpx:titel"/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>
