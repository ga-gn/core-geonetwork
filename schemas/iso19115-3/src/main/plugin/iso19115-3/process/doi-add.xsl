<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
    xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
    xmlns:gn="http://www.fao.org/geonetwork"
    exclude-result-prefixes="#all">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="doi"
        select="''"/>
    <xsl:param name="doiProtocolRegex"
        select="'(DOI|WWW:LINK-1.0-http--metadata-URL)'"/>
    
    <xsl:variable name="doiProtocol"
        select="'DOI'"/>
    <xsl:variable name="doiName"
        select="'Digital Object Identifier'"/>
    
    
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
            
            <xsl:for-each select="mdb:identificationInfo">
                <xsl:copy>
                    <xsl:copy-of select="@*" />
                    <mri:MD_DataIdentification>
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <mri:citation>
                                    <cit:CI_Citation>
                                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title"/>
                                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date"/>
                                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:edition"/>
                                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:editionDate"/>
                                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier[*/mcc:codeSpace/gco:CharacterString = 'Geoscience Australia Persistent Identifier']"/>
                                        <cit:identifier>
                                            <mcc:MD_Identifier>
                                                <mcc:code>
                                                    <gco:CharacterString><xsl:value-of select="$doi"/></gco:CharacterString>
                                                </mcc:code>
                                                <mcc:codeSpace>
                                                    <gco:CharacterString><xsl:value-of select="$doiName"/></gco:CharacterString>
                                                </mcc:codeSpace>
                                            </mcc:MD_Identifier>
                                        </cit:identifier>
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
                        
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:abstract" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:purpose" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:status" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:pointOfContact" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:spatialRepresentationType" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:spatialResolution" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:topicCategory" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:extent" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:resourceMaintenance" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:graphicOverview" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:resourceFormat" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:descriptiveKeywords" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:resourceConstraints" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:associatedResource" />
                        <xsl:apply-templates select="mri:MD_DataIdentification/mri:defaultLocale" />
                    </mri:MD_DataIdentification>
                </xsl:copy>
            </xsl:for-each>
                
                
            
            
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
    
</xsl:stylesheet>

