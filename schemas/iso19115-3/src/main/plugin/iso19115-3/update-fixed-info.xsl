<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
  xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
  xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0"
  xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:java="java:org.fao.geonet.util.XslUtil"
  xmlns:mime="java:org.fao.geonet.util.MimeTypeFinder"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">
  
  <xsl:import href="convert/ISO19139/utility/create19115-3Namespaces.xsl"/>
  <xsl:import href="source-dataset-alt.xsl"/>
  <xsl:include href="convert/functions.xsl"/>

	<!-- The correct codeList Location goes here -->
	<xsl:variable name="codeListLocation" select="'codeListLocation'"/>

  <!-- If no metadata linkage exist, build one based on
  the metadata UUID. -->
  <xsl:variable name="createMetadataLinkage" select="true()"/>
  <xsl:variable name="url" select="/root/env/siteURL"/>
  <xsl:variable name="uuid" select="/root/env/uuid"/>

  <xsl:variable name="metadataIdentifierCodeSpace"
                select="'urn:uuid'"
                as="xs:string"/>

  <xsl:template match="/root">
    <xsl:apply-templates select="mdb:MD_Metadata"/>
  </xsl:template>
  
  <xsl:template match="mdb:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      
      <xsl:call-template name="add-iso19115-3-namespaces"/>
      
      <!-- Add metadataIdentifier if it doesn't exist
      TODO: only if not harvested -->
      <mdb:metadataIdentifier>
        <mcc:MD_Identifier>
          <!-- authority could be for this GeoNetwork node ?
            <mcc:authority><cit:CI_Citation>etc</cit:CI_Citation></mcc:authority>
          -->
	<mcc:authority>
	  <cit:CI_Citation>
	    <cit:title>
	       <gco:CharacterString>GeoNetwork UUID</gco:CharacterString>
	    </cit:title>
	  </cit:CI_Citation>
	</mcc:authority>
          <mcc:code>
            <gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
          </mcc:code>
          <mcc:codeSpace>
            <gco:CharacterString><xsl:value-of select="$metadataIdentifierCodeSpace"/></gco:CharacterString>
          </mcc:codeSpace>
        </mcc:MD_Identifier>
      </mdb:metadataIdentifier>

  <!--    <xsl:apply-templates select="mdb:metadataIdentifier[
                                    mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString !=
                                    $metadataIdentifierCodeSpace]"/>-->

      <xsl:apply-templates select="mdb:defaultLocale"/>
      <xsl:apply-templates select="mdb:parentMetadata"/>
      <xsl:apply-templates select="mdb:metadataScope"/>
      <xsl:apply-templates select="mdb:contact"/>


      <xsl:variable name="isCreationDateAvailable"
                    select="mdb:dateInfo/*[cit:dateType/*/@codeListValue = 'creation']"/>
      <xsl:variable name="isRevisionDateAvailable"
                    select="mdb:dateInfo/*[cit:dateType/*/@codeListValue = 'revision']"/>

      <!-- Add creation date if it does not exist-->
      <xsl:if test="not($isCreationDateAvailable)">
        <mdb:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="{concat($codeListLocation,'#CI_DateTypeCode')}" codeListValue="creation"/>
            </cit:dateType>
          </cit:CI_Date>
        </mdb:dateInfo>
      </xsl:if>
      <xsl:if test="not($isRevisionDateAvailable)">
        <mdb:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="{concat($codeListLocation,'#CI_DateTypeCode')}" codeListValue="revision"/>
            </cit:dateType>
          </cit:CI_Date>
        </mdb:dateInfo>
      </xsl:if>


	  <xsl:apply-templates select="mdb:dateInfo"/>

      <!-- Preserve date order -->
      <!-- <xsl:for-each select="mdb:dateInfo">
        <xsl:variable name="currentDateType" select="*/cit:dateType/*/@codeListValue"/> -->

        <!-- Update revision date-->
        <!-- <xsl:choose>
          <xsl:when test="$currentDateType = 'revision' and /root/env/changeDate">
            <mdb:dateInfo>
              <cit:CI_Date>
                <cit:date>
                  <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
                </cit:date>
                <cit:dateType>
                  <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/>
                </cit:dateType>
              </cit:CI_Date>
            </mdb:dateInfo>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each> -->



      <!-- Add metadataStandard if it doesn't exist -->
      <xsl:choose>
        <xsl:when test="not(mdb:metadataStandard)">
          <mdb:metadataStandard>
            <cit:CI_Citation>
              <cit:title>
                <gco:CharacterString>ISO19115-1:2014/ISO19115-3:2015</gco:CharacterString>
              </cit:title>
              <cit:edition>
                <gco:CharacterString>2015</gco:CharacterString>
              </cit:edition>
            </cit:CI_Citation>
          </mdb:metadataStandard>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="mdb:metadataStandard"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- Add metadataProfile if it doesn't exist -->
      <xsl:choose>
        <xsl:when test="not(mdb:metadataProfile)">
          <mdb:metadataProfile>
            <cit:CI_Citation>
              <cit:title>
                <gco:CharacterString>Geoscience Australia Community Metadata Profile of ISO 19115-1:2014</gco:CharacterString>
              </cit:title>
              <cit:edition>
                <gco:CharacterString>Version 2.0, September 2018</gco:CharacterString>
              </cit:edition>
              <cit:identifier>
					<mcc:MD_Identifier>
					   <mcc:code>
						  <gco:CharacterString>http://pid.geoscience.gov.au/dataset/ga/122551</gco:CharacterString>
					   </mcc:code>
					</mcc:MD_Identifier>
				 </cit:identifier>
            </cit:CI_Citation>
          </mdb:metadataProfile>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="mdb:metadataProfile"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Add gaid if specified as alternativeMetadataReference, otherwise copy existing reference to gaid 
			     NOTE: If you change the codeSpace, you must also change it in index.xsl, layout/layout-custom-fields.xsl, extract-ga-id.xsl
					 and in the ISO19139-to-ISO19115-3 conversion script in web/src/main/webapp/xsl/conversion/import 
					 This codeSpace value is the way in which the ga-id is recognized. -->
			<xsl:choose>
				<xsl:when test="/root/env/gaid">
					<mdb:alternativeMetadataReference>
						<cit:CI_Citation>
							<cit:title>
								<gco:CharacterString>Geoscience Australia Products Catalogue (eCat) – Short identifier for metadata record.</gco:CharacterString>
							</cit:title>
							<cit:identifier>
								<mcc:MD_Identifier>
									<mcc:code>
										<gco:CharacterString>
											<xsl:value-of select="/root/env/gaid" />
										</gco:CharacterString>
									</mcc:code>
									<mcc:codeSpace>
										<gco:CharacterString>eCatId</gco:CharacterString>
									</mcc:codeSpace>
								</mcc:MD_Identifier>
							</cit:identifier>
						</cit:CI_Citation>
					</mdb:alternativeMetadataReference>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of
						select="mdb:alternativeMetadataReference[cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString='eCatId']" />
				</xsl:otherwise>
			</xsl:choose>
     
		 	<!-- Now process all other alternativeMetadataReference elements -->
      <!-- <xsl:apply-templates select="mdb:alternativeMetadataReference[cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString!='eCatId']"/> -->
      <!--<xsl:apply-templates select="mdb:alternativeMetadataReference"/>-->
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>

      <xsl:variable name="pointOfTruthUrl" select="concat($url, 'catalog.search#/metadata/', $uuid)"/>

      <xsl:if test="$createMetadataLinkage and count(mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage/*[. = $pointOfTruthUrl]) = 0">
        <!-- TODO: This should only be updated for not harvested records ? -->
        <mdb:metadataLinkage>
          <cit:CI_OnlineResource>
            <cit:linkage>
              <!-- TODO: define a URL pattern and use it here -->
              <!-- TODO: URL could be multilingual ? -->
              <gco:CharacterString><xsl:value-of select="$pointOfTruthUrl"/></gco:CharacterString>
            </cit:linkage>
            <cit:protocol gco:nilReason="missing">
				<gco:CharacterString xsi:type="gco:CodeType"
									 codeSpace="http://pid.geoscience.gov.au/def/schema/ga/ISO19115-3-2016/codelist/ga_profile_codelists.xml#gapCI_ProtocolTypeCode"/>
			 </cit:protocol>
            <!-- TODO: Could be relevant to add description of the
            point of truth for the metadata linkage but this
            needs to be language dependant. -->
            <cit:function>
              <cit:CI_OnLineFunctionCode codeList="{concat($codeListLocation,'#CI_OnLineFunctionCode')}"
                                         codeListValue="completeMetadata"/>
            </cit:function>
          </cit:CI_OnlineResource>
        </mdb:metadataLinkage>
      </xsl:if>

      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:apply-templates select="mdb:identificationInfo"/>
      <xsl:apply-templates select="mdb:contentInfo"/>
      <!--<xsl:apply-templates select="mdb:distributionInfo"/>-->
	  <xsl:choose>
			<xsl:when
				test="//cit:CI_Citation[starts-with(cit:title/gco:CharacterString, 'Source Dataset Classification')]">
				<mdb:distributionInfo>
					<mrd:MD_Distribution>
					<xsl:for-each select="//mrd:MD_Distribution/mrd:distributionFormat">
						<xsl:copy>
							<xsl:if test="position() = 1">
								<xsl:copy-of select="*[position() = 1]"/>
							</xsl:if>
						</xsl:copy>
					  </xsl:for-each>
						
						<xsl:for-each
							select="//mri:MD_Keywords[starts-with(mri:thesaurusName/cit:CI_Citation/cit:title/gco:CharacterString, 'Source Dataset Classification')]/mri:keyword">

							<xsl:variable name="sdlKeyword" select="gco:CharacterString" />
							<xsl:variable name="eCatId"
								select="//mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString" />
							<xsl:call-template name="sdl_online">
								<xsl:with-param name="sdlKeyword" select="$sdlKeyword" />
								<xsl:with-param name="eCatId" select="$eCatId" />
							</xsl:call-template>

						</xsl:for-each>
					</mrd:MD_Distribution>
				</mdb:distributionInfo>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="mdb:distributionInfo" />
			</xsl:otherwise>
		</xsl:choose>
      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
      <xsl:apply-templates select="mdb:acquisitionInformation"/>
    </xsl:copy>
  </xsl:template>

	<xsl:template match="cit:CI_Citation/cit:identifier[mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString = 'Geoscience Australia Persistent Identifier']">
	
	<xsl:variable name="codelistvalue" select="//mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue" />

		<xsl:copy>
			<mcc:MD_Identifier>
				<mcc:code>
					<gco:CharacterString>
						<xsl:choose>
							<xsl:when test="/root/env/gaid">
								<xsl:variable name="ecatId" select="/root/env/gaid" />
								<xsl:choose>
									<xsl:when test="$codelistvalue='service'">
										<xsl:value-of select="concat('https://pid.geoscience.gov.au/', 'service', '/ga/', $ecatId)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('https://pid.geoscience.gov.au/', 'dataset', '/ga/', $ecatId)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="ecatId" select="//mdb:alternativeMetadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[mcc:codeSpace/gco:CharacterString='eCatId']/mcc:code/gco:CharacterString" />
								<xsl:choose>
									<xsl:when test="$codelistvalue='service'">
										<xsl:value-of select="concat('https://pid.geoscience.gov.au/', 'service', '/ga/', $ecatId)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('https://pid.geoscience.gov.au/', 'dataset', '/ga/', $ecatId)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</mcc:code>
				<mcc:codeSpace>
					<gco:CharacterString>Geoscience Australia Persistent Identifier</gco:CharacterString>
				</mcc:codeSpace>
			</mcc:MD_Identifier>
		</xsl:copy>
	</xsl:template>
  
  
  <!-- Update revision date -->
  <xsl:template match="mdb:dateInfo[cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue='lastUpdate']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="/root/env/changeDate">
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="{concat($codeListLocation,'#CI_DateTypeCode')}" codeListValue="revision"/>
            </cit:dateType>
          </cit:CI_Date>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="@gml:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat 
    ordering) by default -->
  <xsl:template match="@srsName">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="srsName">
          <xsl:text>CRS:84</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]">
    <xsl:copy>
      <xsl:attribute name="gml:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="*[gco:CharacterString]">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name()='gco:nilReason')]"/>
      <xsl:choose>
        <xsl:when test="normalize-space(gco:CharacterString)=''">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- codelists: set @codeList path -->
  <xsl:template match="lan:LanguageCode[@codeListValue]" priority="10">
    <lan:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
    </lan:LanguageCode>
  </xsl:template>
  
  <xsl:template match="dqm:*[@codeListValue]" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat('http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19157_Schemas/resources/codelist/ML_gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[@codeListValue]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat($codeListLocation,'#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
  
  <!-- Joseph - Add Protocol codeSpace to GA Profile codelist -->
  <xsl:template match="cit:CI_OnlineResource[not(cit:protocol/gco:CharacterString/@codeSpace = 'http://pid.geoscience.gov.au/def/schema/ga/ISO19115-3-2016/codelist/ga_profile_codelists.xml#gapCI_ProtocolTypeCode')]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="cit:linkage"/>
      <cit:protocol>
        <gco:CharacterString>
		  <xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance">gco:CodeType</xsl:attribute>
          <xsl:attribute name="codeSpace">http://pid.geoscience.gov.au/def/schema/ga/ISO19115-3-2016/codelist/ga_profile_codelists.xml#gapCI_ProtocolTypeCode</xsl:attribute>
          <xsl:value-of select="cit:protocol/gco:CharacterString"/>
        </gco:CharacterString>
      </cit:protocol>
      <xsl:copy-of select="cit:applicationProfile"/>
	  <xsl:copy-of select="cit:name"/>
      <xsl:copy-of select="cit:description"/>
      <xsl:copy-of select="cit:function"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- online resources: download -->
  <xsl:template match="cit:CI_OnlineResource[matches(cit:protocol/gco:CharacterString,'^WWW:DOWNLOAD-.*-http--download.*') and cit:name]">
    <xsl:variable name="fname" select="cit:name/gco:CharacterString|cit:name/gcx:MimeFileType"/>
    <xsl:variable name="mimeType">
      <xsl:call-template name="getMimeTypeFile">
        <xsl:with-param name="datadir" select="/root/env/datadir"/>
        <xsl:with-param name="fname" select="$fname"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <cit:linkage>
        <gco:CharacterString>
          <xsl:choose>
            <xsl:when test="/root/env/config/downloadservice/simple='true'">
              <xsl:value-of select="concat(/root/env/siteURL,'/resources.get?uuid=',/root/env/uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
            </xsl:when>
            <xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
              <xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?uuid=',/root/env/uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
            </xsl:when>
            <xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
              <xsl:value-of select="cit:linkage/gco:CharacterString"/>
            </xsl:otherwise>
          </xsl:choose>
        </gco:CharacterString>
      </cit:linkage>
      <xsl:copy-of select="cit:protocol"/>
      <xsl:copy-of select="cit:applicationProfile"/>
      <cit:name>
        <gcx:MimeFileType type="{$mimeType}">
          <xsl:value-of select="$fname"/>
        </gcx:MimeFileType>
      </cit:name>
      <xsl:copy-of select="cit:description"/>
      <xsl:copy-of select="cit:function"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- online resources: link-to-downloadable data etc -->
  <xsl:template match="cit:CI_OnlineResource[starts-with(cit:protocol/gco:CharacterString,'WWW:LINK-') and contains(cit:protocol/gco:CharacterString,'http--download')]">
    <xsl:variable name="mimeType">
      <xsl:call-template name="getMimeTypeUrl">
        <xsl:with-param name="linkage" select="cit:linkage/gco:CharacterString"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="cit:linkage"/>
      <xsl:copy-of select="cit:protocol"/>
      <xsl:copy-of select="cit:applicationProfile"/>
      <cit:name>
        <gcx:MimeFileType type="{$mimeType}"/>
      </cit:name>
      <xsl:copy-of select="cit:description"/>
      <xsl:copy-of select="cit:function"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Joseph added - For source dataset online resource, append eCatId to linkage -->
   <xsl:template match="cit:CI_OnlineResource[(cit:name/gco:CharacterString='Link to Source Dataset')]">
 
 	<xsl:variable name="eCatIdzip" select="concat(/root/env/gaid,'.zip')"/>
 		
    <xsl:variable name="mimeType">
      <xsl:call-template name="getMimeTypeUrl">
        <xsl:with-param name="linkage" select="cit:linkage/gco:CharacterString"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="srclinkage" select="cit:linkage/gco:CharacterString" />
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <cit:linkage>
        <gco:CharacterString>
			<xsl:value-of select="concat($srclinkage,/root/env/gaid,'/', $eCatIdzip)"/>
        </gco:CharacterString>
      </cit:linkage>
      <xsl:copy-of select="cit:protocol"/>
      <xsl:copy-of select="cit:applicationProfile"/>
      <cit:name>
        <gcx:MimeFileType type="{$mimeType}"/>
      </cit:name>
      <xsl:copy-of select="cit:description"/>
      <xsl:copy-of select="cit:function"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gcx:FileName[name(..)!='cit:contactInstructions']">
    <xsl:copy>
      <xsl:attribute name="src">
        <xsl:choose>
          <xsl:when test="/root/env/config/downloadservice/simple='true'">
            <xsl:value-of select="concat(/root/env/siteURL,'/resources.get?uuid=',/root/env/uuid,'&amp;fname=',.,'&amp;access=private')"/>
          </xsl:when>
          <xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
            <xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?uuid=',/root/env/uuid,'&amp;fname=',.,'&amp;access=private')"/>
          </xsl:when>
          <xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
            <xsl:value-of select="@src"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Do not allow to expand operatesOn sub-elements 
    and constrain users to use uuidref attribute to link
    service metadata to datasets. This will avoid to have
    error on XSD validation.  |mrc:featureCatalogueCitation[@uuidref] -->
  <xsl:template match="srv:operatesOn">
    <xsl:copy>
      <xsl:copy-of select="@uuidref"/>
      <xsl:if test="@uuidref">
        <xsl:choose>
          <xsl:when test="not(string(@xlink:href)) or starts-with(@xlink:href, /root/env/siteURL)">
            <xsl:attribute name="xlink:href">
              <xsl:value-of select="concat(/root/env/siteURL,'csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://standards.iso.org/iso/19115/-3/mdb/1.0&amp;elementSetName=full&amp;id=',@uuidref)"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="@xlink:href"/>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Set local identifier to the first 3 letters of iso code. Locale ids
    are used for multilingual charcterString using #iso2code for referencing.
  -->
  <xsl:template match="mdb:MD_Metadata/*/lan:PT_Locale">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="id"
                    select="lower-case(java:twoCharLangCode(lan:language/lan:LanguageCode/@codeListValue))"/>
      
      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space(@id)='' or normalize-space(@id)!=$id">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- Apply same changes as above to the lan:LocalisedCharacterString -->
  <xsl:variable name="language" select="//(mdb:defaultLocale|mdb:otherLocale)/lan:PT_Locale" /> <!-- Need list of all locale -->
  
  <xsl:template match="lan:LocalisedCharacterString">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
      <xsl:variable name="ptLocale" select="$language[upper-case(replace(normalize-space(@id), '^#', '')) = string($currentLocale)]"/>
      <xsl:variable name="id" select="upper-case(java:twoCharLangCode($ptLocale/lan:language/lan:LanguageCode/@codeListValue))"/>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$id != '' and ($currentLocale = '' or @locale != concat('#', $id)) ">
        <xsl:attribute name="locale">
          <xsl:value-of select="concat('#',$id)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- ================================================================= -->
  <!-- Adjust the namespace declaration - In some cases name() is used to get the 
    element. The assumption is that the name is in the format of  <ns:element> 
    however in some cases it is in the format of <element xmlns=""> so the 
    following will convert them back to the expected value. This also corrects the issue 
    where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
  <!-- Note: Only included prefix gml, mds and gco for now. -->
  <!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
  <!-- ================================================================= -->
  
  <xsl:template name="correct_ns_prefix">
    <xsl:param name="element" />
    <xsl:param name="prefix" />
    <xsl:choose>
      <xsl:when test="local-name($element)=name($element) and $prefix != '' ">
        <xsl:element name="{$prefix}:{local-name($element)}">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mdb:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'mdb'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gco:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gco'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gml:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gml'"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
