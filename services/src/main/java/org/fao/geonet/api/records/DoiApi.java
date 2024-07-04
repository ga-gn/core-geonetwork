/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */
package org.fao.geonet.api.records;

import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.services.ReadWriteController;
import org.fao.geonet.api.API;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.api.ApiUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.doi.client.DoiManager;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.domain.Constants;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.UriBuilder;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

import static org.fao.geonet.api.ApiParams.API_CLASS_RECORD_TAG;
import static org.fao.geonet.api.ApiParams.API_PARAM_RECORD_UUID;

/**
 * Handle DOI creation.
 */
@RequestMapping(value = {
    "/{portal}/api/records"
})
@Tag(name = API_CLASS_RECORD_TAG)
@Controller("doi")
@PreAuthorize("hasAuthority('Editor')")
@ReadWriteController
public class DoiApi {

    @Autowired
    private DoiManager doiManager;

    private Map<String, String> report = new HashMap<>();

    static final String DOI_REPORT = "doi_report";
    static final String DOI_CREATE_STATUS = "doi_create_status";

    @Operation(
        summary = "Check that a record can be submitted to DataCite for DOI creation. " +
            "DataCite requires some fields to be populated.")
    @RequestMapping(value = "/{metadataUuid}/doi/checkPreConditions",
        method = RequestMethod.GET,
        produces = {
            MediaType.APPLICATION_JSON_VALUE
        }
    )
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Record can be proposed to DataCite."),
        @ApiResponse(responseCode = "404", description = "Metadata not found."),
        @ApiResponse(responseCode = "400", description = "Record does not meet preconditions. Check error message."),
        @ApiResponse(responseCode = "500", description = "Service unavailable."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    public
    @ResponseBody
    ResponseEntity<Map<String, Boolean>> checkDoiStatus(
        @Parameter(
            description = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @Parameter(hidden = true)
            HttpServletRequest request
    ) throws Exception {
        AbstractMetadata metadata = ApiUtils.canEditRecord(metadataUuid, request);
        ServiceContext serviceContext = ApiUtils.createServiceContext(request);
        String eCatId = getECatIdFromMetadata(metadata);
        final Map<String, Boolean> reportStatus = doiManager.check(serviceContext, metadata, null, eCatId);
        return new ResponseEntity<>(reportStatus, HttpStatus.OK);
    }

    @Operation(
        summary = "Check the DOI URL created based on current configuration and pattern.")
    @RequestMapping(value = "/{metadataUuid}/doi/checkDoiUrl",
        method = RequestMethod.GET,
        produces = {
            MediaType.TEXT_PLAIN_VALUE
        }
    )
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "DOI URL created."),
        @ApiResponse(responseCode = "404", description = "Metadata not found."),
        @ApiResponse(responseCode = "500", description = "Service unavailable."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    public
    @ResponseBody
    ResponseEntity<String> checkDoiUrl(
        @Parameter(
            description = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @Parameter(hidden = true)
            HttpServletRequest request
    ) throws Exception {
        AbstractMetadata metadata = ApiUtils.canEditRecord(metadataUuid, request);
        String eCatId = getECatIdFromMetadata(metadata);
        return new ResponseEntity<>(doiManager.checkDoiUrl(metadata, eCatId), HttpStatus.OK);
    }


    @Operation(
        summary = "Submit a record to the Datacite metadata store in order to create a DOI.")
    @RequestMapping(value = "/{metadataUuid}/doi",
        method = RequestMethod.PUT,
        produces = {
            MediaType.APPLICATION_JSON_VALUE
        }
    )
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Check status of the report."),
        @ApiResponse(responseCode = "404", description = "Metadata not found."),
        @ApiResponse(responseCode = "500", description = "Service unavailable."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    public
    @ResponseBody
    ResponseEntity<Map<String, String>> createDoi(
        @Parameter(
            description = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @Parameter(hidden = true)
            HttpServletRequest request,
        @Parameter(hidden = true)
            HttpSession session
    ) throws Exception {
        AbstractMetadata metadata = ApiUtils.canEditRecord(metadataUuid, request);
        ServiceContext serviceContext = ApiUtils.createServiceContext(request);
        String eCatId = getECatIdFromMetadata(metadata);
        Map<String, String> doiInfo = doiManager.register(serviceContext, metadata, eCatId);
        return new ResponseEntity<>(doiInfo, HttpStatus.CREATED);
    }



    @Operation(
        summary = "Remove a DOI (this is not recommended, DOI are supposed to be persistent once created. This is mainly here for testing).")
    @RequestMapping(value = "/{metadataUuid}/doi",
        method = RequestMethod.DELETE,
        produces = {
            MediaType.APPLICATION_JSON_VALUE
        }
    )
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "DOI unregistered."),
        @ApiResponse(responseCode = "404", description = "Metadata or DOI not found."),
        @ApiResponse(responseCode = "500", description = "Service unavailable."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public
    @ResponseBody
    ResponseEntity unregisterDoi(
        @Parameter(
            description = API_PARAM_RECORD_UUID,
            required = true)
        @PathVariable
            String metadataUuid,
        @Parameter(hidden = true)
            HttpServletRequest request,
        @Parameter(hidden = true)
            HttpSession session
    ) throws Exception {
        AbstractMetadata metadata = ApiUtils.canEditRecord(metadataUuid, request);
        ServiceContext serviceContext = ApiUtils.createServiceContext(request);
        String eCatId = getECatIdFromMetadata(metadata);
        doiManager.unregisterDoi(metadata, serviceContext, eCatId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @Hidden
    @Operation(
        summary = "Create DOI in bulk.")
    @RequestMapping(value = "/doi/bulk", method = RequestMethod.PUT)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "DOI created."),
        @ApiResponse(responseCode = "404", description = "Metadata or DOI not found."),
        @ApiResponse(responseCode = "500", description = "Service unavailable."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN) })
    public ResponseEntity createDOI(@Parameter(required = false) String bucket, HttpServletRequest request,
                                    @Parameter(hidden = true) HttpSession session) {

        if (report != null && !report.isEmpty()) report.clear();

        request.getSession().setAttribute(DOI_CREATE_STATUS, false);
        ServiceContext context = ApiUtils.createServiceContext(request);
        Runnable task = () -> {
            startDOICreation(context, bucket, session);
        };

        new Thread(task).start();

        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    private void startDOICreation(ServiceContext serviceContext, String bucket, HttpSession session) {

        try {
            UserSession userSession = serviceContext.getUserSession();
            SelectionManager selectionManager = SelectionManager.getManager(userSession);
            Set<String> uuids = new HashSet<>();
            if (selectionManager != null) {
                synchronized (selectionManager.getSelection(bucket)) {
                    uuids.addAll(selectionManager.getSelection(bucket));
                }
            }

            uuids.forEach(uuid -> {
                String eCatId = "";
                try {
                    AbstractMetadata metadata = ApiUtils.getRecord(uuid);
                    if (metadata.getDataInfo().getType().codeString.equals(String.valueOf(Constants.YN_FALSE))) {
                        eCatId = getECatIdFromMetadata(metadata);
                        Map<String, String> doiInfo = doiManager.register(serviceContext, metadata, eCatId);
                        if (doiInfo.get("update") != null) {
                            report.put(eCatId, "Successfully updated DOI for the eCatId: " + eCatId);
                        } else {
                            report.put(eCatId, "Successfully created DOI for the eCatId: " + eCatId);
                        }
                    } else {
                        report.put(eCatId, "Not a metadata record. Selected record ( " + uuid
                            + " ) seems to be Template/Sub directory.");
                    }
                } catch (Exception e) {
                    report.put(eCatId, e.getMessage());
                }
            });
        } catch (Exception e) {
            Log.error(Geonet.SCHEMA_MANAGER, " Bulk DOI creation failed, Error is " + e.getMessage());
        } finally {
            session.setAttribute(DOI_REPORT, report);
            session.setAttribute(DOI_CREATE_STATUS, true);
        }
    }

    @RequestMapping(value = "/doi/status", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Boolean doiCreateStatus(HttpServletRequest request) throws Exception {
        return (Boolean) request.getSession().getAttribute(DOI_CREATE_STATUS);
    }

    @RequestMapping(value = "/doi/report", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, String> doiCreateReport(HttpServletRequest request) throws Exception {
        return (Map<String, String>) request.getSession().getAttribute(DOI_REPORT);
    }

    public String getECatIdFromMetadata(AbstractMetadata metadata) {
        String eCatId = "";
        try {
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document document = dBuilder.parse(new InputSource(new StringReader(metadata.getData())));
            NodeList alternativeList = document.getElementsByTagName("mdb:alternativeMetadataReference");
            eCatId = alternativeList.item(0).getChildNodes().item(1).getChildNodes().item(0)
                .getNextSibling().getNextSibling().getNextSibling().getFirstChild().getNextSibling().getChildNodes()
                .item(0).getNextSibling().getTextContent().replaceAll("\\s+","");
        } catch (Exception e) {
            report.put("Unable to get eCatId from uuid = ".concat(metadata.getUuid()), e.getMessage());
        }
        return eCatId;
    }

//    TODO: At some point we may add support for DOI States management
//    https://support.datacite.org/docs/mds-api-guide#section-doi-states
}


