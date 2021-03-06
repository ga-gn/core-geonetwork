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

package org.fao.geonet.api.processing.report;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.api.processing.report.registry.IRegisteredProcess;
import org.fao.geonet.api.processing.report.registry.ProcessingReportRegistry;
import org.fao.geonet.domain.ISODate;
import org.springframework.context.ApplicationContext;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

/**
 * A report about a processing.
 */
@XmlRootElement(name = "report")
@XmlType(propOrder = {
    "uuid", "startIsoDateTime", "endIsoDateTime",
    "ellapsedTimeInSeconds", "totalTimeInSeconds","infos", "errors"
})
@XmlAccessorType(XmlAccessType.PUBLIC_MEMBER)
public abstract class ProcessingReport
    implements IProcessingReport, IRegisteredProcess {

    /**
     * The list of report error
     */
    protected List<Report> errors = Collections.synchronizedList(new ArrayList<Report>());
    /**
     * The list of report error
     */
    protected List<InfoReport> infos = Collections.synchronizedList(new ArrayList<InfoReport>());
    private ProcessingReportRegistry registry;
    private String uuid;
    private ISODate startIsoDateTime;
    private ISODate endIsoDateTime;

    public ProcessingReport() {
        this.uuid = UUID.randomUUID().toString();
        processStart();
        register();
    }

    @Override
    @XmlAttribute
    public String getUuid() {
        return this.uuid;
    }

    @Override
    @XmlAttribute
    public String getType() {
        return this.getClass().getSimpleName();
    }

    @Override
    @XmlAttribute
    public String getStartIsoDateTime() {
        return startIsoDateTime.getDateAndTime();
    }

    @Override
    @XmlAttribute
    public String getEndIsoDateTime() {
        return endIsoDateTime == null ? "" : endIsoDateTime.getDateAndTime();
    }

    @Override
    public void processStart() {
        this.startIsoDateTime = new ISODate();
    }

    @Override
    public void processEnd() {
        this.endIsoDateTime = new ISODate();
    }

    @Override
    public void close() {
        processEnd();
        unregister();
    }

    @Override
    @XmlAttribute
    public long getEllapsedTimeInSeconds() {
        return new ISODate().timeDifferenceInSeconds(startIsoDateTime);
    }

    @Override
    @XmlAttribute
    public long getTotalTimeInSeconds() {
        return endIsoDateTime == null ? -1 : endIsoDateTime.timeDifferenceInSeconds(startIsoDateTime);
    }

    @Override
    public boolean isRunning() {
        return false;
    }

    @Override
    public void register() {
        ApplicationContext applicationContext = ApplicationContextHolder.get();
        this.registry = applicationContext.getBean(ProcessingReportRegistry.class);

        if (registry != null) {
            registry.add(this);
        }
    }

    @Override
    public void unregister() {
        if (registry != null) {
            registry.remove(this.getUuid());
        }
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        unregister();
    }

    @XmlElement(name = "errors")
    public List<Report> getErrors() {
        return errors;
    }

    public synchronized void addError(Exception error) {
        this.errors.add(new ErrorReport(error));
    }

    @XmlElement(name = "infos")
    public List<InfoReport> getInfos() {
        return infos;
    }

    public synchronized void addInfos(String message) {
        this.infos.add(new InfoReport(message));
    }
}
