<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
  xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0"
  xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0">

  <xsl:template match="/root">
    <xsl:apply-templates select="*[name() != 'env']"/>
  </xsl:template>

  <xsl:template match="mdb:MD_Metadata|*[@gco:isoType='mdb:MD_Metadata']">
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
      <xsl:choose>
			<xsl:when test="/root/env/gaid">
				<mdb:alternativeMetadataReference>
					<cit:CI_Citation>
						<cit:title>
							<gco:CharacterString>
								Geoscience Australia - short identifier for metadata record with
								uuid
								<xsl:value-of select="/root/env/uuid" />
							</gco:CharacterString>
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
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>
      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:apply-templates select="mdb:identificationInfo"/>
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

  <xsl:template match="mdb:alternativeMetadataReference"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gex:EX_Extent">
      <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="gex:geographicElement"/>
          <xsl:apply-templates select="gex:verticalElement"/>
          <xsl:apply-templates select="gex:temporalElement"/>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="mdb:acquisitionInformation">
      <xsl:copy>
          <mac:scope>
            <mcc:MD_Scope>
              <mcc:level>
                <mcc:MD_ScopeCode codeList="http://standards.iso.org/iso/19115/resources/Codelists/cat/codelists.xml#MD_ScopeCode" codeListValue="collectionHardware"/>
              </mcc:level>
            </mcc:MD_Scope>
          </mac:scope>
          <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
    <mdb:MD_Metadata xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
      xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
      xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
      xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
      xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
      xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
      xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.1"
      xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
      xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
      xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
      xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
      xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/2.0"
      xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/2.0"
      xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
      xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
      xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
      xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
      xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
      xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
      xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
      xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
      xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
      xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
      xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0"
      xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
      xmlns:gml="http://www.opengis.net/gml/3.2"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      xsi:schemaLocation="http://standards.iso.org/iso/19115/-3/cat/1.0 https://schemas.isotc211.org/19115/-3/cat/1.0/cat.xsd
      http://standards.iso.org/iso/19115/-3/cit/2.0 https://schemas.isotc211.org/19115/-3/cit/2.0/cit.xsd
      http://standards.iso.org/iso/19115/-3/gcx/1.0 https://schemas.isotc211.org/19115/-3/gcx/1.0/gcx.xsd
      http://standards.iso.org/iso/19115/-3/gex/1.0 https://schemas.isotc211.org/19115/-3/gex/1.0/gex.xsd
      http://standards.iso.org/iso/19115/-3/lan/1.0 https://schemas.isotc211.org/19115/-3/lan/1.0/lan.xsd
      http://standards.iso.org/iso/19115/-3/srv/2.1 https://schemas.isotc211.org/19115/-3/srv/2.1/srv.xsd
      http://standards.iso.org/iso/19115/-3/mas/1.0 https://schemas.isotc211.org/19115/-3/mas/1.0/mas.xsd
      http://standards.iso.org/iso/19115/-3/mcc/1.0 https://schemas.isotc211.org/19115/-3/mcc/1.0/mcc.xsd
      http://standards.iso.org/iso/19115/-3/mco/1.0 https://schemas.isotc211.org/19115/-3/mco/1.0/mco.xsd
      http://standards.iso.org/iso/19115/-3/mda/1.0 https://schemas.isotc211.org/19115/-3/mda/1.0/mda.xsd
      http://standards.iso.org/iso/19115/-3/mdb/2.0 https://schemas.isotc211.org/19115/-3/mdb/2.0/mdb.xsd
      http://standards.iso.org/iso/19115/-3/mds/2.0 https://schemas.isotc211.org/19115/-3/mds/2.0/mds.xsd
      http://standards.iso.org/iso/19115/-3/mdt/2.0 https://schemas.isotc211.org/19115/-3/mdt/2.0/mdt.xsd
      http://standards.iso.org/iso/19115/-3/mex/1.0 https://schemas.isotc211.org/19115/-3/mex/1.0/mex.xsd
      http://standards.iso.org/iso/19115/-3/mmi/1.0 https://schemas.isotc211.org/19115/-3/mmi/1.0/mmi.xsd
      http://standards.iso.org/iso/19115/-3/mpc/1.0 https://schemas.isotc211.org/19115/-3/mpc/1.0/mpc.xsd
      http://standards.iso.org/iso/19115/-3/mrc/2.0 https://schemas.isotc211.org/19115/-3/mrc/2.0/mrc.xsd
      http://standards.iso.org/iso/19115/-3/mrd/1.0 https://schemas.isotc211.org/19115/-3/mrd/1.0/mrd.xsd
      http://standards.iso.org/iso/19115/-3/mri/1.0 https://schemas.isotc211.org/19115/-3/mri/1.0/mri.xsd
      http://standards.iso.org/iso/19115/-3/mrl/2.0 https://schemas.isotc211.org/19115/-3/mrl/2.0/mrl.xsd
      http://standards.iso.org/iso/19115/-3/mrs/1.0 https://schemas.isotc211.org/19115/-3/mrs/1.0/mrs.xsd
      http://standards.iso.org/iso/19115/-3/msr/2.0 https://schemas.isotc211.org/19115/-3/msr/2.0/msr.xsd
      http://standards.iso.org/iso/19157/-2/mdq/1.0 https://schemas.isotc211.org/19157/-2/mdq/1.0/mdq.xsd
      http://standards.iso.org/iso/19115/-3/mac/2.0 https://schemas.isotc211.org/19115/-3/mac/2.0/mac.xsd
      http://standards.iso.org/iso/19115/-3/gco/1.0 https://schemas.isotc211.org/19115/-3/gco/1.0/gco.xsd
      http://standards.iso.org/iso/19115/-3/gmw/1.0 https://schemas.isotc211.org/19115/-3/gmw/1.0/gmw.xsd
      http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd
      http://www.w3.org/1999/xlink http://www.w3.org/1999/xlink.xsd">
      <xsl:copy-of select="//mdb:metadataIdentifier"/>
      <xsl:copy-of select="//mdb:defaultLocale"/>
      <xsl:copy-of select="//mdb:parentMetadata"/>
      <xsl:copy-of select="//mdb:metadataScope"/>
      <xsl:copy-of select="//mdb:contact"/>
      <xsl:copy-of select="//mdb:dateInfo"/>
      <xsl:copy-of select="//mdb:metadataStandard"/>
      <xsl:copy-of select="//mdb:metadataProfile"/>
      <xsl:copy-of select="//mdb:alternativeMetadataReference"/>
      <xsl:copy-of select="//mdb:otherLocale"/>
      <xsl:copy-of select="//mdb:metadataLinkage"/>
      <xsl:copy-of select="//mdb:spatialRepresentationInfo"/>
      <xsl:copy-of select="//mdb:referenceSystemInfo"/>
      <xsl:copy-of select="//mdb:metadataExtensionInfo"/>
      <xsl:copy-of select="//mdb:identificationInfo"/>
      <xsl:copy-of select="//mdb:contentInfo"/>
      <xsl:copy-of select="//mdb:distributionInfo"/>
      <xsl:copy-of select="//mdb:dataQualityInfo"/>
      <xsl:copy-of select="//mdb:resourceLineage"/>
      <xsl:copy-of select="//mdb:portrayalCatalogueInfo"/>
      <xsl:copy-of select="//mdb:metadataConstraints"/>
      <xsl:copy-of select="//mdb:applicationSchemaInfo"/>
      <xsl:copy-of select="//mdb:metadataMaintenance"/>
      <xsl:copy-of select="//mdb:acquisitionInformation"/>
    </mdb:MD_Metadata>
  </xsl:template>
</xsl:stylesheet>

