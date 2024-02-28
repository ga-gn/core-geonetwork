package org.fao.geonet.domain;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

@Entity
@Table(name = "ecatid")
public class ECatId {

	static final String ID_SEQ_NAME = "ecat_id_seq";
	static final String ID_NAME = "ecat_id";

	@Id
	@SequenceGenerator(name = ECatId.ID_NAME,sequenceName= ECatId.ID_SEQ_NAME, initialValue = 140000, allocationSize = 1)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = ECatId.ID_NAME)
    @Column(name = "id", updatable = false)
    protected Long id;
}
