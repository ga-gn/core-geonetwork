<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0" xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
	xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0" xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
	xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0" xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
	xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0" xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/1.0"
	xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0" xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
	xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0" xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
	xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0" xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
	xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0" xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
	xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0" xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
	xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:gn="http://www.fao.org/geonetwork"
	xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
	xmlns:gn-fn-iso19115-3="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	version="2.0">

	<xsl:import href="utility-fn.xsl" />
	<xsl:import href="utility-tpl.xsl" />

	<xsl:template mode="csv"
		match="mdb:MD_Metadata|*[@gco:isoType='mdb:MD_Metadata']" priority="2">


		<metadata>
			<xsl:variable name="langId"
				select="gn-fn-iso19115-3:getLangId(., $lang)" />
			<xsl:variable name="seperator" select="'~'" />
			<uuid>
        		<xsl:value-of select="mdb:metadataIdentifier/*/mcc:code"/>
      			</uuid>
			<eCatId>
				<xsl:value-of
					select="mdb:alternativeMetadataReference/*/cit:identifier/*/mcc:code" />
			</eCatId>

			<xsl:if test="xs:boolean($Title)">
				<Title>
					<xsl:apply-templates mode="localised"
						select="mdb:identificationInfo/*/mri:citation/*/cit:title">
						<xsl:with-param name="langId" select="$langId" />
					</xsl:apply-templates>
				</Title>
			</xsl:if>

			<xsl:if test="xs:boolean($Abstract)">
				<Abstract>
					<xsl:apply-templates mode="localised"
						select="mdb:identificationInfo/*/mri:abstract">
						<xsl:with-param name="langId" select="$langId" />
					</xsl:apply-templates>
				</Abstract>
			</xsl:if>
			
			<xsl:if test="xs:boolean($MetadataScope)">
				<MetadataScope>
					<xsl:value-of select="mdb:metadataScope/mdb:MD_MetadataScope/@id" />
					<xsl:value-of select="$seperator" />
					<xsl:value-of select="mdb:metadataScope/*/mdb:name" />
					<xsl:value-of select="$seperator" />
					<xsl:value-of
						select="mdb:metadataScope/*/mdb:resourceScope/*/@codeListValue" />
				</MetadataScope>
			</xsl:if>

			<xsl:if test="xs:boolean($ParentMetadata)">
				<ParentMetadata>
					<xsl:value-of
						select="mdb:parentMetadata/cit:CI_Citation/cit:identifier[last()]/mcc:MD_Identifier/mcc:code/gcx:FileName/text()" />
				</ParentMetadata>
			</xsl:if>


			<xsl:if test="xs:boolean($CitationDate)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date">
					<xsl:element name="CitationDate">
						<xsl:value-of select="cit:date/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:dateType/*/@codeListValue" />
					</xsl:element>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($Purpose)">
				<Purpose>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:purpose/gco:CharacterString" />
				</Purpose>
			</xsl:if>

			<xsl:if test="xs:boolean($Status)">
				<Status>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:status/mcc:MD_ProgressCode/@codeListValue" />
				</Status>
			</xsl:if>

			<!--<xsl:if test="xs:boolean($imageChecked)"> <xsl:for-each select="mdb:identificationInfo/*/mri:graphicOverview/*/mcc:fileName"> 
				<image> <xsl:value-of select="*/text()"/> </image> </xsl:for-each> </xsl:if> -->

			<xsl:if test="xs:boolean($Keyword)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:descriptiveKeywords/*[not(mri:thesaurusName)]">
					<Keyword>
						<xsl:value-of select="mri:keyword/gco:CharacterString" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="mri:type/mri:MD_KeywordTypeCode/@codeListValue" />
					</Keyword>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($Keyword-Thesaurus)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:descriptiveKeywords/*[mri:thesaurusName]">
					<Keyword-Thesaurus>
						<xsl:value-of select="mri:thesaurusName/*/cit:title/gco:CharacterString" />
						<xsl:value-of select="$seperator" />
						<xsl:for-each select="mri:keyword">
							<xsl:value-of select="gco:CharacterString" />
							<xsl:if test="position() != last()">
								<xsl:value-of select="','" />
							</xsl:if>
						</xsl:for-each>
					</Keyword-Thesaurus>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($TopicCategory)">
				<TopicCategory>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:topicCategory/mri:MD_TopicCategoryCode" />
				</TopicCategory>
			</xsl:if>


			<xsl:if test="xs:boolean($MaintenanceFrequency)">
				<MaintenanceFrequency>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency/mmi:MD_MaintenanceFrequencyCode/@codeListValue"/>
				</MaintenanceFrequency>
			</xsl:if>
			<xsl:if test="xs:boolean($ResponsibleParty)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility">
					<ResponsibleParty>
						<xsl:value-of select="cit:party/*/cit:name/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:role/cit:CI_RoleCode/@codeListValue" />
					</ResponsibleParty>
				</xsl:for-each>
			</xsl:if>

			<!-- One column per contact role -->
			<xsl:if test="xs:boolean($ResourceContact)">
				<xsl:for-each select="mdb:identificationInfo/*/mri:pointOfContact">
					<xsl:element name="ResourceContact">
						<xsl:apply-templates mode="localised"
							select="*/cit:party/*/cit:name">
							<xsl:with-param name="langId" select="$langId" />
						</xsl:apply-templates>
						<xsl:value-of select="$seperator" />
						<xsl:apply-templates mode="localised"
							select="*/cit:role/*/@codeListValue">
							<xsl:with-param name="langId" select="$langId" />
						</xsl:apply-templates>
					</xsl:element>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($MetadataContact)">
				<xsl:for-each select="mdb:contact">
					<xsl:element name="MetadataContact">
						<xsl:apply-templates mode="localised"
							select="*/cit:party/*/cit:name">
							<xsl:with-param name="langId" select="$langId" />
						</xsl:apply-templates>
						<xsl:value-of select="$seperator" />
						<xsl:apply-templates mode="localised"
							select="*/cit:role/*/@codeListValue">
							<xsl:with-param name="langId" select="$langId" />
						</xsl:apply-templates>
					</xsl:element>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($GeographicalExtent)">
				<xsl:for-each
					select="mdb:identificationInfo/*//gex:EX_GeographicBoundingBox">
					<GeographicalExtent>
						<xsl:value-of select="gex:westBoundLongitude" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="gex:eastBoundLongitude" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="gex:southBoundLatitude" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="gex:northBoundLatitude" />
					</GeographicalExtent>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($SpatialExtentDescription)">
				<SpatialExtentDescription>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:extent/*/gex:description/gco:CharacterString" />
				</SpatialExtentDescription>
			</xsl:if>

			<xsl:if test="xs:boolean($HorizontalSpatialReferenceSystem)">
				<HorizontalSpatialReferenceSystem>
					<xsl:value-of
						select="mdb:referenceSystemInfo/*/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString" />
				</HorizontalSpatialReferenceSystem>
			</xsl:if>

			<xsl:if test="xs:boolean($VerticalExtent)">
				<VerticalExtent>
					<xsl:if test="mdb:identificationInfo/*/mri:extent/*/gex:verticalElement">
						<xsl:value-of
							select="mdb:identificationInfo/*/mri:extent/*/gex:verticalElement/*/gex:minimumValue/gco:Real" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of
							select="mdb:identificationInfo/*/mri:extent/*/gex:verticalElement/*/gex:maximumValue/gco:Real" />
					</xsl:if>
				</VerticalExtent>
			</xsl:if>

			<xsl:if test="xs:boolean($VerticalCRS)">
				<VerticalCRS>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:verticalElement/*/gex:verticalCRSId/*/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString" />
				</VerticalCRS>
			</xsl:if>


			<xsl:if test="xs:boolean($TemporalExtent)">
				<TemporalExtent>
					<xsl:if test="mdb:identificationInfo/*/mri:extent/*/gex:temporalElement">
						<xsl:value-of
							select="mdb:identificationInfo/*/mri:extent/*/gex:temporalElement/*/gex:extent/gml:TimePeriod/gml:beginPosition" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of
							select="mdb:identificationInfo/*/mri:extent/*/gex:temporalElement/*/gex:extent/gml:TimePeriod/gml:endPosition" />
					</xsl:if>
				</TemporalExtent>
			</xsl:if>


			<xsl:if test="xs:boolean($MetadataConstraint)">
				<xsl:for-each select="mdb:metadataConstraints/*">
					<MetadataConstraints>
						<xsl:copy-of select="." />
					</MetadataConstraints>
				</xsl:for-each>
			</xsl:if>


			<xsl:if test="xs:boolean($SecurityConstraint)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_SecurityConstraints">
					<SecurityConstraints>
						<xsl:value-of select="mco:classification/mco:MD_ClassificationCode/@codeListValue" />
					</SecurityConstraints>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($ResourceLegalConstraint)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints">
					<ResourceLegalConstraints>
						<xsl:value-of select="mco:reference/cit:CI_Citation/cit:title/*/text()" />
					</ResourceLegalConstraints>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($UseLimitations)">
				<UseLimitations>
					<xsl:value-of
						select="mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString" />
				</UseLimitations>
			</xsl:if>


			<xsl:if test="xs:boolean($DistributionLink)">
				<xsl:for-each
					select="mdb:distributionInfo/*/mrd:distributor/*/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/*">
					<DistributionLink>
						<xsl:value-of select="cit:name/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:description/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:linkage/*/text()" />
					</DistributionLink>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($DistributionFormat)">
			   <DistributionFormat>
				<xsl:value-of select="mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorTransferOptions/mrd:MD_DigitalTransferOptions/mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString" />
				</DistributionFormat>
			</xsl:if>

			<xsl:if test="xs:boolean($DataStorageLink)">
        <xsl:for-each
          select="mdb:identificationInfo/*/mri:resourceFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource">
			    <DataStorageLink>
            <xsl:value-of select="cit:name/*/text()" />
            <xsl:value-of select="$seperator" />
            <xsl:value-of select="cit:description/*/text()" />
            <xsl:value-of select="$seperator" />
            <xsl:value-of select="cit:linkage/*/text()" />
			    </DataStorageLink>
        </xsl:for-each>
			</xsl:if>



			<xsl:if test="xs:boolean($Lineage)">
				<Lineage>
					<xsl:value-of
						select="mdb:resourceLineage/mrl:LI_Lineage/mrl:statement/gco:CharacterString" />
				</Lineage>
			</xsl:if>

			<!-- <xsl:if test="xs:boolean($SourceScopeCode)">
				<SourceScopeCode>
					<xsl:value-of
						select="mdb:resourceLineage/mrl:LI_Lineage/mrl:scope/mcc:MD_Scope/mcc:level/mcc:MD_ScopeCode/@codeListValue" />
				</SourceScopeCode>
			</xsl:if> -->

			<xsl:if test="xs:boolean($SourceDescription)">
				<SourceDescription>
					<xsl:value-of
						select="mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description/gco:CharacterString" />
				</SourceDescription>
			</xsl:if>


			<xsl:if test="xs:boolean($AssociatedResourcesLink)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:associatedResource/*/mri:metadataReference/cit:CI_Citation/cit:onlineResource/cit:CI_OnlineResource">
					<AssociatedResourcesLink>
						<xsl:value-of select="cit:name/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:description/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:linkage/*/text()" />
					</AssociatedResourcesLink>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($AdditionalInfo)">
				<xsl:for-each
					select="mdb:identificationInfo/*/mri:additionalDocumentation/cit:CI_Citation">
					<AdditionalInformationLink>
						<xsl:value-of select="cit:title/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:onlineResource/*/cit:description/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:onlineResource/*/cit:linkage/*/text()" />
					</AdditionalInformationLink>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($ServiceParameter)">
				<xsl:for-each
					select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:parameter/srv:SV_Parameter">
					<ServiceParameter>
						<xsl:value-of select="srv:name/gco:MemberName/gco:aName/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of
							select="srv:name/gco:MemberName/gco:attributeType/gco:TypeName/gco:aName/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="srv:direction/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="srv:description/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="srv:optionality/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="srv:repeatability/*/text()" />
					</ServiceParameter>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($ConnectPoint)">
				<xsl:for-each
					select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint">
					<ConnectPoint>
						<xsl:value-of select="cit:CI_OnlineResource/cit:linkage/*/text()" />
						<xsl:value-of select="$seperator" />
						<xsl:value-of select="cit:CI_OnlineResource/cit:protocol/*/text()" />
					</ConnectPoint>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($ServiceType)">
				<ServiceType>
					<xsl:value-of
						select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:ScopedName" />
				</ServiceType>
			</xsl:if>

			<xsl:if test="xs:boolean($ServiceTypeVersion)">
				<xsl:for-each
					select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceTypeVersion">
					<ServiceTypeVersion>
						<xsl:value-of select="*/text()" />
					</ServiceTypeVersion>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="xs:boolean($CouplingType)">
				<CouplingType>
					<xsl:value-of
						select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:couplingType/srv:SV_CouplingType/@codeListValue" />
				</CouplingType>
			</xsl:if>

			<xsl:if test="xs:boolean($OperationName)">
				<OperationName>
					<xsl:value-of
						select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationName/gco:CharacterString" />
				</OperationName>
			</xsl:if>

			<xsl:if test="xs:boolean($DistributedComputingPlatform)">
				<DistributedComputingPlatform>
					<xsl:value-of
						select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:distributedComputingPlatform/srv:DCPList/@codeListValue" />
				</DistributedComputingPlatform>
			</xsl:if>

			<xsl:if test="xs:boolean($OperationDescription)">
				<OperationDescription>
					<xsl:value-of
						select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationDescription/gco:CharacterString" />
				</OperationDescription>
			</xsl:if>

			<xsl:copy-of select="gn:info" />
		</metadata>
	</xsl:template>
</xsl:stylesheet>
