<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
  xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.1"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">

  <xsl:param name="date"/>

  <xsl:template match="/mdb:MD_Metadata|*[contains(@gco:isoType, 'mdb:MD_Metadata')]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mdb:metadataIdentifier"/>
      <xsl:apply-templates select="mdb:defaultLocale"/>
      <xsl:apply-templates select="mdb:parentMetadata"/>
      <xsl:apply-templates select="mdb:metadataScope"/>
      <xsl:apply-templates select="mdb:contact"/>
      <xsl:apply-templates select="mdb:dateInfo"/>
      <xsl:apply-templates select="mdb:metadataStandard"/>
      <xsl:apply-templates select="mdb:metadataProfile"/>
      <xsl:apply-templates select="mdb:alternativeMetadataReference"/>
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>
      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:choose>
        <xsl:when test="mdb:identificationInfo/srv:SV_ServiceIdentification">
          <xsl:for-each select="mdb:identificationInfo">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <srv:SV_ServiceIdentification>
                <xsl:choose>
                  <xsl:when test="position() = 1">
                    <mri:citation>
                      <cit:CI_Citation>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:title"/>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:date"/>
                        <xsl:choose>
                          <xsl:when test="boolean(srv:SV_ServiceIdentification/mri:citation/mri:CI_Citation/cit:date/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication')">
                            <xsl:call-template name="revise"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:call-template name="publish"/>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:edition"/>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:editionDate"/>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:identifier"/>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty"/>
                        <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:citation/cit:CI_Citation/cit:series"/>
                      </cit:CI_Citation>
                    </mri:citation>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="mri:citation"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:abstract"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:purpose"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:credit"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:status"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:pointOfContact"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:topicCategory"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:extent"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:resourceMaintenance"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:graphicOverview"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:resourceFormat"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:descriptiveKeywords"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:resourceSpecificUsage"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:resourceConstraints"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:aggregationInfo"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/mri:associatedResource"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:serviceType"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:serviceTypeVersion"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:accessProperties"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:restrictions"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:extent"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:couplingType"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:coupledResource"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:operatedDataset"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:profile"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:serviceStandard"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:containsOperations"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:operatesOn"/>
                <xsl:apply-templates select="srv:SV_ServiceIdentification/srv:containsChain"/>
              </srv:SV_ServiceIdentification>
            </xsl:copy>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="mdb:identificationInfo">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <mri:MD_DataIdentification>
                <xsl:choose>
                  <xsl:when test="position() = 1">
                    <mri:citation>
                      <cit:CI_Citation>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title"/>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date"/>
                        <xsl:choose>
                          <xsl:when test="boolean(mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication')">
                            <xsl:call-template name="revise"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:call-template name="publish"/>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:edition"/>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:editionDate"/>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier"/>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty"/>
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:series"/>
                      </cit:CI_Citation>
                    </mri:citation>
                    <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation[position() > 1]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="mri:citation"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:abstract"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:purpose"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:status"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:pointOfContact"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:spatialRepresentationType"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:spatialResolution"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:topicCategory"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:extent"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:resourceMaintenance"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:resourceFormat"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:descriptiveKeywords"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:resourceConstraints"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:associatedResource"/>
                <xsl:apply-templates select="mri:MD_DataIdentification/mri:defaultLocale"/>
              </mri:MD_DataIdentification>
            </xsl:copy>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="mdb:contentInfo"/>
      <xsl:apply-templates select="mdb:distributionInfo"/>
      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
      <xsl:apply-templates select="mdb:acquisitionInformation"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="revise">
    <cit:date>
      <cit:CI_Date>
        <cit:date>
          <gco:DateTime>
            <xsl:value-of select="$date"/>
          </gco:DateTime>
        </cit:date>
        <cit:dateType>
          <cit:CI_DateTypeCode codeList="codeListLocation#CI_DateTypeCode" codeListValue="revision"/>
        </cit:dateType>
      </cit:CI_Date>
    </cit:date>
  </xsl:template>

  <xsl:template name="publish">
    <cit:date>
      <cit:CI_Date>
        <cit:date>
          <gco:DateTime>
            <xsl:value-of select="$date"/>
          </gco:DateTime>
        </cit:date>
        <cit:dateType>
          <cit:CI_DateTypeCode codeList="codeListLocation#CI_DateTypeCode" codeListValue="publication"/>
        </cit:dateType>
      </cit:CI_Date>
    </cit:date>
  </xsl:template>

</xsl:stylesheet>
