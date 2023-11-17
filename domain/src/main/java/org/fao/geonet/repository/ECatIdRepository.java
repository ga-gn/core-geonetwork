package org.fao.geonet.repository;

import org.fao.geonet.domain.ECatId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ECatIdRepository extends JpaRepository<ECatId, Long> {
	/**
     * @return
     */
    @Query(value = "select nextval('ecat_id_seq')", nativeQuery = true)
    Long getGaid();
}
