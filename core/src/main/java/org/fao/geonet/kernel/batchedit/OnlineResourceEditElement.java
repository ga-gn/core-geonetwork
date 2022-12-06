//==============================================================================
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Joseph John,
//===	Canberra - Australia. email: joseph.john@ga.gov.au
//==============================================================================
package org.fao.geonet.kernel.batchedit;

import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Geonet.Namespaces;
import org.fao.geonet.exceptions.BatchEditException;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

/**
 * This class creates online resource element for Data storage, Associated
 * resources, Additional Information and Distribution link.
 * 
 * @author Joseph John - U89263
 *
 */
public class OnlineResourceEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();

	SchemaManager schemaManager;
	
	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParam> listOfUpdates, BatchEditReport report) {

		schemaManager = context.getBean(SchemaManager.class);
		
		String headerVal = header.getKey();
		String onlineValue = csvr.get(headerVal);
		
		String[] contents = onlineValue.split(content_separator);
		for (String content : contents) {
			String[] values = content.split(type_separator);

			String name = "", desc = "", linkage = "", protocol = "WWW:LINK-1.0-http--link", function = "";

			if (values.length > 0)
				name = values[0];
			if (values.length > 1)
				desc = values[1];
			if (values.length > 2)
				linkage = values[2];
			if (values.length > 3)
				protocol = values[3];
			if (values.length > 4)
				function = values[4];

			Element rootE = null;
			
			try {
				if (Geonet.EditType.ASSOCIATED_RES.equalsIgnoreCase(headerVal)) {
					rootE = getOnlineResourceElement(name, desc, linkage, protocol, function);
				} else if (Geonet.EditType.DISTRIBUTION_LINK.equalsIgnoreCase(headerVal)){
					rootE = getDistributionOnlineResourceElement(name, desc, linkage, protocol, function);
				}else if (Geonet.EditType.DATA_STORAGE_LINK.equalsIgnoreCase(headerVal)){
					rootE = getResourceFormatElement(content);
				}else if (Geonet.EditType.ADDITIONAL_INFO.equalsIgnoreCase(headerVal)) {
					rootE = additionalInformation(name, desc, linkage, protocol, function);
				}
			} catch (BatchEditException e) {
				List<String> errs = report.getErrorInfo();
				errs.add(e.getMessage());
				report.setErrorInfo(errs);
			}

			if(rootE != null){
				String strEle = out.outputString(rootE);
	
				//Log.debug(Geonet.GA, "OnlineResource EditElement --> strEle : " + strEle);
	
				String _val = "<gn_add>" + strEle + "</gn_add>";
	
				BatchEditParam e = new BatchEditParam(_xpath.getXPath(), _val);
				listOfUpdates.add(e);
			}
		}

	}

	/**
	 * Creates Online resource element 
	 * @param _name
	 * @param description
	 * @param link
	 * @return
	 * @throws BatchEditException
	 */
	private Element getDistributionOnlineResourceElement(String name, String description, String link, String protocol, String function) throws BatchEditException {
		try{
			Element digitalTransferOptions = new Element("MD_DigitalTransferOptions", Geonet.Namespaces.MRD);
			
			Path p = schemaManager.getSchemaDir("iso19115-3").resolve("csv").resolve("distribution-link.xsl");
			
			Map<String, Object> params = new HashMap<>();
			params.put("name", name);
			params.put("description", description);
			params.put("linkage", link);
			params.put("protocol", protocol);
			params.put("function", function);
			
			digitalTransferOptions = Xml.transform(digitalTransferOptions, p, params);
			
			return digitalTransferOptions;
			
			
		}catch(Exception e){
			Log.error(Geonet.GA, String.format("Unable to process Online Resource Element having name %s and link %s, %s", name, link, e.getMessage()));
			throw new BatchEditException(String.format("Unable to process Online Resource Element having name %s and link %s", name, link));
		}
	}
	
	
	/**
	 * Creates Online resource for resource format - Data Storage 
	 * @param _name
	 * @param description
	 * @param link
	 * @return
	 * @throws BatchEditException
	 */
	private Element getResourceFormatElement(String link) throws BatchEditException {
		try{
			
			Element mdFormat = new Element("MD_Format", Namespaces.MRD);
			Path p = schemaManager.getSchemaDir(Geonet.SCHEMA_ISO_19115_3).resolve("csv").resolve("resource-format.xsl");
			
			Map<String, Object> params = new HashMap<>();
			params.put("linkage", link);
			mdFormat = Xml.transform(mdFormat, p, params);
			
			return mdFormat;
			
		}catch(Exception e){
			Log.error(Geonet.GA, String.format("Unable to process resource format having name link %s" , link));
			throw new BatchEditException(String.format("Unable to process resource format having name link %s" , link));
		}
	}
	
	/**
	 * Creates Online resource element 
	 * @param _name
	 * @param description
	 * @param link
	 * @return
	 * @throws BatchEditException
	 */
	private Element getOnlineResourceElement(String name, String description, String link, String protocol, String function) throws BatchEditException {
		try{
			
			return onlineResElement(name, description, link, protocol, function);
			
		}catch(BatchEditException e){
			Log.error(Geonet.GA, String.format("Unable to process Online Resource Element having name %s link %s" , name, link));
			throw new BatchEditException(String.format("Unable to process Online Resource Element having name %s link %s" , name, link));
		}
	}

	/**
	 * Creates additional information link
	 * @param _name
	 * @param description
	 * @param link
	 * @return
	 * @throws BatchEditException
	 */
	private Element additionalInformation(String name, String description, String link, String protocol, String function) throws BatchEditException {
		try{
			Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);
			Element onlineres = new Element("onlineResource", Geonet.Namespaces.CIT);
			Element title = new Element("title", Geonet.Namespaces.CIT);
	
			citation.addContent(title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(name)));
			citation.addContent(onlineres.addContent(onlineResElement(name, description, link, protocol, function)));
		
			return citation;
			
		}catch(BatchEditException e){
			Log.error(Geonet.GA, String.format("Unable to process additional Information having name %s link %s" , name, link));
			throw new BatchEditException(String.format("Unable to process additional Information having name %s link %s" , name, link));
		}
	}

	/**
	 * Create online resource element
	 * @param _name
	 * @param description
	 * @param link
	 * @return
	 * @throws BatchEditException
	 */
	private Element onlineResElement(String name, String description, String link, String protocol, String function) throws BatchEditException {

		try {
			Element onlineRes = new Element("CI_OnlineResource", Geonet.Namespaces.CIT);
			Path p = schemaManager.getSchemaDir(Geonet.SCHEMA_ISO_19115_3).resolve("csv").resolve("online-resource.xsl");
			
			Map<String, Object> params = new HashMap<>();
			params.put("name", name);
			params.put("description", description);
			params.put("linkage", link);
			params.put("protocol", protocol);
			params.put("function", function);
			
			onlineRes = Xml.transform(onlineRes, p, params);
			
			return onlineRes;
		} catch (Exception e) {
			Log.error(Geonet.GA, String.format("Unable to process onlineRes Element having name %s link %s" , name, link));
			throw new BatchEditException(String.format("Unable to process onlineRes Element having name %s link %s" , name, link));
		}
	}
}
