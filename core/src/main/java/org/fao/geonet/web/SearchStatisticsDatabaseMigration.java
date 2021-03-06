/*
 * =============================================================================
 * ===	Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * ===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * ===	and United Nations Environment Programme (UNEP)
 * ===
 * ===	This program is free software; you can redistribute it and/or modify
 * ===	it under the terms of the GNU General Public License as published by
 * ===	the Free Software Foundation; either version 2 of the License, or (at
 * ===	your option) any later version.
 * ===
 * ===	This program is distributed in the hope that it will be useful, but
 * ===	WITHOUT ANY WARRANTY; without even the implied warranty of
 * ===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * ===	General Public License for more details.
 * ===
 * ===	You should have received a copy of the GNU General Public License
 * ===	along with this program; if not, write to the Free Software
 * ===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 * ===
 * ===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * ===	Rome - Italy. email: geonetwork@osgeo.org
 * ==============================================================================
 */

package org.fao.geonet.web;

import org.fao.geonet.DatabaseMigrationTask;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.log.QueryRequest;
import org.fao.geonet.kernel.search.log.SearchRequestParam;
import org.fao.geonet.kernel.search.log.SearcherLogger;
import org.fao.geonet.utils.Log;
import org.joda.time.DateTime;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import static org.fao.geonet.kernel.search.log.LuceneQueryParamType.isExcludedField;

/**
 */
public class SearchStatisticsDatabaseMigration extends DatabaseMigrationTask {

    @Override
    public void update(Connection connection) throws SQLException {
        Log.debug(Geonet.DB, "SearchStatisticsDatabaseMigration");

        int rowCount = 0;
		int offset = 0;
		
        SearcherLogger searcherLogger = applicationContext.getBean(SearcherLogger.class);

        try(Statement stmt = connection.createStatement(); 
				ResultSet resultSet = stmt.executeQuery("SELECT COUNT(*) as reqCount FROM requests")){
			if(resultSet.next()) {
				rowCount = resultSet.getInt("reqCount");
			}
			
		}

		Log.info(Geonet.DB, "No of request Row Count: " + rowCount);
		
		while (rowCount >= offset) {
			
			PreparedStatement statement = connection.prepareStatement(
					"SELECT id, requestdate, ip, query, hits, lang, sortby, spatialfilter, type, service, autogenerated, simple "
							+ "FROM requests OFFSET ? ROWS FETCH FIRST 10 ROW ONLY");
			statement.setInt(1, offset);
			
			Log.info(Geonet.DB, "executing the sql statement with offest: " + offset);
			
			try (ResultSet resultSet = statement.executeQuery()) {
		            while (resultSet.next()) {
		                int id = resultSet.getInt(1);
		                QueryRequest queryRequest = new QueryRequest(
		                    resultSet.getString(3),
		                    new DateTime(resultSet.getString(2)).toDate().getTime()
		                );


		                List<SearchRequestParam> queryInfos = new ArrayList<>();
		                PreparedStatement paramsResultStm = null;
		                try {
		                    paramsResultStm = connection.prepareStatement(
		                        "SELECT id, requestid, querytype, termfield, termtext, similarity, lowertext, uppertext, inclusive " +
		                            "FROM params WHERE requestid=?");
		                    paramsResultStm.setInt(1, id);

		                    ResultSet paramsResultSet = paramsResultStm.executeQuery();
		                    while (paramsResultSet.next()) {

		                        String term = paramsResultSet.getString(4);
		                        if (!isExcludedField(term)) {
		                            SearchRequestParam searchRequestParam = new SearchRequestParam();
		                            searchRequestParam.setId(paramsResultSet.getInt(1));
		                            //                    searchRequestParam.setQueryType(paramsResultSet.getString(3));
		                            searchRequestParam.setTermField(paramsResultSet.getString(4));
		                            searchRequestParam.setTermText(paramsResultSet.getString(5));
		                            searchRequestParam.setSimilarity(paramsResultSet.getInt(6));
		                            searchRequestParam.setLowerText(paramsResultSet.getString(7));
		                            searchRequestParam.setUpperText(paramsResultSet.getString(8));
		                            searchRequestParam.setInclusive(paramsResultSet.getBoolean(9));
		                            queryInfos.add(searchRequestParam);
		                        }
		                    }

		                } finally {
		                    if (paramsResultStm != null) {
		                        paramsResultStm.close();
		                    }
		                }

		                queryRequest.setQueryInfos(queryInfos);
		                queryRequest.setHits(resultSet.getInt(5));
		                queryRequest.setService(resultSet.getString(10));
		                queryRequest.setLanguage(resultSet.getString(6));
		                queryRequest.setLuceneQuery(resultSet.getString(4));
		                queryRequest.setSortBy(resultSet.getString(7));
		                queryRequest.setSpatialFilter(resultSet.getString(8));
		                queryRequest.isSimpleQuery();

		                if (!queryRequest.storeToEs(searcherLogger.getIndex(), searcherLogger.getIndexType())) {
		                    Log.warning(Geonet.SEARCH_LOGGER, "unable to log query into database...");
		                } else {
		                    if (Log.isDebugEnabled(Geonet.SEARCH_LOGGER))
		                        Log.debug(Geonet.SEARCH_LOGGER, "Query saved to database");
		                }
		            }
		        }
			
			offset += 10;
		}
		
        

    }
}
